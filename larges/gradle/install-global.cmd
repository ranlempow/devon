@setlocal
@call "%~dp0\..\..\base\basic.cmd" %0
@call %VA_CMD% get-args %*
@if not "%ERROR_MSG%" == "" @goto :Error

@rem [X]function app_info
@if "%REQUEST_LOCATION%" == "system" @(
	@set ERROR_MSG=support location is global, locale
	@goto :Error
)

@REM function get_versions
:FetchVersionList
@set RELEASE_URL=https://services.gradle.org/distributions/
@call %VA_CMD% download "%RELEASE_URL%" "%TEMP%\gradle_release"
@if not "%ERROR_MSG%" == "" @goto :Error

@echo.> "%VERSION_SPCES_FILE%"
@setlocal EnableDelayedExpansion
@for /F "tokens=* USEBACKQ" %%F IN (`FINDSTR  /R /C:"distributions/gradle" "%TEMP%\gradle_release"`) do @(
    @for /F "delims=- tokens=2,3 USEBACKQ" %%G IN ('%%F') do @(
        @set var1=%%H
        @if "!var1:~0,-2!" == "bin.zip" @(
            @REM gradle¤£¤À¬[ºc
            @echo %APPNAME%=%%G@any[bin]>> "%VERSION_SPCES_FILE%"
        )
    )
)
@endlocal
@call %VA_CMD% semver --default-args
@if not "%ERROR_MSG%" == "" @goto :Error

@REM dispatch prepare_base -> prepare_local prepare_global prepare_system
:FoundVersionPoint
@set APPVER=%MATCH_VER%
@set INSTALLER=gradle-%APPVER%-bin.zip
@call %VA_CMD% download "%RELEASE_URL%%INSTALLER%" "%TEMP%\%INSTALLER%"  --skip-exists

@REM after DRY-RUN
@REM install_base -> install_local ...
@call %VA_CMD% before-install
@if not "%ERROR_MSG%" == "" @goto :Error

@call %VA_CMD% unzip "%TEMP%\%INSTALLER%" "%TEMP%\uncheck-gradle" --delete-before
@call %VA_CMD% move "%TEMP%\uncheck-gradle\gradle-%APPVER%" "%REAL_TARGETDIR%"
@call %VA_CMD% gen-env "%REAL_TARGETDIR%" "GRADLE_HOME:$SCRIPT_SOURCE$;$GRADLE_HOME$\bin;"

:Error
@call %VA_CMD% done
@endlocal
@goto :eof

:Validate
@for /F "tokens=* USEBACKQ" %%F in (`cmd /C gradle -v ^| findstr Gradle`) do @set CHECK_STRING=%%F
@if not "%CHECK_STRING%" == "Gradle %VA_INFO_VERSION%" @goto :ValidateFailed
@goto :ValidateSuccess
@goto :eof

::BeforeMove

::AfterMove

