


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
# Colors
###############################################################################

# This file echoes a bunch of color codes to the terminal to demonstrate what's
# available. Each line is the color code of one forground color, out of 17
# (default + 16 escapes), followed by a test use of that color on all nine
# background colors (default + 8 escapes).
function colors_ansi () {
  T='gYw'   # The test text
  printf "\n                 40m     41m     42m     43m     44m     45m     46m     47m\n";
  for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' '  36m' '1;36m' '  37m' '1;37m';
  do FG=${FGs// /}
    printf " $FGs \033[$FG  $T  "
    for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
    do printf "$EINS \033[$FG\033[$BG  $T \033[0m\033[$BG \033[0m";
    done
    echo;
  done
  echo
}

# generates an 8 bit color table (256 colors) for reference,
# using the ANSI CSI+SGR \033[48;5;${val}m for background and
# \033[38;5;${val}m for text (see "ANSI Code" on Wikipedia)
function colors_256 () {
  printf "\n   +  "
  for i in {0..35}; do
    printf "%2b " $i
  done
  printf "\n\n %3b  " 0
  for i in {0..15}; do
    printf "\033[48;5;${i}m  \033[m "
  done
  #for i in 16 52 88 124 160 196 232; do
  for i in {0..6}; do
    let "i = i*36 +16"
    printf "\n\n %3b  " $i
    for j in {0..35}; do
      let "val = i+j"
      printf "\033[48;5;${val}m  \033[m "
    done
  done
  printf "\n"
}

# generates an 8 bit color table (256 colors) showing the colors used by
# Ethan Schnoover's Solarized theme
function colors_solarized () {
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

function ss
{
  typeset f x
  typeset -i c=0
  typeset re="${1-}"

  while (( $c < ${#DS[*]} ))
  do
    f=${DS[$c]}
    if [[ -n "$re" && "$(echo $f | grep $re)" == "" ]]; then
      ((c=c+1))
      continue
    fi
    if (( ${#f} > 120 )); then
      x="...$(echo $f | cut -c$((${#f}-120))-)"
    else
      x=$f
    fi
    echo "$((c+1))) $x"
    ((c=c+1))
  done
}

function csd
{
  if [[ $# -eq 0 ]] ; then
    echo 'Please specify a stack number (type ss to see options):'
    read stack_arg
  else
    stack_arg=$1
  fi

  if [ $stack_arg == "ss" ]; then
    ss
    return 0
  fi

  typeset num=${stack_arg-}
  typeset removedDirectory

#  if [ "${num##+([0-9])}" != "" ]; then
  if [ "$(echo $num | sed 's/^[0-9]*$//')" != "" ]; then
    c=0
    re=$num
    num=0
    while [ "$c" -lt "${#DS[*]}" ]
    do
      if echo "${DS[$c]}" | grep -q $re; then
        num=$(($c+1))
        break
      fi
      ((c=c+1))
    done
  fi
  if [ "$num" == 0 ]; then
    echo "usage: csd <number greater than 0 | regular expression>"
    return 1
  elif [ "$num" -gt "${#DS[*]}" ]; then
    echo "$num is beyond the stack size."
    return 1
  else
    num=$((num-1))
    typeset dir="${DS[$num]}"
    shiftStackUp $num
    cd_ "$dir"
    return $?
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

#store prompts while protecting namespace
function get_prompt {
  c="\[\033["
  p="${c}38;5;136\]"

  face='\[\033[38;5;240m\]ಠ_ಠ\[\e[m\]\[\033[38;5;125m\] (\@)\[\em\]\[\e[m\] \[\033[38;5;37m\]\W'
  local git_part=""
  if declare -F __git_ps1 >/dev/null 2>&1; then
    git_part="$(__git_ps1 ' \[\033[38;5;64m\](%s)\[\033[m\]')"
  fi

  n="${c}m]"
  echo -e "${face}${git_part} "
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

function rununtilfail() {
  while $@; do :; done
}

function enterdockercontainer() {
  docker exec -it $@ bash
}

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

ports() {
  if [ $# -eq 0 ]; then
    # Show all listening ports with a compact table.
    sudo lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null \
      | awk 'NR==1 {printf "%-20s %-10s %-10s %-6s %s\n", $1, $2, $3, $4, $9} NR>1 {printf "%-20s %-10s %-10s %-6s %s\n", $1, $2, $3, $4, $9}'
    return 0
  fi

  for port in "$@"; do
    echo "=== Port $port ==="
    sudo lsof -nP -iTCP:$port -sTCP:LISTEN 2>/dev/null \
      | awk 'NR==1 {printf "%-20s %-10s %-10s %-6s %s\n", $1, $2, $3, $4, $9} NR>1 {printf "%-20s %-10s %-10s %-6s %s\n", $1, $2, $3, $4, $9}'
    echo
  done
}

# PIP
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

eval "$(/opt/homebrew/bin/brew shellenv)"

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

docker_publish_ecr() {
  # Check if both arguments are provided
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: docker_publish_ecr <image_name> <tag>"
    return 1
  fi

  # Assign the provided arguments to variables
  local IMAGE_NAME="$1"
  local TAG="$2"

  # Run the commands with the dynamic image name and tag
  docker build --platform linux/amd64 -t $IMAGE_NAME:$TAG .
  docker tag $IMAGE_NAME:$TAG 640539939441.dkr.ecr.us-east-1.amazonaws.com/$IMAGE_NAME:$TAG
  # Push to ECR
  docker push 640539939441.dkr.ecr.us-east-1.amazonaws.com/$IMAGE_NAME:$TAG
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

# Rust
. "$HOME/.cargo/env"

# Python
alias python='python3'

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

. "$HOME/.local/bin/env"


eval "$(direnv hook bash)"

# deno
export PATH=$PATH:$HOME/.deno/bin/

export HUSKY=0

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
