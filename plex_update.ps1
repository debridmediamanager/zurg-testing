Add-Type -AssemblyName System.Web

# Plex server details
$plexUrl = "http://plexip:32400"
$plexToken = "your-token"
$mount = "Z:"
$path = $args[2]
$retryAmount = 30

# Function to URL encode a string
function UrlEncode($value) {
    [System.Web.HttpUtility]::UrlEncode($value)
}

# Example path to a log
Start-Transcript -Path C:\Zurg\zurg-testing\logs\plex_update.log

Write-Host $args

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

# Function to trigger library updates for all folders modified within the last 5 minutes
function UpdateFoldersWithinLast5Minutes($directories, $retries) {
    $startTime = (Get-Date).AddMinutes(-5)
    $foundNewItem = $false

    foreach ($directory in $directories) {
        $folders = Get-ChildItem -Path $directory -Directory | Where-Object { $_.LastWriteTime -gt $startTime }

        if ($folders.Count -gt 0) {
            $foundNewItem = $true
            Write-Host "Folders found in $directory modified within the last 5 minutes:"

            foreach ($folder in $folders) {
                UpdateFolderLast5 $folder $directory
            }
        } else {
            Write-Host "No folders found in $directory modified within the last 5 minutes."
        }
    }

    if (!$foundNewItem) {
        if (!$retries -eq 0) {
            $retries--
            Write-Host "Retries: $retries"
            Write-Host "Trying again..."
            Start-Sleep -Seconds 1
            UpdateFoldersWithinLast5Minutes $directories $retries
        }
    }
}

# Function to trigger library update for a specific folder
function UpdateFolderLast5($folder, $directory) {
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

        $request = Invoke-WebRequest -Uri $final_url -UseBasicParsing -Method Get

        Write-Host $request

        Write-Host "Partial refresh request successful for: $($folder.FullName)"
    }
    } catch {
        Write-Host "Error refreshing: $($folder.FullName)"
        Write-Host "Error details: $_"
    }
}

# Example usage - REPLACE WITH YOUR DIRECTORIES
$directoriesToUpdate = @("Z:\movies4k", "Z:\moviesHD", "Z:\anime", "Z:\4k-shows", "Z:\shows")

if ($args.length -gt 4) {
    Write-Host "Update within last 5 minutes"
    UpdateFoldersWithinLast5Minutes $directoriesToUpdate $retryAmount
}
else {
    Write-Host "Normal method"
    if ($args[2].StartsWith("__all__")) {
        Write-Host "Path starts with '__all__'."
        $path = $args[3]
    }

    UpdateFolder $retryAmount
}
