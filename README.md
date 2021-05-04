---
external help file: Convert-Media-help.xml
Module Name: Convert-Media
online version:
schema: 2.0.0
---

# Convert-Media

## SYNOPSIS
Script to automate the process of transcoding video files.

## SYNTAX

```
Convert-Media [[-FilePath] <String>] [[-Destination] <String>] [-Quiet] [<CommonParameters>]
```

## DESCRIPTION
The script is designed to be called from another program, passing both the full path of the content to be converted
as well as the destination for the transcoded output on the command line.
The script leverages the Handbrake CLI to perform background
encoding jobs.
The default hard-coded preset is optimized for H265 using AMD VCE drivers for hardware (GPU) encoding.

## EXAMPLES

### EXAMPLE 1
```
Powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -File .\Convert-Media.ps1 -FilePath ".\movie.wmv" -Destination ".\Folder\"
```

Typical use on the command line using relative paths

### EXAMPLE 2
```
Powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Convert-Media.ps1" -FilePath "%F" -Destination "G:\"
```

Example calling the script from another program like qBittorrent

## PARAMETERS

### -FilePath
This should be the fully qualified path to the imput file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Destination
This is the path the the output directory.
It does not need to be fully qualified.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Quiet
Specifying the quiet parameter will prevent the script from showing the progress of the conversion in a console window.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

Non .MP4 video files
## OUTPUTS

A transcoded .MP4 video file
## NOTES
Author: Paul Boyer

Date: 5-4-2021
## RELATED LINKS
