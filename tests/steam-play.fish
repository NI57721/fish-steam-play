#!/usr/bin/env fish

source (status dirname)/../functions/steam-play.fish
set --global fish_complete_path
complete --erase --command steam-play
source (status dirname)/../completions/steam-play.fish
set --global STEAM_PLAY_STATE (mktemp -d)

set --global lookup_name 'Portal 2'

function steam
  set --global launched $argv
end
function curl
  if set --query lookup_failed
    return 22
  end
  jq --null-input --arg name "$lookup_name" '{"620": {success: true, data: {name: $name}}}'
end
function check --argument-names description
  if not eval $argv[2..]
    printf 'FAIL: %s\n' "$description" >&2
    exit 1
  end
end

for help_args in '' -h --help
  set --erase launched
  set --global output (steam-play (string match --regex '.+' -- "$help_args"))
  check 'help succeeds' 'test $status -eq 0'
  check 'help displays usage' 'string match --quiet --regex -- "^Usage:" $output'
  check 'help does not launch Steam' 'not set --query launched'
end

steam-play --id 00620 -novid 'two words' --help
check 'ID argument count' 'test (count $launched) -eq 5'
check 'ID and arguments preserved' 'test "$launched[1]" = -applaunch; and test "$launched[2]" = 620; and test "$launched[3]" = -novid; and test "$launched[4]" = "two words"; and test "$launched[5]" = --help'
check 'game name saved' 'test (jq -r .\"620\" "$STEAM_PLAY_STATE/games.json") = "Portal 2"'
steam-play 'Portal 2' -novid 'two words'
check 'name argument count' 'test (count $launched) -eq 4'
check 'saved name launches with arguments' 'test "$launched[1]" = -applaunch; and test "$launched[2]" = 620; and test "$launched[3]" = -novid; and test "$launched[4]" = "two words"'
check 'name completion' 'string match -q -- "*Portal*2*" (complete -C "steam-play Por")'
set --global initial_completions (complete -C 'steam-play ')
check 'initial completion includes ID option' 'string match -q -- "--id*" $initial_completions'
check 'initial completion includes help option' 'string match -q -- "--help*" $initial_completions'
check 'initial completion includes saved name' 'string match -q -- "*Portal*2*" $initial_completions'
check 'ID completion shows game name' 'contains -- (printf "620\tPortal 2") (complete -C "steam-play --id ")'
check 'ID completion filters by ID prefix' 'contains -- (printf "620\tPortal 2") (complete -C "steam-play --id 6")'
check 'no completions after ID argument' 'test -z (complete -C "steam-play --id 620 " | string collect)'
check 'no names after game argument' 'test -z (complete -C "steam-play \'Portal 2\' Por" | string collect)'
steam-play Missing 2>/dev/null
check 'unknown name fails' 'test $status -eq 1'
set --erase launched
steam-play --id 2>/dev/null
check 'missing ID fails' 'test $status -eq 1'
check 'missing ID does not launch Steam' 'not set --query launched'
steam-play --id invalid 2>/dev/null
check 'invalid ID fails' 'test $status -eq 1'
printf '%s\n' '{"730": "Counter-Strike 2"}' > "$STEAM_PLAY_STATE/games.json"
steam-play --id 620
check 'new entry preserves existing entries' 'test (jq length "$STEAM_PLAY_STATE/games.json") -eq 2'
set --global lookup_name 'Portal 2 Updated'
steam-play --id 620
check 'name is updated' 'test (jq -r .\"620\" "$STEAM_PLAY_STATE/games.json") = "Portal 2 Updated"'
check 'same ID updates without duplicates' 'test (jq length "$STEAM_PLAY_STATE/games.json") -eq 2'
printf '%s\n' '{"620": "Portal 2 Updated", "730": "Portal 2 Updated"}' > "$STEAM_PLAY_STATE/games.json"
set --erase launched
steam-play 'Portal 2 Updated' 2>/dev/null
check 'ambiguous name fails' 'test $status -eq 1'
check 'ambiguous name does not launch Steam' 'not set --query launched'
set --global lookup_failed 1
steam-play --id 730 -console 2>/dev/null
check 'lookup failure still launches' 'test "$launched" = "-applaunch 730 -console"'
check 'lookup failure preserves cache' 'test (jq -r .\"620\" "$STEAM_PLAY_STATE/games.json") = "Portal 2 Updated"'
set --global STEAM_PLAY_STATE "$STEAM_PLAY_STATE/empty"
check 'empty state has no completions' 'test -z (__fish_steam_play_names | string collect)'
set --erase STEAM_PLAY_STATE
set --local --export XDG_STATE_HOME ''
check 'XDG fallback' 'test (__steam_play_state_dir) = "$HOME/.local/state/steam-play"'
printf 'All tests passed.\n'
