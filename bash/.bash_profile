
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Source global definitions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
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

alias grep=ggrep

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && dirname $(readlink .bash_profile) )

FILES="$DIR"/scripts/*.sh
echo -e '\033[33mLoading function files'
for f in $FILES
do
  echo "Loading $(basename $f)"
  . "$f"
done

# Set Editor to vim
export EDITOR='vim'
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


# PIP
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

function npm-which() {
    npm_bin=$(npm bin)
    bin_name=$1
    local_path="${npm_bin}/${bin_name}"

    [[ -f $local_path ]] && echo "$local_path" && return

    which "$bin_name"
}

eval "$(/opt/homebrew/bin/brew shellenv)"

export GPG_TTY=$(tty)

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

function ecr_docker_login() {
  aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 640539939441.dkr.ecr.us-east-1.amazonaws.com
}

function mfa_aws_login() {
  export AWS_PROFILE=default

  cat ~/awsUser || (echo "Type your AWS user and press enter"; read awsUser; echo $awsUser > ~/awsUser);

  awsUser=$(cat ~/awsUser)

  echo "Type your OTP and press enter"
  read otp
  serialNumber=("arn:aws:iam::640539939441:mfa/"$awsUser)
  export $(printf "keyID=%s secretAccessKey=%s sessionToken=%s" $(aws sts get-session-token --serial-number $serialNumber --token-code $otp --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" --output text))
  if ! (cat ~/.aws/credentials | grep default)
  then
    mkdir -p ~/.aws
    aws configure set region us-east-1 --profile default
    aws configure set output json --profile default
    echo "Type your AWS_ACCESS_KEY_ID and press enter"
    read ACCESS_KEY_ID
    echo "Type your AWS_SECRET_ACCESS_KEY and press enter"
    read SECRET_ACCESS_KEY
    aws configure set aws_access_key_id $ACCESS_KEY_ID --profile default
    aws configure set aws_secret_access_key $SECRET_ACCESS_KEY --profile default
    export AWS_PROFILE=default
    unset ACCESS_KEY_ID SECRET_ACCESS_KEY
  fi;
  aws configure set region us-east-1 --profile cerebrum-token
  aws configure set output json --profile cerebrum-token
  aws configure set aws_access_key_id $keyID --profile cerebrum-token
  aws configure set aws_secret_access_key $secretAccessKey --profile cerebrum-token
  aws configure set aws_session_token $sessionToken --profile cerebrum-token
  export AWS_PROFILE=cerebrum-token
  unset awsUser otp serialNumber keyID secretAccessKey sessionToken
  echo "Happy Coding!"
  echo "Your kubernetes context is: $(kubectl config current-context)"
}

# RUBY
eval "$(rbenv init - bash)"

merge_renovate_branches() {
  # Get the current timestamp
  timestamp=$(date +%Y%m%d%H%M%S)

  # Set the new branch name
  new_branch_name="lucianbuzzo/${timestamp}_renovate_pipeline"

  # Fetch the latest branches
  git fetch

  # Get the current branch
  current_branch=$(git symbolic-ref --short HEAD)

  # Check if the current branch is 'master' or 'main'
  if [[ "$current_branch" == "master" ]] || [[ "$current_branch" == "main" ]]; then
    # Create the new branch based on the current branch
    git checkout -b "$new_branch_name"
  else
    new_branch_name="$current_branch"
  fi

  # Get the list of branches with the 'renovate' and 'dependabot' prefixes
  branches=$(git branch -r | grep -E 'origin/(renovate|dependabot)')

  # Merge the branches with the new branch
  for branch in $branches; do
    echo "Merging $branch into $new_branch_name"
    git merge --no-ff --allow-unrelated-histories -Xtheirs "$branch" -m "Merged $branch"
  done

  # Push the new branch to the remote repository
  git push origin "$new_branch_name"

  echo "All 'renovate' and 'dependabot' branches merged into '$new_branch_name' and pushed to the remote repository."
}


export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# factor lang
export PATH=$PATH:/Applications/factor

export_npm_token

# SSL cert env vars used for local development of cerebrum frontend clients
export CEREBRUM_SSL_CERT=~/cerebrum-local-ssl-certs/_wildcard.cerebrum.com.pem
export CEREBRUM_SSL_KEY=~/cerebrum-local-ssl-certs/_wildcard.cerebrum.com-key.pem

HISTSIZE=10000
HISTFILESIZE=20000

# Rust
. "$HOME/.cargo/env"

# Python
eval "$(pyenv init -)"
alias python='python3'
