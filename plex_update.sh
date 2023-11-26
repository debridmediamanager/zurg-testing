#!/bin/bash

# if you are missing xmllint
# sudo apt install libxml2-utils

plex_url="http://yourplexip:32400"
token="yourplextoken"
zurg_mount="/mnt/zurg" # replace with your zurg mount

# Get the list of section IDs
section_ids=$(curl -sLX GET "$plex_url/library/sections" -H "X-Plex-Token: $token" | xmllint --xpath "//Directory/@key" - | sed 's/key="//g' | tr '"' '\n')

for arg in "$@"
do
    modified_arg="$zurg_mount/$arg"
    echo "Detected update on: $arg"
    echo "Absolute path: $modified_arg"

    encoded_arg=$(echo -n "$modified_arg" | python3 -c "import sys, urllib.parse as ul; print (ul.quote_plus(sys.stdin.read()))")

    if [ -z "$encoded_arg" ]; then
        echo "Error: Encoded argument is empty. Check the input or encoding process."
        continue
    fi

    for section_id in $section_ids
    do
        final_url="${plex_url}/library/sections/${section_id}/refresh?path=${encoded_arg}&X-Plex-Token=${token}"

        echo "Encoded argument: $encoded_arg"
        echo "Section ID: $section_id"
        echo "Final URL: $final_url"

        curl -s "$final_url"
    done
done

echo "All updated sections refreshed"

# credits to godver3
