    <#
    .SYNOPSIS
        Script to automate the process of transcoding video files.
    .DESCRIPTION
        The script is designed to be called from another program, passing both the full path of the content to be converted
        as well as the destination for the transcoded output on the command line. The script leverages the Handbrake CLI to perform background
        encoding jobs. The default hard-coded preset is optimized for H265 using AMD VCE drivers for hardware (GPU) encoding.
    .Parameter FilePath
        This should be the fully qualified path to the imput file.
    .Parameter Destination
        This is the path the the output directory. It does not need to be fully qualified. 
    .Parameter Quiet
        Specifying the quiet parameter will prevent the script from showing the progress of the conversion in a console window. 
    .EXAMPLE
        PS C:\> Powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -File .\Convert-Media.ps1 -FilePath ".\movie.wmv" -Destination ".\Folder\"
        Typical use on the command line using relative paths
    .EXAMPLE
        Powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Convert-Media.ps1" -FilePath "%F" -Destination "G:\"
        Example calling the script from another program like qBittorrent
    .INPUTS
        Non .MP4 video files
    .OUTPUTS
        A transcoded .MP4 video file
    .NOTES
        Author: Paul Boyer
        Date: 5-4-2021
    #>
    param (
        [Parameter(Position=0,Mandatory=$true)]
        [String]
        $FilePath,
        [Parameter(Position=1,Mandatory=$true)]
        [String]
        $Destination,
        [Parameter()]
        [switch]
        $Quiet

    )
    # If the destination parameter isn't provided, create the new file in the same directory as the source
    if ($Destination -eq "") {
        $Destination = $(Split-Path -Path $FilePath -Parent);
    }

    # Make sure to expand the path
    $Destination = Resolve-Path -Path $Destination

    <# Constants #>
        # Path to Handbrake CLI executable
        [String]$HANDBRAKE_CLI = "$env:ProgramFiles\HandbrakeCLI\HandbrakeCLI.exe"

    # Check if the file is already an MP4. If yes, then don't run through Handbrake
    if ([System.IO.Path]::GetExtension($FilePath) -notlike "mp4") {
        Write-Information ("`nCalling Handbrake for Converstion - {0}" -f $FilePath) -InformationAction Continue

        $ConversionJob = Start-Job -Name $("Handbrake Conversion Job - {0}" -f $(Split-Path -Path $FilePath -Leaf)) -ArgumentList $HANDBRAKE_CLI, $FilePath, $Destination -ScriptBlock {
            try{
                [String]$ArgumentList = ("-v -i `""+$args[1]+"`" -o `""+$args[2]+"\"+$args[1].ToString().Substring($args[1].ToString().LastIndexOf('\'),$args[2].ToString().Length-4)+".mp4`" -f av_mp4 -e vce_h265 -Z `"H.265 MKV 2160p60`"")

                # Write out the command line call that is processing the file     
                Write-Information ($args[0]+$ArgumentList)            
                
                # Actually start processing the file
                Write-Host ("Start Processing {0}" -f $File) -ForegroundColor Yellow
                
                # Supress the console window if -Quiet is passed
                if($Quiet){
                    Start-Process -FilePath $args[0] -Wait -ArgumentList $ArgumentList -NoNewWindow
                }else{
                    Start-Process -FilePath $args[0] -Wait -ArgumentList $ArgumentList
                }
                
                # Notify that the file has completed without error
                Write-Information "Processing Complete" -InformationAction Continue
            }catch{
                Write-Error $("Error processing file with Handbrake `n{0}" -f $ERROR)
            }
        }
    }else{
        Write-Host "File is already an MP4" -ForegroundColor Yellow
    }

    # Wait-Job -Job $ConversionJob
    # Receive-Job -Job $ConversionJob