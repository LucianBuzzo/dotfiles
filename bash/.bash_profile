


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

# Load bash-completion if it is installed.
bash_completion_paths=(
  "/opt/homebrew/etc/profile.d/bash_completion.sh"
  "/usr/local/etc/profile.d/bash_completion.sh"
  "/opt/homebrew/etc/bash_completion"
  "/usr/local/etc/bash_completion"
)

for candidate in "${bash_completion_paths[@]}"; do
  if [ -f "$candidate" ]; then
    # shellcheck source=/dev/null
    . "$candidate"
    break
  fi
done
unset bash_completion_paths

# Load fzf completion and key bindings if available.
fzf_shell_paths=(
  "/opt/homebrew/opt/fzf/shell"
  "/usr/local/opt/fzf/shell"
)

for candidate in "${fzf_shell_paths[@]}"; do
  if [ -f "$candidate/completion.bash" ]; then
    # shellcheck source=/dev/null
    . "$candidate/completion.bash"
  fi
  if [ -f "$candidate/key-bindings.bash" ]; then
    # shellcheck source=/dev/null
    . "$candidate/key-bindings.bash"
  fi
done
unset fzf_shell_paths

#
# Load git prompt (for __git_ps1) if available
git_prompt_paths=(
  "$HOME/.git-prompt.sh"
  "/opt/homebrew/etc/bash_completion.d/git-prompt.sh"
  "/opt/homebrew/share/git-core/git-prompt.sh"
  "/usr/local/etc/bash_completion.d/git-prompt.sh"
  "/usr/local/share/git-core/git-prompt.sh"
  "/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh"
  "/Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-prompt.sh"
)

for candidate in "${git_prompt_paths[@]}"; do
  if [ -f "$candidate" ]; then
    # shellcheck source=/dev/null
    . "$candidate"
    break
  fi
done

###############################################################################
# Aliases
###############################################################################

alias reloadbash='. ~/.bash_profile'
if command -v eza >/dev/null 2>&1; then
  alias ll='eza -alh --group-directories-first'
else
  alias ll='ls -alhFG'
fi
alias gs='git status'

# Check if ggrep (GNU grep) is installed
if command -v ggrep >/dev/null 2>&1; then
    alias grep='ggrep'
fi




# Recursive search for text in files
function findin {
  grep -Rl "$@"
}

# Recursive search for file name
function findfilename {
  if [ -z "$1" ]; then
    echo "Usage: findfilename <pattern>"
    return 1
  fi
  find . -iname "*$1*"
}

###############################################################################
# AWS
###############################################################################

