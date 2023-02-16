{ pkgs, lib, hostname, unstable, ... }:

{
  imports = [ ];

  home.packages = with pkgs; [
    pythonPackages.editorconfig
    unstable.kak-lsp
  ];

  programs.kakoune = {
    enable = true;
    config = {
      colorScheme = "tomorrow-night";
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
      # kak-fzf             # fzf mode, not needed with broot
      # kak-powerline       # A powerline
      kak-git-mode        # A git user mode for better interaction
      # kak-kit             # Git porcellain. Don't need it, we have lazygit
      # auto-pairs is more trouble than worth it, not smart enough about
      # balancing!
      # kak-auto-pairs    # Auto close parens, etc.
      kak-buffers         # smarter buffer movements # superseded by tabs-kak
      tabs-kak
    ];
    extraConfig =
      let
        os = builtins.elemAt (builtins.match "(.*[[:space:]])?NAME\=\"?([A-z]*).*" (builtins.readFile /etc/os-release)) 1;
        launchWorkflow = {
          "i44pc6.informatik.kit.edu" = "launch-tmux-workflow";
          "nixos-framework" = "launch-kitty-workflow";
          "nixos-lt" = "launch-kitty-workflow";
          "Sebastian-PC" = "launch-kitty-workflow"; # FIXME
        }."${hostname}";
      in ''
      hook global ModuleLoaded powerline %{
        hook global WinDisplay .* %{
          powerline-theme tomorrow-night
          powerline-separator triangle
          powerline-format 'mode_info line_column position bufname filetype git'
        }
      }

      # Highlight trailing whitespace. But we simply delete it anyway
      # add-highlighter global/show-trailing-whitespaces regex '\h+$' 0:Error
      # Remove trailing whitespace
      hook global BufWritePre .* %{ try %{ execute-keys -draft \%s\h+$<ret>d } }
      hook global InsertChar k %{ try %{
          exec -draft hH <a-k>jk<ret> d
          exec <esc>
      }}

      # EditorConfig
      hook global BufOpenFile .* editorconfig-load
      hook global BufNewFile .* editorconfig-load

      # Disable mouse capture
      set global ui_options terminal_enable_mouse=false

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
      map global user 8 ':eval %sh{echo "echo $(echo -n $kak_reg_dot | iconv -f utf8 -t ucs-2 | od --address-radix=n --format=x4)" }<ret>' -docstring "Show UCS-2 encoding of selection"
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
      #
      # TODO: Need to add _@ (neither case characters) in par-1.53
      map global user f '<a-x>|${pkgs.par}/bin/par w$kak_opt_autowrap_column "B=.,?_q_Q_A_a" q "Q=_s->"<ret>' -docstring "Wrap lines of selection"

      ## Copying from tmux

      map global user T '<a-|> cat > /tmp/kak-cpy && ${pkgs.tmux}/bin/tmux new-window "cat /tmp/kak-cpy; read"<ret>' -docstring "Open selection in new tmux window for copying"

      # Git mode
      map global user g ': enter-user-mode git<ret>' -docstring "Git mode"
      hook global WinCreate .* %{ evaluate-commands %sh{
        if [ $kak_buffile != $kak_bufname ] && git ls-files --error-unmatch "$kak_buffile" > /dev/null 2>&1; then
          echo "git-mode-show-diff"
        fi
      }}
      hook global BufWritePost .* git-mode-update-diff
      hook global BufReload .* git-mode-update-diff
      ## lazygit
      map global user G ': launch-tmux-workflow "${pkgs.lazygit}/bin/lazygit"<ret>' -docstring 'Launch lazygit'
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

      # Special math chars mode
      declare-user-mode math
      map global user m ': enter-user-mode math<ret>' -docstring "Math characters mode"
      map global math Z 'iℤ<esc>' -docstring "ℤ"
      map global math N 'iℕ<esc>' -docstring "ℕ"
      map global math m 'i↦<esc>' -docstring "↦"
      map global math a 'i→<esc>' -docstring "→"
      map global math <€> 'i∈<esc>' -docstring "∈"
      map global math <lt> 'i≤<esc>' -docstring "≤"
      map global math <gt> 'i≥<esc>' -docstring "≥"
      map global math E 'i∃<esc>' -docstring "∃"
      map global math A 'i∀<esc>' -docstring "∀"
      map global math n 'i∩<esc>' -docstring "∩"
      map global math u 'i∪<esc>' -docstring "∪"
      map global math ( 'i⊂<esc>' -docstring "⊂"
      map global math ) 'i⊆<esc>' -docstring "⊆"
      map global math [ 'i⊏<esc>' -docstring "⊏"
      map global math ] 'i⊑<esc>' -docstring "⊑"
      map global math l 'i⊔<esc>' -docstring "⊔"
      map global math g 'i⊓<esc>' -docstring "⊓"
      map global math <#> 'i♯<esc>' -docstring "♯"

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
      #hook global WinCreate .* %{
      #  set-option global modelinefmt_tabs '%val{cursor_line}:%val{cursor_char_column} {{context_info}} {{mode_info}}'
      #}
      map global normal ^ q
      map global normal <a-^> Q
      map global normal q b
      map global normal Q B
      map global normal <a-q> <a-b>
      map global normal <a-Q> <a-B>
      # map global normal b ': enter-user-mode tabs<ret>' -docstring 'tabs'
      # map global normal B ': enter-user-mode -lock tabs<ret>' -docstring 'tabs (lock)'

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

      def launch-kitty-workflow \
        -params 1..2 \
        -docstring 'launch-kitty-workflow <cli command> [<kak command after resume>]: Runs specified cli command in new kitty window.  Upon exit of command the optional kak command is executed.' \
        %{ evaluate-commands %sh{

        cli_cmd="$1"
        post_resume_cmd="$2"

        ${pkgs.kitty}/bin/kitty sh -c "$cli_cmd" > /dev/null 2>&1
        echo $post_resume_cmd
      }}

      def for-each-line \
          -docstring "for-each-line <command> <path to file>: run command with the value of each line in the file" \
          -params 2 \
          %{ evaluate-commands %sh{

          while read f; do
              printf "$1 $f\n"
          done < "$2"
      }}

      ## broot integration
      def run-broot %{
          # Need --color=yes below, https://github.com/Canop/broot/issues/397
          ${launchWorkflow} \
              "${pkgs.broot}/bin/broot --color=yes --conf=$HOME/.config/broot/select.toml > /tmp/broot-files-%val{client_pid}" \
              "for-each-line edit /tmp/broot-files-%val{client_pid}"
      }
      map global normal <c-p> ': run-broot<ret>' -docstring 'select files in broot'

      # kak-lsp
      eval %sh{${unstable.kak-lsp}/bin/kak-lsp --kakoune -s $kak_session}
      set global lsp_cmd "kak-lsp -s %val{session} -vvvv --log /tmp/kak-lsp-%val{session}.log"
      # eval %sh{${unstable.kak-lsp}/bin/kak-lsp --kakoune -s $kak_session -vvv --log /tmp/kak-lsp-$kak_session.log}
      map global user l ': enter-user-mode lsp<ret>' -docstring "LSP mode"
      hook global WinSetOption filetype=haskell %{
        lsp-enable-window
        lsp-auto-hover-enable
        set-option global lsp_hover_max_lines 10
        # set-option global lsp_show_hover_format 'printf %s "''${lsp_diagnostics}"'

        # Inlay diagnostics
        # Not supported by HLS
        #hook window -group hs-inlay-hints BufReload .* hs-analyzer-inlay-hints
        #hook window -group hs-inlay-hints NormalIdle .* hs-analyzer-inlay-hints
        #hook window -group hs-inlay-hints InsertIdle .* hs-analyzer-inlay-hints
        #hook -once -always window WinSetOption filetype=.* %{
        #  remove-hooks window hs-inlay-hints
        #}

        # Semantic tokens
        # Not supported by HLS
        #hook window -group semantic-tokens BufReload .* lsp-semantic-tokens
        #hook window -group semantic-tokens NormalIdle .* lsp-semantic-tokens
        #hook window -group semantic-tokens InsertIdle .* lsp-semantic-tokens
        #hook -once -always window WinSetOption filetype=.* %{
        #  remove-hooks window semantic-tokens
        #}
      }
      hook global BufCreate .*\.lhs %{ set buffer filetype latex }

      # haskell mode
      declare-user-mode haskell
      map global user h ': enter-user-mode haskell<ret>' -docstring "Haskell mode"
      map global haskell p 'i{-# NOINLINE #-}<esc>bbe' -docstring "Insert NOINLINE pragma snippet"
      map global haskell t 'o  | pprTrace "" (vcat [ppr arg]) False = undefined<esc><a-h>wwwlli' -docstring "Insert pprTrace guard"
      # Kudos to wz1000 for this ... device
      define-command ghc-jump-note %{
        try %{
          execute-keys 'xsNote \[[^\]\n]+\]<ret>'
          evaluate-commands %sh{
            brace=$(echo '{}' | cut -b1)
            echo "echo $brace"
            out=$(${pkgs.ripgrep}/bin/rg --no-messages --vimgrep -i --engine pcre2 "^ ?[$brace\-#*]* *\Q$kak_reg_dot\E\s*$")
            [ -n "$out" ] || { echo 'echo "No definition found!"' ; exit 1; }
            ln=$(printf "$out\n" | wc -l)
            if [ "$ln" -gt 1 ]; then
              output=$(mktemp -d "''${TMPDIR:-/tmp}"/kak-grep.XXXXXXXX)/fifo
              mkfifo $output
              ( printf "$out\n" > $output & ) > /dev/null 2>&1 < /dev/null
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

    [search-modes]
    "<empty>" = "fuzzy path"
  '';

  xdg.configFile."kak-lsp/kak-lsp.toml".text = ''
    [language.haskell]
    filetypes = ["haskell"]
    roots = ["hie.yaml", "Setup.hs", "cabal.project", "stack.yaml", "*.cabal"]
    command = "haskell-language-server-wrapper"
    args = ["--lsp"]
    [language.lean]
    filetypes = ["lean"]
    roots = ["lean-toolchain", "lakefile.lean"]
    command = "lean"
    args = ["--server"]
  '';
}
