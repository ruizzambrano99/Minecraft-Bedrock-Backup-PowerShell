# =====================================================================
# CONFIGURATION
# =====================================================================

# Main OneDrive directory for backups
$DESTINATION = "$env:ONEDRIVE\MINECRAFT"

# Log file (will be saved inside the backup folder)
$LOGFILE = "$DESTINATION\backup_log.log"

# Minecraft Bedrock worlds path (Using wildcards '*' to auto-detect any User ID and their worlds)
$SOURCE = "$env:APPDATA\Minecraft Bedrock\Users\*\games\com.mojang\minecraftWorlds\*"

# =====================================================================
# SCRIPT LOGIC (Do not modify below this line)
# =====================================================================

# Create destination folder if it doesn't exist
if (!(Test-Path $DESTINATION)) { New-Item -ItemType Directory -Force -Path $DESTINATION | Out-Null }

" " | Out-File -FilePath $LOGFILE -Append
"======================================================" | Out-File -FilePath $LOGFILE -Append
"DATE AND TIME: $(Get-Date)" | Out-File -FilePath $LOGFILE -Append
"OPERATION: Starting individual world backups (.mcworld)..." | Out-File -FilePath $LOGFILE -Append

try {
    # 1. Get the current date and create the backup folder in OneDrive
    $f = Get-Date -Format 'yyyy-MM-dd_HH-mm'
    $d = "$DESTINATION\Backup_$f"
    New-Item -ItemType Directory -Force -Path $d | Out-Null

    # 2. Iterate through ALL world folders dynamically finding the User ID
    Get-ChildItem -Path $SOURCE -Directory | ForEach-Object { 
        
        # 3. Build the path to the levelname.txt file
        $l = "$($_.FullName)\levelname.txt"
        
        # 4. Check if the file exists and extract a clean name
        if (Test-Path $l) {
            $n = (Get-Content $l -TotalCount 1) -replace '[\\/:*?\"<>|]','_'
        } else {
            $n = $_.Name
        }
        
        # --- ENSURE EMPTY FOLDERS (So they are included in the .mcworld file) ---
        $packs = @("behavior_packs", "resource_packs")
        foreach ($p in $packs) {
            $pPath = Join-Path $_.FullName $p
            if (!(Test-Path $pPath)) { New-Item -ItemType Directory -Path $pPath -Force | Out-Null }
            
            # Create a temporary file so the folder isn't completely empty when compressing
            $tempFile = Join-Path $pPath ".p"
            if (!(Test-Path $tempFile)) { " " | Out-File $tempFile }
        }
        
        # 5. Compress as .zip and then rename to .mcworld
        $zipTemp = "$d\$n.zip"
        $finalName = "$d\$n.mcworld"
        
        # Compress the files
        Compress-Archive -Path "$($_.FullName)\*" -DestinationPath $zipTemp -Force 
        
        # Rename to .mcworld
        Rename-Item -Path $zipTemp -NewName $finalName -Force
    }

    "RESULT: Success. Folders packaged as .mcworld in $DESTINATION" | Out-File -FilePath $LOGFILE -Append
}
catch {
    "RESULT: ERROR. The process failed: $_" | Out-File -FilePath $LOGFILE -Append
}

"======================================================" | Out-File -FilePath $LOGFILE -Append