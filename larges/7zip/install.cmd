@setlocal
@set SCRIPT_SOURCE=%~dp0
@if "%SCRIPT_SOURCE:~-1%"=="\" @set SCRIPT_SOURCE=%SCRIPT_SOURCE:~0,-1%
@call %SCRIPT_SOURCE%\..\..\base\get-args.cmd %*
@if not "%ERROR_MSG%" == "" @goto :_Error


:MainInstall
@if "%REQUEST_ARCH%" == "x32" @set SENZIP_ARCH=
@if "%REQUEST_ARCH%" == "x64" @set SENZIP_ARCH=-x64
@if "%REQUEST_VER%" == "X" @(
    @REM default version
    @set SENZIP_VER=16.01
) else @(
    @set SENZIP_VER=%REQUEST_VER%
)
@for /F "delims=. tokens=1,2" %%A in ("%SENZIP_VER%") do @(
    @set SENZIP_MAJOR=%%A
    @set SENZIP_MINOR=%%B
)


:FoundVersion
@set SENZIP_NAME=7z%SENZIP_MAJOR%%SENZIP_MINOR%%SENZIP_ARCH%
@set SENZIP_URL=http://www.7-zip.org/a/%SENZIP_NAME%.msi
@set MSI_FILE=%TEMP%\%SENZIP_NAME%.msi
@call "%VA_HOME%\base\download.cmd" "%SENZIP_URL%" "%MSI_FILE%" --skip-exists
@if errorlevel 1 goto :_Error
@if %REQUEST_LOCATION% == system @(
    @goto :InstallSystem
) else @(
    @goto :InstallGlobal
)

:InstallGlobal
@set TARGETDIR=%REQUEST_TARGETDIR%
@set NAME=%REQUEST_NAME%
@if "%NAME%" == "" @set NAME=7-Zip-%SENZIP_VER%

@if "%DRYRUN%" == "1" @goto :_Done
@call "%VA_HOME%\base\msi.cmd" unpack "%MSI_FILE%" "\Files\7-Zip"
@if errorlevel 1 @goto :_Error
@call "%VA_HOME%\base\gen-env.cmd" "7-zip" "%SENZIP_VER%" "%TARGETDIR%\%NAME%" "$SCRIPT_SOURCE$;" "%SCRIPT_SOURCE%\validate.cmd"
@set SETENV_PATH=%TARGETDIR%\%NAME%\set-env.cmd
@call "%VA_HOME%\base\validate.cmd" "%SCRIPT_SOURCE%\validate.cmd"
@goto :_Done


:InstallSystem
@if "%DRYRUN%" == "1" @goto :_Done
@call "%VA_HOME%\base\msi.cmd" install "%MSI_FILE%"
@if errorlevel 1 @goto :_Error
@goto :_Done


:_Error
@call "%VA_HOME%\base\done.cmd"
@endlocal
@goto :eof


:_Done
@call "%VA_HOME%\base\done.cmd" "7zip" "%SENZIP_VER%"
@endlocal
@set /P VA_LAST_INSTALLED=<%TEMP%\va_last_installed
@goto :eof
