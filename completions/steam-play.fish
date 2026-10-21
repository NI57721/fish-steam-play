#!/usr/bin/env fish

function __fish_steam_play_names
  functions --query steam-play; or functions steam-play > /dev/null
  set --local path (__steam_play_state_dir)
  if test -f "$path/games.json"
    jq --raw-output 'to_entries[] | [.value, .key] | @tsv' "$path/games.json"
  end
end

function __fish_steam_play_ids
  functions --query steam-play; or functions steam-play > /dev/null
  set --local path (__steam_play_state_dir)
  if test -f "$path/games.json"
    jq --raw-output 'to_entries[] | [.key, .value] | @tsv' "$path/games.json"
  end
end

complete --command steam-play --no-files
complete --command steam-play --condition 'set -l words (commandline -opc); test (count $words) -eq 1; or begin; test (count $words) -eq 2; and test "$words[2]" = --id; end' --long-option id --require-parameter --arguments '(__fish_steam_play_ids)' --description 'Launch by Steam app ID and save its name'
complete --command steam-play --condition 'test (count (commandline -opc)) -eq 1' --short-option h --long-option help --description 'Display help'
complete --command steam-play --condition 'test (count (commandline -opc)) -eq 1' --arguments '(__fish_steam_play_names) --id\t"Launch by Steam app ID and save its name" --help\t"Display help"'
