# FFmpeg_whatsapp
For Reducing video quality using FFmpeg


## Requirements:
<!--  -->
```FFmpeg``` is required to run the project <!--  -->
[FFmpeg download website for windows](https://www.gyan.dev/ffmpeg/builds/#release-builds)      
[Direct Download link](https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z) use [7-Zip](https://www.7-zip.org/) for extraction.
ffmpeg.exe will be inside ```bin``` folder, copy it to ReduceVideoQuality.ps1 location
## Instructions to run ReduceVideoQuality.ps1:
1. Download ReduceVideoQuality.ps1 file *from github*
    - *OR  Download Repository as Zip and Extract*
    - *OR ```git clone https://github.com/ankitT20/FFmpeg_whatsapp.git```*
2. Ensure ffmpeg.exe is in the same directory/*folder* as the *ReduceVideoQuality.ps1* and video file.
3. Select and Right click *ReduceVideoQuality.ps1*, click **Run with PowerShell**.
    - *OR Open PowerShell, navigate to the directory containing the script, and run it using ```ReduceVideoQuality.ps1```.*
4. Follow the prompts to provide the filename and select options.

If running scripts is dissabled on your system, search powershell, *Right click and 'Run as Administrator'*, and run the following:<!-- To view all policy: ```Get-ExecutionPolicy -List``` -->
```Set-ExecutionPolicy -ExecutionPolicy RemoteSigned```
<!-- After work is completed: ```Set-ExecutionPolicy -ExecutionPolicy Undefined``` -->

# Documentation
## For Reducing video quality
### higher crf means reduced quality , range is 0 to 51
```
ffmpeg -i input.mp4 -vcodec libx265 -crf 28 output.mp4
ffmpeg -i input.mp4 -vcodec libx265 -crf 23 output.mp4
ffmpeg -i input.mp4 -c:v libx265 -crf 26 -preset fast -c:a aac -b:a 128k output.mp4
```
default crf value is 23, and libx265 is HEVC (*High Efficiency Video Coding*) , for x264 [refer](https://unix.stackexchange.com/questions/28803/how-can-i-reduce-a-videos-size-with-ffmpeg)

### for lossless
```
ffmpeg -i input.mp4 -vcodec libx265 -x265-params lossless=1 output.mp4
```
verify using console output - x265 [info]: Rate Control                        : Lossless


# For WHATSAPP higgest quality video 64MB limit, without sending as document.
### Two-Pass Encoding
##    for 64MB video without audio
calculate bitrate

64 * 8000 / 349 = 1467

64(desired file size) * 8(byte to bit) * 1000(MB to KB) / 349(**duration of video in seconds**) = 1467 (do multiplication first)
```
ffmpeg -y -i input.mp4 -c:v libx265 -b:v 1467k -x265-params pass=1 -an -f null NUL && ^
ffmpeg -i input.mp4 -c:v libx265 -b:v 1467k -x265-params pass=2 -an output_64MB.mp4
```

##    for 64MB video
calculate bitrate

64 * 8000 / 349 = 1467

64(desired file size) * 8(byte to bit) * 1000(MB to KB) / 349(**duration of video in seconds**) = 1467 (do multiplication first)

1467 - 128 kBit/s (desired audio bitrate) = 1339 kBit/s video bitrate
```
ffmpeg -y -i input.mp4 -c:v libx265 -b:v 1339k -x265-params pass=1 -an -f null NUL && ^
ffmpeg -i input.mp4 -c:v libx265 -b:v 1339k -x265-params pass=2 -c:a aac -b:a 128k output.mp4
```

[Refrence](https://trac.ffmpeg.org/wiki/Encode/H.265#Ratecontrolmodes)

## Speed Up or Slow Down a Video  
> For 3x speed (LOW QUALITY) (to slow PTS*3)  
```ffmpeg -i 'input.mp4' -filter:v "setpts=PTS/3,fps=60" -an output.mp4```  
> For 3x speed (lossless) where 0.3 is 1/3 in decimal representation.  
```ffmpeg -itsscale 0.3 -i 'input.mp4' -c copy -an fast.mp4```  

