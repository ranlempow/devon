@REM 第4個參數記得要加引號, 要不然會解析錯誤
@REM @set APPNAME=%~1
@REM @set APPVERSION=%~2

@set TARGET=%~1
@set SETUPS=%~2
@set VALIDATE_SCRIPT=%~3
@set PATCHMOVED_SCRIPT=%~4

@set SETENV_TARGET=%TARGET%\set-env.cmd
@set PATCHMOVED_TARGET=%TARGET%\patch-moved.cmd

@if not "%ERROR_MSG%" == "" @goto :Error

@REM 讀取樣板並取代 APPNAME, 建立腳本檔
@powershell -Command "(Get-Content '%~dp0set-env.begin.temp') | ForEach-Object { $_ -replace '\${APPNAME}', '%APPNAME%'.ToUpper() -replace '\${AppNameSmall}', '%APPNAME%' -replace '\${AppVersion}', '%MATCH_VER%' } | Set-Content '%SETENV_TARGET%'"
@powershell -Command "(Get-Content '%~dp0set-env.set.temp') | ForEach-Object { $_ -replace '\${APPNAME}', '%APPNAME%'.ToUpper() -replace '\${AppNameSmall}', '%APPNAME%' -replace '\${AppVersion}', '%MATCH_VER%' } | Add-Content '%SETENV_TARGET%'"
@call :WriteSetup set-env
@echo @goto :eof>> "%SETENV_TARGET%"

@REM clear-env
@powershell -Command "(Get-Content '%~dp0set-env.clear.temp') | ForEach-Object { $_ -replace '\${APPNAME}', '%APPNAME%'.ToUpper() -replace '\${AppNameSmall}', '%APPNAME%' -replace '\${AppVersion}', '%MATCH_VER%' } | Add-Content '%SETENV_TARGET%'"
@call :WriteSetup clear-env
@echo @goto :eof>> "%SETENV_TARGET%"

@REM validate
@powershell -Command "(Get-Content '%~dp0set-env.validate.temp') | ForEach-Object { $_ -replace '\${APPNAME}', '%APPNAME%'.ToUpper() -replace '\${AppNameSmall}', '%APPNAME%' -replace '\${AppVersion}', '%MATCH_VER%' } | Add-Content '%SETENV_TARGET%'"
::@if exist "%VALIDATE_SCRIPT%" @type "%VALIDATE_SCRIPT%">> "%SETENV_TARGET%"
@call :FindStrBetween "%SCRIPT_SOURCE%" ":Validate" "@goto :eof"
@if not "%START_INDEX%" == "" if not "%END_INDEX%" == "" @call :CopyLines "%SCRIPT_SOURCE%" %START_INDEX% %END_INDEX% "%SETENV_TARGET%"
@echo @goto :eof>> "%SETENV_TARGET%"

@REM patchmoved
@powershell -Command "(Get-Content '%~dp0set-env.patchmoved.temp') | ForEach-Object { $_ -replace '\${APPNAME}', '%APPNAME%'.ToUpper() -replace '\${AppNameSmall}', '%APPNAME%' -replace '\${AppVersion}', '%MATCH_VER%' } | Add-Content '%SETENV_TARGET%'"
::@if exist "%PATCHMOVED_SCRIPT%" @type "%PATCHMOVED_SCRIPT%">> "%SETENV_TARGET%"

@echo @goto :BeforeMove>> "%SETENV_TARGET%"
@call :FindStrBetween "%SCRIPT_SOURCE%" ":BeforeMove" "@goto :eof"
@if not "%START_INDEX%" == "" if not "%END_INDEX%" == "" @call :CopyLines "%SCRIPT_SOURCE%" %START_INDEX% %END_INDEX% "%SETENV_TARGET%"
@echo @goto :eof>> "%SETENV_TARGET%"

