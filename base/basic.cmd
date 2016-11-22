@rem input: %0
@rem output: VA_HOME, VA_CMD, SCRIPT_SOURCE, SCRIPT_FOLDER, APPNAME

@if "%BASE_INIT%" == "1" @goto :eof
@pushd %~dp0..
@set VA_HOME=%CD%
@popd
@set VA_CMD="%VA_HOME%/base/dispatch.cmd"

@if "%~1" == "" @goto :end
@set SCRIPT_SOURCE=%~1
@set SCRIPT_FOLDER=%~dp1
@if "%SCRIPT_FOLDER:~-1%"=="\" @set SCRIPT_FOLDER=%SCRIPT_FOLDER:~0,-1%

@for %%F in ("%SCRIPT_FOLDER%") do @set APPNAME=%%~nxF

:end
@set BASE_INIT=1
