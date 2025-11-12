@echo off
setlocal enabledelayedexpansion

set "ipa=%~1"
set "mcpack=%~2"
set "subpack=%~3"

curl -L "%ipa%" -o input.ipa
curl -L "%mcpack%" -o input.mcpack

mkdir MCPACK
mkdir IPA

echo Exracting IPA...
rem powershell -Command Expand-Archive -Path "input.ipa" -DestinationPath "IPA"
7z x input.ipa -oIPA
echo Done exracting IPA...

echo Exracting MCPACK...
rem powershell -Command Expand-Archive -Path "input.mcpack" -DestinationPath "MCPACK"
7z x input.mcpack -oMCPACK
echo Done exracting MCPACK...

if exist "MCPACK\manifest.json" (
    set "mcpack=MCPACK"
) else (
    for /d /r "MCPACK" %%D in (*) do (
        if exist "%%D\manifest.json" (
            set "mcpack=%%D"
            goto skip_loop
        )
    )
)
:skip_loop
echo MCPACK folder is: !mcpack!
pushd !mcpack!
tree /f /a
popd

tree /f /a

for %%M in (!mcpack!\renderer\materials\*.material.bin) do (
    echo copy /d /b "%%~M" "IPA\Payload\minecraftpe.app\data\renderer\materials"
    copy /d /b "%%~M" "!ipa!\Payload\minecraftpe.app\data\renderer\materials"
)

if defined subpack (
    for %%M in (!mcpack!\subpacks\!subpack!\renderer\materials\*.material.bin) do (
        echo copy /d /b "%%~M" "IPA\Payload\minecraftpe.app\data\renderer\materials"
        copy /d /b "%%~M" "IPA\Payload\minecraftpe.app\data\renderer\materials"
    )
)

rem echo Zipping IPA...
rem powershell -Command Compress-Archive -Path "IPA\*" -DestinationPath "output.ipa"
rem 7z a output.ipa "IPA\*"
rem echo Done zipping IPA...
