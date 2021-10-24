    function Convert-Media{
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
        [ValidateScript({
            # Check if the file is already an MP4.
            if ([System.IO.Path]::GetExtension($FilePath) -notlike "mp4") {return $true} else {return $false}
        })]
        [String]
        $FilePath,
        [Parameter(Position=1,Mandatory=$true)]
        [ValidateScript({
            # Check if the detination path exists and is a directory
            if (Test-Path -Path $(Resolve-Path -Path $_) -PathType Container){return $true} else {return $false}
        })]
        [String]
        $Destination
    )
    #Requires -Version 5.1

    # Import the settings from the configuration file
    [Object]$Settings = ConvertFrom-Json -InputObject $(Get-Content $PSScriptRoot\Settings.json -Raw)
    
    # Generate the name of the output file
    [String]$OutFile = "$($Destination)\$([System.IO.Path]::GetFileNameWithoutExtension($FilePath)).mp4"

    Write-Information ("`nCalling Handbrake for Converstion - {0}" -f $(Split-Path $FilePath -Leaf)) -InformationAction Continue

    try{
        # Begin the video processing by calling Handbrake
        Start-Process -FilePath $Settings.Handbrake.CLI -NoNewWindow -Wait -ArgumentList "--input `"$($FilePath)`" --output `"$($OutFile)`" --format $($Settings.Handbrake.Conversion.Format) --encoder $($Settings.Handbrake.Conversion.Encoder) --preset `"$($Settings.Handbrake.Conversion.Preset)`" --main-feature --verbose"

        # Notify that the file has completed without error
        Write-Information "Processing Complete" -InformationAction Continue

    }catch{
        Write-Error $("Error processing file with Handbrake `n{0}" -f $ERROR)

    }
}