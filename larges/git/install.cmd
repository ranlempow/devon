@setlocal
@set SCRIPT_SOURCE=%~dp0
@if "%SCRIPT_SOURCE:~-1%"=="\" @set SCRIPT_SOURCE=%SCRIPT_SOURCE:~0,-1%
@call %SCRIPT_SOURCE%\..\..\base\get-args.cmd %*
@if not "%ERROR_MSG%" == "" @goto :_Error

@if "%REQUEST_ARCH%" == "x86" @set GIT_ARCH=32
@if "%REQUEST_ARCH%" == "x64" @set GIT_ARCH=64

::@if %REQUEST_LOCATION% == system @(
::    @goto :InstallSystem
::) else @(
::    @goto :InstallGlobal
::)

:MainInstall

@set RELEASE_URL=https://api.github.com/repos/git-for-windows/git/releases

@rem @echo finding git-for-windows download url...
@call %VA_HOME%\download.cmd "%RELEASE_URL%" "%TEMP%\git_release.json"
@if errorlevel 1 @goto :_Error


@echo. > "%TEMP%\git_release_filter"
@FOR /F "tokens=* USEBACKQ" %%F IN (`FINDSTR  /R /C:"browser_download_url" %TEMP%\git_release.json`) DO @(
    echo %%F >> "%TEMP%\git_release_filter"
)

@if not "%REQUEST_VAR%" == "" @(
    @set GIT_VER=%REQUEST_VAR%
    :: TODO: fiter arch
    @goto :FoundVersion
)


:: TODO: fiter arch
:FindNewestVersion
@FOR /F "tokens=* USEBACKQ" %%F IN (`FINDSTR  /R /C:"PortableGit-[0-9]*.[0-9]*.[0-9]*-%GIT_ARCH%" %TEMP%\git_release_filter`) DO @(
    @set LINE=%%F
    @goto :FindNewestVersion_Break
)
:FindNewestVersion_Break
@for /F "delims=: tokens=3" %%P in (%LINE%) do @(
   @set SFX_URL=https:%%P
)

@for /F "delims=/ tokens=8" %%P in ("%SFX_URL%") do @(
   @set SFX_NAME=%%P
)
@for /F "delims=- tokens=2,3" %%A in ("%SFX_NAME%") do @(
    @set GIT_VER=%%A
    @set GIT_ARCH=%%B
)


:FoundVersion
@set SFX_NAME=PortableGit-%GIT_VER%-%GIT_ARCH%-bit.7z.exe
@set LINE=
@FOR /F "tokens=* USEBACKQ" %%F IN (`FINDSTR  /R /C:"%SFX_NAME%" %TEMP%\git_release_filter`) DO @(
    @set LINE=%%F
    @goto :FoundVersion_Break
)
:FoundVersion_Break
@for /F "delims=: tokens=3" %%P in (%LINE%) do @(
   @set SFX_URL=https:%%P
)

@call %VA_HOME%\download.cmd "%SFX_URL%" "%TEMP%\%SFX_NAME%" --skip-exists
@if errorlevel 1 goto :_Error


@set SFXFILE=%TEMP%\%SFX_NAME%
@set TARGETDIR=%LOCALAPPDATA%\Programs\git-%GIT_VER%-%GIT_ARCH%-bit
@if exist %TARGETDIR% @(
    rd /Q /S %TARGETDIR%
)

@rem @echo installing %SFXFILE% to %TARGETDIR%
@"%SFXFILE%" -y -InstallPath="%TARGETDIR%"
@if errorlevel 1 @(
    @set "ERROR_MSG= 7z SFX self unpack failed"
    @goto :_Error
)

@goto :_Done


:_Error
@call "%VA_HOME%\base\done.cmd"
@endlocal
@goto :eof

:_Done
@call "%VA_HOME%\base\done.cmd" "Git" "%GIT_VER%"
@endlocal
@set /P VA_LAST_INSTALLED=<%TEMP%\va_last_installed
@goto :eof
