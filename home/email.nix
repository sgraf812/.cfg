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
      };
      msmtp.enable = true;
      notmuch.enable = true;
      astroid.enable = true;
    };
  };
}
