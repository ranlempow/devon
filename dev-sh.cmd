@setlocal EnableDelayedExpansion
@setlocal

@set SPLITSTR=%~dp0
:nextVar
   @for /F tokens^=1*^ delims^=^\ %%a in ("%SPLITSTR%") do @(
      set LAST=%%a
      set SPLITSTR=%%b
   )
@if defined SPLITSTR goto nextVar
@set TITLE=%LAST%

@set PATH_ADDED=
@set PATH_ADDED=%PATH_ADDED%%~dp0bin;
@set PATH_ADDED=%PATH_ADDED%%~dp0bin\python-3.4.4;
@set PATH_ADDED=%PATH_ADDED%%~dp0bin\python-3.4.4\Scripts;

@set CMDSCRIPT=
@set CMDSCRIPT=!CMDSCRIPT! set PATH=!PATH_ADDED!%PATH%^&
@set CMDSCRIPT=!CMDSCRIPT! set PYTHONPATH=%~dp0;%PYTHONPATH%^&
@set CMDSCRIPT=!CMDSCRIPT! set PROMPT=$C!TITLE!$F$S$P$G^&
@set CMDSCRIPT=!CMDSCRIPT! echo.# This¤¤¤å is a tool of install large dependency^&
@set CMDSCRIPT=!CMDSCRIPT! echo.  [manage] - install or remove larges^&

@if [%1] EQU [] goto StartShell

:Excute
@set CMDSCRIPT=!CMDSCRIPT! %1^&
start "[%TITLE%]" cmd.exe /U /C "%CMDSCRIPT%"
@rem start C:\Users\ran\Desktop\PyCmd\PyCmd.exe -t [%TITLE%] -c "%CMDSCRIPT%"
@goto quit

:StartShell
start "[%TITLE%]" cmd.exe /U /K "%CMDSCRIPT%"
@rem start C:\Users\ran\Desktop\PyCmd\PyCmd.exe -t [%TITLE%] -k "%CMDSCRIPT%"
@goto quit


:quit
@endlocal

