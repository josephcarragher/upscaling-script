@echo off
GOTO START
1. cut up mkv into images in folder (images)
2. upscale (waifuoutputs)
3. build back mkv from images (upscaledvid)
3.5. delete images, waifuoutputs
4. merge mkvs (merged)
5. delete files from intermediary folders

TODO:
Make output nice (mute stock, add more clear steps)
Maybe cut out mkvmerge for ffmpeg
:START

:: >NUL 2>&1

:: Locations for the original file folder, cut images, upscaled images, upscaled video, merged final product, and programs
set original=C:\Users\Joseph\Documents\upscalingwork\testing
set images=C:\Users\Joseph\Documents\upscalingwork\images
set upscaledimg=C:\Users\Joseph\Documents\upscalingwork\waifuoutputs
set upscaledvid=C:\Users\Joseph\Documents\upscalingwork\upscaledvid
set final=C:\Users\Joseph\Documents\upscalingwork\merged
set ffmpegloc=C:\Users\Joseph\Downloads\ffmpeg-2023-01-25-git-2c3107c3e9-full_build\bin
set mkvmergeloc=C:\Users\Joseph\Downloads\mkvtoolnix

Echo Origin folder: %original%
echo:

Echo Total file list:
for %%x in (%original%/*.mkv) do (
    echo %%~nx.mkv
)

echo:
setlocal enabledelayedexpansion
:: loop for each video to not mix up the decomposed images. above delayedexpansion is needed to have variables in a loop? idk why
for %%x in (%original%/*.mkv) do (
    Echo Working on %%~nx.mkv
    Echo Cutting up frames
    %ffmpegloc%\ffmpeg.exe -i "%original%\%%~nx.mkv" -qscale:v 1 -qmin 1 -qmax 1 "%images%\frame-%%06d.png" >NUL 2>&1
    
    Echo Upscaling
    C:\Users\Joseph\Downloads\realesrgan-ncnn-vulkan-20220424-windows\realesrgan-ncnn-vulkan.exe -i "%images%" -o "%upscaledimg%" -n realesr-animevideov3 -s 2 -g 1 >NUL 2>&1

    :: this requires knowing the fps of the video. batch cannot in herently do floats so after ffprobe gets the fps fraction, powershell is used to get the decimal
    for /F "delims=" %%L in ('%ffmpegloc%\ffprobe.exe -v error -select_streams v -of default^=noprint_wrappers^=1:nokey^=1 -show_entries stream^=r_frame_rate "%original%\%%~nx.mkv"') do (set "fps=%%L") >NUL 2>&1
    for /f "delims=" %%a in ('powershell -Command !fps!') do set result=%%a

    :: now that fps is found, ffmpeg can rebuild the video
    Echo Calculated fps: !result!
    Echo Rebuilding into video
    %ffmpegloc%\ffmpeg.exe -r !result! -i "%upscaledimg%\frame-%%06d.png" -c:v libx264 -r !result! -pix_fmt yuv420p "%upscaledvid%\%%~nx.mkv" >NUL 2>&1

    Echo %%~nx.mkv upscaled!
    Echo Deleting intermediary items
    cd %images%
    del *.png
    cd %upscaledimg%
    del *.png
    echo:
)
endlocal >NUL 2>&1 REM for some reason this sometimes spits out an error, sometimes not. so im muting it

Echo Merging MKVs
for %%x in (%original%/*.mkv) do "%mkvmergeloc%\mkvmerge.exe" -o "%final%\%%~nx.mkv" -D ( "%original%\%%~nx.mkv" ) -A -S -T -M -B --no-chapters ( "%upscaledvid%\%%~nx.mkv" ) >NUL 2>&1

Echo Deleting intermediary items
cd %upscaledvid%
del *.mkv

Echo Done
pause
