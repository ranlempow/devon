@rem require: APPNAME
@rem output: REQUEST_*, VERSION_SPCES_FILE


@echo off
::pushd %~dp0..
::set VA_HOME=%CD%
::popd
@if "%VA_HOME%" == "" @set VA_HOME=%~dp0..

@rem == init setting variables ==
set ERROR_MSG=
@set VERSION_SPCES_FILE=%TEMP%\version_spces.txt
set REQUEST_SPEC=
set REQUEST_APP=
set REQUEST_VER=x
set REQUEST_PATCHES=.
set REQUEST_LOCATION=global
set LOG_LEVEL=3
set DRYRUN=
set FORCE=
@rem set CHECKONLY=
set UPGRADE=
set TARGET_OS=
set TARGET_OS_TYPE=
set TARGET_OS_NAME=
set TARGET_OS_VER=
set TARGET_OS_ARCH=

@rem ============================

:Loop
set head=%~1
set parm=%~2

if "%head%" == "" goto :GetRestArgs
if "%parm%" == "" set parm=__NONE__

if "%head%" == "--spec" (
    set REQUEST_SPEC=%parm%
    goto :Parse2
)

if "%head%" == "--app" (
    set REQUEST_APP=%parm%
    goto :Parse2
)

if "%head%" == "--version" (
    set REQUEST_VER=%parm%
    goto :Parse2
)

if "%head%" == "--arch" (
    set REQUEST_ARCH=%parm%
    goto :Parse2
)


if "%head%" == "--patches" (
    set REQUEST_PATCHES=%parm%
    goto :Parse2
)

@REM 安裝的目錄名稱
if "%head%" == "--name" (
    set REQUEST_NAME=%parm%
    goto :Parse2
)

@REM 安裝的父目錄所在地
set OR=
if "%head%" == "-d" set OR=1
if "%head%" == "--targetdir" set OR=1
if "%OR%" == "1" (
    set REQUEST_TARGETDIR=%parm%
    goto :Parse2
)

@rem 不真正下載與執行, 只顯示相關參數
if "%head%" == "--dry" (
    set DRYRUN=1
    goto :Parse1
)

@rem 強迫重新下載與安裝
if "%head%" == "--force" (
    set FORCE=1
    goto :Parse1
)

@rem 只測試安裝是否成功, 不進行安裝
if "%head%" == "--check-only" (
    set CHECKONLY=1
    goto :Parse1
)

@rem 只測試安裝是否成功, 不進行安裝
if "%head%" == "--no-check" (
    set NOCHECK=1
    goto :Parse1
)

@rem 不使用字體顏色
if "%head%" == "--no-color" (
    set NO_COLOR=1
    goto :Parse1
)


@rem 螢幕輸出相關, LOG_LEVEL
if "%head%" == "--silent" (
    set LOG_LEVEL=5
    goto :Parse1
)
if "%head%" == "--quiet" (
    set LOG_LEVEL=4
    goto :Parse1
)

set OR=
if "%head%" == "-V" set OR=1
if "%head%" == "--verbose" set OR=1
if "%OR%" == "1" (
    set /A LOG_LEVEL-=1
    goto :Parse1
)
if "%head%" == "-VV" (
    set /A LOG_LEVEL-=2
    goto :Parse1
)
if "%head%" == "-VVV" (
    set /A LOG_LEVEL-=3
    goto :Parse1
)


@rem 支援以下三種安裝地點, 預設地點由安裝程式決定
@rem system: 需要root權限, 通常為官方預設的正常安裝程序
@rem global & local: 使用者家目錄或是專案目錄 

if "%head%" == "--system" (
    set REQUEST_LOCATION=system
    goto :Parse1
)
if "%head%" == "--global" (
    set REQUEST_LOCATION=global
    goto :Parse1
)
if "%head%" == "--local" (
    set REQUEST_LOCATION=local
    goto :Parse1
)

goto :GetRestArgs

:Parse1
@shift
@goto :Loop
:Parse2
@if "%parm%" == "__NONE__" @goto :_BadArgument
@if "%parm:~0,1%" == "-" @goto :_BadArgument
@shift
@shift
@goto :Loop
:_BadArgument
@set ERROR_MSG=Bad argument after "%head%"
@goto :_Error
:_BadOption
@set ERROR_MSG=Unkwond option "%head%"
@goto :_Error


:GetRestArgs
@set REST_ARGS=
@set REST_ARGS_PRINT=
:GetRestArgsLoop
@if "%~1" == "" @goto :Main
@set REST_ARGS=%REST_ARGS% %1
@set REST_ARGS_PRINT=%REST_ARGS_PRINT% %~1
@shift
@goto :GetRestArgsLoop


:Main
@call "%VA_HOME%\base\print.cmd" debug message init "TARGET_OS=%TARGET_OS%"
@call "%VA_HOME%\base\print.cmd" debug message init "REST_ARGS=%REST_ARGS_PRINT%"


if "%REQUEST_ARCH%" == "" (
    if "%PROCESSOR_ARCHITECTURE%" == "x86" ( 
        set REQUEST_ARCH=x86
    ) else (
        set REQUEST_ARCH=x64
    )
)

@if "%REQUEST_LOCATION%" == "global" @if "%REQUEST_TARGETDIR%" == "" @set REQUEST_TARGETDIR=%LOCALAPPDATA%\Programs


if not "%REQUEST_SPEC%" == "" (
    @call "%VA_HOME%\base\semver.cmd" --specs "%REQUEST_SPEC%" --output-format env
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
@set REQUEST_SPEC=%APPNAME%=%REQUEST_VER%@%REQUEST_ARCH%[%REQUEST_PATCHES%]
@call "%VA_HOME%\base\print.cmd" info version request %APPNAME% %REQUEST_VER% %REQUEST_ARCH% %REQUEST_PATCHES%
goto :_Done



:_Error
@cmd /C exit /b 1
@goto _Quit

:_Done
@cmd /C exit /b 0
@goto _Quit

:_Quit
set head=
set parm=
@echo on
@goto :eof
