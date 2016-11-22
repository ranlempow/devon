@rem require: REQUEST_*, APPNAME, APPVER, INSTALLER
@rem output: TARGETDIR, REAL_TARGET, BACK_TARGET, NAME
@if "%VA_HOME%" == "" @set VA_HOME=%~dp0..

@if not "%ERROR_MSG%" == "" @goto :Error

@set TARGETDIR=%REQUEST_TARGETDIR%
@if "%REQUEST_NAME%" == "" @(
    @set NAME=%APPNAME%-%APPVER%
) else @(
    @set NAME=%REQUEST_NAME%
)

@call "%VA_HOME%\base\print.cmd" debug task-info
@if "%DRYRUN%" == "1" @(
	@set ERROR_MSG=DRYRUN
	@goto :Error
)
@set REAL_TARGET=%TARGETDIR%\%NAME%
@set BACK_TARGET=%TARGETDIR%\backupfor-%APPNAME%
@if exist "%REAL_TARGET%" @call "%VA_HOME%\base\move.cmd" "%REAL_TARGET%" "%BACK_TARGET%"

:Error