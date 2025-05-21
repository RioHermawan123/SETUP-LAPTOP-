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
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 0 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------   
@echo off

setlocal
echo 1. OFFICE HOME 2021
echo 2. Copy OFFICE PRO PLUS 2021
echo 3. Copy OFFICE HOME 2024
set /p userInput="PILIH (1, 2, atau 3) atau ENTER(2x) Untuk Skip : "

if "%userInput%"=="" (
    echo No input provided. No action taken.
) else if "%userInput%"=="1" (
    echo No action taken for OFFICE HOME 2021.
) else if "%userInput%"=="2" (
    echo COPYING OFFICE PRO PLUS 2021
    xcopy "%~d0\ProPlus2021Retail.img" "C:\ProgramData" /Y
) else if "%userInput%"=="3" (
    echo COPYING OFFICE HOME 2024
    xcopy "%~d0\Home2024Retail.img" "C:\ProgramData" /Y
) else (
    echo Invalid option selected. No action taken.
)

echo Starting file copy...
xcopy %~d0\finishing_project\copier.bat C:\ProgramData
xcopy %~d0\finishing_project C:\ProgramData\finishing_project /E /H /C /I
echo File copy completed.
:: Get the system manufacturer

for /f "tokens=2 delims=:" %%i in ('systeminfo ^| find "System Manufacturer"') do set "Manufacturer=%%i"

:: Trim leading spaces
set "Manufacturer=%Manufacturer:~1%"

:: Check if Manufacturer contains "HP" or "HUAWEI"
echo %Manufacturer% | findstr /i "HP HUAWEI" >nul
if %errorlevel%==0 (
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v "HPAutoRunCopier" /t REG_SZ /d "C:\ProgramData\copier.bat" /f
	reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE /v BypassNRO /t REG_DWORD /d 1 /f
	shutdown /r /t 0
) else (
    start %Windir%\System32\Sysprep\Sysprep.exe /Oobe /Reboot /Unattend:%~d0\finishing_project\Unattend.xml

)

endlocal
