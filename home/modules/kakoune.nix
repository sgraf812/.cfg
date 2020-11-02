{ pkgs, lib, ... }:

{
  imports = [ ];

  home.packages = with pkgs; [ ];

  programs.kakoune = {
    enable = true;
    config = {
      numberLines = {
        enable = true;
        relative = true;
      };
      scrollOff = {
        columns = 5;
        lines = 2;
      };
      showMatching = true;
    };
    plugins = with pkgs.kakounePlugins; [
      kak-fzf
      kak-powerline
      # kak-vertical-selection # unclear if needed
      kak-lsp
      kak-git-mode
    ];
    extraConfig = ''
      colorscheme tomorrow-night
      
      hook global InsertChar k %{ try %{
            exec -draft hH <a-k>jk<ret> d
              exec <esc>
      }}
      map global normal <c-p> ': fzf-mode<ret>'
      map global normal 0 <a-h>
      map global normal $ <a-l>
      map global normal § $

      # User mode stuff
      ## Copy and pasting from clipboard
      map global user y '<a-|>${pkgs.xclip}/bin/xclip -selection clipboard -in <ret>' -docstring "Copy to clipboard"
      map global user p '<a-!>${pkgs.xclip}/bin/xclip -selection clipboard -out <ret>' -docstring "Paste from clipboard (after)"
      map global user P '!${pkgs.xclip}/bin/xclip -selection clipboard -out <ret>' -docstring "Paste from clipboard (before)"
      # Git mode
      map global user g ': enter-user-mode git<ret>' -docstring "Git mode"
      ## Other shortcuts
      map global user w ':write <ret>' -docstring "Save current buffer"
      map global user e ':e<space>'
      map global user a '*%s<ret>' -docstring "Select all occurrences"

      # Tab completion
      hook global InsertCompletionShow .* %{
          try %{
              # this command temporarily removes cursors preceded by whitespace;
              # if there are no cursors left, it raises an error, does not
              # continue to execute the mapping commands, and the error is eaten
              # by the `try` command so no warning appears.
              execute-keys -draft 'h<a-K>\h<ret>'
              map window insert <tab> <c-n>
              map window insert <s-tab> <c-p>
          }
      }
      hook global InsertCompletionHide .* %{
          unmap window insert <tab> <c-n>
          unmap window insert <s-tab> <c-p>
      }
    '';
  };

  xdg.configFile."kak-lsp/kak-lsp.toml".source = ./kak/kak-lsp.toml;
}
