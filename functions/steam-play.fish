#!/usr/bin/env fish

function steam-play
  argparse 'f/fetch' 'h/help' -- $argv
    or return 1
  set --local arg (string join ' ' -- $argv)

  if set --query _flag_help; or test -z "$arg"
    __steam_play_help
    return 0
  end

  if set --query _flag_fetch
    __steam_play_fetch
    __steam_play_cache
    return 0
  end

  steam "steam://rungameid/$arg"
end

function __steam_play_state_dir
  if set --query STEAM_PLAY_STATE
    printf "$STEAM_PLAY_STATE"
  else
    printf "$XDG_STATE_HOME/steam-play"
  end
end

function __steam_play_fetch
  set --local STEAM_API_URI https://api.steampowered.com/ISteamApps/GetAppList/v0002/
  set --local path (__steam_play_state_dir)

  mkdir --parent "$path"
  curl --silent "$STEAM_API_URI" > "$path/app-list.json"
end

function __steam_play_cache
  set --local path (__steam_play_state_dir)
  set --local cache "$path/cache"

  if test -f "$path/app-list.json"
    jq -rc '.applist.apps[] | "\(.appid)\\t\(.name)" ' "$path/app-list.json" > "$cache"
  end
end

function __steam_play_help
  printf "Usage:
  steam-play [options] <id|title>

Launch a Steam game specified by its app ID.
Completion by ID or title is available.
The game list is fetched automatically on the first run, or when -f / --fetch is
used explicitly.  
Note: Completion is not triggered until at least 3 characters are typed, to
avoid hanging due to the large number of entries.

Options:
  -f, --fetch           Fetch the app list of games explicitly.
  -h, --help            Display this help message.

Environment Variable:
  STEAM_PLAY_STATE      Path to store or read the app list.
                        Defaults to: \$XDG_STATE_HOME/steam-play
"
end

