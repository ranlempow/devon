rem TODO: Need test

@rem output: REQUEST_*, REQUEST_SPEC, VERSION_SPCES_FILE

::: function BrickvPrepare(
                           spec=?, app=?, ver=x, patches=., arch=?,
                           name=?, targetdir=?, global_dir=?,
                           system=N, global=N, local=N,
                           dry=N, force=N, check_only=N, no_check=N, no_color=N,
                           silent=N, quiet=N, v=N, vv=N, vvv=N, allow_empty_location=N,
                           REST_ARGS_PRINT=....)

@rem == init setting variables ==
set REQUEST_SPEC=%spec%
set REQUEST_APP=%app%
set REQUEST_VER=%ver%
set REQUEST_ARCH=%arch%
set REQUEST_PATCHES=%patches%

if "%REQUEST_ARCH%" == "" (
    if "%PROCESSOR_ARCHITECTURE%" == "x86" (
        set REQUEST_ARCH=x86
    ) else (
        set REQUEST_ARCH=x64
    )
)

@rem 支援以下三種安裝地點, 預設地點由安裝程式決定
@rem system: 需要root權限, 通常為官方預設的正常安裝程序
@rem global & local: 使用者家目錄或是專案目錄
if not "%allow_empty_location%" == "1" set REQUEST_LOCATION=global
if "%system%" == "1" set REQUEST_LOCATION=system
if "%global%" == "1" set REQUEST_LOCATION=global
if "%local%" == "1" set REQUEST_LOCATION=local

if "%APPS_GLOBAL_DIR%" == "" (
    if "%GLOBAL_DIR%" == "" set GLOBAL_DIR=%LOCALAPPDATA%\Programs
) else (
    if "%GLOBAL_DIR%" == "" set set GLOBAL_DIR=%APPS_GLOBAL_DIR%
)

if "%APPS_LOCAL_DIR%" == "" (
    if not "%PRJ_BIN%" == "" (
        set LOCAL_DIR=%PRJ_BIN%
    ) else (
        set LOCAL_DIR=%cd%
    )
) else (
    set LOCAL_DIR=%APPS_LOCAL_DIR%
)

@REM 安裝的目錄名稱
set REQUEST_NAME=%name%
@REM 安裝的父目錄所在地
set REQUEST_TARGETDIR=%targetdir%
rem @if "%REQUEST_LOCATION%" == "global" @if "%REQUEST_TARGETDIR%" == "" @set REQUEST_TARGETDIR=%LOCALAPPDATA%\Programs


@rem 不真正下載與執行, 只顯示相關參數
if "%dry%" == "1" set DRYRUN=1
@rem 強迫重新下載與安裝
if "%force%" == "1" set FORCE=1
@rem 只測試安裝是否成功, 不進行安裝
if "%check_only%" == "1" set CHECKONLY=1
@rem 只測試安裝是否成功, 不進行安裝
if "%no_check%" == "1" set NOCHECK=1

@rem 螢幕輸出相關, LOG_LEVEL
set LOG_LEVEL=3
if "%silent%" == "1" set LOG_LEVEL=5
if "%quiet%" == "1" set LOG_LEVEL=4
if "%v%" == "1" set /A LOG_LEVEL-=1
if "%vv%" == "1" set /A LOG_LEVEL-=2
if "%vvv%" == "1" set /A LOG_LEVEL-=3
@rem 不使用字體顏色
if "%no_color%" == "1" set NO_COLOR=1

@rem set CHECKONLY=
@rem set UPGRADE=
set TARGET_OS=
set TARGET_OS_TYPE=
set TARGET_OS_NAME=
set TARGET_OS_VER=
set TARGET_OS_ARCH=


:Main
call :PrintMsg debug init "TARGET_OS=%TARGET_OS%"
call :PrintMsg debug init "REST_ARGS=%REST_ARGS_PRINT%"


if not "%REQUEST_SPEC%" == "" (
    rem call :MatchVersion --specs "%REQUEST_SPEC%" --output-format env
    call :MatchVersion --output-format env "%REQUEST_SPEC%"
)
if not "%REQUEST_SPEC%" == "" (
    @set REQUEST_APP=%MATCH_APP%
    @set REQUEST_MAJOR=%MATCH_MAJOR%
    @set REQUEST_MINOR=%MATCH_MINOR%
    @set REQUEST_PATCH=%MATCH_PATCH%
    @set REQUEST_ARCH=%MATCH_ARCH%
    @set REQUEST_PATCHES=%MATCH_PATCHES%
    @set REQUEST_VER=%MATCH_VER%
    @set MATCH_APP=
    @set MATCH_MAJOR=
    @set MATCH_MINOR=
    @set MATCH_PATCH=
    @set MATCH_ARCH=
    @set MATCH_PATCHES=
    @set MATCH_VER=
)
set REQUEST_SPEC=%REQUEST_APP%=%REQUEST_VER%@%REQUEST_ARCH%[%REQUEST_PATCHES%]

if not "%REQUEST_APP%" == "" (
  call :PrintVersion info request "%REQUEST_APP%" "%REQUEST_VER%" "%REQUEST_ARCH%" "%REQUEST_PATCHES%"
)
return %DRYRUN%, %FORCE%, %CHECKONLY%, %NOCHECK%, %NO_COLOR%, %LOG_LEVEL%, ^\n^
       %VERSION_SPCES_FILE%, %LOCAL_DIR%, %GLOBAL_DIR%, ^\n^
       %REQUEST_SPEC%, %REQUEST_APP%, ^\n^
       %REQUEST_MAJOR%, %REQUEST_MINOR%, %REQUEST_PATCH%, ^\n^
       %REQUEST_ARCH%, %REQUEST_PATCHES%, %REQUEST_VER%, ^\n^
       %REQUEST_LOCATION%, %REQUEST_NAME%, %REQUEST_TARGETDIR%

::: endfunc

#include("print.cmd")
#include("semver.cmd")
