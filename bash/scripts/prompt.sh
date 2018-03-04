#!/bin/bash

# Configures the bash prompt

# echos the current git branch
# by Lattapon Yodsuwan (https://gist.github.com/clozed2u)
# via (https://gist.github.com/clozed2u/4971506#file-gistfile1-sh)
git_branch () {
  if git rev-parse --git-dir >/dev/null 2>&1
    #then echo -e "" [$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')]
  then echo -e "" \($(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')\)
  else
    echo ""
  fi
}

# Return an ANSI color code based on the current git status
# by Lattapon Yodsuwan (https://gist.github.com/clozed2u)
# via (https://gist.github.com/clozed2u/4971506#file-gistfile1-sh)
function git_color {
  local STATUS=`git status 2>&1`
  if [[ "$STATUS" == *'Not a git repository'* ]]
  then echo ""
  else
    if [[ "$STATUS" != *'working tree clean'* ]]
    then
      # red if need to commit
      echo -e '\033[38;5;160m'
    else
      if [[ "$STATUS" == *'Your branch is ahead'* ]]
      then
        # yellow if need to push
        echo -e '\033[38;5;136m'
      else
        # else green
        echo -e '\033[38;5;64m'
      fi
    fi
  fi
}

#store prompts while protecting namespace
function get_prompt {
  c="\[\033["
  p="${c}38;5;136\]"

  face='\[\033[38;5;240m\]ಠ_ಠ\[\e[m\]\[\033[38;5;125m\] (\@)\[\em\]\[\e[m\] \[\033[38;5;37m\]\W/\[\e[m\]\[$(git_color)\]$(git_branch)\[\033[m\] '

  n="${c}m]"
  echo -e "${face}"
}

export PS1=$(get_prompt)

export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
