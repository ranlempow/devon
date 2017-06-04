@REM SETUPS記得要加引號, 要不然會解析錯誤

::: function BrickvGenEnv(TARGET, APPNAME, APPVER, SETUPS=) delayedexpansion

call :GenEnvInlines
set SETENV_TARGET=%TARGET%\set-env.cmd

echo.> %SETENV_TARGET%
@REM 讀取樣板並取代 APPNAME, 建立腳本檔
call :WriteTextEnv SetEnvBeginTemplate

call :WriteTextEnv SetEnvSetTemplate
call :WriteSetup set-env
if not defined %APPNAME%_setenv_script set %APPNAME%_setenv_script=@goto :eof
call :WriteTextEnv %APPNAME%_setenv_script

@REM clear-env
call :WriteTextEnv SetEnvClearTemplate
call :WriteSetup clear-env
if not defined %APPNAME%_clearenv_script set %APPNAME%_clearenv_script=@goto :eof
call :WriteTextEnv %APPNAME%_clearenv_script


@REM validate
call :WriteTextEnv SetEnvValidateTemplate
if not defined %APPNAME%_validate_script set %APPNAME%_validate_script=@goto :eof
if defined CHECK_EXIST call :WriteTextEnv CHECK_EXIST_TEMPLATE
if defined CHECK_EXEC call :WriteTextEnv CHECK_EXEC_TEMPLATE
if defined CHECK_CMD call :WriteTextEnv CHECK_CMD_TEMPLATE
call :WriteTextEnv %APPNAME%_validate_script

@REM patchmoved
echo :BeforeMove>> "%SETENV_TARGET%"
if not defined %APPNAME%_beforemove_script set %APPNAME%_beforemove_script=@goto :eof
call :WriteTextEnv %APPNAME%_beforemove_script

@echo :AfterMove>> "%SETENV_TARGET%"
if not defined %APPNAME%_aftermove_script set %APPNAME%_aftermove_script=@goto :eof
call :WriteTextEnv %APPNAME%_aftermove_script

@echo :Remove>> "%SETENV_TARGET%"
if not defined %APPNAME%_remove_script set %APPNAME%_remove_script=@goto :eof
call :WriteTextEnv %APPNAME%_remove_script

@REM 寫入腳本後段, 並且把'$'改成'%'
call :WriteTextEnv SetEnvEndTemplate
call :WriteScriptFinal
call :PrintMsg debug setenv %SETENV_TARGET%
::: endfunc

:WriteTextEnv
call :WriteText %~1 "%SETENV_TARGET%" --append
goto :eof


::: function WriteText(VarName, TargetFile, Append=N) delayedexpansion
call (
    (echo,!%VarName%!)>%TMP%\_need_crlf
)
if "%Append%" == "1" (
    more %TMP%\_need_crlf>>%TargetFile%
) else (
    more %TMP%\_need_crlf>%TargetFile%
)
::: endfunc

::: function WriteScriptFinal()
powershell -Command "(Get-Content '%SETENV_TARGET%') | ForEach-Object { $_^\n^
 -replace '\${APPNAME}', '%APPNAME%'.ToUpper()^\n^
 -replace '\${AppNameSmall}', '%APPNAME%'^\n^
 -replace '\${AppCustomName}', '%APPCUSTOMNAME%'^\n^
 -replace '\${AppVersion}', '%APPVER%'^\n^
 -replace '\${CheckExist}', '%CHECK_EXIST%'^\n^
 -replace '\${CheckExec}', '%CHECK_EXEC%'^\n^
 -replace '\${CheckExecArgs}', '%CHECK_EXEC_ARGS%'^\n^
 -replace '\${CheckCmd}', '%CHECK_CMD%'^\n^
 -replace '\${CheckLineword}', '%CHECK_LINEWORD%'^\n^
 -replace '\${CheckOk}', '%CHECK_OK%'^\n^
 -replace '\$', '%%'^\n^
} | Set-Content '%SETENV_TARGET%'"
::: endfunc


:WriteSetup
@REM 解析輸入變數 "a;b:2;c" -> { a: , b:2, c: } ( {key:value, ...} )
@REM value=NULL時, 則key帶表要加入PATH的路徑
@set OUTTYPE=%1
@set LONG=%SETUPS%

:Loop
@if "%LONG%" == "" @goto :eof
@if "%LONG:~0,1%" == ";" @(
    @set LONG=%LONG:~1%
    @goto :Loop
)


@set REST=%LONG:*;=%
@if "%REST%" == "" (
    @set PART=%LONG%
    @set LONG=
) else (
@if not "%REST%" == "%LONG%" @(
    @call set PART=%%LONG:%REST%=%%
    @set LONG=%REST%
) else @(
    @set PART=%LONG%
    @set LONG=
))


@if "%PART:~-1%" == ";" @set PART=%PART:~0,-1%
@call :ParseKeyValue %PART%
@goto :Loop


:ParseKeyValue

@set FULL=%1
@call set "LAST=%FULL:*:=%"
@if "%LAST%" == "%FULL%" @(
    @set HEAD=%FULL%
    @set LAST=
) else @(
    @call set HEAD=%%FULL::%LAST%=%%
)
@call :WriteKeyValue %HEAD% %LAST%
@goto :eof


