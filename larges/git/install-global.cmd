@call %~dp0..\..\base\getargs.cmd %*
@if errorlevel 1 @goto :_Error
@if [%REQUEST_ARCH%] == [] @set REQUEST_ARCH=x32
@if "%REQUEST_ARCH%" == "x32" @set GIT_ARCH=32
@if "%REQUEST_ARCH%" == "x64" @set GIT_ARCH=64


@set RELEASE_URL=https://api.github.com/repos/git-for-windows/git/releases

@echo finding git-for-windows download url...
@call %~dp0..\..\base\psdownloader.cmd "%RELEASE_URL%" "%TEMP%\git_release.json"
@if errorlevel 1 @(
    @set "ERROR_MSG=失敗:無法取得版本列表."
    @goto :_Error
)


@echo. > "%TEMP%\git_release_filter"
@FOR /F "tokens=* USEBACKQ" %%F IN (`FINDSTR  /R /C:"browser_download_url" %TEMP%\git_release.json`) DO @(
    echo %%F >> "%TEMP%\git_release_filter"
)

@if not [%REQUEST_VAR%] == [] @(
    @set GIT_VER=%REQUEST_VAR%
    @if "%REQUEST_ARCH%" == "x32" @(
         @goto :FoundVer
    )
    @if "%REQUEST_ARCH%" == "x64" @(
         @goto :FoundVer
    )
)


:FindNewestVer
@FOR /F "tokens=* USEBACKQ" %%F IN (`FINDSTR  /R /C:"PortableGit-[0-9]*.[0-9]*.[0-9]*-%GIT_ARCH%" %TEMP%\git_release_filter`) DO @(
    @set LINE=%%F
    @goto Break
)
:Break
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


:FoundVer
@set SFX_NAME=PortableGit-%GIT_VER%-%GIT_ARCH%-bit.7z.exe
@set LINE=
@FOR /F "tokens=* USEBACKQ" %%F IN (`FINDSTR  /R /C:"%SFX_NAME%" %TEMP%\git_release_filter`) DO @(
    @set LINE=%%F
    @goto :Break2
)
:Break2
@for /F "delims=: tokens=3" %%P in (%LINE%) do @(
   @set SFX_URL=https:%%P
)

@call %~dp0..\..\base\psdownloader.cmd "%SFX_URL%" "%TEMP%\%SFX_NAME%" --skip-exists
@if errorlevel 1 goto :Error


@set SFXFILE=%TEMP%\%SFX_NAME%
@set TARGETDIR=%LOCALAPPDATA%\Programs\git-%GIT_VER%-%GIT_ARCH%-bit
@if exist %TARGETDIR% @(
    rd /Q /S %TARGETDIR%
)

@echo installing %SFXFILE% to %TARGETDIR%
@"%SFXFILE%" -y -InstallPath="%TARGETDIR%"
@if errorlevel 1 @(
    @set "ERROR_MSG=執行安裝時失敗."
    @goto :_Error
)
@goto :_Done


:_Error
@echo.
@echo ==========================
@echo.
@echo %ERROR_MSG%
@echo.
@cmd /C exit /b 1
@goto :eof


:_Done
@echo.
@echo Done.
@cmd /C exit /b 0
@goto :eof

