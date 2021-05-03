    param (
        [Parameter(Position=0)]
        [String]
        $File,
        [Parameter(Position=1)]
        [String]
        $Directory,
        [Parameter(Position=2)]
        [String]
        $Title,
        [Parameter(Position=3)]
        [String]
        $Destination,
        [Parameter()]
        [ValidateScript({if([System.IO.Path]::GetExtension($_) -eq "json"){$true}else{$false}})]
        [String]
        $EncodingProfile

    )
    
    <# Constants #>
        # Path to Handbrake CLI executable
        [String]$HANDBRAKE_CLI = "$env:ProgramFiles\HandbrakeCLI\HandbrakeCLI.exe"

        # Path to default encoding profile
        #[String]$HANDBRAKE_DEFAULT_PROFILE = "C:\Users\prboy\OneDrive\Documents\Torrenting\Handbrake-AMD_H264_MP4.json"

    # Create a new Credential object
    [pscredential]$Credential = New-Object pscredential "prboyer", $(Get-Content "C:\Users\prboy\OneDrive\Documents\Torrenting\Cred.txt" | ConvertTo-SecureString -Force)

    # Check if the file is already an MP4. If yes, then don't run through Handbrake
    Write-Host 

    if ([System.IO.Path]::GetExtension($File) -notlike "mp4") {
        Write-Information ("Calling Handbrake for Converstion - {0}\{1}" -f $Directory,$File) -InformationAction Continue

        $ConversionJob = Start-Job -Name "Handbrake Conversion Job" -ArgumentList $HANDBRAKE_CLI, $Directory, $File, $Destination -ScriptBlock {
            try{     
                Write-Information ("$args[0] -v -i `""+$args[1]+"\"+$args[2]+"`" -o `""+$args[3]+"\"+$args[2].ToString().Substring(0,$args[2].ToString().Length-4)+".mp4`" -f av_mp4 -e vce_h265 -Z `"H.265 MKV 2160p60`"")            
                
                Write-Host ("Start Processing {0}" -f $File) -ForegroundColor Yellow
                Start-Process -FilePath $args[0] -Wait -ArgumentList ("-v -i `""+$args[1]+"\"+$args[2]+"`" -o `""+$args[3]+"\"+$args[2].ToString().Substring(0,$args[2].ToString().Length-4)+".mp4`" -f av_mp4 -e vce_h265 -Z `"H.265 MKV 2160p60`"") -NoNewWindow
                
                Write-Information "Processing Complete" -InformationAction Continue
            }catch{
                Write-Error $("Error processing file with Handbrake `n{0}" -f $ERROR)
            }
        }
    }else{
        Write-Host "File is already an MP4" -ForegroundColor Yellow
    }














####################
# Constants



#assign input args to vars
# $File = $args[0]
# $Dir = $args[1]
# $Title = $args[2]

# Write-Host "Begin Processing" -ForegroundColor Yellow
# Write-Host "File:" $File
# Write-Host "Download Dir:" $Dir
# Write-Host "Torrent Title:" $Title

# Check if the file is already an MP4. If yes, then don't run through Handbrake
# if ([System.IO.Path]::GetExtension($args[0]) -notlike "mp4") {
#     Write-Host "Calling Handbrake for Converstion" -ForegroundColor Cyan

#     try{
#         Start-Process -FilePath $HANDBRAKECLI -Wait -ArgumentList "-v -i `"$Dir\$File`" -o `"$Destination\$File`" -f av_mp4 -e vce_h265 -Z `"Fast 1080p30`"" -NoNewWindow
    
    
#     }catch{
#         Write-Error "Error processing file with Handbrake"
#     }
# }else{
#     Write-Host "File is already an MP4" -ForegroundColor Yellow
#     Move-Item $Dir\$File -Destination $DESTINATION
# }

# Write-Host "Encoding Complete" -ForegroundColor Green

# Write-Host "Move files to Media Server" -ForegroundColor Cyan

# New-PSDrive -Name "P" -PSProvider FileSystem -Root "\\192.168.1.100\Plex\Media" -Description "Plex Media Server on PRB-FS-1" -Credential $CRED

# Copy-Item $DESTINATION\TV -Recurse -Filter {$_ -like "*.mp4"}