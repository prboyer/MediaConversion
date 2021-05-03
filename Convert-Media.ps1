    param (
        [Parameter(Position=0)]
        [String]
        $File,
        [Parameter(Position=1)]
        [String]
        $SourceDirectory,
        [Parameter(Position=2)]
        [String]
        $Title,
        [Parameter(Position=3)]
        [String]
        $Destination

    )
    # If the destination parameter isn't provided, create the new file in the same directory as the source
    if ($Destination -eq "") {
        $Destination = $SourceDirectory;
    }

    <# Constants #>
        # Path to Handbrake CLI executable
        [String]$HANDBRAKE_CLI = "$env:ProgramFiles\HandbrakeCLI\HandbrakeCLI.exe"

    # Check if the file is already an MP4. If yes, then don't run through Handbrake
    if ([System.IO.Path]::GetExtension($File) -notlike "mp4") {
        Write-Information ("Calling Handbrake for Converstion - {0}\{1}" -f $SourceDirectory,$File) -InformationAction Continue

        $ConversionJob = Start-Job -Name $("Handbrake Conversion Job - {0}" -f $File) -ArgumentList $HANDBRAKE_CLI, $SourceDirectory, $File, $Destination -ScriptBlock {
            try{
                # Write out the command line call that is processing the file     
                Write-Information ("$args[0] -v -i `""+$args[1]+"\"+$args[2]+"`" -o `""+$args[3]+"\"+$args[2].ToString().Substring(0,$args[2].ToString().Length-4)+".mp4`" -f av_mp4 -e vce_h265 -Z `"H.265 MKV 2160p60`"")            
                
                # Actually start processing the file
                Write-Host ("Start Processing {0}" -f $File) -ForegroundColor Yellow
                Start-Process -FilePath $args[0] -Wait -ArgumentList ("-v -i `""+$args[1]+"\"+$args[2]+"`" -o `""+$args[3]+"\"+$args[2].ToString().Substring(0,$args[2].ToString().Length-4)+".mp4`" -f av_mp4 -e vce_h265 -Z `"H.265 MKV 2160p60`"") -NoNewWindow
                
                # Notify that the file has completed without error
                Write-Information "Processing Complete" -InformationAction Continue
            }catch{
                Write-Error $("Error processing file with Handbrake `n{0}" -f $ERROR)
            }
        }
    }else{
        Write-Host "File is already an MP4" -ForegroundColor Yellow
    }