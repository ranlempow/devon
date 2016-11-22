@if "%VA_HOME%" == "" @set VA_HOME=%~dp0..

@set VALIDATE=1

@setlocal
@call "%SETENV_TARGET%" --info
@if not "%VA_INFO_APPNAME%" == "%APPNAME%" @(
	@endlocal
    @set VALIDATE=0
    @goto :Done
)
@endlocal

@setlocal
@call "%SETENV_TARGET%" --validate --quiet
@endlocal
@if errorlevel 1 @set VALIDATE=0

:Done
@if "%VALIDATE%" == "0" (
    @call "%VA_HOME%\base\print.cmd" warning message validate failed
) else (
    @call "%VA_HOME%\base\print.cmd" normal message validate gradle
)
@set VALIDATE=
@goto :eof