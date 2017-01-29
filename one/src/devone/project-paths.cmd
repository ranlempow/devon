#include("parseini.cmd")

::: function GetPrjRoot()
    rem find project root and resolve all paths
    call :get_dir %SCRIPT_SOURCE%
    set PRJ_ROOT=
    pushd %dir%
    set PRJ_ROOT=%cd%
    popd
    return PRJ_ROOT
    :get_dir
        set dir=%~dp0
    goto :eof
::: endfunc


::: function GetTitle(titlePath)
    set SPLITSTR=%titlePath%
    :nextVar
       for /F tokens^=1*^ delims^=^\ %%a in ("%SPLITSTR%") do (
          set LAST=%%a
          set SPLITSTR=%%b
       )
    if defined SPLITSTR goto nextVar
    set TITLE=%LAST%
    return TITLE
::: endfunc


::: function LoadConfigPaths()
    :: 尋找並讀取devone.ini設定檔, 此檔案可以放在PRJ_ROOT或是PRJ_ROOT/config
    :: 不論此設定檔存在與否, 均會回傳以下路徑設定
    :: PRJ_BIN, PRJ_VAR, PRJ_LOG, PRJ_TMP, PRJ_CONF

    call :GetPrjRoot
    call :GetTitle %PRJ_ROOT%

    rem load config
    rem -----------

    rem find config file `devone.ini`
    set CONFIG_PATH=
    pushd %PRJ_ROOT%
    pushd config 2>nul
    if not errorlevel 1 (
        if exist "devone.ini" set CONFIG_PATH=%cd%
        popd
    )
    if exist "devone.ini" set CONFIG_PATH=%cd%
    popd
    if not "%CONFIG_PATH%" == "" set DEVONE_CONFIG_PATH=%CONFIG_PATH%\devone.ini


    @rem builtin config
    @rem --------------


    call :GetIniValue %CONFIG_PATH%\devone.ini layout bin
    set PRJ_BIN_RAW=%inival%
    call :GetIniValue %CONFIG_PATH%\devone.ini layout var
    set PRJ_VAR_RAW=%inival%
    call :GetIniValue %CONFIG_PATH%\devone.ini layout log
    set PRJ_LOG_RAW=%inival%
    call :GetIniValue %CONFIG_PATH%\devone.ini layout tmp
    set PRJ_TMP_RAW=%inival%
    call :GetIniValue %CONFIG_PATH%\devone.ini layout config
    set PRJ_CONF_RAW=%inival%

    if "%PRJ_BIN_RAW%" == "" if exist "%PRJ_ROOT%\bin" set PRJ_BIN_RAW=bin
    if "%PRJ_VAR_RAW%" == "" if exist "%PRJ_ROOT%\var" set PRJ_VAR_RAW=var
    if "%PRJ_LOG_RAW%" == "" if exist "%PRJ_ROOT%\log" set PRJ_LOG_RAW=log
    if "%PRJ_TMP_RAW%" == "" if exist "%PRJ_ROOT%\tmp" set PRJ_TMP_RAW=tmp
    if "%PRJ_CONF_RAW%" == "" if exist "%PRJ_ROOT%\config" set PRJ_CONF_RAW=config

    rem @set PRJ_TOOLS_RAW=\tools
    rem @set PRJ_SRC_RAW=\src
    rem @set PRJ_SCRIPT_RAW=\script
    rem @set PRJ_EXT_RAW=\external
    rem @set PRJ_TEST_RAW=\test
    rem @set PRJ_DOCS_RAW=\docs

    if "%PRJ_BIN_RAW%" == "" set PRJ_BIN_RAW=bin
    set PRJ_BIN=%PRJ_ROOT%\%PRJ_BIN_RAW%
    if "%PRJ_VAR_RAW%" == "" (
        rem if not specify, use the system temp folder
        set PRJ_VAR=%TEMP%\devone-%TITLE%
    ) else (
        set PRJ_VAR=%PRJ_ROOT%\%PRJ_VAR_RAW%
    )
    if "%PRJ_LOG_RAW%" == "" (
        rem by default, log is in the var folder
        set PRJ_LOG=%PRJ_VAR%\log
    ) else (
        set PRJ_LOG=%PRJ_ROOT%\%PRJ_LOG_RAW%
    )
    if "%PRJ_TMP_RAW%" == "" (
        rem by default, tmp is in the var folder
        set PRJ_TMP=%PRJ_VAR%\tmp
    ) else (
        set PRJ_TMP=%PRJ_ROOT%\%PRJ_TMP_RAW%
    )
    if "%PRJ_CONF_RAW%" == "" (
        rem if not specify, use the folder which is store devone.ini
        if not "%CONFIG_PATH%" == "" set PRJ_CONF=%CONFIG_PATH%
    ) else (
        set PRJ_CONF=%PRJ_ROOT%\%PRJ_CONF_RAW%
    )
    if "%PRJ_CONF%" == "" set PRJ_CONF=%PRJ_ROOT%\config


    return DEVONE_CONFIG_PATH, PRJ_ROOT, PRJ_BIN, PRJ_VAR, PRJ_LOG, PRJ_TMP, PRJ_CONF
::: endfunc
