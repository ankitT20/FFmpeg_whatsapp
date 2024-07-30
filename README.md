# FFmpeg_whatsapp
For Reducing video quality using FFmpeg

[FFmpeg download website for windows](https://www.gyan.dev/ffmpeg/builds/#release-builds)      
[Direct Download link](https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z) use [7-Zip](https://www.7-zip.org/) for extraction, ffmpeg.exe will be inside bin folder, copy it to video location, and rename desired video to input.mp4

# For Reducing video quality
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
