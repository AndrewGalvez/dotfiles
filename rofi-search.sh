#!/bin/bash

CACHE_FILE="$HOME/.cache/rofi-search-history"
MAX_HISTORY=50

touch "$CACHE_FILE"

# Format: "query" (no timestamps shown to user, but you could add them)
history=$(tac "$CACHE_FILE" 2>/dev/null | awk '!seen[$0]++')
query=$(echo "$history" | rofi -theme /usr/share/rofi/themes/sidebar.rasi -dmenu -p "Search" -theme-str 'window {width: 50%;}')

[ -z "$query" ] && exit 0

# Update history
sed -i "\|^${query}$|d" "$CACHE_FILE" 2>/dev/null
echo "$query" >> "$CACHE_FILE"
tail -n "$MAX_HISTORY" "$CACHE_FILE" > "$CACHE_FILE.tmp"
mv "$CACHE_FILE.tmp" "$CACHE_FILE"

# Add "! " if needed
if [[ ! "$query" =~ ^! ]]; then
    query="! $query"
fi

firefox "https://duckduckgo.com/?q=$(echo "$query" | jq -sRr @uri)"
