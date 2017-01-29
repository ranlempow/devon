rem Test Ok

::: function PreparePrint(PRINT_LEVEL, MSG_TITLE)
    rem if not "%NO_COLOR%" == "1" if "%NN%" == "" call %~dp0color.cmd
    if "%THISNAME%" == "" set THISNAME=brickv

    if "%PRINT_LEVEL%" == "error" set PRINT_LEVEL=5
    if "%PRINT_LEVEL%" == "warning" set PRINT_LEVEL=4
    if "%PRINT_LEVEL%" == "normal" set PRINT_LEVEL=3
    if "%PRINT_LEVEL%" == "info" set PRINT_LEVEL=2
    if "%PRINT_LEVEL%" == "debug" set PRINT_LEVEL=1

    if "%LOG_LEVEL%" == "" set LOG_LEVEL=3

    rem format {14s}
    set MSG_TITLE_F="%MSG_TITLE%              "
    set MSG_TITLE_F=%MSG_TITLE_F:~1,15%
    if "%TEST_SHELL%" == "1" set MSG_TITLE_F=%MSG_TITLE%

    return %PRINT_LEVEL%, %LOG_LEVEL%, %THISNAME%, %MSG_TITLE_F%
::: endfunc

::: function PrintMsg(PRINT_LEVEL, MSG_TITLE, MSG_BODY=....)
    call :PreparePrint "%PRINT_LEVEL%" "%MSG_TITLE%"
    call :ImportColor
    set RedText=0
    if "%MSG_TITLE%" == "error" set RedText=1
    if "%MSG_TITLE%" == "warning" set RedText=1

    if "%RedText%" == "1" (
        set OUTPUT=%THISNAME% %BR%%MSG_TITLE_F%%NN% %MSG_BODY%
    ) else (
        set OUTPUT=%THISNAME% %DC%%MSG_TITLE_F%%NN% %MSG_BODY%
    )
    call :_Print
::: endfunc


::: function PrintVersion(PRINT_LEVEL, MSG_TITLE, PV_APP, PV_VER, PV_ARCH, PV_PATCHES)
    call :PreparePrint "%PRINT_LEVEL%" "%MSG_TITLE%"
    call :ImportColor

    :: request, match, newest
    set OUTPUT=%THISNAME% %DP%%MSG_TITLE_F%%NN% %BW%%PV_APP%%NN%^=%PV_VER%%BW%%NN%@%PV_ARCH%[%PV_PATCHES%]
    call :_Print
::: endfunc


:PrintTaskInfo
::: function PrintTaskInfo()
    call :ImportColor

    set PRINT_LEVEL=1
    set MSG_TITLE=task
    call :PreparePrint "%PRINT_LEVEL%" "%MSG_TITLE%"

    set OUTPUT=%THISNAME% %BR%%MSG_TITLE_F%%NN% target:     %TARGETDIR%
    call :_Print
    set OUTPUT=                      name:       %NAME%
    call :_Print
    set OUTPUT=                      installer:  %INSTALLER%
    call :_Print
::: endfunc



:_Print
if %PRINT_LEVEL% GEQ %LOG_LEVEL% echo.%OUTPUT%
goto :eof

#include("color.cmd")
