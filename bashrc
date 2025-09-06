# reload bashrc
export PATH="$HOME/bin:$PATH"

# Alias to show full path and tree up to depth 123

# tree
alias tree='tree -C -L 1'
# alias treefull='pwd && tree -haL 123'
alias reload='source ~/.bashrc'

treefull() {
  echo "Path: "
  pwd
  tree -haL 123
}

fulltree() {
  treefull "$@"
}

# quick commit
commit() {

  set -e  # Exit immediately on error
  
  # Colors
  BOLD="\033[1m"
  C_WHITE="\033[38;5;15m"     # bright white foreground
  C_GREEN3="\033[48;5;34m"    # green3 background
  CYAN="\033[36m"
  YELLOW="\033[33m"
  RED="\033[31m"
  RESET="\033[0m"
  
  push=true
  msg=""
  
  # Parse args
  for arg in "$@"; do
    if [ "$arg" = "-l" ]; then
      push=false
    else
      if [ -z "$msg" ]; then
        msg="$arg"
      else
        msg="$msg $arg"
      fi
    fi
  done
  
  # Detect current branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || {
    echo "❌ Not a git repository."
    exit 1
  }
  
  # If no message, auto-generate one
  if [ -z "$msg" ]; then
    tz_abbr=$(date +%Z)
    msg="auto-commit: Termux, $(date +"%b %d, %Y %-I:%M %p [$tz_abbr]")"
  fi
  
  # Stage all changes
  git add -A
  
  # Try commit and capture output
  commit_output=$(git commit -m "$msg" 2>&1) || true
  
  # If nothing to commit, show short but informative message with color-coded status
  if echo "$commit_output" | grep -q "nothing to commit"; then
    remote_status=$(git status -sb | head -n1 | sed 's/^## //')
    case "$remote_status" in
      *ahead*)    color=$YELLOW ;;
      *behind*)   color=$RED ;;
      *diverged*) color=$RED ;;
      *)          color=$CYAN ;;
    esac
    echo -e "${color}Nothing to commit.${RESET} (${remote_status})"
    exit 0
  fi
  
  # Push if not local-only
  if [ "$push" = true ]; then
    git push origin "$branch"
  fi
  
  # Banner output — white text on green3 background
  echo -e "\n${BOLD}${C_GREEN3}${C_WHITE} COMMIT SUCCESSFUL ${RESET}"
  echo -e "Branch: ${BOLD}${branch}${RESET}"
  echo -e "Commit message: ${BOLD}$msg${RESET}"
  if [ "$push" = true ]; then
    echo -e "${CYAN}Pushed to origin/${branch}${RESET}\n"
  else
    echo -e "${YELLOW}Local commit only — not pushed${RESET}\n"
  fi

}
