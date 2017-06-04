::: function BrickvPrepare(spec,
                               global_dir=?, local_dir=?, global=N, local=N,
                               silent=N, quiet=N, verobse=N, debug=N
                               )

set REQUEST_SPEC=%spec%
@rem 支援以下三種安裝地點, 預設地點由安裝程式決定
@rem system: 需要root權限, 通常為官方預設的正常安裝程序
@rem global & local: 使用者家目錄或是專案目錄
@rem 讓large自己決定default時要使用哪個location

if "%global%" == "1" set REQUEST_LOCATION=global
if "%local%" == "1" set REQUEST_LOCATION=local

@rem TODO: 以下這些在active與devon.ini中設定?
if "%BRICKV_GLOBAL_DIR%" == "" set BRICKV_LOCAL_DIR=%global_dir%
if "%BRICKV_GLOBAL_DIR%" == "" set BRICKV_GLOBAL_DIR=%LOCALAPPDATA%\Programs
if "%BRICKV_LOCAL_DIR%" == "" set BRICKV_LOCAL_DIR=%local_dir%
if "%BRICKV_LOCAL_DIR%" == "" set BRICKV_LOCAL_DIR=%cd%

set LOG_LEVEL=3
if "%silent%" == "1" set LOG_LEVEL=5
if "%quiet%" == "1" set LOG_LEVEL=4
if "%verbose%" == "1" set /A LOG_LEVEL-=1
if "%debug%" == "1" set /A LOG_LEVEL-=2

rem set TARGET_OS=
rem set TARGET_OS_TYPE=
rem set TARGET_OS_NAME=
rem set TARGET_OS_VER=
rem set TARGET_OS_ARCH=

@rem 不使用字體顏色
@rem 使用環境變數設定
rem if "%no_color%" == "1" set NO_COLOR=1

return %LOG_LEVEL%, ^\n^
       %REQUEST_SPEC%, %REQUEST_LOCATION%, %BRICKV_LOCAL_DIR%, %BRICKV_GLOBAL_DIR%

::: endfunc


#include("print.cmd")

