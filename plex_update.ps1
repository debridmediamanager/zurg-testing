# PLEX PARTIAL SCAN script or PLEX UPDATE script
# When zurg detects changes, it can trigger this script IF your config.yml contains
# on_library_update: & { & '.\plex_update.ps1' $args }

# this uses python3
# docker compose exec zurg apk add python3
# sudo apt install python3

$plex_url = "http://yourplexip:32400" # If you're using zurg inside a Docker container, by default it is 172.17.0.1:32400
$token = "yourplextoken" # open Plex in a browser, open dev console and copy-paste this: window.localStorage.getItem("myPlexAccessToken")
$zurg_mount = "/mnt/zurg" # replace with your zurg mount path, ensure this is what Plex sees

# Get the list of section IDs
$section_ids = (Invoke-WebRequest -Uri "$plex_url/library/sections" -Headers @{"X-Plex-Token" = $token} -Method Get).Content |
    Select-Xml -XPath "//Directory/@key" |
    ForEach-Object { $_.Node.Value }

foreach ($arg in $args) {
    $modified_arg = "$zurg_mount/$arg"
    Write-Host "Detected update on: $arg"
    Write-Host "Absolute path: $modified_arg"

    $encoded_arg = [System.Web.HttpUtility]::UrlEncode($modified_arg)

    if ([string]::IsNullOrEmpty($encoded_arg)) {
        Write-Host "Error: Encoded argument is empty. Check the input or encoding process."
        continue
    }

    foreach ($section_id in $section_ids) {
        $final_url = "${plex_url}/library/sections/${section_id}/refresh?path=${encoded_arg}&X-Plex-Token=${token}"

        Write-Host "Encoded argument: $encoded_arg"
        Write-Host "Section ID: $section_id"
        Write-Host "Final URL: $final_url"

        Invoke-WebRequest -Uri $final_url -Method Get
    }
}

Write-Host "All updated sections refreshed"
