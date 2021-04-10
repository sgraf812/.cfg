{ pkgs, lib, ... }:

{
  imports = [ ];

  home.packages = with pkgs; [ ];

  programs.mbsync.enable = true;
  programs.msmtp.enable = true;

  programs.notmuch = {
    enable = true;
    hooks = {
      preNew = "mbsync --all";
    };
  };

  programs.astroid = {
    enable = true;
    externalEditor = "${pkgs.neovim-qt}/bin/nvim-qt -- -c 'set ft=mail' '+set fileencoding=utf-8' '+set ff=unix' '+set enc=utf-8' '+set fo+=w' %1";
    pollScript = "${pkgs.notmuch}/bin/notmuch new";
    extraConfig = {
      attachments = {
        external_open_cmd = "${pkgs.xdg_utils}/bin/xdg-open";
      };
    };
  };

  accounts.email.accounts = {
    private = {
      address = "sgraf1337@gmail.com";
      realName = "Sebastian Graf";
      flavor = "gmail.com";
      userName = "sgraf1337@gmail.com";
      passwordCommand = "cat ${./keys/private/gmail.txt}";
      mbsync = {
        enable = true;
        create = "maildir";
        patterns = [ "INBOX" "[Gmail]/Gesendet" "[Gmail]/Entwürfe" "[Gmail]/Papierkorb" "[Gmail]/Alle Nachrichten" ];
      };
      msmtp.enable = true;
      notmuch.enable = true;
      astroid.enable = true;
    };
    work = {
      address = "sebastian.graf@kit.edu";
      realName = "Sebastian Graf";
      flavor = "plain";
      userName = "sgraf";
      passwordCommand = "cat ${./keys/private/work.txt}";
      mbsync = {
        enable = true;
        create = "maildir";
        patterns = [ "INBOX" "Archives" "Deleted Items" "Sent" "Sent Items" "Trash" "Templates" ];
      };
      msmtp.enable = true;
      notmuch.enable = true;
      astroid = {
        enable = true;
      };
      imap = {
        host = "imap.informatik.kit.edu";
        port = 993;
        tls.enable = true;
        tls.useStartTls = false;
      };
      smtp = {
        host = "smtp.informatik.kit.edu";
        port = 587;
        tls.enable = true;
        tls.useStartTls = true;
      };
    };
    "info@juphka" = {
      address = "info@juphka.de";
      realName = "Junge Philharmonie Karlsruhe";
      flavor = "plain";
      userName = "info@juphka.de";
      passwordCommand = "cat ${./keys/private/info-juphka.txt}";
      mbsync = {
        enable = true;
        create = "maildir";
        patterns = [ "INBOX" "Archives" "Deleted Items" "Sent" "Sent Items" "Trash" "Templates" ];
      };
      msmtp.enable = true;
      notmuch.enable = true;
      astroid = {
        enable = true;
      };
      imap = {
        host = "web104.dogado.net";
        port = 143;
        tls.enable = true;
        tls.useStartTls = true;
      };
      smtp = {
        host = "web104.dogado.net";
        port = 25;
        tls.enable = true;
        tls.useStartTls = true;
      };
    };
    "mitspielen@juphka" = {
      address = "mitspielen@juphka.de";
      realName = "Junge Philharmonie Karlsruhe";
      flavor = "plain";
      userName = "mitspielen@juphka.de";
      passwordCommand = "cat ${./keys/private/mitspielen-juphka.txt}";
      mbsync = {
        enable = true;
        create = "maildir";
        patterns = [ "INBOX" "Archives" "Deleted Items" "Sent" "Sent Items" "Trash" "Templates" ];
      };
      msmtp.enable = true;
      notmuch.enable = true;
      astroid.enable = true;
      imap = {
        host = "web104.dogado.net";
        port = 143;
        tls.enable = true;
        tls.useStartTls = true;
      };
      smtp = {
        host = "web104.dogado.net";
        port = 25;
        tls.enable = true;
        tls.useStartTls = true;
      };
    };
  };
}
