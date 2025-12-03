function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return 0
    fi
  done

  # If no main branch was found, fall back to master but return error
  echo master
  return 1
}

alias gaa='git add -A'
alias gcam='git commit -am'
alias gcb='git checkout -b'
alias gst='git status'
alias gp='git push'
alias gl='git pull'

alias gra='git rebase --abort'
alias grc='git rebase --continue'

alias gcm='git checkout $(git_main_branch)'

alias la='ls -lahF --color=auto'
alias gauth="gcloud auth login --update-adc"

alias tf='terraform'
alias zed='open -a Zed'
alias k='kubectl'
alias kontext='kubectl config use-context'
