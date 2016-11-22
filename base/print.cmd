@setlocal
@if not "%NO_COLOR%" == "1" @call %~dp0color.cmd
@set PRINT_LEVEL=%~1
@set PRINT_TYPE=%~2
@set THISNAME=brickv

@if "%PRINT_LEVEL%" == "error" @set PRINT_LEVEL=5
@if "%PRINT_LEVEL%" == "warning" @set PRINT_LEVEL=4
@if "%PRINT_LEVEL%" == "normal" @set PRINT_LEVEL=3
@if "%PRINT_LEVEL%" == "info" @set PRINT_LEVEL=2
@if "%PRINT_LEVEL%" == "debug" @set PRINT_LEVEL=1

@if "%PRINT_TYPE%" == "message" @goto :PrintMsg
@if "%PRINT_TYPE%" == "version" @goto :PrintVersion
@if "%PRINT_TYPE%" == "task-info" @goto :PrintTaskInfo
@goto :_Quit

:PrintMsg
@set MSG_TITLE=%~3
@set MSG_BODY=%~4
@set MSG_TITLE_F=%MSG_TITLE%                
@set MSG_TITLE_F=%MSG_TITLE_F:~0,14%
@if "%MSG_TITLE%" == "error" @(
    @set OUTPUT=%THISNAME% %BR%%MSG_TITLE_F%%NN% %MSG_BODY%
) else @(
	@set OUTPUT=%THISNAME% %DC%%MSG_TITLE_F%%NN% %MSG_BODY%
)
@call :Print
@goto :_Quit


:PrintVersion
:: request, match, newest

@set MSG_TITLE=%~3
@set PV_APP=%~4
@set PV_VER=%~5
@set PV_ARCH=%~6
@set PV_PATCHES=%~7
@set MSG_TITLE_F=%MSG_TITLE%                
@set MSG_TITLE_F=%MSG_TITLE_F:~0,14%
@set OUTPUT=%THISNAME% %DP%%MSG_TITLE_F%%NN% %BW%%PV_APP%%NN%^=%PV_VER%%BW%@%NN%%PV_ARCH%[%PV_PATCHES%]
@call :Print
@goto :_Quit

:PrintTaskInfo
@set PRINT_LEVEL=1
@set MSG_TITLE=task
@set MSG_TITLE_F=%MSG_TITLE%                
@set MSG_TITLE_F=%MSG_TITLE_F:~0,14%
@set OUTPUT=%THISNAME% %BR%%MSG_TITLE_F%%NN% target:     %TARGETDIR%
@call :Print
@set OUTPUT=                      name:       %NAME%
@call :Print
@set OUTPUT=                      installer:  %INSTALLER%
@call :Print
@goto :_Quit




:Print
@if %PRINT_LEVEL% GEQ %LOG_LEVEL% @echo %OUTPUT%
@goto :eof


:_Quit
@endlocal