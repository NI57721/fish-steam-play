#!/usr/bin/env fish

function __fish_steam_play_ids
  set --local path (__steam_play_state_dir)
  set --local cache "$path/cache"
  set -l token (commandline -ct)

  if test (string length -- "$token") -lt 3
    return
  end

  if ! test -f "$path/app-list.json"
    __steam_play_fetch
  end

  if ! test -f "$cache"
    __steam_play_cache
  end

  cat "$cache"
end

complete --no-files --command steam-play --keep-order --arguments '(__fish_steam_play_ids)'

