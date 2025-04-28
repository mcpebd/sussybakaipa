@echo off
setlocal enabledelayedexpansion

set "ipa=%~1"
set "mcpack=%~2"
set "subpack=%~3"

curl -L "%ipa%" -o input.ipa
curl -L "%mcpack%" -o input.mcpack

mkdir MCPACK
mkdir IPA
powershell -Command Expand-Archive -Path "input.ipa" -DestinationPath "IPA"
powershell -Command Expand-Archive -Path "input.mcpack" -DestinationPath "MCPACK"

for /d /r "MCPACK" %%D in (*) do (
    if exist "%%D\manifest.json" (
        set "mcpack=%%D"
    )
)

for %%M in (!mcpack!\renderer\materials\*.material.bin) do (
    copy /d /b "%%~M" "!ipa!\Payload\minecraftpe.app\data\renderer\materials"
)

if defined subpack (
    for %%M in (!mcpack!\subpacks\!subpack!\renderer\materials\*.material.bin) do (
        copy /d /b "%%~M" "!ipa!\Payload\minecraftpe.app\data\renderer\materials"
    )
)

powershell -Command Compress-Archive -Path "%ipa%\*" -DestinationPath "output.ipa"
