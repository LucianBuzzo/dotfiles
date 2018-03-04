
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# show motd is one is available
if [ -f /etc/motd ]; then
  cat /etc/motd
  echo
  echo
fi

# Load bash auto completion script
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && dirname $(readlink .bash_profile) )

FILES="$DIR"/scripts/*.sh
echo -e '\033[38;5;240mLoading function files'
for f in $FILES
do
  echo "Importing $f file..."
  . "$f"
done

function cs-to-ts() {
  decaffeinate $1
  mv $(echo $1 | sed 's/\.coffee/\.js/') $(echo $1 | sed 's/\.coffee/\.ts/')
  git rm $1
  npm run prettify
  code -r $(echo $1 | sed 's/\.coffee/\.ts/')
  git add $(echo $1 | sed 's/\.coffee/\.ts/')
}

# Detect if we're in an SSH session
function is_ssh() {
	if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
		return 0
	# many other tests omitted
	else
	  case $(ps -o comm= -p $PPID) in
	    sshd|*/sshd) return 0;;
	  esac
	fi
	return 1
}

# /etc/profile.d/complete-hosts.sh
# Autocomplete Hostnames for SSH etc.
# by Jean-Sebastien Morisset (http://surniaulula.com/)
_complete_hosts () {
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    host_list=`{
        for c in /etc/ssh_config /etc/ssh/ssh_config ~/.ssh/config
        do [ -r $c ] && sed -n -e 's/^Host[[:space:]]//p' -e 's/^[[:space:]]*HostName[[:space:]]//p' $c
        done
        for k in /etc/ssh_known_hosts /etc/ssh/ssh_known_hosts ~/.ssh/known_hosts
        do [ -r $k ] && egrep -v '^[#\[]' $k|cut -f 1 -d ' '|sed -e 's/[,:].*//g'
        done
        sed -n -e 's/^[0-9][0-9\.]*//p' /etc/hosts; }|tr ' ' '\n'|grep -v '*'`
    COMPREPLY=( $(compgen -W "${host_list}" -- $cur))
    return 0
}
complete -F _complete_hosts ssh
complete -F _complete_hosts ssh
complete -F _complete_hosts tunnel
complete -F _complete_hosts sftp

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

function host_alias {
  if [ -z "$MYHOSTALIAS" ]; then
    echo -e $(hostname -s)
  else
    echo $MYHOSTALIAS
  fi
}

#store prompts while protecting namespace
function get_prompt {
  c="\[\033["
  p="${c}38;5;136\]"

  face='\[\033[38;5;240m\]ಠ_ಠ\[\e[m\]\[\033[38;5;125m\] (\@)\[\em\]\[\e[m\] \[\033[38;5;37m\]\W/\[\e[m\]\[$(git_color)\]$(git_branch)\[\033[m\] '
  ssh_session='\[\033[38;5;240m\]\u\[\033[38;5;37m\]@$(host_alias)\[\em\]\[\033[38;5;125m\] (\@)\[\em\]\[\e[m\] \[\033[38;5;37m\]\W/\[\e[m\]\[$(git_color)\]$(git_branch)\[\033[m\] '

  n="${c}m]"
  if is_ssh; then
    echo -e "${ssh_session}"
  else
    echo -e "${face}"
  fi
}

export PS1=$(get_prompt)

export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

alias reloadbash='. ~/.bash_profile'
alias ll='ls -alhFG'
alias gs='git status'
alias mp='markdown-preview'

if [ !SSH_SESSION ]
  then
    alias gotolifetime='cd /www/sites/lifetime/htdocs/sites/all/themes/lifetime_v2/'
    alias gotocastrol='cd /www/sites/academy/htdocs/sites/all/'
    alias gotobentosnips='cd /www/sites/bentosnips/htdocs/'
    # Generate a 10 char password using md5
    alias generatepass='date | md5 | cut -c1-10'
fi

function findin {
  grep -Rl "$@"
}

# If we're running on the local machine grab Brew installed vim, otherwise find
# out where vim is installed and run that instead
function vim {
  # we need to turn off stty to allow <C-s> mappings
  # Save and then restore terminal settings
  local STTYOPTS="$(stty -g)"
  stty stop '' -ixoff
  if is_ssh; then
    local VIM=`which vim`
     $VIM "$@"
  elif [[ "$OSTYPE" == 'linux-gnu' ]]; then
    local VIM=`which vim`
     $VIM "$@"
  else
    local VIM=`which vim`
     $VIM "$@"
  fi
  stty "$STTYOPTS"
}

function tunnel {
  #ssh -w 'any' "$@"
  local HOSTALIAS="'export MYHOSTALIAS=$1; /bin/bash -il'"
  ssh "$@" -t \'"$HOSTALIAS"\'
}

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

### Added by the Heroku Toolbelt
export PATH="~/.composer/vendor/bin:$PATH"

alias diary='cd ~/journal && vim `date +"%Y-%m-%d"`.markdown'

function findfilename {
  find $PWD | grep "$@"
}

export PATH="$HOME/.yarn/bin:$PATH"

alias uistart='cd ~/projects/resin-ui && API_HOST=api.resinstaging.io npm start'

alias stagingCommit='curl -s https://dashboard.resinstaging.io | grep COMMIT'

