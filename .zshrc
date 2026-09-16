# --- Zinit install ---
export ZINIT_HOME="$HOME/.local/share/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# --- Completion (cached) ---
autoload -Uz compinit
if [[ -n "$ZSH_COMPDUMP" && -f "$ZSH_COMPDUMP" ]]; then
  compinit -C
else
  compinit
fi

# autosuggestions грузится синхронно — нужен до первого промпта
zinit light zsh-users/zsh-autosuggestions

# --- Plugins (turbo mode) ---
zinit ice wait"0"; zinit light zsh-users/zsh-completions
zinit ice wait"0"; zinit light hlissner/zsh-autopair
zinit ice wait"0"; zinit snippet OMZP::git
# fzf/zoxide могут стоять системно (Linux, dev-контейнер) — тогда zinit их не тянет
command -v fzf >/dev/null || { zinit ice wait"1"; zinit light junegunn/fzf }
command -v zoxide >/dev/null || { zinit ice wait"1" as"program"; zinit light ajeetdsouza/zoxide }
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
# syntax highlighting должен быть последним
zinit ice wait"0"; zinit light zsh-users/zsh-syntax-highlighting

# starship может отсутствовать (голый контейнер) — тогда остаётся встроенный промпт
command -v starship >/dev/null && eval "$(starship init zsh)"

alias ll="ls -lah"

# FZF поиск по истории — лучше стандартного Ctrl+R
fzf-history-widget() {
  local selected
  selected=$(fc -rl 1 | fzf --height 40% --reverse --border --query "$LBUFFER") || return
  LBUFFER=$(echo "$selected" | sed 's/^[ ]*[0-9]\+[ ]*//')
}
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

# Быстрый переход по директориям
fzf-cd-widget() {
  local dir
  dir=$(zoxide query -l | fzf --height 40% --reverse --border) || return
  cd "$dir"
}
zle -N fzf-cd-widget
bindkey '^G' fzf-cd-widget

# --- History ---
HISTFILE="$HOME/.zsh_history"
# В dev-контейнере ~/.shell-history — именованный том, история переживает пересборку
[ -d "$HOME/.shell-history" ] && HISTFILE="$HOME/.shell-history/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# --- mise (версии ruby/node/python на проект) ---
export PATH="$HOME/.local/bin:$PATH"
command -v mise >/dev/null && eval "$(mise activate zsh)"

# --- Локальные настройки конкретной машины ---
# Секреты, токены и пути, специфичные для хоста, живут здесь и в репозиторий не попадают
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
