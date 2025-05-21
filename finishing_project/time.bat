:: ### START UAC SCRIPT ###

if "%2"=="firstrun" exit
cmd /c "%0" null firstrun

if "%1"=="skipuac" goto skipuacstart

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (shift & goto gotPrivileges)

setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs"
ECHO UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs"
"%temp%\OEgetPrivileges.vbs"
exit /B

:gotPrivileges

setlocal & pushd .

cd /d %~dp0
cmd /c "%0" skipuac firstrun
cd /d %~dp0

:skipuacstart

if "%2"=="firstrun" exit

:: ### END UAC SCRIPT ###

:: ### START OF YOUR OWN BATCH SCRIPT BELOW THIS LINE ###
::harus admin
@echo off
setlocal enabledelayedexpansion
set "drive=C"

for %%d in (C D) do (
    manage-bde -status %%d: | find "Conversion Status" | find /i "Fully Encrypted" >nul
    if %errorlevel% equ 0 (
        echo Drive %%d sudah encrypted. Sedang Decrypting...
        manage-bde -off %%d:
    ) else (
        echo Drive %%d sudah decrypted.
    )
)
endlocal

    net start W32Time
    w32tm /resync
    echo sync complete

