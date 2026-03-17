export EDITOR='vim'
export PATH="$HOME/.yarn/bin:$PATH"
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

export GPG_TTY="$(tty 2>/dev/null || true)"

export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:/Applications/factor"
export PATH="$PATH:$HOME/.local/bin/"

export CEREBRUM_SSL_CERT=~/cerebrum-local-ssl-certs/_wildcard.cerebrum.com.pem
export CEREBRUM_SSL_KEY=~/cerebrum-local-ssl-certs/_wildcard.cerebrum.com-key.pem

export BUN_INSTALL="$HOME/.bun"
export PATH="$PATH:$BUN_INSTALL/bin"
export PATH="$PATH:$HOME/.deno/bin/"
export PATH="$PATH:/Users/lucianbuzzo/.lmstudio/bin"

if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi

if [ -f "$HOME/.local/bin/env" ]; then
  source "$HOME/.local/bin/env"
fi

alias mp='markdown-preview'
generatepass() {
  if command -v md5 >/dev/null 2>&1; then
    date | md5 | cut -c1-16
  else
    date | md5sum | cut -c1-16
  fi
}
alias uistart='cd ~/projects/resin-ui && API_HOST=api.resinstaging.io npm start'
alias diary='cd ~/journal && vim $(date +"%Y-%m-%d").markdown'
alias stagingCommit='curl -s https://dashboard.resinstaging.io | grep COMMIT'
alias dcup='docker-compose up --build'
alias assignment-start='docker build -t smart-lighting-dashboard . && docker run -p 8000:8000 smart-lighting-dashboard'
alias assignment-stop='docker rmi smart-lighting-dashboard --force'
alias roam='~/bin/roam'

if command -v ggrep >/dev/null 2>&1; then
  alias grep='ggrep'
fi

findin() {
  grep -Rl "$@"
}

findfilename() {
  if [ -z "$1" ]; then
    echo "Usage: findfilename <pattern>"
    return 1
  fi

  find . -iname "*$1*"
}

