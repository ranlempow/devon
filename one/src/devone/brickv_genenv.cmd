@REM SETUPS記得要加引號, 要不然會解析錯誤
@REM @set APPNAME=%~1
@REM @set MATCH_VER=%~2

::: function BrickvGenEnv(TARGET, SETUPS=) delayedexpansion

call :GenEnvInlines

set SETENV_TARGET=%TARGET%\set-env.cmd

set APPNAME=app1
set MATCH_VER=1.0

if "%APPNAME%" == "" error("APPNAME undefined")
if "%MATCH_VER%" == "" error("MATCH_VER undefined")

echo.> %SETENV_TARGET%
@REM 讀取樣板並取代 APPNAME, 建立腳本檔
call :WriteScript SetEnvBeginTemplate
call :WriteScript SetEnvSetTemplate
call :WriteSetup set-env
echo @goto :eof>> "%SETENV_TARGET%"

@REM clear-env
call :WriteScript SetEnvClearTemplate
call :WriteSetup clear-env
echo @goto :eof>> "%SETENV_TARGET%"

@REM vaildate
call :WriteScript SetEnvVaildateTemplate

if not "!%APPNAME%_Vaildate!" == "" call WriteText "!%APPNAME%_Vaildate!" "%TEMP%\code" --append
echo @goto :eof>> "%SETENV_TARGET%"

@REM patchmoved
rem call :WriteScript SetEnvPatchMovedTemplate
echo :BeforeMove>> "%SETENV_TARGET%"
if not "!%APPNAME%_BeforeMove!" == "" call WriteText "!%APPNAME%_BeforeMove!" "%TEMP%\code" --append
echo @goto :eof>> "%SETENV_TARGET%"

@echo :AfterMove>> "%SETENV_TARGET%"
if not "!%APPNAME%_AfterMove!" == "" call WriteText "!%APPNAME%_AfterMove!" "%TEMP%\code" --append
echo @goto :eof>> "%SETENV_TARGET%"


@REM 寫入腳本後段, 並且把'$'改成'%'
call :WriteScript SetEnvEndTemplate
@powershell -Command "(Get-Content '%SETENV_TARGET%') | ForEach-Object { $_ -replace '\$', '%%' } | Set-Content '%SETENV_TARGET%'"

rem TODO: 移到更高層的地方
rem @if not "%NOCHECK%" == "1" if exist "%VAILDATE_SCRIPT%" @(
rem     @call "%VA_HOME%\base\vaildate.cmd" "%VAILDATE_SCRIPT%"
rem )

::: endfunc


::: function WriteText(VarName, TargetFile, Append=N) delayedexpansion
call (
    (echo:!%VarName%!)>%TMP%\_need_crlf
)
if "%Append%" == "1" (
    more %TMP%\_need_crlf>>%TargetFile%
) else (
    more %TMP%\_need_crlf>%TargetFile%
)
::: endfunc


::: function WriteScript(VarName)
call :WriteText %VarName% "%TEMP%\%VarName%"
powershell -Command "(Get-Content '%TEMP%\%VarName%') | ForEach-Object { $_ -replace '\${APPNAME}', '%APPNAME%'.ToUpper() -replace '\${AppNameSmall}', '%APPNAME%' -replace '\${AppVersion}', '%MATCH_VER%' } | Add-Content '%SETENV_TARGET%'"
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
    @if "%OUTTYPE%" == "set-env" @echo @set PATH=%KEY%;$PATH$>> "%SETENV_TARGET%"
    @if "%OUTTYPE%" == "clear-env" @echo @call @set PATH=$$PATH:%KEY%;=$$>> "%SETENV_TARGET%"
) else @(
    @if "%OUTTYPE%" == "set-env" @echo @set %KEY%=%VALUE%>> "%SETENV_TARGET%"
    @if "%OUTTYPE%" == "clear-env" @echo @set %KEY%=>> "%SETENV_TARGET%"
)
@goto :eof














:GenEnvInlines

::: inline(SetEnvBeginTemplate)
@set SCRIPT_SOURCE=%~dp0
@if "%SCRIPT_SOURCE:~-1%"=="\" @set SCRIPT_SOURCE=%SCRIPT_SOURCE:~0,-1%
@set SETENV_PATH=%~0

@if "%2" == "--quiet" @set QUIET=1
@if "%1" == "--info" @call :GetInfo
@if "%1" == "" @call :SetEnv
@if "%1" == "--set" @call :SetEnv
@if "%1" == "--clear" @call :ClearEnv
@if "%1" == "--check" @call :Vaildate
@if "%1" == "--vaildate" @call :Vaildate
@if "%1" == "--before-move" @call :BeforeMove
@if "%1" == "--after-move" @call :AfterMove
@goto :Quit

:GetInfo
@if "%2" == "appname" @(
    @echo ${AppNameSmall}
    @goto :eof
)
@if "%2" == "version" @(
    @echo ${AppVersion}
    @goto :eof
)
@set VA_INFO_APPNAME=${AppNameSmall}
@set VA_INFO_VERSION=${AppVersion}
@goto :eof
::: endinline

::: inline(SetEnvSetTemplate)
:SetEnv
@if not "%VA_${APPNAME}_BASE%" == "" @call %VA_${APPNAME}_BASE%\set-env.cmd --clear
@set VA_${APPNAME}_BASE=%SCRIPT_SOURCE%
::: endinline



::: inline(SetEnvClearTemplate)
:ClearEnv
@if not "%VA_${APPNAME}_BASE%" == "%SCRIPT_SOURCE%" @goto :eof
@set BA_${APPNAME}_BASE=
::: endinline

::: inline(SetEnvVaildateTemplate)
:VaildateFailed
@if not "%QUIET%" == "1" @echo "failed"
@endlocal
@cmd /C exit /b 1
@goto :eof

:VaildateSuccess
@if not "%QUIET%" == "1" @echo "ok"
@endlocal
@cmd /C exit /b 0
@goto :eof

:Vaildate
@setlocal
@call :GetInfo
@call :SetEnv
::: endinline


::: inline(SetEnvPatchMovedTemplate)
:PatchMoved
::: endinline


::: inline(SetEnvEndTemplate)
:Quit
@set SCRIPT_SOURCE=
@set SETENV_PATH=
:::
goto :eof
