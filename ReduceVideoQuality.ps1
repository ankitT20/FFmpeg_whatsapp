# Simple FFmpeg Script for Video Processing
# Get-ExecutionPolicy -List  
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned  
# After work complete  
# Set-ExecutionPolicy -ExecutionPolicy Undefined  

function Get-VideoDuration {
    param (
        [string]$filename
    )
    $durationOutput = ffmpeg -i "$filename" 2>&1 | Select-String "Duration"
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

function Get-TempFilename {
    param (
        [string]$baseFilename
    )
    $tempFilename = "$baseFilename.mp4"
    $i = 1
    while (Test-Path $tempFilename) {
        $tempFilename = "$baseFilename($i).mp4"
        $i++
    }
    return $tempFilename
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
        $command = "ffmpeg -i `"$filename`" -vcodec libx265 -x265-params lossless=1 `"$outputFilename`""
    } else {
        $command = "ffmpeg -i `"$filename`" -vcodec libx265 -crf $crf `"$outputFilename`""
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
    
    $bitrate = [math]::Floor(752000 / $duration)

    if ($audioOption -eq 1) {
        $videoBitrate = [math]::Floor($bitrate - 128)
        $command1 = "ffmpeg -y -i `"$filename`" -c:v libx265 -b:v ${videoBitrate}k -x265-params pass=1 -an -f null NUL"
        $command2 = "ffmpeg -i `"$filename`" -c:v libx265 -b:v ${videoBitrate}k -x265-params pass=2 -c:a aac -b:a 128k `"$outputFilename`""
    } elseif ($audioOption -eq 2) {
        $command1 = "ffmpeg -y -i `"$filename`" -c:v libx265 -b:v ${bitrate}k -x265-params pass=1 -an -f null NUL"
        $command2 = "ffmpeg -i `"$filename`" -c:v libx265 -b:v ${bitrate}k -x265-params pass=2 -an `"$outputFilename`""
    } else {
        $command1 = "ffmpeg -y -i `"$filename`" -c:v libx265 -b:v ${bitrate}k -r 30 -x265-params pass=1 -an -f null NUL"
        $command2 = "ffmpeg -i `"$filename`" -c:v libx265 -b:v ${bitrate}k -r 30 -x265-params pass=2 -an `"$outputFilename`""
    }

    $finalCommand = "($command1) ; ($command2)"
    Write-Host "Running commands: $finalCommand"
    Invoke-Expression $finalCommand
    Write-Host "DONE: output file name is " $outputFilename
}


function SpeedUp-Video {
    param (
        [string]$filename,
        [string]$outputFilename
    )

    $ratio = Read-Host "Enter speed up ratio number (e.g. 2 for 2x, 3 for 3x)"
    $parsedRatio = 0

    if (-not [double]::TryParse($ratio, [ref]$parsedRatio)) {
        Write-Host "Invalid ratio. Please enter a valid number like 2 or 3."
        exit
    }

    if ($parsedRatio -le 0) {
        Write-Host "Speed-up ratio must be greater than 0."
        exit
    }

    # Calculate video PTS multiplier (1 / ratio)
    $videoPTS = [math]::Round(1 / $parsedRatio, 3)
    $audioTempo = $parsedRatio
    $command = "ffmpeg -i `"$filename`" -filter_complex `"[0:v]setpts=$videoPTS*PTS[v];[0:a]atempo=$audioTempo[a]`" -map `"[v]`" -map `"[a]`" `"$outputFilename`""
    Write-Host "Running command: $command"
    Invoke-Expression $command
    Write-Host "DONE: Sped-up video saved to $outputFilename"
}

function AllInOne {
    param (
        [string]$filename,
        [string]$outputFilename,
        [string]$tempFilename
    )
    $ratio = Read-Host "Enter speed up ratio number (e.g. 2 for 2x, 3 for 3x)"
    $parsedRatio = 0
    if (-not [double]::TryParse($ratio, [ref]$parsedRatio)) {
        Write-Host "Invalid ratio. Please enter a valid number like 2 or 3."
        exit
    }
    if ($parsedRatio -le 0) {
        Write-Host "Speed-up ratio must be greater than 0."
        exit
    }
    $videoPTS = [math]::Round(1 / $parsedRatio, 3)
    $audioTempo = $parsedRatio
    $command = "ffmpeg -i `"$filename`" -filter_complex `"[0:v]setpts=$videoPTS*PTS[v];[0:a]atempo=$audioTempo[a]`" -map `"[v]`" -map `"[a]`" `"$tempFilename`""
    Write-Host "Running command: $command"
    Invoke-Expression $command
    Write-Host "DONE: Speed-up video"
    
    $fileSizeBytes = (Get-Item $tempFilename).Length
    $maxSizeBytes = 94MB
    if ($fileSizeBytes -lt $maxSizeBytes) {
        Write-Host "The Speed-up video is already under 94MB. No need to process."
        Rename-Item -Path $tempFilename -NewName $outputFilename
        Write-Host "DONE: output file name is " $outputFilename
        exit
    }
    
    $duration = Get-VideoDuration -filename $tempFilename
    $bitrate = [math]::Floor(752000 / $duration)
    $videoBitrate = [math]::Floor($bitrate - 128)
    $command1 = "ffmpeg -y -i `"$tempFilename`" -c:v libx265 -b:v ${videoBitrate}k -x265-params pass=1 -an -f null NUL"
    $command2 = "ffmpeg -i `"$tempFilename`" -c:v libx265 -b:v ${videoBitrate}k -x265-params pass=2 -c:a aac -b:a 128k `"$outputFilename`""
    $finalCommand = "($command1) ; ($command2)"
    Write-Host "Running commands: $finalCommand"
    Invoke-Expression $finalCommand
    Write-Host "DONE: output file name is " $outputFilename
    Remove-Item $tempFilename -Force
}

function Show-Menu {
    param (
        [string]$filename,
        [int]$duration,
        [string]$outputFilename,
        [string]$tempFilename
    )

    Write-Host "Select an option:"
    Write-Host "1. For Reducing video quality"
    Write-Host "2. For WHATSAPP highest quality video 94MB limit, without sending as document"
    Write-Host "3) Speed up Video+Audio (low quality)"
    Write-Host "4) ALL IN ONE (Speed up both Video+Audio (low quality) & convert to WhatsApp 94MB)"
    Write-Host " "
    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        1 { Reduce-VideoQuality -filename $filename -outputFilename $outputFilename }
        2 { WhatsApp-VideoQuality -filename $filename -duration $duration -outputFilename $outputFilename }
        3 { SpeedUp-Video -filename $filename -outputFilename $outputFilename }
        4 { AllInOne -filename $filename -outputFilename $outputFilename -tempFilename $tempFilename }
        default { Write-Host "Invalid choice, please select a number (1 or 2 or...)" }
    }
}

# Ensure TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Install Chocolatey if not already installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..."
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install ffmpeg-full if not already installed
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "Installing FFmpeg..."
    choco install ffmpeg-full -y
}

Write-Host "Ensure input video file are in current directory/folder as seen beside. If not then change directory to the folder where the video file is located using cd. OR give full path of the video file."
Write-Host " "

# Main script
$filename = Read-Host "Enter the filename of the video"
# If user didn't include an extension, assume .mp4
if (-not ($filename -match "\.\w+$")) {
    $filename += ".mp4"
}
if (-not (Test-Path $filename)) {
    Write-Host "File not found. Please make sure the file exists and try again."
    exit
}

$duration = Get-VideoDuration -filename $filename
# Write-Host "Duration of Video in seconds:" $duration
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($filename)
$outputFilename = Get-UniqueOutputFilename -baseFilename "${baseName}_output"
# $outputFilename = Get-UniqueOutputFilename -baseFilename "output"
$tempFilename = Get-TempFilename -baseFilename "temp"

Show-Menu -filename $filename -duration $duration -outputFilename $outputFilename -tempFilename $tempFilename

