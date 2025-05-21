@echo off
set "tempFile=%temp%\\delete_finishing_project.bat"
> "%tempFile%" echo @echo off
>>"%tempFile%" echo rmdir /s /q "%TEMP%\finishing_project"
REM >>"%tempFile%" echo del /Q "%~f0"
>>"%tempFile%" echo exit
exit
