@call %~dp0..\..\base\getargs.cmd %*
@if errorlevel 1 @goto :_Error
@if [%REQUEST_ARCH%] == [] @set REQUEST_ARCH=x32
if "%REQUEST_ARCH%" == "x32" @set NODE_ARCH=x86
if "%REQUEST_ARCH%" == "x64" @set NODE_ARCH=x64

set NODE_RELEASE_FILE=win-%NODE_ARCH%-msi
start "jq" /wait cmd /C type index.json ^| jq-win64.exe -c ". | map(select(.files |  contains([\"%NODE_RELEASE_FILE%\"]))) | .[] | [.version, .npm]" ^> filter

rem set /P LINE=<filter

for /F "delims=. tokens=1,2,3" %%A in ("%REQUEST_VER%") do (
    set REQUEST_MAJOR=%%A
    set REQUEST_MINOR=%%B
    set REQUEST_HOTFIX=%%C
)
@for /F "tokens=*" %%A in (filter) do @call :MatchVer "%%A"

goto :D

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

:D
echo %NODE_VER%
echo %NPM_VER%

set NODE_VER=
set NPM_VER=
