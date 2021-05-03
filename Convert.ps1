
Start-Transcript $PSScriptRoot\log.txt

####################
# Constants

# Path to Handbrake CLI executable
$HANDBRAKECLI = "$env:ProgramFiles\HandbrakeCLI\HandbrakeCLI.exe"

$HANDBRAKE_PROFILE = "C:\Users\prboy\OneDrive\Documents\Torrenting\Handbrake-AMD_H264_MP4.json"

$DESTINATION = "G:\FINISHED"

$CRED = New-Object pscredential "prboyer", $(Get-Content "C:\Users\prboy\OneDrive\Documents\Torrenting\Cred.txt" | ConvertTo-SecureString -Force)

#assign input args to vars
$File = $args[0]
$Dir = $args[1]
$Title = $args[2]

Write-Host "Begin Processing" -ForegroundColor Yellow
Write-Host "File:" $File
Write-Host "Download Dir:" $Dir
Write-Host "Torrent Title:" $Title

# Check if the file is already an MP4. If yes, then don't run through Handbrake
if ($args[0] -notlike "*.mp4") {
    Write-Host "Calling Handbrake for Converstion" -ForegroundColor Cyan

    try{
        Start-Process -FilePath $HANDBRAKECLI -Wait -ArgumentList "-v -i `"$Dir\$File`" -o `"$Destination\$File`" -f av_mp4 -e vce_h265 -Z `"Fast 1080p30`"" -NoNewWindow
    
    
    }catch{
        Write-Error "Error processing file with Handbrake"
    }
}else{
    Write-Host "File is already an MP4" -ForegroundColor Yellow
    Move-Item $Dir\$File -Destination $DESTINATION
}

Write-Host "Encoding Complete" -ForegroundColor Green

Write-Host "Move files to Media Server" -ForegroundColor Cyan

# New-PSDrive -Name "P" -PSProvider FileSystem -Root "\\192.168.1.100\Plex\Media" -Description "Plex Media Server on PRB-FS-1" -Credential $CRED

# Copy-Item $DESTINATION\TV -Recurse -Filter {$_ -like "*.mp4"}

Stop-Transcript