@echo @goto :AfterMove>> "%SETENV_TARGET%"
@call :FindStrBetween "%SCRIPT_SOURCE%" ":AfterMove" "@goto :eof"
@if not "%START_INDEX%" == "" if not "%END_INDEX%" == "" @call :CopyLines "%SCRIPT_SOURCE%" %START_INDEX% %END_INDEX% "%SETENV_TARGET%"
@echo @goto :eof>> "%SETENV_TARGET%"
::@if exist "%PATCHMOVED_SCRIPT%" @echo @call "%%~dp0set-env.cmd" --patch-moved> "%PATCHMOVED_TARGET%"


@REM 寫入腳本後段, 並且把'!'改成'%'
@powershell -Command "(Get-Content '%~dp0set-env.end.temp') | ForEach-Object { $_ -replace '\${APPNAME}', '%APPNAME%'.ToUpper() -replace '\${AppNameSmall}', '%APPNAME%' -replace '\${AppVersion}', '%MATCH_VER%' } | Add-Content '%SETENV_TARGET%'"
@powershell -Command "(Get-Content '%SETENV_TARGET%') | ForEach-Object { $_ -replace '\$', '%%' } | Set-Content '%SETENV_TARGET%'"

@if not "%NOCHECK%" == "1" if exist "%VALIDATE_SCRIPT%" @(
    @call "%VA_HOME%\base\validate.cmd" "%VALIDATE_SCRIPT%"
)
@goto :eof


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
    @if "%OUTTYPE%" == "clear-env" @echo @set PATH=$$PATH:%KEY%;=$$>> "%SETENV_TARGET%"
    @rem @echo @set PATH=%KEY%;!PATH!>> "%SETENV_TARGET%"
    @rem @echo @call set PATH=!!PATH:%KEY%;=!!>> "%CLEARENV_TARGET%"
) else @(
    @if "%OUTTYPE%" == "set-env" @echo @set %KEY%=%VALUE%>> "%SETENV_TARGET%"
    @if "%OUTTYPE%" == "clear-env" @echo @set %KEY%=>> "%SETENV_TARGET%"
    @rem @echo @set %KEY%=%VALUE%>> "%SETENV_TARGET%"
    @rem @echo @set %KEY%=>> "%CLEARENV_TARGET%"
)
@goto :eof


:FindStrBetween
@set targetfile=%~1
@set startline=%~2
@set endline=%~3
@set START_INDEX=
@set END_INDEX=
@setlocal EnableDelayedExpansion
@set idx=1
@for /F "tokens=* USEBACKQ delims=" %%F IN ("%targetfile%") do @(
    @if "%%F" == "%startline%" @set /A START_INDEX=!idx!+1
    @if not "!START_INDEX!" == "" @if "%%F" == "%endline%" @set /A END_INDEX=!idx!
    @set /A idx=!idx!+1
)

@if not "%START_INDEX%" == "" @if not "%END_INDEX%" == "" @(
    @echo %START_INDEX%> "%TEMP%\start_index"
    @echo %END_INDEX%> "%TEMP%\end_index"
    @set write=1
)
@if not "%write%" == "1" @(
    @echo.> "%TEMP%\start_index"
    @echo.> "%TEMP%\end_index"
)
@endlocal
@set /P START_INDEX=< "%TEMP%\start_index"
@set /P END_INDEX=< "%TEMP%\end_index"
@call "%VA_HOME%\base\print.cmd" debug message gen-env "%START_INDEX%,%END_INDEX% in %targetfile%"
@goto :eof

:CopyLines
@set srcfile=%~1
@set startidx=%~2
@set endidx=%~3
@set appendfile=%~4
@setlocal EnableDelayedExpansion
@set idx=1
@for /F "tokens=* USEBACKQ delims=" %%F IN ("%srcfile%") do @(
    @if !idx! GEQ %startidx% @if !idx! LSS %endidx% @echo %%F>> "%appendfile%"
    @set /A idx=!idx!+1
)
@endlocal
@goto :eof


:Error
@goto :eof
