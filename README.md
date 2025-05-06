# FFmpeg_whatsapp
For Reducing video size and quality using FFmpeg  
## Requirements:  
```FFmpeg``` is required to run the project  
[FFmpeg download website for windows](https://www.gyan.dev/ffmpeg/builds/#release-builds)      
[Direct Download link](https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z) use [7-Zip](https://www.7-zip.org/) for extraction.
ffmpeg.exe will be inside ```bin``` folder, copy it to ReduceVideoQuality.ps1 location
## Instructions to run ReduceVideoQuality.ps1:
1. Download ReduceVideoQuality.ps1 file *from github*
>    - *OR  Download Repository as Zip and Extract*
>    - *OR ```git clone https://github.com/ankitT20/FFmpeg_whatsapp.git```*
2. Ensure **ffmpeg.exe** and *ReduceVideoQuality.ps1* and input video file are all in same directory/*folder*.
3. Right click *ReduceVideoQuality.ps1*, click **Run with PowerShell**.
>    - *OR Open PowerShell, navigate to the directory containing the script, and run it using ```.\ReduceVideoQuality.ps1```.*
4. Follow the prompts to provide the filename and select options.  

> [!NOTE]
> If running scripts is dissabled on your system, search powershell, *Right click and 'Run as Administrator'*, and run the following:  ```Set-ExecutionPolicy -ExecutionPolicy RemoteSigned```  
  
> [!TIP]
> After work is completed: ```Set-ExecutionPolicy -ExecutionPolicy Undefined```  
> To view all policy: ```Get-ExecutionPolicy -List```  
# Documentation
## For Reducing video quality
> [!TIP]
> Similar to x264, the x265 encoder has 2 rate control algorithms:  
> Constant Rate Factor (CRF)  
> 2-pass target bitrate  
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
## for 64MB video
calculate bitrate  
512000 / 349 = 1467  
64(desired file size) * 8(byte to bit) * 1000(MB to KB) / 349(**duration of video in seconds**) = 1467 (do multiplication first)  
1467 - 128 kBit/s (desired audio bitrate) = 1339 kBit/s video bitrate
```
ffmpeg -y -i input.mp4 -c:v libx265 -b:v 1339k -x265-params pass=1 -an -f null NUL && ^
ffmpeg -i input.mp4 -c:v libx265 -b:v 1339k -x265-params pass=2 -c:a aac -b:a 128k output.mp4
```
## for 64MB video without audio
calculate bitrate  
64 * 8000 / 349 = 1467  
64(desired file size) * 8(byte to bit) * 1000(MB to KB) / 349(**duration of video in seconds**) = 1467 (do multiplication first)  
512000 / [duration of video in seconds]
```
ffmpeg -y -i input.mp4 -c:v libx265 -b:v 1467k -x265-params pass=1 -an -f null NUL && ^
ffmpeg -i input.mp4 -c:v libx265 -b:v 1467k -x265-params pass=2 -an output_64MB.mp4
```
### for 64MB video without audio with Framerate of 30FPS
```
ffmpeg -y -i input.mp4 -c:v libx265 -b:v 1467k -r 30 -x265-params pass=1 -an -f null NUL && ^
ffmpeg -i input.mp4 -c:v libx265 -b:v 1467k -r 30 -x265-params pass=2 -an output_64MB.mp4
```
[Refrence](https://trac.ffmpeg.org/wiki/Encode/H.265#Ratecontrolmodes)  

## Speed up video and audio at the same time:
> Using a complex filtergraph
> For 3x
```
ffmpeg -i input.mp4 -filter_complex "[0:v]setpts=0.3*PTS[v];[0:a]atempo=3.0[a]" -map "[v]" -map "[a]" output.mp4
```
> For 2x ```ffmpeg -i input.mp4 -filter_complex "[0:v]setpts=0.5*PTS[v];[0:a]atempo=2.0[a]" -map "[v]" -map "[a]" output.mp4```  

### Slow Down video and audio at the same time:
> raw bitstream method
```
ffmpeg -fflags +genpts -r 15 -i raw.h264 -i input.mp4 -map 0:v -c:v copy -map 1:a -af atempo=0.5 -movflags faststart output.mp4
```

## Speed Up or Slow Down a Video(without audio)  
> For 3x speed (LOW QUALITY) (to slow PTS*3)  
```ffmpeg -i 'input.mp4' -filter:v "setpts=PTS/3,fps=60" -an output.mp4```  
> For 3x speed (lossless) where 0.3 is 1/3 in decimal representation. *(this will create 100fps+ video, so -r 30 is MANDATORY afterwords)*  
```ffmpeg -itsscale 0.3 -i 'input.mp4' -c copy -an fast.mp4```  
  
## Change framerate  
> Change framerate without re-encoding *(won't reduce file size to 64MB afterwards, but still -r 30 is MANDATORY if using reduce size commands)*:  
```(./ffmpeg -y -i input.mp4 -an -c copy -f h264 seeing_noaudio.h264) ; (./ffmpeg -y -r 30 -i seeing_noaudio.h264 -an -c copy fps.mp4)```  
