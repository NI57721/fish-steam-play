#!/usr/bin/env fish

function steam-play
  if not set --query argv[1]
    __steam_play_help
    return 0
  end

  switch "$argv[1]"
    case -h --help
      __steam_play_help
    case --id
      __steam_play_by_id $argv[2..]
    case '*'
      __steam_play_by_name $argv
  end
end

function __steam_play_by_id
  if not set --query argv[1]; or not string match --quiet --regex '^[0-9]+$' -- "$argv[1]"
    printf 'steam-play: --id requires a numeric app ID.\n' >&2
    return 1
  end
  set --local id (string replace --regex '^0+' '' -- "$argv[1]")
  set --erase argv[1]
  __steam_play_remember "$id"
  steam -applaunch "$id" $argv
end

function __steam_play_by_name
  set --local name "$argv[1]"
  set --local path (__steam_play_state_dir)
  set --local ids
  if test -f "$path/games.json"
    set ids (jq --raw-output --arg name "$name" 'to_entries[] | select(.value == $name) | .key' "$path/games.json")
  end
  if test (count $ids) -ne 1
    printf 'steam-play: unknown or ambiguous game name: %s. Use --id to launch it.\n' "$name" >&2
    return 1
  end
  set --erase argv[1]
  steam -applaunch "$ids[1]" $argv
end

function __steam_play_state_dir
  if set --query STEAM_PLAY_STATE; and test -n "$STEAM_PLAY_STATE"
    printf '%s\n' "$STEAM_PLAY_STATE"
  else if set --query XDG_STATE_HOME; and test -n "$XDG_STATE_HOME"
    printf '%s/steam-play\n' "$XDG_STATE_HOME"
  else
    printf '%s/.local/state/steam-play\n' "$HOME"
  end
end

function __steam_play_remember --argument-names id
  set --local path (__steam_play_state_dir)
  set --local response (curl --fail --silent --show-error --connect-timeout 5 --max-time 15 "https://store.steampowered.com/api/appdetails?appids=$id&filters=basic")
  if test $status -ne 0
    printf 'steam-play: could not fetch game name; launching by ID.\n' >&2
    return 1
  end
  set --local game (printf '%s\n' $response | jq --compact-output --exit-status --arg id "$id" '.[$id] | select(.success == true) | .data | select(.name | type == "string" and length > 0) | {($id): .name}')
  if test $status -ne 0
    printf 'steam-play: no game name returned; launching by ID.\n' >&2
    return 1
  end
  mkdir --parent -- "$path"; or return 1
  set --local temporary (mktemp "$path/games.XXXXXX"); or return 1
  set --local saved '{}'
  if test -f "$path/games.json"
    set saved (cat "$path/games.json")
  end
  printf '%s\n' "$saved" | jq --argjson game "$game" '. + $game' > "$temporary"
  and mv -- "$temporary" "$path/games.json"
end

function __steam_play_help
  printf '%s\n' 'Usage:
  steam-play --id <number> [options...]
  steam-play <game name> [options...]

Launch a Steam game and pass additional arguments to it.
Launching by ID fetches and saves the game name for later launches and completion.
Quote game names containing spaces. Names must match the saved name exactly.

Options:
  --id <number>        Launch by Steam app ID and save its name.
  -h, --help           Display this help message.

Environment:
  STEAM_PLAY_STATE     Override the state directory.
                      Default: $XDG_STATE_HOME/steam-play
                      (or $HOME/.local/state/steam-play).'
end
