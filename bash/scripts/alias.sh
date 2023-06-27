#!/bin/bash

alias reloadbash='. ~/.bash_profile'
alias ll='ls -alhFG'
alias gs='git status'
alias mp='markdown-preview'
# Generate a 16 char password using md5
alias generatepass='date | md5 | cut -c1-16'
alias uistart='cd ~/projects/resin-ui && API_HOST=api.resinstaging.io npm start'
alias diary='cd ~/journal && vim `date +"%Y-%m-%d"`.markdown'
alias stagingCommit='curl -s https://dashboard.resinstaging.io | grep COMMIT'
alias dcup='docker-compose up --build'

alias assignment-start='docker build -t smart-lighting-dashboard . && docker run -p 8000:8000 smart-lighting-dashboard'
alias assignment-stop='docker rmi smart-lighting-dashboard --force'

# If we're running on the local machine grab Brew installed vim, otherwise find
# out where vim is installed and run that instead
function vim {
  # we need to turn off stty to allow <C-s> mappings
  # Save and then restore terminal settings
  local STTYOPTS="$(stty -g)"
  stty stop '' -ixoff
  if [[ "$OSTYPE" == 'linux-gnu' ]]; then
    local VIM=`which vim`
     $VIM "$@"
  else
    local VIM=`which vim`
     $VIM "$@"
  fi
  stty "$STTYOPTS"
}

# Recursive search for text in files
function findin {
  grep -Rl "$@"
}

# Recursive search for file name
function findfilename {
  find $PWD | grep "$@"
}

# Check if ggrep (GNU grep) is installed
if command -v ggrep >/dev/null 2>&1; then
    alias grep='ggrep'
fi

