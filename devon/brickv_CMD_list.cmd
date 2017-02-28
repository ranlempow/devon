
::: function brickv_CMD_list(spec=, args=....) delayedexpansion
    call :BrickvPrepare --spec "%spec%" --allow-empty-location %args%
    set args=
    call :ImportColor


    set VERSION_SPCES_FILE=%TEMP%\spces-list.ver.txt
    set MATCH_SPCES_FILE=%TEMP%\spces-match.ver.txt
    call :DiscoverApp
    call :IterMatchVersion :brickv_CMD_list_startcb 999999

    goto :brickv_CMD_list_endcb
    :brickv_CMD_list_startcb
        set "ActivateMark= "
        if "%Activate%" == "1" set ActivateMark=*
        echo. %BP%!ActivateMark!%NN% %BW%!MATCH_APP!%NN%=!AppInfoVersion! !Location!
        goto :eof
    :brickv_CMD_list_endcb

::: endfunc

::: function brickv_CMD_versions(spec, args=....) delayedexpansion
    call :BrickvPrepare --spec %spec% %args%
    call :brickv_CMD_install --only-versions --spec %spec% %args%
    FOR /F "delims=$ tokens=1 USEBACKQ" %%F IN ("%VERSION_SPCES_FILE%") do (
        echo %%F
    )
::: endfunc