update_aws_env_vars() {
  local profile="cerebrum-token"
  local credentials="$HOME/.aws/credentials"
  local env_file="$PWD/.env"
  local tmp_keys tmp_env key value kv

  if [ ! -f "$credentials" ]; then
    echo "Profile ${profile} not found in ${credentials}"
    return 1
  fi

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

  tmp_env="$(mktemp)"

  if [ -f "$env_file" ]; then
    cp "$env_file" "$tmp_env"
  else
    : > "$tmp_env"
  fi

  while IFS= read -r kv; do
    key="${kv%%=*}"
    value="${kv#*=}"
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

colors_ansi() {
  local T FG FGs BG
  T='gYw'
  printf "\n                 40m     41m     42m     43m     44m     45m     46m     47m\n"
  for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' '  36m' '1;36m' '  37m' '1;37m'; do
    FG=${FGs// /}
    printf " $FGs \033[$FG  $T  "
    for BG in 40m 41m 42m 43m 44m 45m 46m 47m; do
      printf " \033[$FG\033[$BG  $T \033[0m\033[$BG \033[0m"
    done
    echo
  done
  echo
}

colors_256() {
  local i j val
  printf "\n   +  "
  for i in {0..35}; do
    printf "%2b " "$i"
  done
  printf "\n\n %3b  " 0
  for i in {0..15}; do
    printf "\033[48;5;%sm  \033[m " "$i"
  done
  for i in {0..6}; do
    (( i = i * 36 + 16 ))
    printf "\n\n %3b  " "$i"
    for j in {0..35}; do
      (( val = i + j ))
      printf "\033[48;5;%sm  \033[m " "$val"
    done
  done
  printf "\n"
}

colors_solarized() {
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

export DIRSTACK_MAX="${DIRSTACK_MAX:-15}"
typeset -ga DS
DS=()

eecho() {
  print -u2 -r -- "$*"
}

popStack() {
  local retv

  if (( ${#DS[@]} == 0 )); then
    eecho "Cannot pop stack.  No elements to pop."
    return 1
  fi

  retv="${DS[1]}"
  shift DS
  print -r -- "$retv"
}

pushStack() {
  local newvalue="$1"
  local entry
  local -a filtered

  filtered=()
  for entry in "${DS[@]}"; do
    if [[ "$entry" != "$newvalue" ]]; then
      filtered+=("$entry")
    fi
  done

  DS=("$newvalue" "${filtered[@]}")
  while (( ${#DS[@]} > DIRSTACK_MAX )); do
    unset 'DS[-1]'
  done
}

pd() {
  local dirname="${1-}"
  local firstdir seconddir ret

  if [ -z "$dirname" ]; then
    firstdir="$(pwd)"
    if (( ${#DS[@]} == 0 )); then
      eecho "Stack is empty.  Cannot swap."
      return 1
    fi
    seconddir="$(popStack)"
    pushStack "$firstdir"
    builtin cd "$seconddir"
    ret=$?
    return "$ret"
  fi

  if [ -d "$dirname" ]; then
    if [ "$dirname" != '.' ]; then
      pushStack "$(pwd)"
    fi
    builtin cd "$dirname"
    ret=$?
    return "$ret"
  fi

  eecho "zsh: $dirname: not found"
  return 1
}

cd_() {
  local ret=0

  if [ $# -eq 0 ]; then
    pd "$HOME"
    ret=$?
  elif [[ $# -eq 1 && "$1" == "-" ]]; then
    pd
    ret=$?
  elif [ $# -gt 1 ]; then
    local from="$1"
    local to="$2"
    local c=0
    local path=
    local x
    local numberOfFroms

    x="$(pwd)"
    numberOfFroms="$(echo "$x" | tr '/' '\n' | grep -c "^$from$")"
    while [ "$c" -lt "$numberOfFroms" ]; do
      local subc="$c"
      local tokencount=0
      path=
      for subdir in $(echo "$x" | tr '/' '\n' | tail -n +2); do
        if [[ "$subdir" == "$from" ]]; then
          if [ "$subc" -eq "$tokencount" ]; then
            path="$path/$to"
            subc=$((subc + 1))
          else
            path="$path/$from"
            tokencount=$((tokencount + 1))
          fi
        else
          path="$path/$subdir"
        fi
      done
      if [ -d "$path" ]; then
        break
      fi
      c=$((c + 1))
    done
    if [ "$path" = "$x" ]; then
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

  return "$ret"
}

ss() {
  local f x
  local c=1
  local re="${1-}"

  while [ "$c" -le "${#DS[@]}" ]; do
    f="${DS[$c]}"
    if [[ -n "$re" ]] && ! echo "$f" | grep -q "$re"; then
      c=$((c + 1))
      continue
    fi
    if (( ${#f} > 120 )); then
      x="...$(echo "$f" | cut -c$((${#f} - 120))-)"
    else
      x="$f"
    fi
    echo "$c) $x"
    c=$((c + 1))
  done
}

csd() {
  local stack_arg num dir c re

  if [ $# -eq 0 ]; then
    echo 'Please specify a stack number (type ss to see options):'
    read -r stack_arg
  else
    stack_arg="$1"
  fi

  if [ "$stack_arg" = "ss" ]; then
    ss
    return 0
  fi

  num="${stack_arg-}"

  if [ "$(echo "$num" | sed 's/^[0-9]*$//')" != "" ]; then
    c=1
    re="$num"
    num=0
    while [ "$c" -le "${#DS[@]}" ]; do
      if echo "${DS[$c]}" | grep -q "$re"; then
        num="$c"
        break
      fi
      c=$((c + 1))
    done
  fi

  if [ "$num" = 0 ]; then
    echo "usage: csd <number greater than 0 | regular expression>"
    return 1
  elif [ "$num" -gt "${#DS[@]}" ]; then
    echo "$num is beyond the stack size."
    return 1
  fi

  dir="${DS[$num]}"
  unset "DS[$num]"
  DS=("${DS[@]}")
  cd_ "$dir"
}

alias cd='cd_'

npm-which() {
  local npm_bin bin_name local_path

  bin_name="$1"
  if command -v npm >/dev/null 2>&1; then
    npm_bin="$(npm bin)"
  else
    npm_bin=""
  fi
  local_path="${npm_bin}/${bin_name}"

  if [[ -n "$npm_bin" && -f "$local_path" ]]; then
    echo "$local_path"
  else
    which "$bin_name"
  fi
}

sops_decrypt() {
  local encrypted_file decrypted_file

  if [ -z "$1" ]; then
    echo "Usage: decrypt_sops <path/to/sops.filename.yml>"
    return 1
  fi

  encrypted_file="$1"
  if [ ! -f "$encrypted_file" ]; then
    echo "Error: Encrypted file '${encrypted_file}' not found."
    return 1
  fi

  decrypted_file="${encrypted_file%.*}.yml"
  decrypted_file="${decrypted_file/sops./}"

  sops -d "$encrypted_file" > "$decrypted_file"
  echo "Decrypted '${encrypted_file}' to '${decrypted_file}'"
}

sops_encrypt() {
  local decrypted_file encrypted_file kms_file use_existing_key choice kms_arn new_kms_arn new_label current_date
  local -a options

  if [ -z "$1" ]; then
    echo "Usage: encrypt_sops <path/to/filename.yml>"
    return 1
  fi

  decrypted_file="$1"
  encrypted_file="sops.${decrypted_file##*/}"

  if [ ! -f "$decrypted_file" ]; then
    echo "Error: Decrypted file '${decrypted_file}' not found."
    return 1
  fi

  kms_file="$HOME/.sops_kms_arns"
  [ -f "$kms_file" ] || touch "$kms_file"

  use_existing_key=""
  while [[ "$use_existing_key" != "y" && "$use_existing_key" != "n" ]]; do
    printf "Do you want to use a pre-existing KMS key? (y/n): "
    read -r use_existing_key
  done

  if [ "$use_existing_key" = "y" ]; then
    options=($(awk -F'\t' '{print $1 "\t" $2 "\t" $3}' "$kms_file"))
    echo "Select a KMS ARN:"
    printf "%-4s | %-12s | %-50s | %-20s\n" "No." "Date" "ARN" "Label"
    echo "--------------------------------------------------------------------------------------------"
    local index=1
    local i
    for (( i = 1; i <= ${#options[@]}; i += 3 )); do
      printf "%-4d | %-12s | %-50s | %-20s\n" "$index" "${options[$i]}" "${options[$((i + 1))]}" "${options[$((i + 2))]}"
      index=$((index + 1))
    done
    printf "Enter the number of the KMS ARN: "
    read -r choice
    kms_arn="${options[$(((choice - 1) * 3 + 2))]}"
  else
    printf "Enter new KMS ARN: "
    read -r new_kms_arn
    if [ -z "$new_kms_arn" ]; then
      echo "Invalid KMS ARN. Aborting."
      return 1
    fi
    printf "Enter a label for the new KMS ARN: "
    read -r new_label
    if [ -z "$new_label" ]; then
      echo "Invalid label. Aborting."
      return 1
    fi
    current_date="$(date "+%Y-%m-%d")"
    printf "%s\t%s\t%s\n" "$current_date" "$new_kms_arn" "$new_label" >> "$kms_file"
    kms_arn="$new_kms_arn"
  fi

  sops -e --kms "$kms_arn" --encrypted-regex '^(data|stringData|secrets)$' "$decrypted_file" > "$encrypted_file"
  echo "Encrypted '${decrypted_file}' to '${encrypted_file}' using KMS ARN '${kms_arn}'"
}

rununtilfail() {
  while "$@"; do :; done
}

enterdockercontainer() {
  docker exec -it "$@" bash
}

ports() {
  local port

  if [ $# -eq 0 ]; then
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

ecr_docker_login() {
  aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 640539939441.dkr.ecr.us-east-1.amazonaws.com
}

mfa_aws_login() {
  local awsUser otp serialNumber keyID secretAccessKey sessionToken ACCESS_KEY_ID SECRET_ACCESS_KEY

  export AWS_PROFILE=default

  if [ ! -f "$HOME/awsUser" ]; then
    echo "Type your AWS user and press enter"
    read -r awsUser
    echo "$awsUser" > "$HOME/awsUser"
  fi

  awsUser="$(cat "$HOME/awsUser")"

  echo "Type your OTP and press enter"
  read -r otp
  serialNumber="arn:aws:iam::640539939441:mfa/$awsUser"
  read -r keyID secretAccessKey sessionToken <<< "$(aws sts get-session-token --serial-number "$serialNumber" --token-code "$otp" --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" --output text)"
  export keyID secretAccessKey sessionToken

  if ! grep -q default "$HOME/.aws/credentials" 2>/dev/null; then
    mkdir -p "$HOME/.aws"
    aws configure set region us-east-1 --profile default
    aws configure set output json --profile default
    echo "Type your AWS_ACCESS_KEY_ID and press enter"
    read -r ACCESS_KEY_ID
    echo "Type your AWS_SECRET_ACCESS_KEY and press enter"
    read -r SECRET_ACCESS_KEY
    aws configure set aws_access_key_id "$ACCESS_KEY_ID" --profile default
    aws configure set aws_secret_access_key "$SECRET_ACCESS_KEY" --profile default
    export AWS_PROFILE=default
  fi

  aws configure set region us-east-1 --profile cerebrum-token
  aws configure set output json --profile cerebrum-token
  aws configure set aws_access_key_id "$keyID" --profile cerebrum-token
  aws configure set aws_secret_access_key "$secretAccessKey" --profile cerebrum-token
  aws configure set aws_session_token "$sessionToken" --profile cerebrum-token
  export AWS_PROFILE=cerebrum-token
  unset awsUser otp serialNumber keyID secretAccessKey sessionToken ACCESS_KEY_ID SECRET_ACCESS_KEY
  echo "Happy Coding!"
  echo "Your kubernetes context is: $(kubectl config current-context)"
}

merge_renovate_branches() {
  local timestamp new_branch_name current_branch branches branch

  timestamp="$(date +%Y%m%d%H%M%S)"
  new_branch_name="lucianbuzzo/${timestamp}_renovate_pipeline"

  git fetch

  current_branch="$(git symbolic-ref --short HEAD)"
  if [[ "$current_branch" == "master" || "$current_branch" == "main" ]]; then
    git checkout -b "$new_branch_name"
  else
    new_branch_name="$current_branch"
  fi

  branches="$(git branch -r | grep -E 'origin/(renovate|dependabot)')"
  for branch in ${(f)branches}; do
    echo "Merging $branch into $new_branch_name"
    git merge --no-ff --allow-unrelated-histories -Xtheirs "$branch" -m "Merged $branch"
  done

  git push origin "$new_branch_name"
  echo "All 'renovate' and 'dependabot' branches merged into '$new_branch_name' and pushed to the remote repository."
}

gcm() {
  local commit_message choice

  generate_commit_message() {
    git diff --cached | llm "
Below is a diff of all staged changes, coming from the command:

\`\`\`
git diff --cached
\`\`\`

Please generate a concise, one-line commit message for these changes, including a conventional-commit prefix. The response should have a 72 character limit and should not be wrapped in grave accents (\`)"
  }

  read_input() {
    printf "%s" "$1"
    read -r REPLY
  }

  echo "Generating AI-powered commit message..."
  commit_message="$(generate_commit_message)"

  while true; do
    echo
    echo "Proposed commit message:"
    echo "$commit_message"

    read_input "Do you want to (a)ccept, (e)dit, (r)egenerate, or (c)ancel? "
    choice="$REPLY"

    case "$choice" in
      a|A)
        if git commit -m "$commit_message"; then
          echo "Changes committed successfully!"
          return 0
        fi
        echo "Commit failed. Please check your changes and try again."
        return 1
        ;;
      e|E)
        read_input "Enter your commit message: "
        commit_message="$REPLY"
        if [ -n "$commit_message" ] && git commit -m "$commit_message"; then
          echo "Changes committed successfully with your message!"
          return 0
        fi
        echo "Commit failed. Please check your message and try again."
        return 1
        ;;
      r|R)
        echo "Regenerating commit message..."
        commit_message="$(generate_commit_message)"
        ;;
      c|C)
        echo "Commit cancelled."
        return 1
        ;;
      *)
        echo "Invalid choice. Please try again."
        ;;
    esac
  done
}

docker_publish_ecr() {
  local IMAGE_NAME TAG

  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: docker_publish_ecr <image_name> <tag>"
    return 1
  fi

  IMAGE_NAME="$1"
  TAG="$2"

  docker build --platform linux/amd64 -t "$IMAGE_NAME:$TAG" .
  docker tag "$IMAGE_NAME:$TAG" "640539939441.dkr.ecr.us-east-1.amazonaws.com/$IMAGE_NAME:$TAG"
  docker push "640539939441.dkr.ecr.us-east-1.amazonaws.com/$IMAGE_NAME:$TAG"
}

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

gravious() {
  local sess dir_slug timestamp

  if [[ -n "$1" ]]; then
    sess="$1"
  else
    dir_slug="$(printf '%s' "${PWD#$HOME/}" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9._-' '-' | sed 's/^-*//; s/-*$//')"
    timestamp="$(date +"%Y%m%d-%H%M")"
    sess="${dir_slug}-${timestamp}"
  fi

  openclaw gateway status >/dev/null 2>&1 || openclaw gateway start
  openclaw tui --session "$sess"
}
