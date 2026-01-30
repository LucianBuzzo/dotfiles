#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

YES=0
FORCE=0
NON_INTERACTIVE=0
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage: ./setup.sh [options]

Options:
  -y, --yes              Accept defaults and skip prompts where possible.
  -f, --force            Overwrite existing files by backing them up first.
  -n, --non-interactive  Never prompt (implies skipping optional inputs).
  -d, --dry-run          Show what would change without writing.
  -h, --help             Show this help.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes)
      YES=1
      NON_INTERACTIVE=1
      ;;
    -f|--force)
      FORCE=1
      ;;
    -n|--non-interactive)
      NON_INTERACTIVE=1
      ;;
    -d|--dry-run)
      DRY_RUN=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

is_macos() {
  [ "$(uname -s)" = "Darwin" ]
}

is_linux() {
  [ "$(uname -s)" = "Linux" ]
}

info() {
  printf "\033[38;5;240m%s\033[0m\n" "$1"
}

success() {
  printf "\033[38;5;64m%s\033[0m\n" "$1"
}

warn() {
  printf "\033[38;5;214m%s\033[0m\n" "$1"
}

confirm() {
  if [ "$YES" -eq 1 ] || [ "$NON_INTERACTIVE" -eq 1 ]; then
    return 0
  fi
  local prompt="$1"
  local reply
  read -r -p "$prompt [y/N] " reply
  case "$reply" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

backup_path() {
  local path="$1"
  local stamp
  stamp="$(date +%Y%m%d%H%M%S)"
  echo "${path}.bak.${stamp}"
}

dry() {
  if [ "$DRY_RUN" -eq 1 ]; then
    info "[dry-run] $1"
    return 0
  fi
  return 1
}

link_path() {
  local origin="$1"
  local dest="$2"
  local origin_path="$ROOT_DIR/$origin"

  if [ ! -e "$origin_path" ]; then
    warn "Missing source: $origin_path (skipping)"
    return 1
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ "$dest" -ef "$origin_path" ]; then
      info "Already linked: $dest"
      return 0
    fi

    if [ "$FORCE" -eq 1 ] || confirm "Overwrite $(basename "$dest")?"; then
      local backup
      backup="$(backup_path "$dest")"
      if dry "Would back up $dest to $backup"; then
        :
      else
        mv "$dest" "$backup"
        info "Backed up to $backup"
      fi
    else
      warn "Skipped: $dest"
      return 0
    fi
  fi

  mkdir -p "$(dirname "$dest")"
  if dry "Would link $origin_path -> $dest"; then
    :
  else
    ln -s "$origin_path" "$dest"
    success "Linked $dest"
  fi
}

ensure_dir() {
  local dir="$1"
  if [ -d "$dir" ]; then
    info "Exists: $dir"
    return 0
  fi

  if [ -L "$dir" ]; then
    if [ "$FORCE" -eq 1 ] || confirm "Replace broken link $(basename "$dir")?"; then
      local backup
      backup="$(backup_path "$dir")"
      if dry "Would back up $dir to $backup"; then
        :
      else
        mv "$dir" "$backup"
        info "Backed up to $backup"
      fi
    else
      warn "Skipped: $dir"
      return 0
    fi
  fi

  if dry "Would create $dir"; then
    :
  else
    mkdir -p "$dir"
    success "Created $dir"
  fi
}

ensure_git_config() {
  local key="$1"
  local value="$2"
  if ! git config --global --get "$key" >/dev/null 2>&1; then
    if dry "Would set git $key to \"$value\""; then
      :
    else
      git config --global "$key" "$value"
      success "Set git $key"
    fi
  else
    info "Git $key already set"
  fi
}

setup_bash() {
  info "Bash: linking profile and input settings"
  link_path "bash/.bash_profile" "$HOME_DIR/.bash_profile"
  link_path ".inputrc" "$HOME_DIR/.inputrc"
}

setup_vim() {
  info "Vim: linking configs"
  link_path "vim/.vimrc" "$HOME_DIR/.vimrc"
  ensure_dir "$HOME_DIR/.vimbackups"
  link_path "vim" "$HOME_DIR/.config/nvim"
}

setup_vscode() {
  info "VS Code: linking settings and extensions"
  if [ -x "$ROOT_DIR/vscode/install.sh" ]; then
    if [ "$DRY_RUN" -eq 1 ]; then
      info "[dry-run] Would run vscode/install.sh"
    else
      "$ROOT_DIR/vscode/install.sh"
    fi
  else
    warn "VS Code installer not found, skipping"
  fi
}

setup_git() {
  if ! command -v git >/dev/null 2>&1; then
    warn "Git not found, skipping git config"
    return 0
  fi

  info "Git: configuring defaults"
  ensure_git_config "core.editor" "vim"
  ensure_git_config "init.defaultBranch" "main"

  if ! git config --global --get user.name >/dev/null 2>&1; then
    if [ -n "${GIT_NAME:-}" ]; then
      if dry "Would set git user.name from GIT_NAME"; then
        :
      else
        git config --global user.name "$GIT_NAME"
        success "Set git user.name from GIT_NAME"
      fi
    elif [ "$NON_INTERACTIVE" -eq 0 ]; then
      read -r -p "Git user.name (leave blank to skip): " name
      if [ -n "$name" ]; then
        if dry "Would set git user.name to \"$name\""; then
          :
        else
          git config --global user.name "$name"
          success "Set git user.name"
        fi
      fi
    else
      warn "Git user.name not set"
    fi
  fi

  if ! git config --global --get user.email >/dev/null 2>&1; then
    if [ -n "${GIT_EMAIL:-}" ]; then
      if dry "Would set git user.email from GIT_EMAIL"; then
        :
      else
        git config --global user.email "$GIT_EMAIL"
        success "Set git user.email from GIT_EMAIL"
      fi
    elif [ "$NON_INTERACTIVE" -eq 0 ]; then
      read -r -p "Git user.email (leave blank to skip): " email
      if [ -n "$email" ]; then
        if dry "Would set git user.email to \"$email\""; then
          :
        else
          git config --global user.email "$email"
          success "Set git user.email"
        fi
      fi
    else
      warn "Git user.email not set"
    fi
  fi
}

info "Dotfiles setup wizard"
if is_macos; then
  info "Detected macOS"
elif is_linux; then
  info "Detected Linux"
else
  warn "Unknown OS, continuing anyway"
fi

setup_bash
setup_vim
setup_vscode
setup_git

success "Setup complete. Reload your shell to pick up changes."
