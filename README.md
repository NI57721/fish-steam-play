# steam-play
Launcher for Steam games with Fish completion for saved game names.

## Installation
Use [Fisher](https://github.com/jorgebucaran/fisher).
```sh
fisher install NI57721/fish-steam-play
```

## Usage
```fish
steam-play --id 620
steam-play 'Portal 2'
steam-play 'Portal 2' -novid
steam-play --id 620 -novid
```

`steam-play --id <number> [options...]` launches a game by its Steam app ID.
It queries the Steam Store for the game name and saves it for future launches
and Fish completion. If the lookup fails, the game still launches by ID.

`steam-play <game name> [options...]` launches a game using its saved name.
Names must match exactly; quote names containing spaces. Additional arguments
are passed unchanged to `steam -applaunch <id>`.
If multiple saved IDs share a name, use `--id` to choose the game.

Run `steam-play --help` (or `steam-play -h`) to display help. With no arguments,
`steam-play` also displays help.

`steam-play <Tab>` completes `--id`, `--help`, and saved game names.
`steam-play --id <Tab>` completes saved app IDs with game names as descriptions.
Completion reads only saved data and never makes network requests.
The old full game list and `--fetch` option are no longer used.

## State directory
Game names are stored in `$XDG_STATE_HOME/steam-play/games.json` as an object
mapping app IDs to names (for example, `{"620": "Portal 2"}`).
When `XDG_STATE_HOME` is unset or empty, `$HOME/.local/state/steam-play` is used.
Set `STEAM_PLAY_STATE` to override the state directory.

## Dependencies
- [steam](https://store.steampowered.com/about/)
- [Fish](https://fishshell.com/)
- [curl](https://curl.se/)
- [jq](https://jqlang.org/)

## Licence
`fish-steam-play` is MIT licensed. See [LICENSE](LICENSE).
