Add-Type -AssemblyName System.Web

# Plex server details - EDIT BELOW
$plexUrl = "http://YourPlexIP:32400"
$plexToken = "YourTokenHere"

# Function to URL encode a string
function UrlEncode($value) {
    [System.Web.HttpUtility]::UrlEncode($value)
}

# Example path to a log - EDIT BELOW
Start-Transcript -Path "C:\Path\To\zurg-testing\plex_update.log"

# Function to trigger library update for a specific folder
function UpdateFolder($folder, $directory) {
    $section_ids = (Invoke-WebRequest -Uri "$plexUrl/library/sections" -Headers @{"X-Plex-Token" = $plexToken} -UseBasicParsing -Method Get).Content |
                   Select-Xml -XPath "//Directory/@key" |
                   ForEach-Object { $_.Node.Value }

    Write-Host "IDs: $section_ids"
    Write-Host "Path: $directory\$folder"
    $encodedPath = UrlEncode("$directory\$folder")

    try {
        # Trigger the library update for the specific folder
        foreach ($section_id in $section_ids) {
            $final_url = "${plexUrl}/library/sections/${section_id}/refresh?path=${encodedPath}&X-Plex-Token=${plexToken}"
            
            Write-Host "Encoded argument: $encodedPath"
            Write-Host "Section ID: $section_id"
            Write-Host "Final URL: $final_url"

            Invoke-WebRequest -Uri $final_url -UseBasicParsing -Method Get

            Write-Host "Partial refresh request successful for: $($folder.FullName)"
        }
    } catch {
        Write-Host "Error refreshing: $($folder.FullName)"
        Write-Host "Error details: $_"
    }
}

# Function to trigger library updates for all folders modified within the last 5 minutes
function UpdateFoldersWithinLast5Minutes($directories) {
    $startTime = (Get-Date).AddMinutes(-5)

    Start-Sleep -Seconds 5

    foreach ($directory in $directories) {
        $folders = Get-ChildItem -Path $directory -Directory | Where-Object { $_.LastWriteTime -gt $startTime }

        if ($folders.Count -gt 0) {
            Write-Host "Folders found in $directory modified within the last 5 minutes:"
            
            # Introduce a 10-second delay before triggering the library update for each folder
            Start-Sleep -Seconds 10

            foreach ($folder in $folders) {
                UpdateFolder $folder $directory
            }
        } else {
            Write-Host "No folders found in $directory modified within the last 5 minutes."
        }
    }
}

# Example usage - update folders modified within the last 5 minutes - EDIT BELOW
$directoriesToUpdate = @("T:\movies","T:\anime","T:\shows")
UpdateFoldersWithinLast5Minutes $directoriesToUpdate

Write-Host "All updated sections partially refreshed."