:WriteKeyValue
@REM 將key,value輸出到兩個腳本
@set KEY=%1
@set VALUE=%2
@if "%VALUE%" == "" @(
    @if "%OUTTYPE%" == "set-env" @echo.@set PATH=%KEY%;$PATH$>> "%SETENV_TARGET%"
    @if "%OUTTYPE%" == "clear-env" @echo.@set PATH=^!PATH:%KEY%;=^!>> "%SETENV_TARGET%"
) else @(
    @if "%OUTTYPE%" == "set-env" @echo.@set %KEY%=%VALUE%>> "%SETENV_TARGET%"
    @if "%OUTTYPE%" == "clear-env" @echo.@set %KEY%=>> "%SETENV_TARGET%"
    @echo.@set RET_VAR=%%RET_VAR%% %KEY%>> "%SETENV_TARGET%"
)
@goto :eof














:GenEnvInlines


::: inline(SetEnvBeginTemplate)
@setlocal enabledelayedexpansion

@set SCRIPT_FOLDER=%~dp0
@if "%SCRIPT_FOLDER:~-1%"=="\" @set SCRIPT_FOLDER=%SCRIPT_FOLDER:~0,-1%
@set SETENV_PATH=%~0

@if "%~2" == "--quiet" @set QUIET=1
@if "%~1" == "--info" @call :GetInfo
@if "%~1" == "" @call :SetEnv
@if "%~1" == "--set" @call :SetEnv
@if "%~1" == "--clear" @call :ClearEnv
@if "%~1" == "--validate" @call :Validate
@if "%~1" == "--before-move" @call :BeforeMove
@if "%~1" == "--after-move" @call :AfterMove

@if defined VALID_ERR (
    if defined QUIET echo Validate Failed: %VALID_ERR%
    set FAILED=1
)
@set "FINAL_RET_SCRIPT=if [%FAILED%] == [1] cmd /C exit /b 1"
@if defined RET_SCRIPT set "FINAL_RET_SCRIPT=!RET_SCRIPT! ^& !FINAL_RET_SCRIPT!"
@for %%x in (%RET_VAR%) do @(
    call set "value=%%%%x%%"
    set "FINAL_RET_SCRIPT=call set ^"%%x=!value!^" ^& !FINAL_RET_SCRIPT!"
)
@endlocal & %FINAL_RET_SCRIPT%
@goto :eof


:GetInfo
@set VA_INFO_APPNAME=${AppNameSmall}
@set VA_INFO_VERSION=${AppVersion}
@set VA_INFO_CUSTOMNAME=${AppCustomName}
@if defined QUIET (
    echo APPNAME=%VA_INFO_APPNAME%
    echo VERSION=%VA_INFO_VERSION%
    echo CUSTOMNAME=%VA_INFO_CUSTOMNAME%
)
@set RET_VAR=VA_INFO_APPNAME VA_INFO_VERSION VA_INFO_CUSTOMNAME
@goto :eof
::: endinline

::: inline(SetEnvSetTemplate)
:SetEnv
@if not "%VA_${APPNAME}_BASE%" == "" @call %VA_${APPNAME}_BASE%\set-env.cmd --clear
@set VA_${APPNAME}_BASE=%SCRIPT_FOLDER%
@set RET_VAR=VA_${APPNAME}_BASE PATH
::: endinline


::: inline(SetEnvClearTemplate)
:ClearEnv
@if not "%VA_${APPNAME}_BASE%" == "%SCRIPT_FOLDER%" @goto :eof
@set VA_${APPNAME}_BASE=
@set RET_VAR=VA_${APPNAME}_BASE PATH

::: endinline


::: inline(SetEnvValidateTemplate)
:Validate
@call :GetInfo
@call :SetEnv
@set RET_VAR=VALID_ERR
@set VALID_ERR=
::: endinline


::: inline(CHECK_EXIST_TEMPLATE)
    @set CHECK_EXIST=${CheckExist}
    @if not exist "%SCRIPT_FOLDER%\%CHECK_EXIST%" @(
        set "VALID_ERR=%SCRIPT_FOLDER%\%CHECK_EXIST% not exist" & goto :eof
    )
::: endinline

::: inline(CHECK_EXEC_TEMPLATE)
    @set CHECK_EXEC=${CheckExec}
    @set CHECK_EXEC_ARGS=${CheckExecArgs}
    @if not exist "%SCRIPT_FOLDER%\%CHECK_EXEC%" @(
        set "VALID_ERR=%SCRIPT_FOLDER%\%CHECK_EXEC% not exist" & goto :eof
    ) else (
        "%SCRIPT_FOLDER%\%CHECK_EXEC%" %CHECK_EXEC_ARGS%
        if errorlevel 1 (set "VALID_ERR=%SCRIPT_FOLDER%\%CHECK_EXEC% execute failed" & goto :eof)
    )
::: endinline

::: inline(CHECK_CMD_TEMPLATE)
    @set CHECK_CMD=${CheckCmd}
    @set CHECK_LINEWORD=${CheckLineword}
    @set CHECK_OK=${CheckOk}
    @if not "%CHECK_OK%" == "" @(
        if "%CHECK_LINEWORD%" == "" (
            for /F "tokens=* USEBACKQ" %%F in (`cmd /C %CHECK_CMD%`) do @set CHECK_STRING=%%F
        ) else (
            for /F "tokens=* USEBACKQ" %%F in (`cmd /C %CHECK_CMD% ^| findstr %CHECK_LINEWORD%`) do @set CHECK_STRING=%%F
        )
        if "!CHECK_STRING:%CHECK_OK%=!" == "%CHECK_STRING%" (
            set "VALID_ERR=validate failed not match %CHECK_STRING% != %CHECK_OK%"
            goto :eof
        )
    ) else (
        cmd /C /D %CHECK_CMD%
        if errorlevel 1 (set "VALID_ERR=execute validate command failed" & goto :eof)
    )
::: endinline



::: inline(SetEnvEndTemplate)
::: endinline

goto :eof

#include("print.cmd")
