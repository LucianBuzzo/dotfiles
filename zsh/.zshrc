autoload -Uz compinit
compinit

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt EXTENDED_GLOB

export KEYTIMEOUT=1

HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=50000
SAVEHIST=50000

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

autoload -Uz colors && colors

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

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

gravious() {
  if ! command -v hermes >/dev/null 2>&1; then
    echo "gravious: hermes not installed, switching to lite mode"
    codex --yolo "$@"
    return $?
  fi

  hermes "$@" --yolo
}

if command -v eza >/dev/null 2>&1; then
  alias ll='eza -alh --group-directories-first'
else
  alias ll='ls -alhG'
fi

alias gs='git status'
alias reloadzsh='source ~/.zshrc'
alias python='python3'

ZVM_CURSOR_STYLE_ENABLED=true
ZVM_INIT_MODE=sourcing
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM

zvm_config() {
  ZVM_NORMAL_MODE_CURSOR="$(zvm_cursor_style "$ZVM_NORMAL_MODE_CURSOR")"
  ZVM_INSERT_MODE_CURSOR="$(zvm_cursor_style "$ZVM_INSERT_MODE_CURSOR")"
}

zsh_vi_mode_paths=()

if [ -n "${ZSH_VI_MODE_PLUGIN_PATH:-}" ]; then
  zsh_vi_mode_paths+=("$ZSH_VI_MODE_PLUGIN_PATH")
fi

zsh_vi_mode_paths+=(
  "/opt/homebrew/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
  "/usr/local/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
  "/usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
  "/usr/share/zsh/site-contrib/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
  "$HOME/.zsh-vi-mode/zsh-vi-mode.plugin.zsh"
)

for candidate in "${zsh_vi_mode_paths[@]}"; do
  if [ -s "$candidate" ]; then
    source "$candidate"
    break
  fi
done
unset zsh_vi_mode_paths

if ! typeset -f zvm_init >/dev/null 2>&1; then
  bindkey -v
fi

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

nvm_paths=(
  "$NVM_DIR/nvm.sh"
  "/opt/homebrew/opt/nvm/nvm.sh"
  "/usr/local/opt/nvm/nvm.sh"
)

for candidate in "${nvm_paths[@]}"; do
  if [ -s "$candidate" ]; then
    source "$candidate"
    break
  fi
done
unset nvm_paths

if [ -f /opt/homebrew/share/fzf/shell/completion.zsh ]; then
  source /opt/homebrew/share/fzf/shell/completion.zsh
fi

if [ -f /opt/homebrew/share/fzf/shell/key-bindings.zsh ]; then
  source /opt/homebrew/share/fzf/shell/key-bindings.zsh
fi

if [ -f /usr/local/share/fzf/shell/completion.zsh ]; then
  source /usr/local/share/fzf/shell/completion.zsh
fi

if [ -f /usr/local/share/fzf/shell/key-bindings.zsh ]; then
  source /usr/local/share/fzf/shell/key-bindings.zsh
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"

  _down_line_or_search_but_atuin_if_at_end() {
    if ! zle down-line-or-search -f nolast; then
      if [[ "$LASTWIDGET" = "up-line-or-history" ]]; then
        zle -I
        zle kill-buffer
      else
        case "$KEYMAP" in
          viins|vicmd) zle "atuin-search-$KEYMAP" ;;
          *) zle atuin-search ;;
        esac
      fi
    fi
  }

  zle -N down-line-or-search-but-atuin-if-at-end _down_line_or_search_but_atuin_if_at_end
  bindkey '^[[B' down-line-or-search-but-atuin-if-at-end
  bindkey '^[OB' down-line-or-search-but-atuin-if-at-end
  bindkey -M viins '^[[B' down-line-or-search-but-atuin-if-at-end
  bindkey -M viins '^[OB' down-line-or-search-but-atuin-if-at-end
  bindkey -M vicmd 'j' down-line-or-search-but-atuin-if-at-end
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"

  # starship's default zle-keymap-select uses `zle reset-prompt`, which
  # interacts badly with zsh-vi-mode and this multiline prompt. Use a light
  # redisplay instead so mode switches don't recurse or eat screen lines.
  if typeset -f starship_zle-keymap-select >/dev/null 2>&1; then
    starship_zle-keymap-select() {
      zle -R
    }
  fi
fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Hermes completion
if command -v hermes >/dev/null 2>&1; then
  source <(hermes completion zsh 2>/dev/null)
fi
