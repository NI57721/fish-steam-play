# steam-play
Launcher for Steam games with Fish completion by title and ID.
![screenshot](https://raw.githubusercontent.com/NI57721/fish-steam-play/assets/screenshot.gif)

## Installation
Use [Fisher](https://github.com/jorgebucaran/fisher).
```sh
$ fisher install NI57721/fish-steam-play
```

## Usage
`steam-play [options] <id|title>`

Launch a Steam game specified by its app ID.  
Completion by ID or title is available after fetching the app list by -f/--fetch  
option.  
Note: Completion is not triggered until at least 3 characters are typed, to  
avoid hanging due to the large number of entries.

### `steam-play -f / steam-play --fetch`
Fetch the list of Steam games. Required to enable completion by ID or title.

## Environment Variable
### STEAM_PLAY_STATE
Path to store or read the app list.  
Defaults to: `$XDG_STATE_HOME/steam-play`

## Dependencies
- [steam](https://archlinux.org/packages/multilib/x86_64/steam/)
- [jq](https://github.com/jqlang/jq)

## Licence
`fish-steam-play` is MIT licensed. See [LICENSE](LICENSE).

