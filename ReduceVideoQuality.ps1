# Simple FFmpeg Script for Video Processing
# Get-ExecutionPolicy -List  
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned  
# After work complete  
# Set-ExecutionPolicy -ExecutionPolicy Undefined  

function Get-VideoDuration {
    param (
        [string]$filename
    )
    $durationOutput = .\ffmpeg.exe -i "$filename" 2>&1 | Select-String "Duration"
    if ($durationOutput -match "Duration: (\d{2}):(\d{2}):(\d{2})") {
        $hours = [int]$matches[1]
        $minutes = [int]$matches[2]
        $seconds = [int]$matches[3]
        return ($hours * 3600) + ($minutes * 60) + $seconds
    } else {
        Write-Host "Could not retrieve video duration."
        exit
    }
}

function Get-UniqueOutputFilename {
    param (
        [string]$baseFilename
    )
    $outputFilename = "$baseFilename.mp4"
    $i = 1
    while (Test-Path $outputFilename) {
        $outputFilename = "$baseFilename($i).mp4"
        $i++
    }
    return $outputFilename
}

function Reduce-VideoQuality {
    param (
        [string]$filename,
        [string]$outputFilename
    )
    Write-Host "Higher value means more compression"
    $crf = Read-Host "Enter CRF value (recommended is 28, for lossless 0)"
    if (-not $crf) {
        $crf = 28
    }
    if ($crf -eq 0) {
        $command = ".\ffmpeg.exe -i `"$filename`" -vcodec libx265 -x265-params lossless=1 `"$outputFilename`""
    } else {
        $command = ".\ffmpeg.exe -i `"$filename`" -vcodec libx265 -crf $crf `"$outputFilename`""
    }
    Write-Host "Running command: $command"
    Invoke-Expression $command
    Write-Host "DONE: output file name is " $outputFilename
}

function WhatsApp-VideoQuality {
    param (
        [string]$filename,
        [int]$duration,
        [string]$outputFilename
    )
    $audioOption = Read-Host "Include audio? (1. With audio, 2. Without audio, 3. Without audio 30 FPS)"
    
    $bitrate = [math]::Floor(512000 / $duration)

    if ($audioOption -eq 1) {
        $videoBitrate = [math]::Floor($bitrate - 128)
        $command1 = ".\ffmpeg.exe -y -i `"$filename`" -c:v libx265 -b:v ${videoBitrate}k -x265-params pass=1 -an -f null NUL"
        $command2 = ".\ffmpeg.exe -i `"$filename`" -c:v libx265 -b:v ${videoBitrate}k -x265-params pass=2 -c:a aac -b:a 128k `"$outputFilename`""
    } elseif ($audioOption -eq 2) {
        $command1 = ".\ffmpeg.exe -y -i `"$filename`" -c:v libx265 -b:v ${bitrate}k -x265-params pass=1 -an -f null NUL"
        $command2 = ".\ffmpeg.exe -i `"$filename`" -c:v libx265 -b:v ${bitrate}k -x265-params pass=2 -an `"$outputFilename`""
    } else {
        $command1 = ".\ffmpeg.exe -y -i `"$filename`" -c:v libx265 -b:v ${bitrate}k -r 30 -x265-params pass=1 -an -f null NUL"
        $command2 = ".\ffmpeg.exe -i `"$filename`" -c:v libx265 -b:v ${bitrate}k -r 30 -x265-params pass=2 -an `"$outputFilename`""
    }

    $finalCommand = "($command1) ; ($command2)"
    Write-Host "Running commands: $finalCommand"
    Invoke-Expression $finalCommand
    Write-Host "DONE: output file name is " $outputFilename
}

function Show-Menu {
    param (
        [string]$filename,
        [int]$duration,
        [string]$outputFilename
    )

    Write-Host "Select an option:"
    Write-Host "1. For Reducing video quality"
    Write-Host "2. For WHATSAPP highest quality video 64MB limit, without sending as document"
    $choice = Read-Host "Enter your choice (1 or 2)"

    switch ($choice) {
        1 { Reduce-VideoQuality -filename $filename -outputFilename $outputFilename }
        2 { WhatsApp-VideoQuality -filename $filename -duration $duration -outputFilename $outputFilename }
        default { Write-Host "Invalid choice, please select 1 or 2." }
    }
}

# Main script
$filename = Read-Host "Enter the filename of the video"
if (-not (Test-Path $filename)) {
    Write-Host "File not found. Please make sure the file exists and try again."
    exit
}

$duration = Get-VideoDuration -filename $filename
# Write-Host "Duration of Video in seconds:" $duration
$outputFilename = Get-UniqueOutputFilename -baseFilename "output"

Show-Menu -filename $filename -duration $duration -outputFilename $outputFilename
