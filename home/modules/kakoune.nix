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
      showWhitespace = {
        enable = true;
        # We only do this to see tabs
        lineFeed = " ";
        space = " ";
        nonBreakingSpace = " ";
      };
    };
    plugins = with pkgs.kakounePlugins; [
      kak-fzf             # fzf mode
      kak-powerline       # A powerline
      kak-lsp             # A plugin for communicating with lang servers
      kak-git-mode        # A git user mode for better interaction
      kak-kit             # Git porcellain
      # auto-pairs is more trouble than worth it, not smart enough about
      # balancing!
      # kak-auto-pairs    # Auto close parens, etc.
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
      hook global WinSetOption filetype=git-status %{
          map window normal c ': git commit --verbose '
          map window normal l ': git log --oneline --graph<ret>'
          map window normal d ': -- %val{selections}<a-!><home> git diff '
          map window normal D ': -- %val{selections}<a-!><home> git diff --cached '
          map window normal a ': -- %val{selections}<a-!><home> git add '
          map window normal A ': -- %val{selections}<a-!><home> repl git add -p '
          map window normal r ': -- %val{selections}<a-!><home> git reset '
          map window normal R ': -- %val{selections}<a-!><home> repl git reset -p '
          map window normal o ': -- %val{selections}<a-!><home> git checkout '
      }
      hook global WinSetOption filetype=git-log %{
          map window normal d     ': %val{selections}<a-!><home> git diff '
          map window normal <ret> ': %val{selections}<a-!><home> git show '
          map window normal r     ': %val{selections}<a-!><home> git reset '
          map window normal R     ': %val{selections}<a-!><home> repl git reset -p '
          map window normal o     ': %val{selections}<a-!><home> git checkout '
      }
      ## Other shortcuts
      map global user w ':write <ret>' -docstring "Save current buffer"
      map global user e ':e<space>' -docstring "Edit file"
      map global user a '*%s<ret>' -docstring "Select all occurrences"
      map global user * '<a-i>w*%s<ret>' -docstring "Select all occurrences of inner word"
      map global user c ': addhl window/col column 80 default,rgb:303030<ret>' -docstring "Add 80th column highlighter"
      map global user C ': rmhl window/col<ret>' -docstring "Remove 80th column highlighter"

      ## case insensitive search
      map -docstring 'case insensitive search' global user '/' /(?i)
      map -docstring 'case insensitive backward search' global user '<a-/>' <a-/>(?i)
      map -docstring 'case insensitive extend search' global user '?' ?(?i)
      map -docstring 'case insensitive backward extend-search' global user '<a-?>' <a-?>(?i)

      ## Formatting

      # The following line wraps
      #
      # - to (w)idth $kak_opt_autowrap_column
      # - recognising B(ody) characters
      #   - .,?
      #   - _q (single quote) and _Q (double quote)
      #   - _a lower and _A upper case
      # - recogising (q)uote with (Q)uote characters
      #   - spaces _s
      #   - dash -  (Haskell comments!)
      #   - angle bracket > (quotes in markdown)
      #   The q makes sure that we choose the leading quote characters as the
      #   prefix when expanding a single line
      # - making sure that lines (f)it in the least of amount of columns by
      #   redistributing words
      #
      # TODO: Need to add _@ (neither case characters) in par-1.53
      map global user f '<a-x>|${pkgs.par}/bin/par w$kak_opt_autowrap_column "B=.,?_q_Q_A_a" q "Q=_s->" f<ret>' -docstring "Wrap lines of selection"

      ## Copying from tmux

      map global user t '<a-|> cat > /tmp/kak-cpy && tmux new-window "cat /tmp/kak-cpy; read"<ret>' -docstring "Open selection in new tmux window for copying"

      # kak-buffers
      map global normal ^ q
      map global normal <a-^> Q
      map global normal q b
      map global normal Q B
      map global normal <a-q> <a-b>
      map global normal <a-Q> <a-B>
      map global normal b ': enter-user-mode buffers<ret>' -docstring 'buffers'
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

      # auto-pairs.kak: currently disabled
      # hook global WinCreate .* auto-pairs-enable

      # kak-lsp
      hook global WinCreate .* %{
        lsp-auto-hover-enable
        set-option global lsp_show_hover_format 'printf %s "''${lsp_diagnostics}"'
      }
      map global user l ': enter-user-mode lsp<ret>' -docstring "LSP mode"

      # haskell mode
      declare-user-mode haskell
      map global user h ': enter-user-mode haskell<ret>' -docstring "Haskell mode"
      # Kudos to wz1000 for this ... device
      define-command ghc-jump-note %{
        try %{
          execute-keys 'xsNote \[[^\]\n]+\]<ret>'
          evaluate-commands %sh{
            brace=$(echo '{}' | cut -b1)
            echo "echo $brace"
            out=$(${pkgs.ripgrep}/bin/rg --no-messages --vimgrep -i --engine pcre2 "^ ?[$brace\-#*]* *\Q$kak_reg_dot")
            [ -n "$out" ] || { echo 'echo "No definition found!"' ; exit 1; }
            ln=$(cat "$out" | wc -l)
            if [ "$ln" -gt 1 ]; then
              output=$(mktemp -d "''${TMPDIR:-/tmp}"/kak-grep.XXXXXXXX)/fifo
              mkfifo $output
              ( cat "$out" > $output & ) > /dev/null 2>&1 < /dev/null
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
      map global haskell n ': ghc-jump-note<ret>' -docstring "Jump to GHC Note in line under selection"

      # Kudos to andreyorst
      define-command -override -docstring "flygrep: run grep on every key" \
      flygrep %{
          edit -scratch *grep*
          prompt "flygrep: " -on-change %{
              flygrep-call-grep %val{text}
          } nop
      }

      define-command -override flygrep-call-grep -params 1 %{ evaluate-commands %sh{
          length=$(printf "%s" "$1" | wc -m)
          [ -z "''${1##*&*}" ] && text=$(printf "%s\n" "$1" | sed "s/&/&&/g") || text="$1"
          if [ ''${length:-0} -gt 2 ]; then
              printf "%s\n" "info"
              printf "%s\n" "evaluate-commands %&grep '$text'&"
          else
              printf "%s\n" "info -title flygrep %{$((3-''${length:-0})) more chars}"
          fi
      }}
    '';
  };

  xdg.configFile."kak-lsp/kak-lsp.toml".source = ./kak/kak-lsp.toml;
}
