#!/usr/bin/env perl

use warnings;
use strict;

# Trigger a fresh scan so the target network shows up. NetworkManager picks
# the wireless interface itself, so there's nothing to detect here.
# A rescan can fail harmlessly if NM scanned very recently, so ignore errors.
system("nmcli", "device", "wifi", "rescan");

my $qr = `zbarcam --raw --prescale=320x240 /dev/video0 -1`;

# Redact the password field before echoing the code to the terminal.
(my $shown = $qr) =~ s/(P:)[^;]*/${1}******/;
print("QR code read: $shown\n");

die "Does not look like a wifi code.\n" unless $qr =~ /^WIFI:/cg;

my %d;
while ($qr =~ /([A-Z]):([^;]+);/cg) { $d{$1} = $2 };

die "Could not extract SSID\n" unless $d{S};

my $ssid = $d{S};
my $type = uc($d{T} // 'WPA');   # WPA, WEP, or nopass for open networks

# Security settings for `nmcli connection add`/`modify`. We set key-mgmt
# explicitly so nmcli doesn't have to infer it from the scan cache -- that
# inference fails with "key-mgmt is missing" whenever the AP isn't cached.
my @sec;
if ($type eq 'NOPASS' || $type eq '') {
  # open network, no security settings
} elsif ($type eq 'WEP') {
  die "Could not extract password\n" unless $d{P};
  @sec = ("wifi-sec.key-mgmt", "none",
          "wifi-sec.wep-key-type", "key",
          "wifi-sec.wep-key0", $d{P});
} else {  # WPA / WPA2 / WPA3
  die "Could not extract password\n" unless $d{P};
  @sec = ("wifi-sec.key-mgmt", "wpa-psk", "wifi-sec.psk", $d{P});
}

print("Connecting to wifi $ssid...\n");

my %have = map { chomp; ($_ => 1) } `nmcli -t -f NAME connection show`;

# Create the profile only the first time. On later scans of a known network we
# leave the saved profile (and its stored secret) untouched and just bring it
# up -- no churn, and the password never reaches nmcli's argv.
if (!$have{$ssid}) {
  my @add = ("nmcli", "connection", "add", "type", "wifi",
             "con-name", $ssid, "ssid", $ssid, @sec);
  die "Failed to create connection profile for $ssid\n" if system(@add) != 0;
}

# Bring it up. If a pre-existing profile has a stale passphrase, refresh the
# secret once and retry rather than recreating the whole profile.
if (system("nmcli", "connection", "up", "id", $ssid) != 0) {
  die "Failed to connect to $ssid\n" unless @sec;
  warn("Connect failed; refreshing saved credentials and retrying...\n");
  die "Failed to update credentials for $ssid\n"
    if system("nmcli", "connection", "modify", "id", $ssid, @sec) != 0;
  die "Failed to connect to $ssid\n"
    if system("nmcli", "connection", "up", "id", $ssid) != 0;
}
