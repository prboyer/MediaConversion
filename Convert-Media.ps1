    param (
        [Parameter(Position=0)]
        [String]
        $FilePath,
        [Parameter(Position=1)]
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

    # Make sure to expand the paths
    #$FilePath = Resolve-Path -Path $FilePath
    $Destination = Resolve-Path -Path $Destination

    <# Constants #>
        # Path to Handbrake CLI executable
        [String]$HANDBRAKE_CLI = "$env:ProgramFiles\HandbrakeCLI\HandbrakeCLI.exe"

    # Check if the file is already an MP4. If yes, then don't run through Handbrake
    if ([System.IO.Path]::GetExtension($FilePath) -notlike "mp4") {
        Write-Information ("Calling Handbrake for Converstion - {0}" -f $FilePath) -InformationAction Continue

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

    Wait-Job -Job $ConversionJob
    Receive-Job -Job $ConversionJob