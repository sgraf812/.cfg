{ pkgs, lib, ... }:

{
  imports = [ ];

  home.packages = with pkgs; [ ];

  programs.notmuch.enable = true;

  programs.astroid = {
    enable = true;
    externalEditor = "vim -- -c 'set ft=mail' '+set fileencoding=utf-8' '+set ff=unix' '+set enc=utf-8' '+set fo+=w' %1";
  };

  accounts.email.accounts = {
    private = {
      name = "private";
      address = "sgraf1337@gmail.com";
      aliases = [ "SebastianGraf@t-online.de" ];
      realName = "Sebastian Graf";
      flavor = "gmail.com";
      userName = "sgraf1337@gmail.com";
      mbsync.enable = true;
      msmtp.enable = true;
      astroid.enable = true;
      notmuch.enable = true;
    };
  };
}
