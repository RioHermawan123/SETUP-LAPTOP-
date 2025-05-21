@echo off
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------   
echo.
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



setlocal
set "exePath=%~d0\finishing_project\launcher.exe"
set "scriptPath=%~d0\finishing_project\copy.ps1"
"%exePath%" "%scriptPath%"
start %~d0\finishing_project\delete_temp.bat
exit

endlocal
