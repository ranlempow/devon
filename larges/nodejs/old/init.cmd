set BINDIR=%PROJECT_BASE%\bin
if not exist "%BINDIR%" (
    mkdir "%BINDIR%"
)


set APPSDIR=%BINDIR%\apps


set SCRIPT=For ^/F %%%%G in ^(^'dir ^/b %%~dp0^*^'^) do ^(
set SCRIPT=%SCRIPT% IF EXIST ^"%%~dp0%%%%G\set-env.cmd^" call ^"^%%~dp0%%%%G\set-env.cmd^" ^)

setlocal EnableDelayedExpansion
if not exist "%APPSDIR%" (
    mkdir "%APPSDIR%"
    echo !SCRIPT! > "%APPSDIR%\set-env.cmd"
)
setlocal DisableDelayedExpansion
set SCRIPT=

set NODEDIR=%APPSDIR%\node
if not exist "%NODEDIR%" (
    mkdir "%NODEDIR%"
)

if exist %NODEDIR%\node goto InstallNodeNodule
set NodeZipPath=
set /P NodeZipPath=where is node-5.7.1-standalone.zip?
"C:\Program Files\7-Zip\7z.exe" x %NodeZipPath% -o%NODEDIR%
@if [%NodeZipPath%] EQU [] (
    goto quit
)

set SCRIPT1=@set PATH=%%~dp0node;%%PATH%%
set SCRIPT2=@set PATH=%%PROJECT_BASE%%\node_modules\.bin;%%PATH%%
setlocal EnableDelayedExpansion
echo !SCRIPT1!  > "%NODEDIR%\set-env.cmd"
echo !SCRIPT2! >> "%NODEDIR%\set-env.cmd"
setlocal DisableDelayedExpansion
set SCRIPT=
