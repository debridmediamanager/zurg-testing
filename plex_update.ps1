Add-Type -AssemblyName System.Web

$plex_url = "http://yourplexip:32400"
$token = "YourPlexTokenHere"
$zurg_mount = "YourZurgMountLetterHere:"

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
