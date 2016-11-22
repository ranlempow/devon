@rem require: REAL_TARGET, BACK_TARGET, APPNAME, MATCH_VER
@if "%VA_HOME%" == "" @set VA_HOME=%~dp0..

@if not "%ERROR_MSG%" == "" @(
	@if not "%ERROR_MSG%" == "DRYRUN" @(
		@REM rollback
		@if exist "%REAL_TARGET%" @rd /Q /S "%REAL_TARGET%"
	    @if exist "%BACK_TARGET%" @move "%BACK_TARGET%" "%REAL_TARGET%" > null
		@goto :Error
	)
) else @(
	@REM commit
	@if exist "%BACK_TARGET%" @rd /Q /S "%BACK_TARGET%"
)

@if "%DRYRUN%" == "1" @(
    @call "%VA_HOME%\base\print.cmd" normal message skip "%APPNAME%@%MATCH_VER% at %REAL_TARGET%"
) else @(
    @call "%VA_HOME%\base\print.cmd" normal message installed "%APPNAME%@%MATCH_VER% at %REAL_TARGET%"
    ::@echo %TARGETDIR%\%NAME% > "%TEMP%\va_last_installed"
)
@cmd /C exit /b 0
@goto :eof

:Error
@call "%VA_HOME%\base\print.cmd" error message error "%ERROR_MSG%"
@cmd /C exit /b 1
@goto :eof
