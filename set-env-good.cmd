@setlocal enabledelayedexpansion

@set SCRIPT_FOLDER=%~dp0
@if "%SCRIPT_FOLDER:~-1%"=="\" @set SCRIPT_FOLDER=%SCRIPT_FOLDER:~0,-1%
@set SETENV_PATH=%~0

@set "FINAL_RET_SCRIPT=if defined FAILED cmd /C exit /b 1"
@if "%~1" == "--info" @call :GetInfo
@if "%~1" == "" @call :SetEnv
@if "%~1" == "--set" @call :SetEnv
@if "%~1" == "--clear" @call :ClearEnv
@if "%~1" == "--validate" @call :Validate
@if "%~1" == "--before-move" @call :BeforeMove
@if "%~1" == "--after-move" @call :AfterMove
@set "FINAL_RET_SCRIPT=!RET_SCRIPT! ^& !FINAL_RET_SCRIPT!"
@for %%x in (%RET_VAR%) do @(
    call set "value=%%%%x%%"
    set FINAL_RET_SCRIPT=call set ^"%%x=!value!^" ^& !FINAL_RET_SCRIPT!
)
@endlocal & %FINAL_RET_SCRIPT%
@goto :eof


:GetInfo
@set VA_INFO_APPNAME=ansicon
@set VA_INFO_VERSION=1.66
@set RET_VAR=VA_INFO_APPNAME VA_INFO_VERSION
@goto :eof

:SetEnv
@if not "%VA_ANSICON_BASE%" == "" @call %VA_ANSICON_BASE%\set-env.cmd --clear
@set VA_ANSICON_BASE=%SCRIPT_FOLDER%
@set PATH=%SCRIPT_FOLDER%\x64;%PATH%
@set RET_VAR=PATH VA_ANSICON_BASE
@goto :eof

:ClearEnv
@if not "%VA_ANSICON_BASE%" == "%SCRIPT_FOLDER%" @goto :eof
@set VA_ANSICON_BASE=
@call @set PATH=%%PATH:%SCRIPT_FOLDER%\x64;=%%
@set RET_VAR=PATH VA_ANSICON_BASE
@goto :eof

rem :ValidateFailed
rem @set FAILED=1
rem @if not "%QUIET%" == "1" @echo "failed"
rem @goto :eof
rem @rem TODO: use `@goto :Quit` for self test'
rem @rem TODO: use `@call :ClearEnv` for self test
rem :ValidateSuccess
rem @if not "%QUIET%" == "1" @echo "ok"
rem @goto :eof
rem @rem TODO: use `@goto :Quit` for self test
rem @rem TODO: use `@call :ClearEnv` for self test

:Validate
@call :GetInfo
@call :SetEnv
@set CHECK_EXIST=
@set CHECK_CMD=ansicon.exe --help
@set CHECK_LINEWORD=Freeware
@set CHECK_OK=Version %VA_INFO_VERSION%

@goto ValidateSuccess
@goto :eof

:BeforeMove
@goto :eof
:AfterMove
@goto :eof

