GOTO START
1. pull mp4 from mkv (mp4)
2. cut up mp4 into images in folder (images)
3. upscale (waifuoutputs)
4. build back mp4 from images (upscaledvid)
4.5. delete images, waifuoutputs
5. reencode mp4 as mkv (newmkvs)
6. merge mkvs (merged)
7. delete files from intermediary folders

TODO:
Make output nice (mute stock, add more clear steps)
Make all file locations variables for ez pz moving around
Maybe cut out mkvmerge for ffmpeg

:START
@echo off

:: >NUL 2>&1
:: this is for the original mkv folder
:: set original=C:\Users\Joseph\Downloads\[a4e]Birdy_the_Mighty_OVA
set original=C:\Users\Joseph\Documents\upscalingwork\testing
Echo Origin folder: %original%
echo:

:: 1. mkv to mp4
Echo Converting from MKV to MP4
Echo Total file list:
for %%x in (%original%/*.mkv) do (
    C:\Users\Joseph\Downloads\ffmpeg-2023-01-25-git-2c3107c3e9-full_build\bin\ffmpeg.exe -i "%original%\%%~nx.mkv" -codec copy "C:\Users\Joseph\Documents\upscalingwork\mp4\%%~nx.mp4"
    echo %%~nx.mkv
)

echo:
setlocal enabledelayedexpansion
:: loop for each video to not mix up the decomposed images. above delayedexpansion is needed to have variables in a loop? idk why this is retarded
for %%x in (C:\Users\Joseph\Documents\upscalingwork\mp4/*.mp4) do (
    :: 2. cutting video into images
    Echo Working on %%~nx
    ::C:\Users\Joseph\Downloads\ffmpeg-2023-01-25-git-2c3107c3e9-full_build\bin\ffmpeg.exe -i "C:\Users\Joseph\Documents\upscalingwork\mp4\%%~nx.mp4" -qscale:v 1 -qmin 1 -qmax 1 "C:\Users\Joseph\Documents\upscalingwork\images\frame-%%06d.png"
    C:\Users\Joseph\Downloads\ffmpeg-2023-01-25-git-2c3107c3e9-full_build\bin\ffmpeg.exe -i "C:\Users\Joseph\Documents\upscalingwork\testing\%%~nx.mkv" -qscale:v 1 -qmin 1 -qmax 1 "C:\Users\Joseph\Documents\upscalingwork\images\frame-%%06d.png"
    
    :: 3. upscaling
    Echo Upscaling
    C:\Users\Joseph\Downloads\realesrgan-ncnn-vulkan-20220424-windows\realesrgan-ncnn-vulkan.exe -i "C:\Users\Joseph\Documents\upscalingwork\images" -o "C:\Users\Joseph\Documents\upscalingwork\waifuoutputs" -n realesr-animevideov3 -s 2 -g 1

    :: 4. rebuilding upscaled images to video
    Echo Rebuilding into video
    :: this requires knowing the fps of the video. batch cannot in herently do floats so after ffprobe gets the fps fraction, powershell is used to get the decimal
    for /F "delims=" %%L in ('C:\Users\Joseph\Downloads\ffmpeg-2023-01-25-git-2c3107c3e9-full_build\bin\ffprobe.exe -v error -select_streams v -of default^=noprint_wrappers^=1:nokey^=1 -show_entries stream^=r_frame_rate "C:\Users\Joseph\Documents\upscalingwork\mp4\%%~nx.mp4"') do (set "fps=%%L")
    for /f "delims=" %%a in ('powershell -Command !fps!') do set result=%%a
    :: now that fps is found, ffmpeg can rebuild the video
    Echo Calculated fps: !result!
    C:\Users\Joseph\Downloads\ffmpeg-2023-01-25-git-2c3107c3e9-full_build\bin\ffmpeg.exe -r !result! -i "C:\Users\Joseph\Documents\upscalingwork\waifuoutputs\frame-%%06d.png" -c:v libx264 -r !result! -pix_fmt yuv420p "C:\Users\Joseph\Documents\upscalingwork\upscaledvid\%%~nx.mp4"

    :: 4.5 deleting items from intermediary image related folders
    Echo Deleting intermediary items
    cd C:\Users\Joseph\Documents\upscalingwork\waifuoutputs
    del *.png
    cd C:\Users\Joseph\Documents\upscalingwork\images
    del *.png
    echo:
)
endlocal

::set original=C:\Users\Joseph\Documents\upscalingwork\testing

:: 5. mp4 to mkv
Echo Convering all upscaled mp4 to mkv
:: idk why this sometimes makes the first file all lowercase, but in theory windows is case insensitive so...
for %%x in (C:\Users\Joseph\Documents\upscalingwork\upscaledvid/*.mp4) do C:\Users\Joseph\Downloads\ffmpeg-2023-01-25-git-2c3107c3e9-full_build\bin\ffmpeg.exe -i "C:\Users\Joseph\Documents\upscalingwork\upscaledvid\%%~nx.mp4" -codec copy "C:\Users\Joseph\Documents\upscalingwork\newmkvs\%%~nx.mkv"

:: 6. this loops through the original folder and newmkvs, merging them and storing into merged
Echo Merging MKVs
for %%x in (%original%/*.mkv) do "C:\Users\Joseph\Downloads\mkvtoolnix\mkvmerge.exe" -o "C:\Users\Joseph\Documents\upscalingwork\merged\%%~nx.mkv" -D ( "%original%\%%~nx.mkv" ) -A -S -T -M -B --no-chapters ( "C:\Users\Joseph\Documents\upscalingwork\newmkvs\%%~nx.mkv" )

:: 7. deleting leftover items from intermediary folders
Echo Deleting intermediary items
cd C:\Users\Joseph\Documents\upscalingwork\mp4
del *.mp4
cd C:\Users\Joseph\Documents\upscalingwork\newmkvs
del *.mkv
cd C:\Users\Joseph\Documents\upscalingwork\upscaledvid
del *.mp4


Echo Done
pause
