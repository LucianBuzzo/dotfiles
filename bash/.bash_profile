
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


DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && dirname $(readlink .bash_profile) )

FILES="$DIR"/profile_scripts/*.sh
echo -e '\033[38;5;240mLoading function files'
for f in $FILES
do
  echo "Importing $f file..."
  . "$f"
done

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
    if [[ "$STATUS" != *'working directory clean'* ]]
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

# generates an 8 bit color table (256 colors) showing the colors used by
# Ethan Schnoover's Solarized theme
function solarizedcolors {
  printf "\nSWATCH SOLARIZED HEX     16/8 TERMCOL  XTERM/HEX   L*A*B      RGB         HSB        "
  printf "\n------ --------- ------- ---- -------  ----------- ---------- ----------- -----------"
  printf "\n\033[48;5;234m      \033[m base03    #002b36  8/4 brblack  234 #1c1c1c 15 -12 -12   0  43  54 193 100  21"
  printf "\n\033[48;5;235m      \033[m base02    #073642  0/4 black    235 #262626 20 -12 -12   7  54  66 192  90  26"
  printf "\n\033[48;5;240m      \033[m base01    #586e75 10/7 brgreen  240 #585858 45 -07 -07  88 110 117 194  25  46"
  printf "\n\033[48;5;241m      \033[m base00    #657b83 11/7 bryellow 241 #626262 50 -07 -07 101 123 131 195  23  51"
  printf "\n\033[48;5;244m      \033[m base0     #839496 12/6 brblue   244 #808080 60 -06 -03 131 148 150 186  13  59"
  printf "\n\033[48;5;245m      \033[m base1     #93a1a1 14/4 brcyan   245 #8a8a8a 65 -05 -02 147 161 161 180   9  63"
  printf "\n\033[48;5;254m      \033[m base2     #eee8d5  7/7 white    254 #e4e4e4 92 -00  10 238 232 213  44  11  93"
  printf "\n\033[48;5;230m      \033[m base3     #fdf6e3 15/7 brwhite  230 #ffffd7 97  00  10 253 246 227  44  10  99"
  printf "\n\033[48;5;136m      \033[m yellow    #b58900  3/3 yellow   136 #af8700 60  10  65 181 137   0  45 100  71"
  printf "\n\033[48;5;166m      \033[m orange    #cb4b16  9/3 brred    166 #d75f00 50  50  55 203  75  22  18  89  80"
  printf "\n\033[48;5;160m      \033[m red       #dc322f  1/1 red      160 #d70000 50  65  45 220  50  47   1  79  86"
  printf "\n\033[48;5;125m      \033[m magenta   #d33682  5/5 magenta  125 #af005f 50  65 -05 211  54 130 331  74  83"
  printf "\n\033[48;5;61m      \033[m violet    #6c71c4 13/5 brmagenta 61 #5f5faf 50  15 -45 108 113 196 237  45  77"
  printf "\n\033[48;5;33m      \033[m blue      #268bd2  4/4 blue      33 #0087ff 55 -10 -45  38 139 210 205  82  82"
  printf "\n\033[48;5;37m      \033[m cyan      #2aa198  6/6 cyan      37 #00afaf 60 -35 -05  42 161 152 175  74  63"
  printf "\n\033[48;5;64m      \033[m green     #859900  2/2 green     64 #5f8700 60 -20  65 133 153   0  68 100  60"
  printf "\n"
}

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

### Added by the Heroku Toolbelt
export PATH="~/.composer/vendor/bin:$PATH"

alias diary='cd ~/journal && vim `date +"%Y-%m-%d"`.markdown'
