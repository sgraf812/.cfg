function lsghc() {
  function modified_indicator() {
    if git -C $1 diff --no-ext-diff --quiet --exit-code; then
      echo "✓"
    else
      echo "✗"
    fi
  }
  for d in $(\ls -d */); do
    if is_git_dir $d && [ $(git -C $d remote get-url origin) = "https://gitlab.haskell.org/ghc/ghc.git" ]; then
      printf "%s\t%s\t%s\n" $d $(modified_indicator $d) $(git -C $d branch --show-current)
    fi
  done | column -t -s $'\t'
}
