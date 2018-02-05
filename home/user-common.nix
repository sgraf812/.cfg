{ pkgs, ... }:

{
  home.packages = [
    # pkgs.creduce
    pkgs.fswatch
    # pkgs.gcc
    pkgs.htop
    pkgs.man
    pkgs.manpages
    pkgs.nix-repl
    pkgs.p7zip
    pkgs.python
    pkgs.silver-searcher
    pkgs.stack
    pkgs.tldr
    pkgs.tmux
    pkgs.tmuxinator
    pkgs.tree
    pkgs.unzip
    pkgs.vlc
    pkgs.xclip
    pkgs.zathura
    # pkgs.ycomp
  ];

  programs.git = {
    userName = "Sebastian Graf";
    aliases = {
      abort = "rebase --abort";
      amend = "commit --amend";
      cat = "cat-file -p";
      ci = "commit -a";
      co = "checkout";
      conflict = ''!"$EDITOR" -c '/^[<=|>]\\{7\\}' `git ls-files --unmerged | cut -c 51- | uniq`'';
      contains = "branch --contains";
      continue = "!git add -u && git rebase --continue";
      cx = "commit";
      da = "diff HEAD";
      di = "diff";
      dx = "diff --cached";
      fixup = "commit --amend -C HEAD";
      graph = "log --decorate --graph";
      less = "-p cat-file -p";
      lg = "log --decorate --graph --name-status";
      lg1 = "log --decorate --graph --oneline";
      sf = "svn fetch";
      tar = "archive --format=tar";
    };
    extraConfig = {
      core = { 
        editor = "vim";
        pager = "less -x 4 -R -~"; # -F -c
        # excludesfile = "$HOME/.gitignore";
        whitespace = "trailing-space,space-before-tab";
      };
      color.ui = "auto";
      push.default = "matching";
    };
  };

  programs.home-manager = {
    enable = true;
    path = https://github.com/rycee/home-manager/archive/master.tar.gz;
  };

  programs.vim = {
    enable = true;
    extraConfig = builtins.readFile ./vim/vimrc.vim;
    settings = {
      relativenumber = true;
      number = true;
    };
    plugins = [
      "The_NERD_Commenter"
      "The_NERD_tree"
      "fugitive" 
      "sensible" 
      "sleuth" 
      "Solarized" 
      "vim-airline" 
      "vim-gitgutter" 
    ];
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
    initExtra = builtins.readFile zsh/init.zsh;
    shellAliases = {
      setclip = "xclip -selection clipboard -in";
      getclip = "xclip -selection clipboard -out";
      gitc = "git checkout";
      gits = "git status";
      gri = "grep -ri";
      grn = "grep -rn";
      grin = "grep -rin";
      e = "vim";
      ag = ''\ag --pager="less -XFR"'';
    };
  };

  home.file = {
    ".tmux.conf".source = ./tmux/tmux.conf;
    ".tmuxinator".source = ./tmuxinator;
  };
}
