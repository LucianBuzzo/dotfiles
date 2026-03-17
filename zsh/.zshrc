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

ZDOTFILES_DIR="${${(%):-%N}:A:h}"
source "$ZDOTFILES_DIR/.zsh_extras.zsh"

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
  eval "$(atuin init zsh)"
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
