# FFmpeg_whatsapp
PowerShell Script for Reducing Video Size and Quality using FFmpeg to exactly 94MB for WhatsApp  
## Requirements:  
```FFmpeg``` is required to run the project  
1. Open an **administrative PowerShell** *(press Windows key, search powershell and right-click Run as administrator)*
2. Run the following *(right click on terminal for paste or Ctrl+V)*: 
```
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ankitT20/FFmpeg_whatsapp/refs/heads/main/ReduceVideoQuality.ps1'))
```
<!-- If you want to install yt-dlp: ```choco install yt-dlp``` -->
### Manual Method (NOT RECOMMENDED)  
<details>
<summary>Click to see the process</summary>
<!-- ### Download ffmpeg via Official website: 
[FFmpeg download website for windows](https://www.gyan.dev/ffmpeg/builds/#release-builds)  
[Direct Download link](https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z) use [7-Zip](https://www.7-zip.org) for extraction.
ffmpeg.exe will be inside ```bin``` folder, copy the folder path including bin.  
Search Environment Variables open ```Edit the system environment variables```, Go to Environment Variables, Under System variables(bottom box), double click ```Path```, click New, paste folder path, click ok, ok.  
### Instructions to run ReduceVideoQuality.ps1:
1. Download ReduceVideoQuality.ps1 file *from github*
>    - *OR  Download Repository as Zip and Extract*
>    - *OR ```git clone https://github.com/ankitT20/FFmpeg_whatsapp.git```*
2. Ensure *ReduceVideoQuality.ps1* and input video file are all in same directory/*folder*.
3. Right click *ReduceVideoQuality.ps1*, click **Run with PowerShell**.
>    - *OR Open PowerShell, navigate to the directory containing the script, and run it using ```.\ReduceVideoQuality.ps1```.*
4. Follow the prompts to provide the filename and select options.  
> [!NOTE]
> If running scripts is dissabled on your system, search powershell, *Right click and 'Run as Administrator'*, and run the following:  ```Set-ExecutionPolicy Bypass -Scope Process```  
> [!TIP]
> After work is completed: ```Set-ExecutionPolicy -ExecutionPolicy Undefined```  
> To view all policy: ```Get-ExecutionPolicy -List```   -->
<h3>Download ffmpeg via Official website:</h3>
<p><a href="https://www.gyan.dev/ffmpeg/builds/#release-builds">FFmpeg download website for windows</a><br><a href="https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z">Direct Download link</a> use <a href="https://www.7-zip.org">7-Zip</a> for extraction.
ffmpeg.exe will be inside <code>bin</code> folder, copy the folder path including bin.<br>Search Environment Variables open <code>Edit the system environment variables</code>, Go to Environment Variables, Under System variables(bottom box), double click <code>Path</code>, click New, paste folder path, click ok, ok.  </p>
<h3>Instructions to run ReduceVideoQuality.ps1:</h3>
<ol>
<li>Download ReduceVideoQuality.ps1 file <em>from github</em><blockquote>
<ul>
<li><em>OR  Download Repository as Zip and Extract</em></li>
<li><em>OR <code>git clone https://github.com/ankitT20/FFmpeg_whatsapp.git</code></em></li>
</ul>
</blockquote>
</li>
<li>Ensure <em>ReduceVideoQuality.ps1</em> and input video file are all in same directory/<em>folder</em>.</li>
<li>Right click <em>ReduceVideoQuality.ps1</em>, click <strong>Run with PowerShell</strong>.<blockquote>
<ul>
<li><em>OR Open PowerShell, navigate to the directory containing the script, and run it using <code>.\ReduceVideoQuality.ps1</code>.</em></li>
</ul>
</blockquote>
</li>
<li>Follow the prompts to provide the filename and select options.</li>
</ol>
<blockquote>
<p>[!NOTE] 
If running scripts is dissabled on your system, search powershell, <em>Right click and &#39;Run as Administrator&#39;</em>, and run the following:  <code>Set-ExecutionPolicy Bypass -Scope Process</code>  </p>
<p>[!TIP] 
After work is completed: ```Set-ExecutionPolicy -ExecutionPolicy Undefined```  
To view all policy: <code>Get-ExecutionPolicy -List</code>  </p>
</blockquote>

</details>

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


# For WHATSAPP higgest quality video 94MB limit, without sending as document.
As of 14 May 2025: (Android WhatsApp V2.25.14.76) HD LIMIT: 94MB, SD LIMIT: 67MB
### Two-Pass Encoding
## for 94MB video
calculate bitrate  
752000 / 349 = 2154  
94(desired file size) * 8(byte to bit) * 1000(MB to KB) / 349(**duration of video in seconds**) = 2154 (do multiplication first)  
2154 - 128 kBit/s (desired audio bitrate) = 2026 kBit/s video bitrate
```
ffmpeg -y -i input.mp4 -c:v libx265 -b:v 2026k -x265-params pass=1 -an -f null NUL && ^
ffmpeg -i input.mp4 -c:v libx265 -b:v 2026k -x265-params pass=2 -c:a aac -b:a 128k output.mp4
```
## for 94MB video without audio
calculate bitrate  
94 * 8000 / 349 = 2154  
94(desired file size) * 8(byte to bit) * 1000(MB to KB) / 349(**duration of video in seconds**) = 2154 (do multiplication first)  
752000 / [duration of video in seconds]
```
ffmpeg -y -i input.mp4 -c:v libx265 -b:v 2154k -x265-params pass=1 -an -f null NUL && ^
ffmpeg -i input.mp4 -c:v libx265 -b:v 2154k -x265-params pass=2 -an output_64MB.mp4
```
### for 94MB video without audio with Framerate of 30FPS
```
ffmpeg -y -i input.mp4 -c:v libx265 -b:v 2154k -r 30 -x265-params pass=1 -an -f null NUL && ^
ffmpeg -i input.mp4 -c:v libx265 -b:v 2154k -r 30 -x265-params pass=2 -an output_64MB.mp4
```
[Refrence](https://trac.ffmpeg.org/wiki/Encode/H.265#Ratecontrolmodes)  

## Speed up video and audio at the same time:
> Using a complex filtergraph (low quality),  
> For 3x: 
```
ffmpeg -i input.mp4 -filter_complex "[0:v]setpts=0.3*PTS[v];[0:a]atempo=3.0[a]" -map "[v]" -map "[a]" output.mp4
```
> For 2x: ```ffmpeg -i input.mp4 -filter_complex "[0:v]setpts=0.5*PTS[v];[0:a]atempo=2.0[a]" -map "[v]" -map "[a]" output.mp4```  

### Slow Down video and audio at the same time:
> raw bitstream method
```
ffmpeg -fflags +genpts -r 15 -i raw.h264 -i input.mp4 -map 0:v -c:v copy -map 1:a -af atempo=0.5 -movflags faststart output.mp4
```
[Refrence](https://trac.ffmpeg.org/wiki/How%20to%20speed%20up%20/%20slow%20down%20a%20video)  

## Speed Up or Slow Down a Video(without audio)  
> For 3x speed (LOW QUALITY) (to slow PTS*3)  
```ffmpeg -i 'input.mp4' -filter:v "setpts=PTS/3,fps=60" -an output.mp4```  
> For 3x speed (lossless) where 0.3 is 1/3 in decimal representation. *(this will create 100fps+ video, so -r 30 is MANDATORY afterwords)*  
```ffmpeg -itsscale 0.3 -i 'input.mp4' -c copy -an fast.mp4```  
  
## Change framerate  
> Change framerate without re-encoding *(won't reduce file size to 64MB afterwards, but still -r 30 is MANDATORY if using reduce size commands)*:  ```(./ffmpeg -y -i input.mp4 -an -c copy -f h264 seeing_noaudio.h264) ; (./ffmpeg -y -r 30 -i seeing_noaudio.h264 -an -c copy fps.mp4)```  
  
> [!TIP]
> All links are saved at Internet Archive [Wayback Machine](https://web.archive.org)
