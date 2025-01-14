@echo off
echo Converting all OGG's to MP3's...
setlocal
set "ASSETS_PATH=..\..\assets"
for /r "%ASSETS_PATH%" %%F in (*.ogg) do (
    echo Converting %%F
    ffmpeg -hide_banner -loglevel error -y -i "%%F" "%%~dpnF.mp3"
)
endlocal
echo Converted all OGG's to MP3's!