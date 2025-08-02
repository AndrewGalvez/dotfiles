hyprctl clients -j | jq -r '.[] | select(.class | contains("steam")) | select(.title != "Steam") | .title' | sed 's/ - Steam$//'
