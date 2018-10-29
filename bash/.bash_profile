
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
