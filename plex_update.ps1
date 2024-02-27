Add-Type -AssemblyName System.Web
 
# Plex server details - EDIT BELOW
$plexUrl = "http://plex-ip:32400"
$plexToken = "your-plex-token"
 
# Replace with your mount - EDIT BELOW
$mount = "Z:"
 
$path = $args[2]

# Set how many times you want the script to retry if the folder has not yet been added - EDIT BELOW
$retryAmount = 30
 
# Function to URL encode a string
function UrlEncode($value) {
    [System.Web.HttpUtility]::UrlEncode($value, [System.Text.Encoding]::UTF8)
}
 
# Example path to a log - EDIT BELOW
Start-Transcript -Path "C:\Path\To\zurg-testing\logs\plex_update.log"
 
# Function to trigger library update for a specific folder
function UpdateFolder($retries) {
    $section_ids = (Invoke-WebRequest -Uri "$plexUrl/library/sections" -Headers @{"X-Plex-Token" = $plexToken} -UseBasicParsing -Method Get).Content |
    Select-Xml -XPath "//Directory/@key" |
    ForEach-Object { $_.Node.Value }

    Write-Host "IDs: $section_ids"
    $fullPath = Join-Path -Path $mount -ChildPath $path
    Write-Host "Path: $fullPath"
    $encodedPath = UrlEncode $fullPath

    if (Test-Path -LiteralPath $fullPath) {
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
        } else {
            Write-Host "The path does not exist."
        }
    }
}

# Function to trigger library update for a specific folder
function UpdateFolderLast5($folder, $directory) {
    $section_ids = (Invoke-WebRequest -Uri "$plexUrl/library/sections" -Headers @{"X-Plex-Token" = $plexToken} -UseBasicParsing -Method Get).Content |
    Select-Xml -XPath "//Directory/@key" |
    ForEach-Object { $_.Node.Value }
 
    Write-Host "IDs: $section_ids"
    $fullPath = Join-Path -Path $directory -ChildPath $folder.Name
    Write-Host "Path: $fullPath"
    $encodedPath = UrlEncode $fullPath
 
    try {
        # Trigger the library update for the specific folder
        foreach ($section_id in $section_ids) {
            $final_url = "${plexUrl}/library/sections/${section_id}/refresh?path=${encodedPath}&X-Plex-Token=${plexToken}"

            Write-Host "Encoded argument: $encodedPath"
            Write-Host "Section ID: $section_id"
            Write-Host "Final URL: $final_url"

            # Trigger the library update for the specific folder
            $request = Invoke-WebRequest -Uri $final_url -UseBasicParsing -Method Get

            Write-Host $request

            Write-Host "Partial refresh request successful for: $($path)"
        }
    } catch {
        Write-Host "Error refreshing: $($folder.FullName)"
        Write-Host "Error details: $_"
    }
}

# Function to update folders within the last 5 minutes
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
 
# Example usage - REPLACE WITH YOUR DIRECTORIES
$directoriesToUpdate = @("Z:\movies","Z:\anime","Z:\shows","Z:\movies4k","Z:\shows4k")
 
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