function update_aws_env_vars() {
  local profile="cerebrum-token"
  local credentials="$HOME/.aws/credentials"
  local env_file="$PWD/.env"

  if [ ! -f "$credentials" ]; then
    echo "Profile ${profile} not found in ${credentials}"
    return 1
  fi

  local tmp_keys
  tmp_keys="$(mktemp)"

  awk -v profile="$profile" '
    $0 ~ "\\["profile"\\]" {in_profile=1; next}
    /^\[/ {if (in_profile) exit; else next}
    in_profile {
      if ($0 ~ /^[[:space:]]*$/) next
      split($0, a, "=")
      key=a[1]; val=a[2]
      sub(/^[[:space:]]+/, "", key); sub(/[[:space:]]+$/, "", key)
      sub(/^[[:space:]]+/, "", val); sub(/[[:space:]]+$/, "", val)
      if (key != "" && val != "") {
        for (i=1;i<=length(key);i++) {
          c=substr(key,i,1)
          if (c ~ /[a-z]/) c=toupper(c)
          out = out c
        }
        print out "=" val
        out=""
      }
    }
  ' "$credentials" > "$tmp_keys"

  if [ ! -s "$tmp_keys" ]; then
    echo "Profile ${profile} not found in ${credentials}"
    rm -f "$tmp_keys"
    return 1
  fi

  local tmp_env
  tmp_env="$(mktemp)"

  if [ -f "$env_file" ]; then
    cp "$env_file" "$tmp_env"
  else
    : > "$tmp_env"
  fi

  while IFS= read -r kv; do
    local key="${kv%%=*}"
    local value="${kv#*=}"
    if grep -q "^${key}=" "$tmp_env"; then
      sed -i '' "s|^${key}=.*$|${key}=${value}|" "$tmp_env"
    else
      printf "\n%s=%s" "$key" "$value" >> "$tmp_env"
    fi
  done < "$tmp_keys"

  mv "$tmp_env" "$env_file"
  rm -f "$tmp_keys"

  echo "Done! variables written to $env_file"
}

###############################################################################
# Directory Stack
###############################################################################

# alias for cd that enables a directory stack
# more info here (http://derekwyatt.org/2011/08/18/my-bash-directory-management.html)
# by Derek Wyatt (https://gist.github.com/derekwyatt/1154129)
export DIRSTACK_MAX=15
DS=()


function eecho
{
    echo $@ 1>&2
}

function shiftStackUp
{
  typeset num=$1
  typeset -i c=$((num+1))

  while (( $c < ${#DS[*]} ))
  do
    DS[$((`expr $c - 1`))]="${DS[$c]}"
    ((c=c+1))
  done
  unset DS[$((${#DS[*]}-1))]
}

function shiftStackDown
{
  typeset num=$1
  typeset -i c=${#DS[*]}

  while (( $c > $num ))
  do
    DS[$c]="${DS[$((c-1))]}"
    ((c=c-1))
  done
}

function popStack
{
  if [[ ${#DS[*]} == 0 ]]; then
    eecho "Cannot pop stack.  No elements to pop."
    return 1
  fi
  typeset retv="${DS[0]}"
  shiftStackUp 0

  echo $retv
}

function pushStack
{
  typeset newvalue="$1"
  typeset -i c=0

  while (( $c < ${#DS[*]} ))
  do
    if [[ "${DS[$c]}" == "$newvalue" ]]; then
      shiftStackUp $c
    else
      ((c=c+1))
    fi
  done
  shiftStackDown 0
  DS[0]="$newvalue"
  if [[ ${#DS[*]} -gt $DIRSTACK_MAX ]]; then
    unset DS[$((${#DS[*]}-1))]
  fi
}

function cd_
{
  typeset ret=0

  if [ $# == 0 ]; then
    pd "$HOME"
    ret=$?
  elif [[ $# == 1 && "$1" == "-" ]]; then
    pd
    ret=$?
  elif [ $# -gt 1 ]; then
    typeset from="$1"
    typeset to="$2"
    typeset c=0
    typeset path=
    typeset x=$(pwd)
    typeset numberOfFroms=$(echo $x | tr '/' '\n' | grep "^$from$" | wc -l)
    while [ $c -lt $numberOfFroms ]
    do
        path=
        typeset subc=$c
        typeset tokencount=0
        for subdir in $(echo $x | tr '/' '\n' | tail -n +2)
        do
            if [[ "$subdir" == "$from" ]]; then
                if [ $subc -eq $tokencount ]; then
                    path="$path/$to"
                    subc=$((subc+1))
                else
                    path="$path/$from"
                    tokencount=$((tokencount+1))
                fi
            else
                path="$path/$subdir"
            fi
        done
        if [ -d "$path" ]; then
            break
        fi
        c=$((c=c+1))
    done
    if [ "$path" == "$x" ]; then
        echo "Bad substitution"
        ret=1
    else
        pd "$path"
        ret=$?
    fi
  else
    pd "$1"
    ret=$?
  fi

  return $ret
}

function pd
{
  typeset dirname="${1-}"
  typeset firstdir seconddir ret p oldDIRSTACK

  if [ "$dirname" == "" ]; then
    firstdir=$(pwd)
    if [ ${#DS[*]} == 0 ]; then
      eecho "Stack is empty.  Cannot swap."
      return 1
    fi
    seconddir=$(popStack)
    pushStack "$firstdir"
    "cd" "$seconddir"
    ret=$?
    return $ret
  else
    if [ -d "$dirname" ]; then
      if [ "$dirname" != '.' ]; then
        pushStack "$(pwd)"
      fi
      "cd" "$dirname"
      ret=$?
      return $ret
    else
      eecho "bash: $dirname: not found"
      return 1
    fi
  fi
}

alias cd=cd_

###############################################################################
# NPM Utilities
###############################################################################

function npm-which() {
  npm_bin=$(npm bin)
  bin_name=$1
  local_path="${npm_bin}/${bin_name}"

  if [[ -f $local_path ]]; then
    echo "$local_path"
  else
    which "$bin_name"
  fi
}


###############################################################################
# Prompt
###############################################################################

# Configures the bash prompt
GIT_PS1_SHOWDIRTYSTATE=1

# Build a safe, colorized prompt. Keep non-printing ANSI wrapped in \[ ... \]
# so Bash can track cursor position correctly.
function get_prompt {
  local face git_part

  face='\[\e[38;5;240m\]ಠ_ಠ\[\e[0m\]\[\e[38;5;125m\] (\@)\[\e[0m\] \[\e[38;5;37m\]\W\[\e[0m\]'
  git_part=""
  if declare -F __git_ps1 >/dev/null 2>&1; then
    git_part="$(__git_ps1 ' \[\e[38;5;64m\](%s)\[\e[0m\]')"
  fi

  printf '%s\n' "${face}${git_part} "
}

PS1=$(get_prompt)

export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

###############################################################################
# SOPS Helpers
###############################################################################

sops_decrypt() {
  if [ -z "$1" ]; then
    echo "Usage: decrypt_sops <path/to/sops.filename.yml>"
    return 1
  fi

  encrypted_file="$1"

  if [ ! -f "${encrypted_file}" ]; then
    echo "Error: Encrypted file '${encrypted_file}' not found."
    return 1
  fi

  decrypted_file="${encrypted_file%.*}.yml"
  decrypted_file="${decrypted_file/sops./}"

  sops -d "${encrypted_file}" > "${decrypted_file}"
  echo "Decrypted '${encrypted_file}' to '${decrypted_file}'"
}

sops_encrypt() {
  if [ -z "$1" ]; then
    echo "Usage: encrypt_sops <path/to/filename.yml>"
    return 1
  fi

  decrypted_file="$1"
  encrypted_file="${decrypted_file%.*}.yml"
  encrypted_file="sops.${decrypted_file##*/}"

  if [ ! -f "${decrypted_file}" ]; then
    echo "Error: Decrypted file '${decrypted_file}' not found."
    return 1
  fi

  kms_file="$HOME/.sops_kms_arns"

  if [ ! -f "${kms_file}" ]; then
    touch "${kms_file}"
  fi

  use_existing_key=""
  while [[ "$use_existing_key" != "y" && "$use_existing_key" != "n" ]]; do
    echo -n "Do you want to use a pre-existing KMS key? (y/n): "
    read -r use_existing_key
  done

  if [ "$use_existing_key" = "y" ]; then
    options=($(awk -F'\t' '{print $1 "\t" $2 "\t" $3}' "${kms_file}"))
    echo "Select a KMS ARN:"
    printf "%-4s | %-12s | %-50s | %-20s\n" "No." "Date" "ARN" "Label"
    echo "--------------------------------------------------------------------------------------------"
    index=1
    for ((i = 0; i < ${#options[@]}; i += 3)); do
      printf "%-4d | %-12s | %-50s | %-20s\n" "${index}" "${options[i]}" "${options[i+1]}" "${options[i+2]}"
      index=$((index + 1))
    done
    echo -n "Enter the number of the KMS ARN: "
    read -r choice
    kms_arn="${options[((choice - 1) * 3 + 1)]}"
  else
    echo -n "Enter new KMS ARN: "
    read -r new_kms_arn
    if [ -z "${new_kms_arn}" ]; then
      echo "Invalid KMS ARN. Aborting."
      return 1
    fi
    echo -n "Enter a label for the new KMS ARN: "
    read -r new_label
    if [ -z "${new_label}" ]; then
      echo "Invalid label. Aborting."
      return 1
    fi
    current_date=$(date "+%Y-%m-%d")
    echo -e "${current_date}\t${new_kms_arn}\t${new_label}" >> "${kms_file}"
    kms_arn="${new_kms_arn}"
  fi

  sops -e --kms "${kms_arn}" --encrypted-regex '^(data|stringData|secrets)$' "${decrypted_file}" > "${encrypted_file}"
  echo "Encrypted '${decrypted_file}' to '${encrypted_file}' using KMS ARN '${kms_arn}'"
}

# Set Editor to vim
export EDITOR='vim'
export PATH="$HOME/.yarn/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# PIP
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

# Homebrew: load shell env if Homebrew is installed.
# Guarded so shells on hosts without Homebrew (most Linux servers/containers)
# do not error; `brew shellenv` sets PATH and other vars appropriately.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

export GPG_TTY=$(tty)

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


# -----------------------------------------------------------------------------
# AI-powered Git Commit Function
# Copy paste this gist into your ~/.bashrc or ~/.zshrc to gain the `gcm` command. It:
# 1) gets the current staged changed diff
# 2) sends them to an LLM to write the git commit message
# 3) allows you to easily accept, edit, regenerate, cancel
# But - just read and edit the code however you like
# the `llm` CLI util is awesome, can get it here: https://llm.datasette.io/en/stable/

gcm() {
    # Function to generate commit message
    generate_commit_message() {
        git diff --cached | llm "
Below is a diff of all staged changes, coming from the command:

\`\`\`
git diff --cached
\`\`\`

Please generate a concise, one-line commit message for these changes, including a conventional-commit prefix. The response should have a 72 character limit and should not be wrapped in grave accents (\`)"
    }

    # Function to read user input compatibly with both Bash and Zsh
    read_input() {
        if [ -n "$ZSH_VERSION" ]; then
            echo -n "$1"
            read -r REPLY
        else
            read -p "$1" -r REPLY
        fi
    }

    # Main script
    echo "Generating AI-powered commit message..."
    commit_message=$(generate_commit_message)

    while true; do
        echo -e "\nProposed commit message:"
        echo "$commit_message"

        read_input "Do you want to (a)ccept, (e)dit, (r)egenerate, or (c)ancel? "
        choice=$REPLY

        case "$choice" in
            a|A )
                if git commit -m "$commit_message"; then
                    echo "Changes committed successfully!"
                    return 0
                else
                    echo "Commit failed. Please check your changes and try again."
                    return 1
                fi
                ;;
            e|E )
                read_input "Enter your commit message: "
                commit_message=$REPLY
                if [ -n "$commit_message" ] && git commit -m "$commit_message"; then
                    echo "Changes committed successfully with your message!"
                    return 0
                else
                    echo "Commit failed. Please check your message and try again."
                    return 1
                fi
                ;;
            r|R )
                echo "Regenerating commit message..."
                commit_message=$(generate_commit_message)
                ;;
            c|C )
                echo "Commit cancelled."
                return 1
                ;;
            * )
                echo "Invalid choice. Please try again."
                ;;
        esac
    done
}


export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# factor lang
export PATH=$PATH:/Applications/factor

# bpkg
export PATH=$PATH:$HOME/.local/bin/

# SSL cert env vars used for local development of cerebrum frontend clients
export CEREBRUM_SSL_CERT=~/cerebrum-local-ssl-certs/_wildcard.cerebrum.com.pem
export CEREBRUM_SSL_KEY=~/cerebrum-local-ssl-certs/_wildcard.cerebrum.com-key.pem

HISTSIZE=10000
HISTFILESIZE=20000

# Rust: source cargo's env file if it exists (installed via rustup).
# Guarded to avoid errors on machines without Rust.
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Python
alias python='python3'

# Roam CLI
alias roam='~/bin/roam'

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

# Local env: optional per-user script; if present, source it.
# Guarded so missing file is a no-op.
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"


# direnv: enable project-scoped envs if installed. Requires `direnv allow`.
# Guarded to avoid errors if direnv is not installed.
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# zoxide: smarter directory jumping via `z`.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

# ble.sh: required by Atuin's Bash integration; source it before Atuin.
ble_sh_paths=(
  "$HOME/.local/share/blesh/ble.sh"
  "/opt/homebrew/share/blesh/ble.sh"
  "/usr/local/share/blesh/ble.sh"
)

for candidate in "${ble_sh_paths[@]}"; do
  if [ -f "$candidate" ]; then
    # shellcheck source=/dev/null
    . "$candidate"
    break
  fi
done
unset ble_sh_paths

# atuin: enhanced shell history and search.
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init bash)"
fi

# deno
export PATH=$PATH:$HOME/.deno/bin/



# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/lucianbuzzo/.lmstudio/bin"
# End of LM Studio CLI section

_cb_prompt_update='PS1=$(get_prompt)'
if [[ "${PROMPT_COMMAND-}" != *"${_cb_prompt_update}"* ]]; then
  if [ -n "${PROMPT_COMMAND-}" ]; then
    PROMPT_COMMAND="${PROMPT_COMMAND};${_cb_prompt_update}"
  else
    PROMPT_COMMAND="${_cb_prompt_update}"
  fi
fi
unset _cb_prompt_update

gravious() {
  local sess
  if [[ -n "$1" ]]; then
    sess="$1"
  else
    local dir_slug timestamp
    dir_slug="$(printf '%s' "${PWD#$HOME/}" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9._-' '-' | sed 's/^-*//; s/-*$//')"
    timestamp="$(date +"%Y%m%d-%H%M")"
    sess="${dir_slug}-${timestamp}"
  fi

  openclaw gateway status >/dev/null 2>&1 || openclaw gateway start
  openclaw tui --session "$sess"
}
