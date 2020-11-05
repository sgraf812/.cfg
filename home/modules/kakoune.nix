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
      indentWidth = 2;
      tabStop = 5;
      showMatching = true;
      ui = {
        enableMouse = false;
        setTitle = true;
      };
    };
    plugins = with pkgs.kakounePlugins; [
      kak-fzf             # fzf mode
      kak-powerline       # A powerline
      kak-lsp             # A plugin for communicating with lang servers
      kak-git-mode        # A git user mode for better interaction
      kak-auto-pairs      # Auto close parens, etc.
      kak-buffers         # smarter buffer movements
    ];
    extraConfig = ''
      colorscheme tomorrow-night

      # Highlight trailing whitespace. But we simply delete it anyway
      # add-highlighter global/show-trailing-whitespaces regex '\h+$' 0:Error
      # Remove trailing whitespace
      hook global BufWritePre .* %{ try %{ execute-keys -draft \%s\h+$<ret>d } }

      hook global InsertChar k %{ try %{
            exec -draft hH <a-k>jk<ret> d
              exec <esc>
      }}
      map global normal <c-p> ': fzf-mode<ret>'

      # User mode stuff
      ## Copy and pasting from clipboard
      map global user y '<a-|>${pkgs.xclip}/bin/xclip -selection clipboard -in <ret>' -docstring "Copy to clipboard"
      map global user p '<a-!>${pkgs.xclip}/bin/xclip -selection clipboard -out <ret>' -docstring "Paste from clipboard (after)"
      map global user P '!${pkgs.xclip}/bin/xclip -selection clipboard -out <ret>' -docstring "Paste from clipboard (before)"
      # Git mode
      map global user g ': enter-user-mode git<ret>' -docstring "Git mode"
      hook global BufOpenFile .* git-mode-show-diff
      hook global BufWritePost .* git-mode-update-diff
      hook global BufReload .* git-mode-update-diff
      ## Other shortcuts
      map global user w ':write <ret>' -docstring "Save current buffer"
      map global user e ':e<space>'
      map global user a '*%s<ret>' -docstring "Select all occurrences"
      map global user f '|fmt --width $kak_opt_autowrap_column<ret>' -docstring "Wrap lines of selection"

      # kak-buffers
      map global normal ^ q
      map global normal <a-^> Q
      map global normal q b
      map global normal Q B
      map global normal <a-q> <a-b>
      map global normal <a-Q> <a-B>
      map global normal b ': enter-buffers-mode<ret>' -docstring 'buffers'
      map global normal B ': enter-user-mode -lock buffers<ret>' -docstring 'buffers (lock)'

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

      # auto-pairs.kak
      hook global WinCreate .* auto-pairs-enable

      # kak-lsp
      hook global WinCreate .* lsp-auto-hover-enable
      map global user l ': enter-user-mode lsp<ret>' -docstring "LSP mode"

      # Kudos to wz1000 for this ... device
      define-command ghc-jump-note %{
        try %{
          execute-keys 'xsNote \[[^\]\n]+\]<ret>'
          evaluate-commands %sh{
            brace=$(echo '{}' | cut -b1)
            out=$(rg --no-messages --vimgrep -i --engine pcre2 "^ ?[$brace\-#*]* *\Q$kak_reg_dot")
            [ -n "$out" ] || { echo 'echo "No definition found!"' ; exit 1; }
            ln=$(wc -l <<< "$out")
            if [ "$ln" -gt 1 ]; then
              output=$(mktemp -d "${TMPDIR:-/tmp}"/kak-grep.XXXXXXXX)/fifo
              mkfifo $output
              ( cat <<< "$out" > $output & ) > /dev/null 2>&1 < /dev/null
              printf %s\\n "evaluate-commands %{
                       edit! -fifo $output *grep*
                       set-option buffer filetype grep
                       set-option buffer grep_current_line 0
                       hook -always -once buffer BufCloseFifo .* %{ nop %sh{ rm -r $(dirname $output) } }
                   }"
              exit 0
            fi
            file=$(echo "$out" | cut -d: -f1)
            line=$(echo "$out" | cut -d: -f2)
            printf 'edit -existing %s %s\n' "$file" "$line"
          }
        } catch %{
          nop
        }
      }
    '';
  };

  xdg.configFile."kak-lsp/kak-lsp.toml".source = ./kak/kak-lsp.toml;
}
