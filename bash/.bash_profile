
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
echo -e '\033[33mLoading function files'
for f in $FILES
do
  echo "Loading $(basename $f)"
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

# Set Editor to vim
export EDITOR='vim'

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

### Added by the Heroku Toolbelt
export PATH="~/.composer/vendor/bin:$PATH"

export PATH="$HOME/.yarn/bin:$PATH"

function rununtilfail() {
  while $@; do :; done
}

function enterdockercontainer() {
  docker exec -it $@ bash
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$HOME/.cargo/bin:$PATH"

function npm-which() {
    npm_bin=$(npm bin)
    bin_name=$1
    local_path="${npm_bin}/${bin_name}"

    [[ -f $local_path ]] && echo "$local_path" && return

    which "$bin_name"
}

# Solarized Theme Pantheon Terminal
if [ "$(awk -F'[" ]' '/^ID=/{print $2,$3}' /etc/os-release)" = "elementary OS" ]
then
	gsettings set org.pantheon.terminal.settings font 'Droid Sans Mono for Powerline 10'
	gsettings set org.pantheon.terminal.settings background '#00002B2B3636'
	gsettings set org.pantheon.terminal.settings foreground '#838394949696'
	gsettings set org.pantheon.terminal.settings cursor-color '#838394949696'
	#gsettings set org.pantheon.terminal.settings palette '#070736364242:#DCDC32322F2F:#858599990000:#B5B589890000:#26268B8BD2D2:#D3D336368282:#2A2AA1A19898:#EEEEE8E8D5D5:#00002B2B3636:#CBCB4B4B1616:#58586E6E7575:#65657B7B8383:#838394949696:#6C6C7171C4C4:#9393A1A1A1A1:#FDFDF6F6E3E3'
	gsettings set org.pantheon.terminal.settings palette '#070736364242:#DCDC32322F2F:#858599990000:#B5B589890000:#26268B8BD2D2:#D3D336368282:#2A2AA1A19898:#EEEEE8E8D5D5:#00002B2B3636:#CBCB4B4B1616:#858599990000:#65657B7B8383:#26268B8BD2D2:#6C6C7171C4C4:#9393A1A1A1A1:#FDFDF6F6E3E3'
	gsettings set org.pantheon.terminal.settings opacity 98
	gsettings set org.pantheon.terminal.settings follow-last-tab true
fi
