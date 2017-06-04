@call %~dp0..\..\base\getargs.cmd %*
@if errorlevel 1 @goto :_Error
@if [%REQUEST_ARCH%] == [] @set REQUEST_ARCH=x32
if "%REQUEST_ARCH%" == "x32" @set NODE_ARCH=x86
if "%REQUEST_ARCH%" == "x64" @set NODE_ARCH=x64

@set RELEASE_URL=https://nodejs.org/dist/index.json

@call %~dp0..\..\base\psdownloader.cmd "%RELEASE_URL%" "%TEMP%\node_release.json"
@if errorlevel 1 @(
    @set "ERROR_MSG=失敗:無法取得版本列表."
    @goto :_Error
)


set NODE_RELEASE_FILE=win-%NODE_ARCH%-msi
@REM TODO:
set JQ=C:\Users\ran\Desktop\big_depend\larges\nodejs\jq-win64.exe
start "jq" /wait cmd /C type "%TEMP%\node_release.json" ^| "%JQ%" -c ". | map(select(.files |  contains([\"%NODE_RELEASE_FILE%\"]))) | .[] | [.version, .npm]" ^> filter


for /F "delims=. tokens=1,2,3" %%A in ("%REQUEST_VER%") do (
    set REQUEST_MAJOR=%%A
    set REQUEST_MINOR=%%B
    set REQUEST_HOTFIX=%%C
)
@for /F "tokens=*" %%A in (filter) do @call :MatchVer "%%A"
@if [%NODE_VER%] == [] (
    set ERROR_MSG=找不到適合版本.
    goto :_Error
)
goto :DownloadInstall

:MatchVer
@for /F "delims=, tokens=1,2" %%P in (%1) do @(
    @set _NODE_VER=%%P
    @set _NPM_VER=%%Q
)
@set _NODE_VER=%_NODE_VER:~3,-1%
@set _NPM_VER=%_NPM_VER:~1,-2%

@for /F "delims=. tokens=1,2,3" %%A in ("%_NODE_VER%") do @(
    @set _NODE_MAJOR=%%A
    @set _NODE_MINOR=%%B
    @set _NODE_HOTFIX=%%C
)

@if not "%REQUEST_MAJOR%" == "" if not "%REQUEST_MAJOR%" == "%_NODE_MAJOR%" goto :eof
@if not "%REQUEST_MINOR%" == "" if not "%REQUEST_MINOR%" == "%_NODE_MINOR%" goto :eof
@if not "%REQUEST_HOTFIX%" == "" if not "%REQUEST_HOTFIX%" == "%_NODE_HOTFIX%" goto :eof

@if [%NODE_VER%] == [] set NODE_VER=%_NODE_VER%
@if [%NPM_VER%] == [] set NPM_VER=%_NPM_VER%
@set _NODE_VER=
@set _NPM_VER=
@goto :eof

:DownloadInstall
set NODE_NAME=node-v%NODE_VER%-%NODE_ARCH%
@if [%REQUEST_TARGETDIR%] == [] @(
    @set TARGETDIR=%LOCALAPPDATA%\Programs\%NODE_NAME%
) else @(
    @set TARGETDIR=%REQUEST_TARGETDIR%
)

@REM TODO
if not exist "%TARGETDIR%" mkdir "%TARGETDIR%"

set NODE_URL=https://nodejs.org/dist/v%NODE_VER%/win-%NODE_ARCH%/node.exe
@set DOWNLOAD_SKIP=
@if [%FORCE%] == [] @set DOWNLOAD_SKIP=--skip-exists
@call %~dp0..\..\base\psdownloader.cmd "%NODE_URL%" "%TARGETDIR%\node.exe" %DOWNLOAD_SKIP%
@if errorlevel 1 goto :Error

:F_DownloadNPM
set NPM_URL=https://github.com/npm/npm/archive/v%NPM_VER%.zip
@call %~dp0..\..\base\psdownloader.cmd "%NPM_URL%" "%TEMP%\npm-v%NPM_VER%.zip" %DOWNLOAD_SKIP%
@if errorlevel 1 goto :Error

@mkdir "%TARGETDIR%\node_modules"
@call :_Unzip "%TEMP%\npm-v%NPM_VER%.zip" "%TARGETDIR%\node_modules"

:F_Setup:
@rename "%TARGETDIR%\node_modules\npm-%NPM_VER%" "npm"
@xcopy "%TARGETDIR%\node_modules\npm\bin\npm" "%TARGETDIR%\npm*" /K /Y
@xcopy "%TARGETDIR%\node_modules\npm\bin\npm.cmd" "%TARGETDIR%\npm.cmd*" /K /Y

goto :_Done



:_Unzip
set ZipFile=%~1
set ExtractTo=%~2
setlocal EnableDelayedExpansion
@rem Extract the contants of the zip file.
ECHO  set objShell = CreateObject("Shell.Application") > "%temp%\Unzip.vbs"
ECHO  set FilesInZip=objShell.NameSpace("!ZipFile!").items >> "%temp%\Unzip.vbs"
ECHO  objShell.NameSpace("!ExtractTo!").CopyHere(FilesInZip) >> "%temp%\Unzip.vbs"
setlocal DisableDelayedExpansion
"%temp%\Unzip.vbs"
@if errorlevel 1 @(
    @set "ERROR_MSG=啟動錯誤: 解壓縮失敗, 也許這不是正確的壓縮檔."
    @goto :_Error
)
@goto :eof

:_Error

:_Done
