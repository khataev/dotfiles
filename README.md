# dotfiles

Конфиги оболочки, общие для хоста и dev-контейнеров VS Code.

| Файл | Куда раскладывается |
| --- | --- |
| `.zshrc` | `~/.zshrc` |
| `starship.toml` | `~/.config/starship.toml` |
| `gitconfig` | `include.path` в `~/.gitconfig` (сам файл остаётся локальным) |

## Установка

```sh
git clone https://github.com/khataev/dotfiles.git ~/work/dotfiles
~/work/dotfiles/install.sh
```

Скрипт идемпотентен: существующие файлы переносит в `~/.dotfiles-backup/<timestamp>/`, затем ставит симлинки на репозиторий.

## Dev-контейнеры

В пользовательских настройках VS Code (`settings.json`):

```json
"dotfiles.repository": "https://github.com/khataev/dotfiles.git",
"dotfiles.targetPath": "~/dotfiles"
```

`install.sh` расширение находит и запускает само. `dotfiles.installCommand` не задавать с путём через `~` — тильда в проверке существования файла не раскрывается, и установка падает с кодом 126; если нужно явно, то `"install.sh"` без пути (команда выполняется из `targetPath`).

Настройка пользовательская, а не проектная, — применяется ко всем dev-контейнерам и не навязывает окружение коллегам.

От контейнера требуются только бинарники `zsh`, `git`, `curl` (и, по желанию, `starship`, `fzf`, `zoxide` — иначе `.zshrc` соберёт fzf/zoxide через zinit, а промпт останется встроенным). Плагины zinit докачиваются при первом запуске оболочки.

## Что сюда не кладём

- **Секреты и машинно-специфичные пути** (токены, `credential.helper`, обёртки над `gh`) — в `~/.zshrc.local`, он подключается последней строкой `.zshrc` и в репозиторий не попадает.
- **Машинное из `~/.gitconfig`** (`credential.helper` с локальными путями, ключи подписи) — файл не линкуется, репозиторный `gitconfig` подключается в него через `include.path`. ssh-agent и credential helper в контейнер пробрасывает сам Dev Containers.
- **`.zsh_history`** — история привязана к путям конкретной машины.
