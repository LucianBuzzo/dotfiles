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

bindkey -v
export KEYTIMEOUT=1

HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=50000
SAVEHIST=50000

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

autoload -Uz colors && colors

if command -v eza >/dev/null 2>&1; then
  alias ll='eza -alh --group-directories-first'
else
  alias ll='ls -alhG'
fi

alias gs='git status'
alias reloadzsh='source ~/.zshrc'
alias python='python3'

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
  eval "$(atuin init zsh)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
