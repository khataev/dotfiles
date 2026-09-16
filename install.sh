#!/usr/bin/env bash
# Раскладывает конфиги симлинками на этот репозиторий.
# Запускается вручную на хосте и автоматически в dev-контейнере
# (VS Code: настройка dotfiles.installCommand).
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$DOTFILES/$1" dst="$HOME/$2"

  # Уже наш симлинк — ничего не делаем (скрипт идемпотентен)
  [ "$(readlink -f "$dst" 2>/dev/null)" = "$src" ] && return

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP/$(dirname "$2")"
    mv "$dst" "$BACKUP/$2"
    echo "backup: ~/$2 -> $BACKUP/$2"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "link:   ~/$2 -> $src"
}

link .zshrc .zshrc
link starship.toml .config/starship.toml

# ~/.gitconfig не линкуем: Dev Containers пишет в него напрямую при копировании
# конфига с клиента, и через симлинк это затёрло бы файл репозитория.
# Вместо этого подключаем репозиторный gitconfig через include — ~/.gitconfig
# остаётся локальным файлом для машинного (credential helper и т.п.).
if ! git config --global --get-all include.path 2>/dev/null | grep -qx "$DOTFILES/gitconfig"; then
  git config --global --add include.path "$DOTFILES/gitconfig"
  echo "git:    include.path = $DOTFILES/gitconfig"
fi

# В контейнере zsh обычно не является шеллом по умолчанию для remoteUser
if [ -n "${REMOTE_CONTAINERS:-}${CODESPACES:-}" ] && command -v zsh >/dev/null; then
  current="$(getent passwd "$(id -un)" | cut -d: -f7)"
  if [ "$current" != "$(command -v zsh)" ]; then
    sudo chsh -s "$(command -v zsh)" "$(id -un)" 2>/dev/null \
      || chsh -s "$(command -v zsh)" 2>/dev/null \
      || echo "warn: не удалось сменить шелл на zsh — задайте terminal.integrated.defaultProfile.linux"
  fi
fi

echo 'done. Машинно-специфичное (токены, пути) — в ~/.zshrc.local'