::: function brickv_CMD_Update(specs, no_switch=N, no_install=N, args=....) delayedexpansion

    set Installs=
    set Switches=
    set Faileds=
    set PassToInstall=%args%

    rem Switch
    set NotFounds=
    set targets=%specs: =#%

    :brickv_CMD_Update_switch_loop
    for /F "delims=# tokens=1*" %%A IN ("%targets%") do (
        call :brickv_CMD_Update_switch "%%~A"
        set targets=%%B
    )
    if not "%targets%" == "" goto :brickv_CMD_Update_switch_loop
    if "%no_install%" == "1" (
        return
    )


    rem Install
    set targets=%NotFounds%
    :brickv_CMD_Update_install_loop
    for /F "delims=# tokens=1*" %%A IN ("%targets%") do (
        call :brickv_CMD_Update_install "%%~A"
        set targets=%%B
    )
    if not "%targets%" == "" goto :brickv_CMD_Update_install_loop

    set SwitchesString=%Switches:#= %
    if not "%Switches%" == "" call :PrintMsg normal update switched apps: "%SwitchesString%"
    set InstallsString=%Installs:#= %
    if not "%Installs%" == "" if not "%DRYRUN%" == "1" call :PrintMsg normal update installed apps: "%InstallsString%"
    if not "%Installs%" == "" if "%DRYRUN%" == "1" call :PrintMsg normal update skipped apps: "%InstallsString%"

    set FailedsString=%Faileds:#= %
    if not "%Faileds%" == "" call :PrintMsg error error failure apps: "%FailedsString%"
    return "%FailedsString%"


    :brickv_CMD_Update_switch
    if "%~1" == "" goto :eof
    set SwitchSuccess=1
    if not "%no_switch%" == "1" (
        call :brickv_CMD_switch "%~1" --internal
    ) else (
        set SwitchSuccess=0
    )
    if not "%SwitchSuccess%" == "1" (
        call :PrintMsg normal switch "%~1" add to dependency list
        if "%NotFounds%" == "" (set NotFounds=%~1) else (set NotFounds=%NotFounds%#%~1)
    ) else (
        if "%Switches%" == "" (set Switches=%SWITCH_NAME%) else (set Switches=%Switches%#%SWITCH_NAME%)
    )
    goto :eof

    :brickv_CMD_Update_install
    if "%~1" == "" goto :eof
    pcall :brickv_CMD_install --spec "%~1" %PassToInstall%
    if not "%ERROR_MSG%" == "" (
        call :PrintMsg error error %ERROR_MSG%
        if "%Faileds%" == "" (set Faileds=%~1) else (set Faileds=%Faileds%#%~1)
    ) else (
        if "%Installs%" == "" (set Installs=%REQUEST_NAME%) else (set Installs=%Installs%#%REQUEST_NAME%)
    )

    goto :eof
::: endfunc

::: function brickv_CMD_switch(spec, internal=N, args=....) delayedexpansion
    call :BrickvPrepare --spec "%spec%" --allow-empty-location %args%
    set args=
    set AppPath=
    call :ImportColor

    set VERSION_SPCES_FILE=%TEMP%\spces-list.ver.txt
    set MATCH_SPCES_FILE=%TEMP%\spces-match.ver.txt
    call :DiscoverApp
    call :IterMatchVersion "" 1

    set "SWITCH_NAME=%MATCH_APP%=%AppInfoVersion%"
    set SwitchSuccess=0
    if not "%AppPath%" == "" (
        call :PrintMsg normal switch enable "%BW%!MATCH_APP!%NN%=!AppInfoVersion!" at %AppPath%
        echo.@call "%AppPath%\set-env.cmd" --set>> "%POST_SCIRPT%"
        set SwitchSuccess=1
    ) else (
        if not "%internal%" == "1" echo.@set "POST_ERRORLEVEL=1">> "%POST_SCIRPT%"
    )
    if "%internal%" == "1" (
        return %SwitchSuccess%, %AppPath%, %SWITCH_NAME%
    )
::: endfunc


::: function DiscoverApp()
    copy /y NUL "%VERSION_SPCES_FILE%" >NUL
    copy /y NUL "%MATCH_SPCES_FILE%" >NUL

    for /D %%i in (%GLOBAL_DIR%\*) do if exist "%%i\set-env.cmd" (
        call :RecordApp "%%i" global --spec-file "%VERSION_SPCES_FILE%"
    )
    for /D %%i in (%LOCAL_DIR%\*) do if exist "%%i\set-env.cmd" (
        call :RecordApp "%%i" local --spec-file "%VERSION_SPCES_FILE%"
    )
    call :MatchVersion --output-format cmd --all --spec-match "%REQUEST_SPEC%"^\n^
                   --specs-file "%VERSION_SPCES_FILE%" --output "%MATCH_SPCES_FILE%"
    rem use :IterMatchVersion on next
::: endfunc


:IterMatchVersion
set CALLBACK=%~1
set limit=%~2
set count=0
for /F "tokens=1-7 usebackq" %%A IN ("%MATCH_SPCES_FILE%") do (
    set MATCH_CARRY=%%~G
    for /F "delims=, tokens=1-4 usebackq" %%J IN ('!MATCH_CARRY!') do (
        set _Activate=%%J
        set _Location=%%K
        set _AppPath=%%L
        set _AppInfoVersion=%%M
    )
    set Skip=0
    if not "%REQUEST_LOCATION%" == "" if not "%REQUEST_LOCATION%" == "!_Location!" set Skip=1
    if "!Skip!" == "0" set /A "count+=1"
    if !count! GTR !limit! set Skip=1
    if "!Skip!" == "0" (
        set MATCH_APP=%%A
        set MATCH_MAJOR=%%B
        set MATCH_MINOR=%%C
        set MATCH_PATCH=%%D
        set MATCH_ARCH=%%E
        set MATCH_PATCHES=%%F
        set Activate=!_Activate!
        set Location=!_Location!
        set AppPath=!_AppPath!
        set AppInfoVersion=!_AppInfoVersion!
        if not "%CALLBACK%" == "" call %CALLBACK%
    )
)
set CALLBACK=
set count=
set limit=
goto :eof


::: function RecordApp(TARGET, Location, Spec_File=?)
    for /f %%i in ("%TARGET%") do set Filename=%%~nxi
    if "%Filename:~0,10%" == "backupfor-" (
        return
    )
    if "%Filename:~0,7%" == "failed-" (
        return
    )
    call "%TARGET%\set-env.cmd" --info
    call set _VA_BASE=%%VA_%VA_INFO_APPNAME%_BASE%%
    set Activate=0
    if "%_VA_BASE%" == "%TARGET%" set Activate=1
    if not "%Spec_File%" == "" echo.%VA_INFO_APPNAME%=%VA_INFO_VERSION%^\n^
                                    $%Activate%,%Location%,%TARGET%,%VA_INFO_VERSION%>> "%Spec_File%"
::: endfunc


#include("brickv_prepare.cmd")
#include("brickv_CMD_list.cmd")
