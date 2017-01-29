::: function BrickvDownload(Url, Output, Cookie=?, skip_exists=N) delayedexpansion
if "%FORCE%" == ""  if "%skip_exists%" == "1" set SkipExists=1

set err=
set ErrorFile=%TEMP%\download_error
del %ErrorFile% 2>nul

if "%Url%" == "" error("Url not specific")
if "%Output%" == "" error("Output not specific")

if "%SkipExists%" == "1" if exist "%Output%" (
    call :PrintMsg normal cached %Output%
    return
)
call :PrintMsg normal fetch %Url%

#include(ScriptText, "psdownloader.ps1")
set PS_Args=$url='%Url%';$output='%Output%';$Cookie='%Cookie%';$SkipExists='%SkipExists%';$errorFile='%ErrorFile%'
PowerShell -Command "%PS_Args%;!ScriptText:"=!"
if errorlevel 1 set err=1
if exist "%ErrorFile%" set /P dl_error= < "%ErrorFile%"
if "%err%" == "1" error("download %Url% is failed: %dl_error%")

call :PrintMsg info write $output

::: endfunc

#include("print.cmd")
