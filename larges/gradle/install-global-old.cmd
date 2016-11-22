@setlocal
@set SCRIPT_SOURCE=%~dp0
@if "%SCRIPT_SOURCE:~-1%"=="\" @set SCRIPT_SOURCE=%SCRIPT_SOURCE:~0,-1%

@set APPNAME=gradle
@call %SCRIPT_SOURCE%\..\..\base\get-args.cmd %*
@if not "%ERROR_MSG%" == "" @goto :_Error


:FetchVersionList
@set RELEASE_URL=https://services.gradle.org/distributions/
@call "%VA_HOME%\base\download.cmd" "%RELEASE_URL%" "%TEMP%\gradle_release"
@if not "%ERROR_MSG%" == "" @goto :_Error

@echo.> "%VERSION_SPCES_FILE%"
@setlocal EnableDelayedExpansion
@for /F "tokens=* USEBACKQ" %%F IN (`FINDSTR  /R /C:"distributions/gradle" %TEMP%\gradle_release`) do @(
    @for /F "delims=- tokens=2,3 USEBACKQ" %%G IN ('%%F') do @(
        @set var1=%%H
        @if "!var1:~0,-2!" == "bin.zip" @(
            @set GRADLE_VER=%%G
            @REM gradle¤£¤À¬[ºc
            @echo %APPNAME%=%%G@any[bin]>> "%VERSION_SPCES_FILE%"
        )
    )
)
@endlocal
@call "%VA_HOME%\base\semver.cmd" --specs-file "%VERSION_SPCES_FILE%" --match "%REQUEST_SPEC%" --output-format env --logging
@if not "%ERROR_MSG%" == "" @goto :_Error


:FoundVersion
@set TARGETDIR=%REQUEST_TARGETDIR%
@set GRADLE_VER=%MATCH_VER%
@set GRADLE_FILE=gradle-%GRADLE_VER%-bin.zip
@set GRADLE_URL=https://services.gradle.org/distributions/%GRADLE_FILE%
@if "%REQUEST_NAME%" == "" @(
    @set NAME=gradle-%GRADLE_VER%
) else @(
    @set NAME=%REQUEST_NAME%
)
@set INSTALLER=%GRADLE_FILE%
@call "%VA_HOME%\base\download.cmd" "%GRADLE_URL%" "%TEMP%\%GRADLE_FILE%"  --skip-exists
@if not "%ERROR_MSG%" == "" @goto :_Error

@REM TARGETDIR, NAME, INSTALLER
@call "%VA_HOME%\base\print.cmd" debug task-info
@if "%DRYRUN%" == "1" @goto :_Done

@call "%VA_HOME%\base\unzip.cmd" "%TEMP%\%GRADLE_FILE%" "%TARGETDIR%\uncheck-gradle-%GRADLE_VER%" --delete-before
@if errorlevel 1 goto :_Error
@if exist "%TARGETDIR%\%NAME%" @rd /Q /S "%TARGETDIR%\%NAME%"
@move "%TARGETDIR%\uncheck-gradle-%GRADLE_VER%\gradle-%GRADLE_VER%" "%TARGETDIR%\%NAME%" > nul
@if errorlevel 1 @(
    @set ERROR_MSG=can not move folder
    @goto :_Error
)
@rd /Q /S "%TARGETDIR%\uncheck-gradle-%GRADLE_VER%"
@call "%VA_HOME%\base\gen-env.cmd" "gradle" "%GRADLE_VER%" "%TARGETDIR%\%NAME%" "GRADLE_HOME:$SCRIPT_SOURCE$;$GRADLE_HOME$\bin;" "%SCRIPT_SOURCE%\validate.cmd"
@set SETENV_PATH=%TARGETDIR%\%NAME%\set-env.cmd
@call "%VA_HOME%\base\validate.cmd" "%SCRIPT_SOURCE%\validate.cmd"
@goto :_Done


:_Error
@call "%VA_HOME%\base\done.cmd"
@endlocal
@goto :eof
:_Done
@call "%VA_HOME%\base\done.cmd" "%APPNAME%" "%MATCH_VER%"
@endlocal
@set /P VA_LAST_INSTALLED=<%TEMP%\va_last_installed
@goto :eof
