Add-Type -AssemblyName System.Web

# Plex server details - EDIT BELOW
$plexUrl = "http://plex-ip:32400"
$plexToken = "your-plex-token"

# Replace with your mount - EDIT BELOW
$mount = "Z:"

$path = $args[2]

# Set how many times you want the script to retry if the folder has not yet been added
$retryAmount = 30

# Function to URL encode a string
function UrlEncode($value) {
    [System.Web.HttpUtility]::UrlEncode($value)
}

# Example path to a log - EDIT BELOW
Start-Transcript -Path "C:\Zurg\zurg-testing\logs\plex_update.log"

# Function to trigger library update for a specific folder
function UpdateFolder($retries) {
    $section_ids = (Invoke-WebRequest -Uri "$plexUrl/library/sections" -Headers @{"X-Plex-Token" = $plexToken} -UseBasicParsing -Method Get).Content |
    Select-Xml -XPath "//Directory/@key" |
    ForEach-Object { $_.Node.Value }

    Write-Host "IDs: $section_ids"
    Write-Host "Path: $ $mount/$path"
    $encodedPath = UrlEncode("$mount/$path")

    if (Test-Path $mount/$path) {
        Write-Host "Path exists"
        # Trigger the library update for the specific folder
        foreach ($section_id in $section_ids) {
        $final_url = "${plexUrl}/library/sections/${section_id}/refresh?path=${encodedPath}&X-Plex-Token=${plexToken}"

        Write-Host "Encoded argument: $encodedPath"
        Write-Host "Section ID: $section_id"
        Write-Host "Final URL: $final_url"

        $request = Invoke-WebRequest -Uri $final_url -UseBasicParsing -Method Get

        Write-Host $request

        Write-Host "Partial refresh request successful for: $($path)"
        }
    } else {
        if (!$retries -eq 0) {
            $retries--
            Write-Host "Retries: $retries"
            Write-Host "Path not found. Trying again..."
            Start-Sleep -Seconds 1
            UpdateFolder $retries
        }
        else {
            Write-Host "The path does not exist."
        }
    }
}

UpdateFolder $retryAmount
