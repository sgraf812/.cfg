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
      # kak-tabs # assumes sh = bash
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

      map global user T '<a-|> cat > /tmp/kak-cpy && ${pkgs.tmux}/bin/tmux new-window "cat /tmp/kak-cpy; read"<ret>' -docstring "Open selection in new tmux window for copying"

      # Git mode
      map global user g ': enter-user-mode git<ret>' -docstring "Git mode"
      hook global WinCreate .* %{ evaluate-commands %sh{
        if git ls-files --error-unmatch "$kak_hook_param" > /dev/null 2>&1; then
           echo "git-mode-show-diff"
        fi
      }}
      hook global BufWritePost .* git-mode-update-diff
      hook global BufReload .* git-mode-update-diff
      ## kit
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

      # kak-buffers
      map global normal ^ q
      map global normal <a-^> Q
      map global normal q b
      map global normal Q B
      map global normal <a-q> <a-b>
      map global normal <a-Q> <a-B>
      map global normal b ': enter-user-mode buffers<ret>' -docstring 'buffers'
      map global normal B ': enter-user-mode -lock buffers<ret>' -docstring 'buffers (lock)'

      # kak-tabs
      #set-option global modelinefmt_tabs '%val{cursor_line}:%val{cursor_char_column} {{context_info}} {{mode_info}}'
      #map global normal ^ q
      #map global normal <a-^> Q
      #map global normal q b
      #map global normal Q B
      #map global normal <a-q> <a-b>
      #map global normal <a-Q> <a-B>
      #map global normal b ': enter-user-mode tabs<ret>' -docstring 'tabs'
      #map global normal B ': enter-user-mode -lock tabs<ret>' -docstring 'tabs (lock)'

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
          hook -once -always window InsertCompletionHide .* %{
            map window insert <tab> <tab>
            map window insert <s-tab> <s-tab>
          }
        }
      }

      # auto-pairs.kak: currently disabled
      # hook global WinCreate .* auto-pairs-enable

      # suspend and resume stuff
      def launch-tmux-workflow \
        -params 1..2 \
        -docstring 'launch-tmux-workflow <cli command> [<kak command after resume>]: Runs specified cli command in new tmux window.  Upon exit of command the optional kak command is executed.' \
        %{ evaluate-commands %sh{

        cli_cmd="$1"
        post_resume_cmd="$2"

        ${pkgs.tmux}/bin/tmux new-window "$cli_cmd; ${pkgs.tmux}/bin/tmux wait-for -S kak-launch-tmux-workflow-$kak_client_pid" > /dev/null 2>&1
        ${pkgs.tmux}/bin/tmux wait-for kak-launch-tmux-workflow-$kak_client_pid > /dev/null 2>&1
        echo $post_resume_cmd
      }}

      ## tig integration
      def tig-blame -override -docstring 'Open blame in tig for current file and line' %{
          # Note here we aren't passing any command on resume of kakoune
          launch-tmux-workflow "${pkgs.tig}/bin/tig blame +%val{cursor_line} %val{buffile}"
      }
      declare-user-mode tig
      map global tig b ': tig-blame<ret>' -docstring 'show blame (with tig)'
      map global tig s ': launch-tmux-workflow "${pkgs.tig}/bin/tig status"<ret>' -docstring 'show git status (with tig)'
      map global tig m ': launch-tmux-workflow "${pkgs.tig}/bin/tig"<ret>' -docstring 'show main view (with tig)'
      map global user t ': enter-user-mode tig<ret>' -docstring 'tig commands'

      ## ranger integration
      def for-each-line \
          -docstring "for-each-line <command> <path to file>: run command with the value of each line in the file" \
          -params 2 \
          %{ evaluate-commands %sh{

          while read f; do
              printf "$1 $f\n"
          done < "$2"
      }}
      def toggle-ranger %{
          launch-tmux-workflow \
              "${pkgs.ranger}/bin/ranger --choosefiles=/tmp/ranger-files-%val{client_pid}" \
              "for-each-line edit /tmp/ranger-files-%val{client_pid}"
      }
      map global user r ': toggle-ranger<ret>' -docstring 'select files in ranger'
      def toggle-broot %{
          launch-tmux-workflow \
              "${pkgs.broot}/bin/broot --conf=$HOME/.config/broot/select.toml > /tmp/broot-files-%val{client_pid}" \
              "for-each-line edit /tmp/broot-files-%val{client_pid}"
      }
      map global user b ': toggle-broot<ret>' -docstring 'select files in broot'

      # kak-lsp
      map global user l ': enter-user-mode lsp<ret>' -docstring "LSP mode"
      hook global WinCreate .*\.hs %{
        lsp-auto-hover-enable
        set-option global lsp_show_hover_format 'printf %s "''${lsp_diagnostics}"'
      }

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

  xdg.configFile."broot/select.toml".text = ''
    [[verbs]]
    invocation = "ok"
    key = "enter"
    leave_broot = true
    execution = ":print_path"
    apply_to = "file"
  '';

  xdg.configFile."kak-lsp/kak-lsp.toml".source = ./kak/kak-lsp.toml;
}
