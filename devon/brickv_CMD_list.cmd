
::: function brickv_CMD_list(args=...) delayedexpansion

    call :BrickvPrepare %args%
    set args=
    rem set APPNAME=%REQUEST_APP%

    call :ImportColor
    for /D %%i in (%GLOBAL_DIR%\*) do if exist "%%i\set-env.cmd" (
        call :RecordApp "%%i" global
    )
    for /D %%i in (%LOCAL_DIR%\*) do if exist "%%i\set-env.cmd" (
        call :RecordApp "%%i" local
    )
    rem call :FindAppLocation
    rem echo %AppPath%

::: endfunc

::: function brickv_CMD_switch(spec, args=...) delayedexpansion
    call :BrickvPrepare --spec "%spec%" %args%
    set args=
    call :FindAppLocation
    echo %AppPath%
    if "%AppPath%" != "" echo.@call "%AppPath%\set-env.cmd" --set >> "%POST_SCIRPT%"
::: endfunc



::: function FindAppLocation()
    rem need %REQUEST_SPEC%

    set VERSION_SPCES_FILE=%TEMP%\spces-list.ver.txt
    set MATCH_SPCES_FILE=%TEMP%\spces-match.ver.txt
    call :DiscoverApp
    pcall :MatchVersion --output-format env --spec-match "%REQUEST_SPEC%" --specs-file "%VERSION_SPCES_FILE%"
    if not "%ERROR_MSG%" == "" (
        return %AppPath%
    )
    set AppPath=%MATCH_CARRY%
    return %AppPath%
::: endfunc

::: function DiscoverApp()
    if exist "%VERSION_SPCES_FILE%" del "%VERSION_SPCES_FILE%" >nul
    copy /y NUL "%VERSION_SPCES_FILE%" >NUL

    for /D %%i in (%GLOBAL_DIR%\*) do if exist "%%i\set-env.cmd" (
        call :RecordApp "%%i" global --no-print --spec-file "%VERSION_SPCES_FILE%"
    )
    for /D %%i in (%LOCAL_DIR%\*) do if exist "%%i\set-env.cmd" (
        call :RecordApp "%%i" local --no-print --spec-file "%VERSION_SPCES_FILE%"
    )
::: endfunc


::: function RecordApp(TARGET, Location, No_Print=N, Spec_File=?)
    for /f %%i in ("%TARGET%") do set Filename=%%~nxi
    if "%Filename:~0,10%" == "backupfor-" (
        return
    )
    if "%Filename:~0,7%" == "failed-" (
        return
    )
    call "%TARGET%\set-env.cmd" --info
    call set _VA_BASE=%%VA_%VA_INFO_APPNAME%_BASE%%
    if "%_VA_BASE%" == "%TARGET%" set Activate=1
    set "ActivateText= "
    if "%Activate%" == "1" set ActivateText=*
    if not "%No_Print%" == "1" echo. %BP%%ActivateText%%NN% %BW%%VA_INFO_APPNAME%%NN%=%VA_INFO_VERSION% %Location%
    if not "%Spec_File%" == "" echo.%VA_INFO_APPNAME%=%VA_INFO_VERSION%$%TARGET% >> "%Spec_File%"
::: endfunc


#include("brickv_prepare.cmd")
