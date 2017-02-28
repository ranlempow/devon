
@set SCRIPT_SOURCE=%~f0
@set SCRIPT_FOLDER=%~dp0
@if "%SCRIPT_FOLDER:~-1%" == "\" @set SCRIPT_FOLDER=%SCRIPT_FOLDER:~0,-1%



@if not "%~1" == "_start_" (
    set POST_SCIRPT=%TEMP%\devon_post_script-%RANDOM%.cmd
    set POST_ERRORLEVEL=0
)
@if not "%~1" == "_start_" (
    copy /y NUL "%POST_SCIRPT%" >NUL
    cmd /c "%~f0 _start_ %*"
)
@if not "%~1" == "_start_" (
    call "%POST_SCIRPT%"
    del "%POST_SCIRPT%"
)
@if not "%~1" == "_start_" if "%POST_ERRORLEVEL%" == "" set POST_ERRORLEVEL=0
@if not "%~1" == "_start_" (
    set POST_SCIRPT=
    set POST_ERRORLEVEL=
    set SCRIPT_FOLDER=
    set SCRIPT_SOURCE=
    exit /b %POST_ERRORLEVEL%
    goto :eof
)

@call :Main %*
@goto :eof

:EnterPostScript
set _OLD_POST_SCIRPT=%POST_SCIRPT%
set POST_SCIRPT=%TEMP%\devon_post_script-%RANDOM%.cmd
set POST_ERRORLEVEL=0
copy /y NUL "%POST_SCIRPT%" >NUL
goto :eof

:ExecutePostScript
call "%POST_SCIRPT%"
del "%POST_SCIRPT%"
set POST_SCIRPT=%_OLD_POST_SCIRPT%
set _OLD_POST_SCIRPT=
goto :eof
::: function Main(_start_, cmd=shell,
:::                   args=....) delayedexpansion
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_Main %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:Main
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=Main %CALL_STACK%
goto :REALBODY_Main
:REALBODY_Main
set _start_=%~1
if "%_start_%" == "" endlocal & ( set "ERROR_MSG=Need argument _start_" & set "ERROR_SOURCE=dev-sh.cmd" & set "ERROR_BLOCK=Main" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set cmd=shell
set args=

:ArgCheckLoop_Main
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_Main
if x%2x == xx set next=__NONE__

@if "%head%" == "--cmd" @(
    @set cmd=%next%
    @if "%next%" == "__NONE__" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=dev-sh.cmd" & set "ERROR_BLOCK=Main" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @if "%next_prefix%" == "-" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=dev-sh.cmd" & set "ERROR_BLOCK=Main" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @shift
    @shift
    @goto :ArgCheckLoop_Main
)
@goto :GetRestArgs_Main

:GetRestArgs_Main

@set args=%1
@shift
:GetRestArgsLoop_Main
@if "%~1" == "" @goto :Main_Main
@set args=%args% %1
@shift
@goto :GetRestArgsLoop_Main
:Main_Main
@set head=
@set next=
set _devcmd=%cmd%
set _devargs=%args%
set _start_=
set cmd=
set args=
set DEVON_VERSION=1.0.0

if not %_devcmd% == "brickv" call :ActiveDevShell
call :CMD_%_devcmd% %_devargs%

endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof



:SubString
    @if "%Text%" EQU "" goto :ENDSubString
    @for /f "delims=;" %%a in ("!Text!") do @set substring=%%a
    @call goto %LoopCb%
    @if not "%LoopBreak%" == "" goto :ENDSubString

:NextSubString
    @set headchar=!Text:~0,1!
    @set Text=!Text:~1!

    @if "!Text!" EQU "" goto :SubString
    @if "!headchar!" NEQ "%Spliter%" goto :NextSubString
    @goto :SubString

:ENDSubString
@set Text=
@set Spliter=
@set headchar=
@set substring=
@set LoopBreak=
@set LoopCb=
@(set ExitCb=)& call goto %ExitCb%
@goto :eof

:: 讀取ini檔案的方法, 將取得的值寫入%inival%
:: GetIniArray(file, area)
::   inival = "v1;v2"
:: GetIniPairs(file, area)
::   inival = "k1=v1;k2=v2"
:: GetIniValue(file, area, key)
::   inival = "v"

::: function GetIniArray(file, area) extensions delayedexpansion
@setlocal enableextensions enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_GetIniArray %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:GetIniArray
@setlocal enableextensions enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=GetIniArray %CALL_STACK%
goto :REALBODY_GetIniArray
:REALBODY_GetIniArray
set file=%~1
if "%file%" == "" endlocal & ( set "ERROR_MSG=Need argument file" & set "ERROR_SOURCE=parseini.cmd" & set "ERROR_BLOCK=GetIniArray" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set area=%~1
if "%area%" == "" endlocal & ( set "ERROR_MSG=Need argument area" & set "ERROR_SOURCE=parseini.cmd" & set "ERROR_BLOCK=GetIniArray" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift

:ArgCheckLoop_GetIniArray
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_GetIniArray
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=parseini.cmd" & set "ERROR_BLOCK=GetIniArray" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_GetIniArray
:Main_GetIniArray
@set head=
@set next=
set inival=
if not exist "%file%" goto :return_GetIniArray
set area=[%area%]
set currarea=
for /f "usebackq delims=" %%a in ("!file!") do (
    set ln=%%a
    for /f "tokens=* delims= " %%a in ("!ln!") do set ln=%%a
    if not "x!ln!" == "x" (
        if "x!ln:~0,1!"=="x[" (
            set currarea=!ln!
        ) else (
            for /f "tokens=1,2 delims==" %%b in ("!ln!") do (
                set currkey=%%b
                set currval=%%c

                if "x!area!"=="x!currarea!" (
                    if "x!inival!" == "x" (
                        set "inival=!currkey!"
                    ) else (
                        set "inival=!inival!;!currkey!"
                    )
                )
            )
        )
    )
)
:return_GetIniArray
endlocal & (
    set inival=%inival%
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function GetIniPairs(file, area) extensions delayedexpansion
@setlocal enableextensions enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_GetIniPairs %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:GetIniPairs
@setlocal enableextensions enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=GetIniPairs %CALL_STACK%
goto :REALBODY_GetIniPairs
:REALBODY_GetIniPairs
set file=%~1
if "%file%" == "" endlocal & ( set "ERROR_MSG=Need argument file" & set "ERROR_SOURCE=parseini.cmd" & set "ERROR_BLOCK=GetIniPairs" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set area=%~1
if "%area%" == "" endlocal & ( set "ERROR_MSG=Need argument area" & set "ERROR_SOURCE=parseini.cmd" & set "ERROR_BLOCK=GetIniPairs" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift

:ArgCheckLoop_GetIniPairs
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_GetIniPairs
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=parseini.cmd" & set "ERROR_BLOCK=GetIniPairs" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_GetIniPairs
:Main_GetIniPairs
@set head=
@set next=
set inival=
if not exist "%file%" goto :return_GetIniPairs
set area=[%area%]
set currarea=
for /f "usebackq delims=" %%a in ("!file!") do (
    set ln=%%a
    for /f "tokens=* delims= " %%a in ("!ln!") do set ln=%%a
    if not "x!ln!" == "x" (
        if "x!ln:~0,1!"=="x[" (
            set currarea=!ln!
        ) else (
            for /f "tokens=1,2 delims==" %%b in ("!ln!") do (
                set currkey=%%b
                set currval=%%c

                if "x!area!"=="x!currarea!" (
                    if "x!inival!" == "x" (
                        set "inival=!currkey!=!currval!"
                    ) else (
                        set "inival=!inival!;!currkey!=!currval!"
                    )
                )
            )
        )
    )
)
:return_GetIniPairs
endlocal & (
    set inival=%inival%
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function GetIniValue(file, area, key) extensions delayedexpansion
@setlocal enableextensions enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_GetIniValue %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:GetIniValue
@setlocal enableextensions enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=GetIniValue %CALL_STACK%
goto :REALBODY_GetIniValue
:REALBODY_GetIniValue
set file=%~1
if "%file%" == "" endlocal & ( set "ERROR_MSG=Need argument file" & set "ERROR_SOURCE=parseini.cmd" & set "ERROR_BLOCK=GetIniValue" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set area=%~1
if "%area%" == "" endlocal & ( set "ERROR_MSG=Need argument area" & set "ERROR_SOURCE=parseini.cmd" & set "ERROR_BLOCK=GetIniValue" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set key=%~1
if "%key%" == "" endlocal & ( set "ERROR_MSG=Need argument key" & set "ERROR_SOURCE=parseini.cmd" & set "ERROR_BLOCK=GetIniValue" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift

:ArgCheckLoop_GetIniValue
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_GetIniValue
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=parseini.cmd" & set "ERROR_BLOCK=GetIniValue" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_GetIniValue
:Main_GetIniValue
@set head=
@set next=
set inival=
if not exist "%file%" goto :return_GetIniValue
set area=[%area%]
set currarea=

for /f "usebackq delims=" %%a in ("!file!") do (
    set ln=%%a
    for /f "tokens=* delims= " %%a in ("!ln!") do set ln=%%a
    if not "x!ln!" == "x" (
        if "x!ln:~0,1!"=="x[" (
            set currarea=!ln!
        ) else (
            for /f "tokens=1,2 delims==" %%b in ("!ln!") do (
                set currkey=%%b
                set currval=%%c

                if "x!area!"=="x!currarea!" if "x!key!"=="x!currkey!" (
                    set inival=!currval!
                    goto :return_GetIniValue
                )
            )
        )
    )
)
:return_GetIniValue
endlocal & (
    set inival=%inival%
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function GetPrjRoot()
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_GetPrjRoot %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:GetPrjRoot
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=GetPrjRoot %CALL_STACK%
goto :REALBODY_GetPrjRoot
:REALBODY_GetPrjRoot

:ArgCheckLoop_GetPrjRoot
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_GetPrjRoot
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=project-paths.cmd" & set "ERROR_BLOCK=GetPrjRoot" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_GetPrjRoot
:Main_GetPrjRoot
@set head=
@set next=
call :get_dir %SCRIPT_SOURCE%
set PRJ_ROOT=
pushd %dir%
set PRJ_ROOT=%cd%
popd
endlocal & (
    set PRJ_ROOT=%PRJ_ROOT%
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
:get_dir
    set dir=%~dp0
goto :eof
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function GetTitle(titlePath)
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_GetTitle %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:GetTitle
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=GetTitle %CALL_STACK%
goto :REALBODY_GetTitle
:REALBODY_GetTitle
set titlePath=%~1
if "%titlePath%" == "" endlocal & ( set "ERROR_MSG=Need argument titlePath" & set "ERROR_SOURCE=project-paths.cmd" & set "ERROR_BLOCK=GetTitle" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift

:ArgCheckLoop_GetTitle
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_GetTitle
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=project-paths.cmd" & set "ERROR_BLOCK=GetTitle" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_GetTitle
:Main_GetTitle
@set head=
@set next=
set SPLITSTR=%titlePath%
:nextVar
   for /F tokens^=1*^ delims^=^\ %%a in ("%SPLITSTR%") do (
      set LAST=%%a
      set SPLITSTR=%%b
   )
if defined SPLITSTR goto nextVar
set TITLE=%LAST%
endlocal & (
    set TITLE=%TITLE%
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function LoadConfigPaths()
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_LoadConfigPaths %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:LoadConfigPaths
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=LoadConfigPaths %CALL_STACK%
goto :REALBODY_LoadConfigPaths
:REALBODY_LoadConfigPaths

:ArgCheckLoop_LoadConfigPaths
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_LoadConfigPaths
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=project-paths.cmd" & set "ERROR_BLOCK=LoadConfigPaths" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_LoadConfigPaths
:Main_LoadConfigPaths
@set head=
@set next=
:: 尋找並讀取devon.ini設定檔, 此檔案可以放在PRJ_ROOT或是PRJ_ROOT/config
:: 不論此設定檔存在與否, 均會回傳以下路徑設定
:: PRJ_BIN, PRJ_VAR, PRJ_LOG, PRJ_TMP, PRJ_CONF

call :GetPrjRoot
call :GetTitle %PRJ_ROOT%


set CONFIG_PATH=
pushd %PRJ_ROOT%
pushd config 2>nul
if not errorlevel 1 (
    if exist "devon.ini" set CONFIG_PATH=%cd%
    popd
)
if exist "devon.ini" set CONFIG_PATH=%cd%
popd
if not "%CONFIG_PATH%" == "" set DEVON_CONFIG_PATH=%CONFIG_PATH%\devon.ini




call :GetIniValue %CONFIG_PATH%\devon.ini layout bin
set PRJ_BIN_RAW=%inival%
call :GetIniValue %CONFIG_PATH%\devon.ini layout var
set PRJ_VAR_RAW=%inival%
call :GetIniValue %CONFIG_PATH%\devon.ini layout log
set PRJ_LOG_RAW=%inival%
call :GetIniValue %CONFIG_PATH%\devon.ini layout tmp
set PRJ_TMP_RAW=%inival%
call :GetIniValue %CONFIG_PATH%\devon.ini layout config
set PRJ_CONF_RAW=%inival%

if "%PRJ_BIN_RAW%" == "" if exist "%PRJ_ROOT%\bin" set PRJ_BIN_RAW=bin
if "%PRJ_VAR_RAW%" == "" if exist "%PRJ_ROOT%\var" set PRJ_VAR_RAW=var
if "%PRJ_LOG_RAW%" == "" if exist "%PRJ_ROOT%\log" set PRJ_LOG_RAW=log
if "%PRJ_TMP_RAW%" == "" if exist "%PRJ_ROOT%\tmp" set PRJ_TMP_RAW=tmp
if "%PRJ_CONF_RAW%" == "" if exist "%PRJ_ROOT%\config" set PRJ_CONF_RAW=config


if "%PRJ_BIN_RAW%" == "" set PRJ_BIN_RAW=bin
set PRJ_BIN=%PRJ_ROOT%\%PRJ_BIN_RAW%
if "%PRJ_VAR_RAW%" == "" (
    set PRJ_VAR=%TEMP%\devon-%TITLE%
) else (
    set PRJ_VAR=%PRJ_ROOT%\%PRJ_VAR_RAW%
)
if "%PRJ_LOG_RAW%" == "" (
    set PRJ_LOG=%PRJ_VAR%\log
) else (
    set PRJ_LOG=%PRJ_ROOT%\%PRJ_LOG_RAW%
)
if "%PRJ_TMP_RAW%" == "" (
    set PRJ_TMP=%PRJ_VAR%\tmp
) else (
    set PRJ_TMP=%PRJ_ROOT%\%PRJ_TMP_RAW%
)
if "%PRJ_CONF_RAW%" == "" (
    if not "%CONFIG_PATH%" == "" set PRJ_CONF=%CONFIG_PATH%
) else (
    set PRJ_CONF=%PRJ_ROOT%\%PRJ_CONF_RAW%
)
if "%PRJ_CONF%" == "" set PRJ_CONF=%PRJ_ROOT%\config


endlocal & (
    set DEVON_CONFIG_PATH=%DEVON_CONFIG_PATH%
    set PRJ_ROOT=%PRJ_ROOT%
    set PRJ_BIN=%PRJ_BIN%
    set PRJ_VAR=%PRJ_VAR%
    set PRJ_LOG=%PRJ_LOG%
    set PRJ_TMP=%PRJ_TMP%
    set PRJ_CONF=%PRJ_CONF%
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function BasicCheck()
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_BasicCheck %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:BasicCheck
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=BasicCheck %CALL_STACK%
goto :REALBODY_BasicCheck
:REALBODY_BasicCheck

:ArgCheckLoop_BasicCheck
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_BasicCheck
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=dev-sh.cmd" & set "ERROR_BLOCK=BasicCheck" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_BasicCheck
:Main_BasicCheck
@set head=
@set next=
if not "%~d0" == "C:" (
     endlocal & ( set "ERROR_MSG=folder must in C:" & set "ERROR_SOURCE=dev-sh.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
)
echo %~dp0| findstr /R /C:"^[a-zA-Z0-9~.\\:_-]*$">nul 2>&1
if errorlevel 1 (
     endlocal & ( set "ERROR_MSG=folder path contains illegal characters" & set "ERROR_SOURCE=dev-sh.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
)
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof


:ActiveDevShell
if "%DEVSH_ACTIVATE%" == "%SCRIPT_SOURCE%" goto :eof

call :BasicCheck
call :LoadConfigPaths
call :GetTitle %PRJ_ROOT%

set PATH=C:\__dev_setpath;%PATH%

if exist "%PRJ_BIN%" set PATH=%PRJ_BIN%;%PATH%
if exist "%PRJ_TOOLS%" set PATH=%PRJ_TOOLS%;%PATH%
if exist "%PRJ_CONF%" set PATH=%PRJ_CONF%;%PATH%

call :GetIniArray %DEVON_CONFIG_PATH% "path"
call set inival=%inival%
set PATH=%inival%;%PATH%


rmdir /S /Q %PRJ_TMP%\command
md %PRJ_TMP%\command
set PATH=%PRJ_TMP%\command;%PATH%

set inival=
call :GetIniArray %DEVON_CONFIG_PATH% "dotfiles"
(set Text=!inival!)&(set LoopCb=:call_dotfile)&(set ExitCb=:exit_call_dotfile)&(set Spliter=;)
goto :SubString
:call_dotfile
    if exist "!substring!.cmd" call call "!substring!.cmd"
    goto :NextSubString
:exit_call_dotfile
set inival=

call :GetIniPairs %DEVON_CONFIG_PATH% "dependencies"
if not "%inival%" == "" set specs=%inival:;= %
call :EnterPostScript
call :brickv_CMD_Update "%specs%" --no-install --vvv
call :ExecutePostScript


if exist "%PRJ_CONF%\hooks\set-env.cmd" (
    call "%PRJ_CONF%\hooks\set-env.cmd"
)

set PATH=C:\__dev_endpath;%PATH%

call :GenerateCommandStubs

set DEVSH_ACTIVATE=%SCRIPT_SOURCE%
goto :eof

::: function CMD_brickv(brickv_cmd, brickv_args=....)
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_CMD_brickv %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:CMD_brickv
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=CMD_brickv %CALL_STACK%
goto :REALBODY_CMD_brickv
:REALBODY_CMD_brickv
set brickv_cmd=%~1
if "%brickv_cmd%" == "" endlocal & ( set "ERROR_MSG=Need argument brickv_cmd" & set "ERROR_SOURCE=dev-sh.cmd" & set "ERROR_BLOCK=CMD_brickv" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set brickv_args=

:ArgCheckLoop_CMD_brickv
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_CMD_brickv
if x%2x == xx set next=__NONE__

@goto :GetRestArgs_CMD_brickv

:GetRestArgs_CMD_brickv

@set brickv_args=%1
@shift
:GetRestArgsLoop_CMD_brickv
@if "%~1" == "" @goto :Main_CMD_brickv
@set brickv_args=%brickv_args% %1
@shift
@goto :GetRestArgsLoop_CMD_brickv
:Main_CMD_brickv
@set head=
@set next=
call :brickv_CMD_%brickv_cmd% %brickv_args%
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
::: function CMD_welcome()
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_CMD_welcome %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:CMD_welcome
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=CMD_welcome %CALL_STACK%
goto :REALBODY_CMD_welcome
:REALBODY_CMD_welcome

:ArgCheckLoop_CMD_welcome
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_CMD_welcome
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=dev-sh.cmd" & set "ERROR_BLOCK=CMD_welcome" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_CMD_welcome
:Main_CMD_welcome
@set head=
@set next=
if not "%ANSICON%" == "" call :ImportColor
echo %BW%Devone%NN% v%DEVON_VERSION% [project %DC%%TITLE%%NN%]
call :GetIniValue %DEVON_CONFIG_PATH% "help" "*"
if not "%inival%" == "" call echo %inival%
echo.@set PROMPT=$C%DC%!TITLE!%NN%$F$S$P$G > "%POST_SCIRPT%"
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
::: function CMD_version()
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_CMD_version %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:CMD_version
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=CMD_version %CALL_STACK%
goto :REALBODY_CMD_version
:REALBODY_CMD_version

:ArgCheckLoop_CMD_version
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_CMD_version
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=dev-sh.cmd" & set "ERROR_BLOCK=CMD_version" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_CMD_version
:Main_CMD_version
@set head=
@set next=
echo v%DEVON_VERSION%
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function GenerateCommandStubs()
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_GenerateCommandStubs %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:GenerateCommandStubs
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=GenerateCommandStubs %CALL_STACK%
goto :REALBODY_GenerateCommandStubs
:REALBODY_GenerateCommandStubs

:ArgCheckLoop_GenerateCommandStubs
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_GenerateCommandStubs
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=dev-sh.cmd" & set "ERROR_BLOCK=GenerateCommandStubs" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_GenerateCommandStubs
:Main_GenerateCommandStubs
@set head=
@set next=
call :GetIniPairs %DEVON_CONFIG_PATH% "alias"
(set Text=!inival!)&(set LoopCb=:create_alias_file)&(set ExitCb=:exit_create_alias_file)&(set Spliter=;)
goto :SubString
:create_alias_file
    echo !substring!
    for /f "tokens=1,2 delims==" %%a in ("!substring!") do (
        set alias=%%a
        set alias_cmd=%%b
    )
    echo.cmd.exe /C "%alias_cmd%" > %PRJ_TMP%\command\%alias%.cmd
    goto :NextSubString
:exit_create_alias_file
set inival=

echo.@"%SCRIPT_SOURCE%" --cmd %%* > %PRJ_TMP%\command\dev.cmd


set GitHooksScript=#^^!/usr/bin/env bash^

#^

# Copyright (c) 2010-2014, Benjamin C. Meyer ^<ben@meyerhome.net^>^

# All rights reserved.^

#^

# Redistribution and use in source and binary forms, with or without^

# modification, are permitted provided that the following conditions are met:^

# 1. Redistributions of source code must retain the above copyright^

#    notice, this list of conditions and the following disclaimer.^

# 2. Redistributions in binary form must reproduce the above copyright^

#    notice, this list of conditions and the following disclaimer in the^

#    documentation and/or other materials provided with the distribution.^

# 3. Neither the name of the project nor the^

#    names of its contributors may be used to endorse or promote products^

#    derived from this software without specific prior written permission.^

#^

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ''AS IS'' AND ANY^

# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED^

# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE^

# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY^

# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES^

# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;^

# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND^

# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT^

# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS^

# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.^

#^

^

function hook_dirs^

{^

    if [ ^^! -z ^"${1}^" ] ; then^

        hook=^"/${1}^"^

    else^

        hook=^"^"^

    fi^

    echo ^"${HOME}/.git_hooks${hook}^"^

    git rev-parse --git-dir ^&^> /dev/null^

    if [ $? -eq 0 ]; then^

    if [ ^^! -z ^"${PRJ_CONF}^" ]; then^

        echo ^"${PRJ_CONF}/git_hooks${hook}^"^

    elif [ $(git rev-parse --is-bare-repository) = 'false' ]; then^

        cd $(git rev-parse --show-toplevel)^

        echo ^"${PWD}/git_hooks${hook}^"^

        echo ^"${PWD}/.githooks${hook}^"^

    fi^

    fi^

    eval echo ^"`git config hooks.global`^"${hook}^

}^

^

function list_hooks_in_dir^

{^

    path=^"${1}^"^

    level=^"${2}^"^

    if [ ^"$(expr substr $(uname -s) 1 5)^" == ^"MINGW^" ]; then^

        # mingw dose not have perm mode^

        permcheck=^

    else^

        permcheck=-perm +111^

    fi^

    find --help 2^>^&1 ^| grep -- '-L' 2^>/dev/null ^>/dev/null^

    if [ $? -eq 1 ] ; then^

        find ^"${path}/^" -mindepth ${level} -maxdepth ${level} ${permcheck} -type f 2^>/dev/null ^| grep -v ^"^^^^.$^" ^| sort^

    else^

        find -L ^"${path}/^" -mindepth ${level} -maxdepth ${level} ${permcheck} -type f 2^>/dev/null ^| grep -v ^"^^^^.$^" ^| sort^

    fi^

}^

^

function list_hooks^

{^

    GITDIR=`git rev-parse --git-dir`^

    cat ^"${GITDIR}/hooks/pre-commit^" 2^> /dev/null ^| grep 'git-hooks' ^> /dev/null 2^> /dev/null^

    if [ $? = 0 ] ; then^

        echo ^"Git hooks ARE installed in this repository.^"^

        echo ^"^"^

    else^

        echo ^"Git hooks are NOT installed in this repository. (Run 'git hooks --install' to install it)^"^

        echo ^"^"^

    fi^

^

    echo 'Listing User, Project, and Global hooks:'^

    echo '---'^

    for dir in `hook_dirs`; do^

        echo ^"${dir}:^"^

        for hook in `list_hooks_in_dir ^"${dir}^" 2` ; do^

            echo -n `basename \`dirname ^"${hook}^"\``^

            echo -e ^"/`basename ^"${hook}^"` \t- `${hook} --about`^"^

        done^

        echo ^"^"^

    done^

}^

^

function run_hooks^

{^

    dir=^"${1}^"^

    if [[ -z ${dir} ^|^| ^^! -d ^"${dir}^" ]] ; then^

        echo ^"run_hooks requires a directory name as an argument.^"^

        return 1^

    fi^

    shift 1^

    for hook in `list_hooks_in_dir ^"${dir}^" 1`^

    do^

        export last_run_hook=^"${hook} $@^"^

        if [ ^^! -z ${GIT_HOOKS_VERBOSE} ] ; then^

            echo -n ^"@@ Running hook: ^"^

            echo -n `basename \`dirname ^"${hook}^"\``^

            echo ^"/`basename ^"${hook}^"`^"^

        fi^

        ${hook} ^"$@^"^

    done^

}^

^

function run_hook^

{^

    set -e^

    hook=`basename ^"${1}^"`^

    if [ -z ${hook} ] ; then^

        echo ^"run requires a hook argument^"^

        return 1^

    fi^

    shift 1^

    for dir in `hook_dirs ^"${hook}^"`; do^

        if [ ^^! -d ^"${dir}^" ] ; then^

            continue^

        fi^

        run_hooks ^"${dir}^" ^"$@^"^

    done^

    set +e^

}^

^

function install_hooks_into^

{^

    DIR=$1^

    cd ^"${DIR}^"^

^

    set -e^

    mv hooks hooks.old^

    set +e^

    mkdir hooks^

    cd hooks^

    for file in applypatch-msg commit-msg post-applypatch post-checkout post-commit post-merge post-receive pre-applypatch pre-auto-gc pre-commit prepare-commit-msg pre-rebase pre-receive update pre-push^

    do^

        echo ^"${2}^" ^> ^"${file}^"^

        chmod +x ^"${file}^"^

    done^

}^

^

function install_hooks^

{^

    GITDIR=`git rev-parse --git-dir`^

    if [ ^^! $? -eq 0 ] ; then^

        echo ^"$1 must be run inside a git repository^"^

        return 1^

    fi^

    cd ^"${GITDIR}^"^

    if [ ^"${1}^" = ^"--install^" ] ; then^

        if [ -d hooks.old ] ; then^

            echo ^"hooks.old already exists, perhaps you already installed?^"^

            return 1^

        fi^

    cmd='#^^!/usr/bin/env bash^

if [ -f ^"$(git rev-parse --git-dir)/.devon^" ]; then^

if [ -z ^"${PRJ_ROOT}^" ]; then^

    echo ^"Error, your in devon project, but not use dev-sh^"^

    exit 1^

fi^

fi^

git-hooks run ^"$0^" ^"$@^"';^

    install_hooks_into ^"${PWD}^" ^"${cmd}^"^

    else^

        if [ ^^! -d hooks.old ] ; then^

            echo ^"Error, hooks.old doesn't exists, aborting uninstall to not destroy something^"^

            return 1^

        fi^

        rm -rf hooks^

        mv hooks.old hooks^

    fi^

}^

^

function install_global^

{^

    TEMPLATE=^"$HOME/.git-template-with-git-hooks^"^

    if [ ^^! -d ^"${TEMPLATE}^" ] ; then^

        DEFAULT=/usr/share/git-core/templates^

        if [ -d ${DEFAULT} ] ; then^

            cp -rf /usr/share/git-core/templates ^"${TEMPLATE}^"^

        else^

            mkdir -p ^"${TEMPLATE}/hooks^"^

        fi^

        cmd=^"#^^!/usr/bin/env bash^

echo \^"git hooks not installed in this repository.  Run 'git hooks --install' to install it or 'git hooks -h' for more information.\^"^";^

        install_hooks_into ^"${TEMPLATE}^" ^"${cmd}^"^

        mv ^"${TEMPLATE}/hooks.old^" ^"${TEMPLATE}/hooks.original^"^

    fi^

    git config --global init.templatedir ^"${TEMPLATE}^"^

    echo ^"Git global config init.templatedir is now set to ${TEMPLATE}^"^

}^

^

function uninstall_global^

{^

    git config --global --unset init.templatedir^

}^

^

function report_error^

{^

    echo ^"Hook failed: $last_run_hook^"^

    exit 1^

^

}^

^

case $1 in^

    run )^

        if [ ^^! -z ^"${GIT_DIR}^" ] ; then^

            unset GIT_DIR^

        fi^

        shift^

        trap report_error ERR^

        run_hook ^"$@^"^

        ;;^

    --install^|--uninstall )^

        install_hooks ^"$1^"^

        ;;^

    --install-global^|--installglobal )^

        install_global^

        ;;^

    --uninstall-global^|--uninstallglobal )^

        uninstall_global^

        ;;^

    -h^|--help^|-? )^

        echo 'Git Hooks'^

        echo '    A tool to manage project, user, and global Git hooks for multiple git repositories.'^

        echo '    https://github.com/icefox/git-hooks'^

        echo ''^

        echo 'Options:'^

        echo '    --install      Replace existing hooks in this repository with a call to'^

        echo '                   git hooks run [hook].  Move old hooks directory to hooks.old'^

        echo '    --uninstall    Remove existing hooks in this repository and rename hooks.old'^

        echo '                   back to hooks'^

        echo '    --install-global'^

        echo '                   Create a template .git directory that that will be used whenever'^

        echo '                   a git repository is created or cloned that will remind the user'^

        echo '                   to install git-hooks.'^

        echo '    --uninstall-global'^

        echo '                   Turn off the global .git directory template that has the reminder.'^

        echo ^"    run ^<cmd^>      Run the hooks for ^<cmd^> (such as pre-commit)^"^

        echo ^"    (no arguments) Show currently installed hooks^"^

        ;;^

    * )^

        list_hooks^

        ;;^

esac^


echo.!GitHooksScript! > %PRJ_TMP%\command\git-hooks


set GitBashScript=@where git 1^>nul^

@if errorlevel 1 (^

    echo git not found^

    exit /b 1^

)^

@setlocal enabledelayedexpansion^

@set GIT_PATH=^

@for /f ^"tokens=*^" %%%%i in ('where git') do @if ^"^^!GIT_PATH^^!^" == ^"^" set GIT_PATH=%%%%i^

@for /f ^"tokens=*^" %%%%i in (^"%%GIT_PATH%%\..\..\bin^") do @set GIT_BIN=%%%%~fi^

@for /f ^"tokens=*^" %%%%i in (^"%%GIT_PATH%%\..\..\etc^") do @set GIT_ETC=%%%%~fi^

@del /Q ^"%%GIT_ETC%%\bash.bash_logout^" 2^>nul^

@^"%%GIT_BIN%%\bash^" --login -i %%*^

@endlocal^


echo.!GitBashScript! > %PRJ_TMP%\command\bash.cmd
echo.!GitBashScript! > %PRJ_TMP%\command\git-bash.cmd


endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
::: function CMD_shell(no_window=N, no_welcome=N) delayedexpansion
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_CMD_shell %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:CMD_shell
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=CMD_shell %CALL_STACK%
goto :REALBODY_CMD_shell
:REALBODY_CMD_shell
set no_window=0
set no_welcome=0

:ArgCheckLoop_CMD_shell
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_CMD_shell
if x%2x == xx set next=__NONE__

@if "%head%" == "--no-window" @(
    @set no_window=1
    @shift
    @goto :ArgCheckLoop_CMD_shell
)
@if "%head%" == "--no-welcome" @(
    @set no_welcome=1
    @shift
    @goto :ArgCheckLoop_CMD_shell
)

 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=dev-sh.cmd" & set "ERROR_BLOCK=CMD_shell" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_CMD_shell
:Main_CMD_shell
@set head=
@set next=
set CMDSCRIPT=
set CMDSCRIPT=!CMDSCRIPT!        (set no_window=)^&        (set no_welcome=)^&        (set CMDSCRIPT=)^&        (set CALL_STACK=)^&        (set SCRIPT_FOLDER=)^&        (set SCRIPT_SOURCE=)^&        (set DEVON_VERSION=)^&        (set _devcmd=)^&        (set _devargs=)^&


where ansicon.exe 2>&1 1>nul
if not errorlevel 1 (
    set "CMDSCRIPT=!CMDSCRIPT!(ansicon.exe -p)^&"
)

where clink.bat 2>&1 1>nul
if not errorlevel 1 (
    set "CMDSCRIPT=!CMDSCRIPT!(clink.bat inject 1>nul)^&"
)

if not "%no_welcome%" == "1" (
    set "CMDSCRIPT=!CMDSCRIPT!(dev welcome)^&"
)
set "CMDSCRIPT=!CMDSCRIPT!(call)"

pushd %PRJ_ROOT%
echo on
@if "%no_window%" == "1" @(
    @%ComSpec% /K "!CMDSCRIPT!"
) else @(
    @start "[%TITLE%]" %ComSpec% /K "!CMDSCRIPT!"
)
@echo off
popd
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function CMD_setup(UserName=?, GithubToken=?)
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_CMD_setup %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:CMD_setup
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=CMD_setup %CALL_STACK%
goto :REALBODY_CMD_setup
:REALBODY_CMD_setup
set UserName=
set GithubToken=

:ArgCheckLoop_CMD_setup
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_CMD_setup
if x%2x == xx set next=__NONE__

@if "%head%" == "--username" @(
    @set UserName=%next%
    @if "%next%" == "__NONE__" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=CMD_setup.cmd" & set "ERROR_BLOCK=CMD_setup" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @if "%next_prefix%" == "-" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=CMD_setup.cmd" & set "ERROR_BLOCK=CMD_setup" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @shift
    @shift
    @goto :ArgCheckLoop_CMD_setup
)
@if "%head%" == "--githubtoken" @(
    @set GithubToken=%next%
    @if "%next%" == "__NONE__" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=CMD_setup.cmd" & set "ERROR_BLOCK=CMD_setup" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @if "%next_prefix%" == "-" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=CMD_setup.cmd" & set "ERROR_BLOCK=CMD_setup" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @shift
    @shift
    @goto :ArgCheckLoop_CMD_setup
)

 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=CMD_setup.cmd" & set "ERROR_BLOCK=CMD_setup" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_CMD_setup
:Main_CMD_setup
@set head=
@set next=


git rev-parse 1>nul 1>&2
if errorlevel 1  endlocal & ( set "ERROR_MSG=Not a git repository" & set "ERROR_SOURCE=CMD_setup.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )

for /f %%i in ('git rev-parse --git-dir') do set GitDir=%%i
if exist "%GitDir%/.devon" (
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
)

if "%UserName%" == "" set /P UserName=Enter your name (or input 'global' use global config):
if "%GithubToken%" == "" set /P GithubToken=Enter the secret token:

for /f "tokens=1,2 delims==" %%a in ("%GithubToken%") do (
    set LoginName=%%a
    set LoginPassword=%%b
)

if "%UserName%" == ""  endlocal & ( set "ERROR_MSG=User name undefined" & set "ERROR_SOURCE=CMD_setup.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
if "%LoginName%" == ""  endlocal & ( set "ERROR_MSG=Login name undefined" & set "ERROR_SOURCE=CMD_setup.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
if "%LoginPassword%" == ""  endlocal & ( set "ERROR_MSG=Login password undefined" & set "ERROR_SOURCE=CMD_setup.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )

if not exist "%HOME%" mkdir "%HOME%"

echo.machine github.com>> %HOME%/_netrc
echo.login %LoginName%>> %HOME%/_netrc
echo.password %LoginPassword%>> %HOME%/_netrc
echo.>> %HOME%/_netrc

echo.machine api.github.com>> %HOME%/_netrc
echo.login %LoginName%>> %HOME%/_netrc
echo.password %LoginPassword%>> %HOME%/_netrc
echo.>> %HOME%/_netrc


if not "%UserName%" == "global" (
	git config --local user.name %UserName%
	git config --local user.email %UserName%@users.noreply.github.com
)
git config --local core.autocrlf true
git config --local push.default simple


echo. > "%GitDir%/.devon"

endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof


::: function CMD_sync(MOST_CLEAN=N) delayedexpansion
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_CMD_sync %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:CMD_sync
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=CMD_sync %CALL_STACK%
goto :REALBODY_CMD_sync
:REALBODY_CMD_sync
set MOST_CLEAN=0

:ArgCheckLoop_CMD_sync
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_CMD_sync
if x%2x == xx set next=__NONE__

@if "%head%" == "--most-clean" @(
    @set MOST_CLEAN=1
    @shift
    @goto :ArgCheckLoop_CMD_sync
)

 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=CMD_sync.cmd" & set "ERROR_BLOCK=CMD_sync" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_CMD_sync
:Main_CMD_sync
@set head=
@set next=





set MAIN_BRANCH=master
set CURRENT_CHANGES=
for /f %%i in ('git status --porcelain') do set CURRENT_CHANGES=%%i
for /f %%i in ('git symbolic-ref -q --short HEAD') do set CURRENT_BRANCH=%%i

if "%MOST_CLEAN%" == "1" if not "%CURRENT_CHANGES%" == ""  endlocal & ( set "ERROR_MSG=status most clean" & set "ERROR_SOURCE=CMD_sync.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
if not "%CURRENT_CHANGES%" == "" git stash --include-untracked
if not "%CURRENT_BRANCH%" == "%MAIN_BRANCH%" git checkout %MAIN_BRANCH%

git fetch origin --progress
if errorlevel 1  endlocal & ( set "ERROR_MSG=cannot fetch, maybe your network is offline" & set "ERROR_SOURCE=CMD_sync.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )


for /f %%i in ('git merge-base FETCH_HEAD %MAIN_BRANCH%') do set CommonCommit=%%i
git format-patch %CommonCommit%..FETCH_HEAD --stdout > .patchtest

for /f %%i in (".patchtest") do set filesize=%%~zi
if "%filesize%" == "0" (
    call :PrintMsg normal gitsync no change
    del .patchtest
    goto :return_CMD_sync
)

git apply --check .patchtest 2>nul
set errorlevel_save=%errorlevel%
del .patchtest

if "%errorlevel_save%" == "0" (
	call :PrintMsg normal gitsync fast forward
  	git merge -v FETCH_HEAD --ff-only
  	if not "!errorlevel!" == "0" (
	    call :PrintMsg normal gitsync rebase
	    git rebase FETCH_HEAD
  	)
) else (
	call :PrintMsg normal gitsync merge ours
	git merge -v FETCH_HEAD -s recursive -Xours
)

if not errorlevel 1 (
    git push -v origin --progress --tags
) else (
	call :PrintMsg error gitsync merge failed, this is a very rare situation
)

:return_CMD_sync
if not "%CURRENT_BRANCH%" == "%MAIN_BRANCH%" git checkout %CURRENT_BRANCH%
if not "%CURRENT_BRANCH%" == "%MAIN_BRANCH%" git rebase %MAIN_BRANCH%
if errorlevel 1 (
    call :PrintMsg warning gitsync rebase maybe conflict, abort rebase
    git rebase --abort
)
if not "%CURRENT_CHANGES%" == "" git stash pop

git submodule foreach git diff-index --quiet HEAD
if errorlevel 1 (
    call :PrintMsg warning gitsync some submodules is in the dirty status
    call :PrintMsg warning gitsync all submodules will not update until their folder is clean
) else (
	git submodule sync
	git submodule update --init --recursive
)

endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function PreparePrint(PRINT_LEVEL, MSG_TITLE)
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_PreparePrint %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:PreparePrint
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=PreparePrint %CALL_STACK%
goto :REALBODY_PreparePrint
:REALBODY_PreparePrint
set PRINT_LEVEL=%~1
if "%PRINT_LEVEL%" == "" endlocal & ( set "ERROR_MSG=Need argument PRINT_LEVEL" & set "ERROR_SOURCE=print.cmd" & set "ERROR_BLOCK=PreparePrint" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set MSG_TITLE=%~1
if "%MSG_TITLE%" == "" endlocal & ( set "ERROR_MSG=Need argument MSG_TITLE" & set "ERROR_SOURCE=print.cmd" & set "ERROR_BLOCK=PreparePrint" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift

:ArgCheckLoop_PreparePrint
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_PreparePrint
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=print.cmd" & set "ERROR_BLOCK=PreparePrint" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_PreparePrint
:Main_PreparePrint
@set head=
@set next=
if "%THISNAME%" == "" set THISNAME=brickv

if "%PRINT_LEVEL%" == "error" set PRINT_LEVEL=5
if "%PRINT_LEVEL%" == "warning" set PRINT_LEVEL=4
if "%PRINT_LEVEL%" == "normal" set PRINT_LEVEL=3
if "%PRINT_LEVEL%" == "info" set PRINT_LEVEL=2
if "%PRINT_LEVEL%" == "debug" set PRINT_LEVEL=1

if "%LOG_LEVEL%" == "" set LOG_LEVEL=3

set MSG_TITLE_F="%MSG_TITLE%              "
set MSG_TITLE_F=%MSG_TITLE_F:~1,15%
if "%TEST_SHELL%" == "1" set MSG_TITLE_F=%MSG_TITLE%

endlocal & (
    set PRINT_LEVEL=%PRINT_LEVEL%
    set LOG_LEVEL=%LOG_LEVEL%
    set THISNAME=%THISNAME%
    set MSG_TITLE_F=%MSG_TITLE_F%
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
::: function PrintMsg(PRINT_LEVEL, MSG_TITLE, MSG_BODY=....)
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_PrintMsg %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:PrintMsg
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=PrintMsg %CALL_STACK%
goto :REALBODY_PrintMsg
:REALBODY_PrintMsg
set PRINT_LEVEL=%~1
if "%PRINT_LEVEL%" == "" endlocal & ( set "ERROR_MSG=Need argument PRINT_LEVEL" & set "ERROR_SOURCE=print.cmd" & set "ERROR_BLOCK=PrintMsg" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set MSG_TITLE=%~1
if "%MSG_TITLE%" == "" endlocal & ( set "ERROR_MSG=Need argument MSG_TITLE" & set "ERROR_SOURCE=print.cmd" & set "ERROR_BLOCK=PrintMsg" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set MSG_BODY=

:ArgCheckLoop_PrintMsg
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_PrintMsg
if x%2x == xx set next=__NONE__

@goto :GetRestArgs_PrintMsg

:GetRestArgs_PrintMsg

@set MSG_BODY=%1
@shift
:GetRestArgsLoop_PrintMsg
@if "%~1" == "" @goto :Main_PrintMsg
@set MSG_BODY=%MSG_BODY% %1
@shift
@goto :GetRestArgsLoop_PrintMsg
:Main_PrintMsg
@set head=
@set next=
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
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function PrintVersion(PRINT_LEVEL, MSG_TITLE, PV_APP, PV_VER, PV_ARCH, PV_PATCHES)
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_PrintVersion %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:PrintVersion
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=PrintVersion %CALL_STACK%
goto :REALBODY_PrintVersion
:REALBODY_PrintVersion
set PRINT_LEVEL=%~1
if "%PRINT_LEVEL%" == "" endlocal & ( set "ERROR_MSG=Need argument PRINT_LEVEL" & set "ERROR_SOURCE=print.cmd" & set "ERROR_BLOCK=PrintVersion" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set MSG_TITLE=%~1
if "%MSG_TITLE%" == "" endlocal & ( set "ERROR_MSG=Need argument MSG_TITLE" & set "ERROR_SOURCE=print.cmd" & set "ERROR_BLOCK=PrintVersion" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set PV_APP=%~1
if "%PV_APP%" == "" endlocal & ( set "ERROR_MSG=Need argument PV_APP" & set "ERROR_SOURCE=print.cmd" & set "ERROR_BLOCK=PrintVersion" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set PV_VER=%~1
if "%PV_VER%" == "" endlocal & ( set "ERROR_MSG=Need argument PV_VER" & set "ERROR_SOURCE=print.cmd" & set "ERROR_BLOCK=PrintVersion" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set PV_ARCH=%~1
if "%PV_ARCH%" == "" endlocal & ( set "ERROR_MSG=Need argument PV_ARCH" & set "ERROR_SOURCE=print.cmd" & set "ERROR_BLOCK=PrintVersion" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set PV_PATCHES=%~1
if "%PV_PATCHES%" == "" endlocal & ( set "ERROR_MSG=Need argument PV_PATCHES" & set "ERROR_SOURCE=print.cmd" & set "ERROR_BLOCK=PrintVersion" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift

:ArgCheckLoop_PrintVersion
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_PrintVersion
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=print.cmd" & set "ERROR_BLOCK=PrintVersion" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_PrintVersion
:Main_PrintVersion
@set head=
@set next=
call :PreparePrint "%PRINT_LEVEL%" "%MSG_TITLE%"
call :ImportColor

:: request, match, newest
set OUTPUT=%THISNAME% %DP%%MSG_TITLE_F%%NN% %BW%%PV_APP%%NN%^=%PV_VER%%BW%%NN%@%PV_ARCH%[%PV_PATCHES%]
call :_Print
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof


:PrintTaskInfo::: function PrintTaskInfo()
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_PrintTaskInfo %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:PrintTaskInfo
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=PrintTaskInfo %CALL_STACK%
goto :REALBODY_PrintTaskInfo
:REALBODY_PrintTaskInfo

:ArgCheckLoop_PrintTaskInfo
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_PrintTaskInfo
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=print.cmd" & set "ERROR_BLOCK=PrintTaskInfo" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_PrintTaskInfo
:Main_PrintTaskInfo
@set head=
@set next=
call :ImportColor

set PRINT_LEVEL=1
set MSG_TITLE=task
call :PreparePrint "%PRINT_LEVEL%" "%MSG_TITLE%"

set OUTPUT=%THISNAME% %BR%%MSG_TITLE_F%%NN% targetdir:  %TARGETDIR%
call :_Print
set OUTPUT=                       name:       %TARGET_NAME%
call :_Print
set OUTPUT=                       installer:  %INSTALLER%
call :_Print
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof



:_Print
if %PRINT_LEVEL% GEQ %LOG_LEVEL% echo.%OUTPUT%
goto :eof


:ImportColor
if not "%NN%" == "" goto :eof
if "%NO_COLOR%" == "1" goto :eof
if "%TEST_SHELL%" == "1" goto :eof

for /F "skip=1 delims=" %%F in ('
    wmic PATH Win32_LocalTime GET Day^,Month^,Year /FORMAT:TABLE
') do (
    for /F "tokens=1-3" %%L in ("%%F") do (
        set Day=0%%L
        set Month=0%%M
        set Year=%%N
    )
)
set Day=%Day:~-2%
set Month=%Month:~-2%

set ColorTable="%TEMP%\colortable%Year%%Month%%Day%.cmd"
if not exist "%ColorTable%" call :MakeColorTable "%ColorTable%"
call "%ColorTable%"

set Day=
set Month=
set Year=
set ColorTable=
goto :eof

::: function MakeColorTable(ColorTable) delayedexpansion
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_MakeColorTable %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:MakeColorTable
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=MakeColorTable %CALL_STACK%
goto :REALBODY_MakeColorTable
:REALBODY_MakeColorTable
set ColorTable=%~1
if "%ColorTable%" == "" endlocal & ( set "ERROR_MSG=Need argument ColorTable" & set "ERROR_SOURCE=color.cmd" & set "ERROR_BLOCK=MakeColorTable" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift

:ArgCheckLoop_MakeColorTable
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_MakeColorTable
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=color.cmd" & set "ERROR_BLOCK=MakeColorTable" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_MakeColorTable
:Main_MakeColorTable
@set head=
@set next=
for /f %%a in ('"prompt $e & for %%b in (1) do rem"') do @set esc=%%a

set count=0
for %%A IN (K,R,G,Y,B,P,C,W) do call :SetAtomColor %%A

echo @set NN=%esc%[0m> "%ColorTable%"
for %%A IN (_FDK,_FDR,_FDG,_FDY,_FDB,_FDP,_FDC,_FDW, _FBK,_FBR,_FBG,_FBY,_FBB,_FBP,_FBC,_FBW) do (
    for %%B IN ("","") do call :SetColor %%A %%B
)

endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof


:SetColor
@set Front=%~1
@set Back=%~2
@if "%Back%" == "" @(
    @echo @set %Front:~2%=%esc%[0;!%Front%!;40m>> "%ColorTable%"
) else @(
    @echo @set %Front:~1%%Back:~1%=%esc%[0;!%Front%!;!%Back%!m>> "%ColorTable%"
)
@goto :eof


:SetAtomColor
@set _FD%1=3%count%
@set _FB%1=1;3%count%
@set _BD%1=4%count%
@set _BB%1=4;4%count%
@set /A count+=1
@goto :eof




::: function CMD_update()
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_CMD_update %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:CMD_update
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=CMD_update %CALL_STACK%
goto :REALBODY_CMD_update
:REALBODY_CMD_update

:ArgCheckLoop_CMD_update
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_CMD_update
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=CMD_update.cmd" & set "ERROR_BLOCK=CMD_update" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_CMD_update
:Main_CMD_update
@set head=
@set next=



set inival=
call :GetIniPairs %DEVON_CONFIG_PATH% "dependencies"
if not "%inival%" == "" set specs=%inival:;= %

if exist "%PRJ_CONF%\hooks\update.cmd" (
    call "%PRJ_CONF%\hooks\update.cmd"
)

endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function CMD_bootstrap(git_remote)
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_CMD_bootstrap %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:CMD_bootstrap
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=CMD_bootstrap %CALL_STACK%
goto :REALBODY_CMD_bootstrap
:REALBODY_CMD_bootstrap
set git_remote=%~1
if "%git_remote%" == "" endlocal & ( set "ERROR_MSG=Need argument git_remote" & set "ERROR_SOURCE=CMD_update.cmd" & set "ERROR_BLOCK=CMD_bootstrap" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift

:ArgCheckLoop_CMD_bootstrap
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_CMD_bootstrap
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=CMD_update.cmd" & set "ERROR_BLOCK=CMD_bootstrap" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_CMD_bootstrap
:Main_CMD_bootstrap
@set head=
@set next=
call :EnterPostScript
call :brickv_CMD_Update "git=2.x" --vv
call :ExecutePostScript

git clone %git_remote% > "%TEMP%\git-clone-stdout.txt"
if errorlevel 1  endlocal & ( set "ERROR_MSG=git clone failed" & set "ERROR_SOURCE=CMD_update.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
for /F "tokens=1-3 usebackq" %%A IN ("%TEMP%\git-clone-stdout.txt") do (
    if "%%A" == "Cloning" if "%%B" == "into" set ProjectRoot=%%C
)
set ProjectRoot=%ProjectRoot:~1, -4%
echo %ProjectRoot%

if not exist "%ProjectRoot%\dev-sh.cmd"  endlocal & ( set "ERROR_MSG=project not exist" & set "ERROR_SOURCE=CMD_update.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
call "%ProjectRoot%\dev-sh.cmd" init
call "%ProjectRoot%\dev-sh.cmd" update
call "%ProjectRoot%\dev-sh.cmd" shell


endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof


::: function CMD_clear()
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_CMD_clear %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:CMD_clear
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=CMD_clear %CALL_STACK%
goto :REALBODY_CMD_clear
:REALBODY_CMD_clear

:ArgCheckLoop_CMD_clear
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_CMD_clear
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=CMD_clear.cmd" & set "ERROR_BLOCK=CMD_clear" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_CMD_clear
:Main_CMD_clear
@set head=
@set next=




set inival=
call :GetIniArray DEVON_CONFIG_PATH "clear"
(set Text=!inival!)&(set LoopCb=:clear_prject)&(set ExitCb=:exit_clear_prject)&(set Spliter=;)
goto :SubString
:clear_prject
    if not "!substring!" == "" if exist "!PRJ_ROOT!\!substring!" call del "!PRJ_ROOT!\!substring!"
    goto :NextSubString
:exit_clear_prject
set inival=

if exist "%PRJ_CONF%\hooks\clear.cmd" (
    call "%PRJ_CONF%\hooks\clear.cmd"
)

endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof




::: function brickv_CMD_install(ONLY_VERSIONS=N, args=....) delayedexpansion
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_brickv_CMD_install %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:brickv_CMD_install
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=brickv_CMD_install %CALL_STACK%
goto :REALBODY_brickv_CMD_install
:REALBODY_brickv_CMD_install
set ONLY_VERSIONS=0
set args=

:ArgCheckLoop_brickv_CMD_install
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_brickv_CMD_install
if x%2x == xx set next=__NONE__

@if "%head%" == "--only-versions" @(
    @set ONLY_VERSIONS=1
    @shift
    @goto :ArgCheckLoop_brickv_CMD_install
)
@goto :GetRestArgs_brickv_CMD_install

:GetRestArgs_brickv_CMD_install

@set args=%1
@shift
:GetRestArgsLoop_brickv_CMD_install
@if "%~1" == "" @goto :Main_brickv_CMD_install
@set args=%args% %1
@shift
@goto :GetRestArgsLoop_brickv_CMD_install
:Main_brickv_CMD_install
@set head=
@set next=

set ACCEPT=1

call :BrickvPrepare %args%
set args=
set APPNAME=%REQUEST_APP%

call :ExistsLabel %APPNAME%_init
if "%LabelExists%" == "1" (
    call :%APPNAME%_Init
) else (
     endlocal & ( set "ERROR_MSG=%APPNAME% not in installable list" & set "ERROR_SOURCE=brickv_CMD_install.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
)

if not "%PRJ_TMP%" == "" set TEMP=%PRJ_TMP%
set VERSION_SOURCE_FILE=%TEMP%\source_%APPNAME%.ver.txt
set VERSION_SPCES_FILE=%TEMP%\spces-%APPNAME%.ver.txt

if exist "%VERSION_SOURCE_FILE%" del "%VERSION_SOURCE_FILE%" >nul
copy /y NUL "%VERSION_SOURCE_FILE%" >NUL
if exist "%VERSION_SPCES_FILE%" del "%VERSION_SPCES_FILE%" >nul
copy /y NUL "%VERSION_SPCES_FILE%" >NUL

call :ExistsLabel %APPNAME%_versions
if "%LabelExists%" == "1" call :%APPNAME%_versions
if exist "%RELEASE_URL%" call :BrickvDownload "%RELEASE_URL%" "%VERSION_SPCES_FILE%"
if "%ONLY_VERSIONS%" == "1" (
endlocal & (
    set VERSION_SPCES_FILE=%VERSION_SPCES_FILE%
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
)

if exist "%VERSION_SPCES_FILE%" (
    call :MatchVersion --output-format env --spec-match "%REQUEST_SPEC%" --specs-file "%VERSION_SPCES_FILE%"
            if not "!ERROR_MSG!" == "" goto :brickv_CMD_install_Error
) else (
     endlocal & ( set "ERROR_MSG=release version list is empty" & set "ERROR_SOURCE=brickv_CMD_install.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    rem if "%RELEASE_LIST%" == ""  endlocal & ( set "ERROR_MSG=release version list is empty" & set "ERROR_SOURCE=brickv_CMD_install.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
)


call :ExistsLabel %APPNAME%_prepare
if "%LabelExists%" == "1" call :%APPNAME%_prepare
if not "%DOWNLOAD_URL_TEMPLATE%" == "" call set DOWNLOAD_URL=%DOWNLOAD_URL_TEMPLATE%


call :BrickvBeforeInstall
        if not "%ERROR_MSG%" == "" goto :brickv_CMD_install_Error

rem if "%LabelExists%" == "1" call :%APPNAME%_download
if not "%DOWNLOAD_URL%" == "" if "%INSTALLER%" == "" call :FilenameFromUrl "%DOWNLOAD_URL%"
if not "%DOWNLOAD_URL%" == "" if "%INSTALLER%" == "" set INSTALLER=%TEMP%\%Filename%
set Filename=
call :PrintTaskInfo
if "%DRYRUN%" == "1" goto :BrickvInstallFinal

if not "%DOWNLOAD_URL%" == "" (
    call :BrickvDownload "%DOWNLOAD_URL%" "%INSTALLER%" --skip-exists
)
        if not "%ERROR_MSG%" == "" goto :brickv_CMD_install_Error

call :ExistsLabel %APPNAME%_unpack
if "%LabelExists%" == "1" call :%APPNAME%_unpack
        if not "%ERROR_MSG%" == "" goto :brickv_CMD_install_Error
if not "%INSTALLER%" == "" (
    if "%UNPACK_METHOD%" == "msi-install" call :InstallMsi "%INSTALLER%"
            if not "!ERROR_MSG!" == "" goto :brickv_CMD_install_Error
    if "%UNPACK_METHOD%" == "msi-unpack" call :UnpackMsi "%INSTALLER%" "%TARGET%"
            if not "!ERROR_MSG!" == "" goto :brickv_CMD_install_Error
    if "%UNPACK_METHOD%" == "unzip" call :Unzip "%INSTALLER%" "%TARGETDIR%"
            if not "!ERROR_MSG!" == "" goto :brickv_CMD_install_Error
)


set ValidateFailed=0
call :ExistsLabel %APPNAME%_validate
if "%LabelExists%" == "1" call :%APPNAME%_validate
if "%ValidateFailed%" == "1" (
    set ERROR_MSG="extra validate failed"
    goto :brickv_CMD_install_Error
)
call :BrickvGenEnv "%TARGET%" "%SETENV%"
        if not "%ERROR_MSG%" == "" goto :brickv_CMD_install_Error

call :BrickvValidate
if not "%ERROR_MSG%" == "" (
    call :PrintMsg warning warning validate error: %ERROR_MSG%
) else (
    call :PrintMsg noraml validate succeed
)

:BrickvInstallFinal
set ERROR_MSG=
call :BrickvDone
if not "%ERROR_MSG%" == "" if "%CALL_STACK%" == "" goto :_Error
if not "%ERROR_MSG%" == ""  endlocal & ( set "ERROR_MSG=%ERROR_MSG%" & set "ERROR_SOURCE=%ERROR_SOURCE%" & set "ERROR_BLOCK=%ERROR_BLOCK%" & set "ERROR_LINENO=%ERROR_LINENO%" & set "ERROR_CALLSTACK=%ERROR_CALLSTACK%" & goto :eof )
cmd /C exit /b 0
endlocal & (
    set DRYRUN=%DRYRUN%
    set REQUEST_NAME=%REQUEST_NAME%
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof


:brickv_CMD_install_Error
set _ERROR_MSG=%ERROR_MSG%
call :BrickvDone
if not "%ERROR_MSG%" == "" if "%CALL_STACK%" == "" goto :_Error
if not "%ERROR_MSG%" == ""  endlocal & ( set "ERROR_MSG=%ERROR_MSG%" & set "ERROR_SOURCE=%ERROR_SOURCE%" & set "ERROR_BLOCK=%ERROR_BLOCK%" & set "ERROR_LINENO=%ERROR_LINENO%" & set "ERROR_CALLSTACK=%ERROR_CALLSTACK%" & goto :eof )
cmd /C exit /b 1
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function BrickvValidate() delayedexpansion
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_BrickvValidate %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:BrickvValidate
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=BrickvValidate %CALL_STACK%
goto :REALBODY_BrickvValidate
:REALBODY_BrickvValidate

:ArgCheckLoop_BrickvValidate
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_BrickvValidate
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=brickv_CMD_install.cmd" & set "ERROR_BLOCK=BrickvValidate" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_BrickvValidate
:Main_BrickvValidate
@set head=
@set next=
call "%TARGET%\set-env.cmd" --validate --quiet

if errorlevel 1  endlocal & ( set "ERROR_MSG=self validate failed" & set "ERROR_SOURCE=brickv_CMD_install.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )

if not "%CHECK_EXIST%" == "" if not exist "%SCRIPT_FOLDER%\%CHECK_EXIST%" (
     endlocal & ( set "ERROR_MSG=exist validate failed %SCRIPT_FOLDER%\%CHECK_EXIST%" & set "ERROR_SOURCE=brickv_CMD_install.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
)

if "%CHECK_LINEWORD%" == "" if "%CHECK_OK%" == "" (
    if "%CHECK_CMD%" == "" (
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
    )
    cmd /C "%CHECK_CMD%"
    if errorlevel 1  endlocal & ( set "ERROR_MSG=validate command failed" & set "ERROR_SOURCE=brickv_CMD_install.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
)
if "%CHECK_LINEWORD%" == "" (
    for /F "tokens=* USEBACKQ" %%F in (`cmd /C %CHECK_CMD%`) do @set CHECK_STRING=%%F
) else (
    for /F "tokens=* USEBACKQ" %%F in (`cmd /C %CHECK_CMD% ^| findstr %CHECK_LINEWORD%`) do @set CHECK_STRING=%%F
)
if "!CHECK_STRING:%CHECK_OK%=!" == "%CHECK_STRING%"  endlocal & ( set "ERROR_MSG=validate failed not match %CHECK_STRING% != %CHECK_OK%" & set "ERROR_SOURCE=brickv_CMD_install.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof


:ExistsLabel
set LabelExists=1
findstr /i /r /c:"^[ ]*:%~1\>" "%SCRIPT_SOURCE%" >nul 2>nul
if errorlevel 1 set LabelExists=
goto :eof


::: function BrickvPrepare(
:::                            spec=?, app=?, ver=x, patches=., arch=?,
:::                            name=?, targetdir=?,
:::                            system=N, global=N, local=N,
:::                            dry=N, force=N, check_only=N, no_check=N, no_color=N,
:::                            silent=N, quiet=N, v=N, vv=N, vvv=N, allow_empty_location=N,
:::                            REST_ARGS_PRINT=....)
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_BrickvPrepare %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:BrickvPrepare
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=BrickvPrepare %CALL_STACK%
goto :REALBODY_BrickvPrepare
:REALBODY_BrickvPrepare
set spec=
set app=
set ver=x
set patches=.
set arch=
set name=
set targetdir=
set system=0
set global=0
set local=0
set dry=0
set force=0
set check_only=0
set no_check=0
set no_color=0
set silent=0
set quiet=0
set v=0
set vv=0
set vvv=0
set allow_empty_location=0
set REST_ARGS_PRINT=

:ArgCheckLoop_BrickvPrepare
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_BrickvPrepare
if x%2x == xx set next=__NONE__

@if "%head%" == "--spec" @(
    @set spec=%next%
    @if "%next%" == "__NONE__" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_prepare.cmd" & set "ERROR_BLOCK=BrickvPrepare" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @if "%next_prefix%" == "-" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_prepare.cmd" & set "ERROR_BLOCK=BrickvPrepare" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @shift
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--app" @(
    @set app=%next%
    @if "%next%" == "__NONE__" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_prepare.cmd" & set "ERROR_BLOCK=BrickvPrepare" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @if "%next_prefix%" == "-" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_prepare.cmd" & set "ERROR_BLOCK=BrickvPrepare" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @shift
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--ver" @(
    @set ver=%next%
    @if "%next%" == "__NONE__" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_prepare.cmd" & set "ERROR_BLOCK=BrickvPrepare" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @if "%next_prefix%" == "-" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_prepare.cmd" & set "ERROR_BLOCK=BrickvPrepare" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @shift
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--patches" @(
    @set patches=%next%
    @if "%next%" == "__NONE__" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_prepare.cmd" & set "ERROR_BLOCK=BrickvPrepare" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @if "%next_prefix%" == "-" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_prepare.cmd" & set "ERROR_BLOCK=BrickvPrepare" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @shift
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--arch" @(
    @set arch=%next%
    @if "%next%" == "__NONE__" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_prepare.cmd" & set "ERROR_BLOCK=BrickvPrepare" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @if "%next_prefix%" == "-" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_prepare.cmd" & set "ERROR_BLOCK=BrickvPrepare" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @shift
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--name" @(
    @set name=%next%
    @if "%next%" == "__NONE__" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_prepare.cmd" & set "ERROR_BLOCK=BrickvPrepare" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @if "%next_prefix%" == "-" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_prepare.cmd" & set "ERROR_BLOCK=BrickvPrepare" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @shift
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--targetdir" @(
    @set targetdir=%next%
    @if "%next%" == "__NONE__" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_prepare.cmd" & set "ERROR_BLOCK=BrickvPrepare" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @if "%next_prefix%" == "-" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_prepare.cmd" & set "ERROR_BLOCK=BrickvPrepare" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @shift
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--system" @(
    @set system=1
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--global" @(
    @set global=1
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--local" @(
    @set local=1
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--dry" @(
    @set dry=1
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--force" @(
    @set force=1
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--check-only" @(
    @set check_only=1
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--no-check" @(
    @set no_check=1
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--no-color" @(
    @set no_color=1
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--silent" @(
    @set silent=1
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--quiet" @(
    @set quiet=1
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--v" @(
    @set v=1
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--vv" @(
    @set vv=1
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--vvv" @(
    @set vvv=1
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@if "%head%" == "--allow-empty-location" @(
    @set allow_empty_location=1
    @shift
    @goto :ArgCheckLoop_BrickvPrepare
)
@goto :GetRestArgs_BrickvPrepare

:GetRestArgs_BrickvPrepare

@set REST_ARGS_PRINT=%1
@shift
:GetRestArgsLoop_BrickvPrepare
@if "%~1" == "" @goto :Main_BrickvPrepare
@set REST_ARGS_PRINT=%REST_ARGS_PRINT% %1
@shift
@goto :GetRestArgsLoop_BrickvPrepare
:Main_BrickvPrepare
@set head=
@set next=

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

if not "%allow_empty_location%" == "1" set REQUEST_LOCATION=global
if "%system%" == "1" set REQUEST_LOCATION=system
if "%global%" == "1" set REQUEST_LOCATION=global
if "%local%" == "1" set REQUEST_LOCATION=local

set GLOBAL_DIR=%LOCALAPPDATA%\Programs
set LOCAL_DIR=%PRJ_BIN%

set REQUEST_NAME=%name%
set REQUEST_TARGETDIR=%targetdir%


if "%dry%" == "1" set DRYRUN=1
if "%force%" == "1" set FORCE=1
if "%check_only%" == "1" set CHECKONLY=1
if "%no_check%" == "1" set NOCHECK=1

set LOG_LEVEL=3
if "%silent%" == "1" set LOG_LEVEL=5
if "%quiet%" == "1" set LOG_LEVEL=4
if "%v%" == "1" set /A LOG_LEVEL-=1
if "%vv%" == "1" set /A LOG_LEVEL-=2
if "%vvv%" == "1" set /A LOG_LEVEL-=3
if "%no_color%" == "1" set NO_COLOR=1

set TARGET_OS=
set TARGET_OS_TYPE=
set TARGET_OS_NAME=
set TARGET_OS_VER=
set TARGET_OS_ARCH=


:Main
call :PrintMsg debug init "TARGET_OS=%TARGET_OS%"
call :PrintMsg debug init "REST_ARGS=%REST_ARGS_PRINT%"


if not "%REQUEST_SPEC%" == "" (
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
endlocal & (
    set DRYRUN=%DRYRUN%
    set FORCE=%FORCE%
    set CHECKONLY=%CHECKONLY%
    set NOCHECK=%NOCHECK%
    set NO_COLOR=%NO_COLOR%
    set LOG_LEVEL=%LOG_LEVEL%
    set VERSION_SPCES_FILE=%VERSION_SPCES_FILE%
    set LOCAL_DIR=%LOCAL_DIR%
    set GLOBAL_DIR=%GLOBAL_DIR%
    set REQUEST_SPEC=%REQUEST_SPEC%
    set REQUEST_APP=%REQUEST_APP%
    set REQUEST_MAJOR=%REQUEST_MAJOR%
    set REQUEST_MINOR=%REQUEST_MINOR%
    set REQUEST_PATCH=%REQUEST_PATCH%
    set REQUEST_ARCH=%REQUEST_ARCH%
    set REQUEST_PATCHES=%REQUEST_PATCHES%
    set REQUEST_VER=%REQUEST_VER%
    set REQUEST_LOCATION=%REQUEST_LOCATION%
    set REQUEST_NAME=%REQUEST_NAME%
    set REQUEST_TARGETDIR=%REQUEST_TARGETDIR%
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof


::: function MatchVersion(
:::                           default_args=N,
:::                           specs_file=?, spec_match==x,
:::                           all=N, output_format=?, output=?,
:::                           specs_string=.....) delayedexpansion
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_MatchVersion %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:MatchVersion
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=MatchVersion %CALL_STACK%
goto :REALBODY_MatchVersion
:REALBODY_MatchVersion
set default_args=0
set specs_file=
set spec_match==x
set all=0
set output_format=
set output=
set specs_string=

:ArgCheckLoop_MatchVersion
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_MatchVersion
if x%2x == xx set next=__NONE__

@if "%head%" == "--default-args" @(
    @set default_args=1
    @shift
    @goto :ArgCheckLoop_MatchVersion
)
@if "%head%" == "--specs-file" @(
    @set specs_file=%next%
    @if "%next%" == "__NONE__" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=semver.cmd" & set "ERROR_BLOCK=MatchVersion" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @if "%next_prefix%" == "-" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=semver.cmd" & set "ERROR_BLOCK=MatchVersion" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @shift
    @shift
    @goto :ArgCheckLoop_MatchVersion
)
@if "%head%" == "--spec-match" @(
    @set spec_match=%next%
    @if "%next%" == "__NONE__" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=semver.cmd" & set "ERROR_BLOCK=MatchVersion" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @if "%next_prefix%" == "-" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=semver.cmd" & set "ERROR_BLOCK=MatchVersion" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @shift
    @shift
    @goto :ArgCheckLoop_MatchVersion
)
@if "%head%" == "--all" @(
    @set all=1
    @shift
    @goto :ArgCheckLoop_MatchVersion
)
@if "%head%" == "--output-format" @(
    @set output_format=%next%
    @if "%next%" == "__NONE__" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=semver.cmd" & set "ERROR_BLOCK=MatchVersion" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @if "%next_prefix%" == "-" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=semver.cmd" & set "ERROR_BLOCK=MatchVersion" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @shift
    @shift
    @goto :ArgCheckLoop_MatchVersion
)
@if "%head%" == "--output" @(
    @set output=%next%
    @if "%next%" == "__NONE__" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=semver.cmd" & set "ERROR_BLOCK=MatchVersion" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @if "%next_prefix%" == "-" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=semver.cmd" & set "ERROR_BLOCK=MatchVersion" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @shift
    @shift
    @goto :ArgCheckLoop_MatchVersion
)
@goto :GetRestArgs_MatchVersion

:GetRestArgs_MatchVersion

@set specs_string=%~1
@shift
:GetRestArgsLoop_MatchVersion
@if "%~1" == "" @goto :Main_MatchVersion
@set specs_string=%specs_string% %~1
@shift
@goto :GetRestArgsLoop_MatchVersion
:Main_MatchVersion
@set head=
@set next=

set SemverScriptText=$comment = 'app[=ver][@arch][patches] app=...'^

$comment = 'app1=3.1.X@x86 app2=3.1.X@x86'^

^

function ParseVersion {^

    $t = $args[0].split('.')^

    $major = $minor = $patch = 'x'^

    $major = $t[0]^

    if ($t.length -gt 1) { $minor = $t[1] }^

    if ($t.length -gt 2) { $patch = $t[2] }^

    $r = New-Object PSObject^

    $r ^| Add-Member -type NoteProperty -name major -value $major^

    $r ^| Add-Member -type NoteProperty -name minor -value $minor^

    $r ^| Add-Member -type NoteProperty -name patch -value $patch^

    $r^

}^

^

filter ParseSpec {^

    $verSpec = $_^

    $verSpec = $verSpec.replace(([String][char]34), '')^

    # $verSpec = $verSpec.replace(([String][char]34), '').replace('==', '=')^

    # $verSpec = $verSpec.TrimStart(' ')^

    $verSpec, $carry = $verSpec.Split('$', 2)^

    $verSpec = $verSpec.replace(' ', '').replace('==', '=')^

^

    $state = 'ok'^

    $comparator = '='^

    $version = 'x.x.x'^

    $arch = 'any'^

    $patches = '.'^

^

    $t = @($verSpec)^

^

    if ($t[0].Contains('[')) {^

        $t = $t[0].Split('[')^

        if ($t[1].EndsWith(']')) {^

            $patches = $t[1].TrimEnd(']')^

        }^

    }^

    if ($t[0].Contains('[')) { $state = 'error' }^

^

    if ($t[0].Contains('@')) {^

        $t = $t[0].split('@')^

        $arch = $t[1].ToLower()^

    }^

    if ($t[0].Contains('@')) { $state = 'error' }^

^

    if ($t[0].Contains('=')) {^

        $t = $t[0].split('=')^

        $version = $t[1].ToLower()^

    }^

    if ($t[0].Contains('=')) { $state = 'error' }^

    $name = $t[0]^

^

    if ($state -eq 'error') {^

        return $null^

    }^

^

    $pVersion = ParseVersion $version^

    $r = New-Object PSObject^

    $r ^| Add-Member -type NoteProperty -name name -value $name^

    $r ^| Add-Member -type NoteProperty -name version -value $pVersion^

    $r ^| Add-Member -type NoteProperty -name arch -value $arch^

    $r ^| Add-Member -type NoteProperty -name patches -value $patches^

    $r ^| Add-Member -type NoteProperty -name carry -value $carry^

    $r^

}^

^

filter FormatSpec {^

    if ($_.carry) {^

        '{0}={1}.{2}.{3}@{4}[{5}]${6}' -f $_.name, $_.version.major, $_.version.minor, $_.version.patch, $_.arch, $_.patches, $_.carry^

    } else {^

        '{0}={1}.{2}.{3}@{4}[{5}]' -f $_.name, $_.version.major, $_.version.minor, $_.version.patch, $_.arch, $_.patches^

    }^

}^

^

filter FormatSpecForSort {^

    '{0,-15}={1,10}.{2,10}.{3,10}@{4,8}[{5}]${6}' -f $_.name, $_.version.major, $_.version.minor, $_.version.patch, $_.arch, $_.patches, $_.carry^

}^

^

filter FormatSpecForCmd {^

    if ($_.carry) {^

        '{0} {1} {2} {3} {4} {5} {7}{6}{7}' -f $_.name, $_.version.major, $_.version.minor, $_.version.patch, $_.arch, $_.patches, $_.carry, ([String][char]34)^

    } else {^

        '{0} {1} {2} {3} {4} {5}' -f $_.name, $_.version.major, $_.version.minor, $_.version.patch, $_.arch, $_.patches^

    }^

}^

^

function Match {^

    $R = $args[0]^

    $T = $args[1]^

    if ($R.name -ne '' -And $R.name -ne $T.name) { return $false }^

    if ($R.arch -ne 'any' -And $T.arch -ne 'any' -And $R.arch -ne $T.arch) { return $false }^

    if ($R.version.major -ne 'x' -And $T.version.major -ne 'x' -And $R.version.major -ne $T.version.major) { return $false }^

    if ($R.version.minor -ne 'x' -And $T.version.minor -ne 'x' -And $R.version.minor -ne $T.version.minor) { return $false }^

    if ($R.version.patch -ne 'x' -And $T.version.patch -ne 'x' -And $R.version.patch -ne $T.version.patch) { return $false }^

    if ($R.patches -ne '.' -And $R.patches -ne $T.patches) { return $false }^

    return $true^

}^

^

filter MatchFilter {^

    $R = @($args[0]) ^| ParseSpec^

    if (Match $R $_) { return $_ }^

    return $null^

}^

^

function SelectVersion {^

    if ($specsString) { $specsStrings = $specsString.Split(' ')}^

    if ($specsFile) { $specsStrings = Get-Content $specsFile }^

    if (^^!$specsStrings) { return }^

^

    $specs = $specsStrings ^| Where-Object { $_.Trim(' ') }^

    if ($specs -isnot [system.array]) { $specs = @($specs) }^

    $specs = $specs ^| ParseSpec ^| FormatSpecForSort ^| Sort-Object -descending ^| ParseSpec^

    if ($specMatch) { $specs = $specs ^| MatchFilter $specMatch ^| Where-Object { $_ }}^

    if ($specs -eq $null) { return }^

    if ($specs -isnot [system.array]) { $specs = @($specs) }^

^

    if ($bestMatch) { $specs = @($specs[0]) }^

    $specsOutput = $specs ^| ForEach-Object { $formatter.invoke($_) }^

    if ($output) {^

        $specsOutput ^| Set-Content -path $output^

    } else {^

        # because Write-Output to pipe that breaks lines to fit console^

        # instead we use Write-Host to prevent this issue^

        # notice:^

        #   Write-Host output '\n' new line character rather than '\r\n'^

        $specsOutput ^| ForEach-Object { Write-Host $_ }^

    }^

}^

^

function Test {^

    # $specsString = 'app2=3.1.X@x86[a,b] app2=2.1.X@x86[a,b]'^

    # $specsStrings = @(' app1=3.1.X@x86[a, b] ', 'app1=2.1.X@x86[a, b] ', '  ')^

    $specsFile = 'C:\Users\ran\Desktop\brickv\var\tmp\spces-git.ver.txt'^

    $specMatch = 'git=2.10@any[ssh-stab]'^

    $outputFormat = 'cmd'^

    $output = ''^

    $bestMatch = 1^

}^

^

^

$formatter = ${function:FormatSpec}^

if ($outputFormat -eq 'cmd') { $formatter = ${function:FormatSpecForCmd} }^

^

SelectVersion^



if "%default_args%" == "1" (
    set specs_file=%VERSION_SPCES_FILE%
    set spec_match=%REQUEST_SPEC%
    set output_format=env
)

if not exist "%specs_file%" if "%specs_string%" == "" (
     endlocal & ( set "ERROR_MSG=no version specific, use --specs_file or [specs_string...]" & set "ERROR_SOURCE=semver.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
)

set best_match=1
if "%all%" == "1" set best_match=

set output_env=
if "%output_format%" == "env" (
    set output_env=1
    set output_format=cmd
)

@set PSScriptText=
@set PSScriptText=%PSScriptText%$specsString='%specs_string%';
@set PSScriptText=%PSScriptText%$specsFile='%specs_file%';
@set PSScriptText=%PSScriptText%$specMatch='%spec_match%';
@set PSScriptText=%PSScriptText%$bestMatch='%best_match%';
@set PSScriptText=%PSScriptText%$outputFormat='%output_format%';
@set PSScriptText=%PSScriptText%$output='%output%';
@set PSScriptText=%PSScriptText%


if "%output_env%" == "1" goto :ToEnv
PowerShell -Command "%PSScriptText%;!SemverScriptText:"=!"
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof


:ToEnv
rm "%TEMP%\matched_versions.txt" 2>nul
1>"%TEMP%\matched_versions.txt" PowerShell -Command "%PSScriptText%;!SemverScriptText:"=!"
for /F "tokens=1-7 usebackq" %%A IN ("%TEMP%\matched_versions.txt") do (
    set MATCH_APP=%%A
    set MATCH_MAJOR=%%B
    set MATCH_MINOR=%%C
    set MATCH_PATCH=%%D
    set MATCH_ARCH=%%E
    set MATCH_PATCHES=%%F
    set MATCH_CARRY=%%~G
)
set MATCH_VER=%MATCH_MAJOR%
if not "%MATCH_MINOR%" == "x" if not "%MATCH_MINOR%" == "" set MATCH_VER=%MATCH_VER%.%MATCH_MINOR%
if not "%MATCH_PATCH%" == "x" if not "%MATCH_PATCH%" == "" set MATCH_VER=%MATCH_VER%.%MATCH_PATCH%
if "%MATCH_VER%" == ""  endlocal & ( set "ERROR_MSG=request version %spec_match% not found" & set "ERROR_SOURCE=semver.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
call :PrintVersion info match "%MATCH_APP%" "%MATCH_VER%" "%MATCH_ARCH%" "%MATCH_PATCHES%"
endlocal & (
    set MATCH_APP=%MATCH_APP%
    set MATCH_VER=%MATCH_VER%
    set MATCH_MAJOR=%MATCH_MAJOR%
    set MATCH_MINOR=%MATCH_MINOR%
    set MATCH_PATCH=%MATCH_PATCH%
    set MATCH_ARCH=%MATCH_ARCH%
    set MATCH_PATCHES=%MATCH_PATCHES%
    set MATCH_CARRY=%MATCH_CARRY%
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof



::: function Unzip(ZipFile, ExtractTo, delete_before=N) delayedexpansion
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_Unzip %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:Unzip
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=Unzip %CALL_STACK%
goto :REALBODY_Unzip
:REALBODY_Unzip
set ZipFile=%~1
if "%ZipFile%" == "" endlocal & ( set "ERROR_MSG=Need argument ZipFile" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=Unzip" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set ExtractTo=%~1
if "%ExtractTo%" == "" endlocal & ( set "ERROR_MSG=Need argument ExtractTo" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=Unzip" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set delete_before=0

:ArgCheckLoop_Unzip
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_Unzip
if x%2x == xx set next=__NONE__

@if "%head%" == "--delete-before" @(
    @set delete_before=1
    @shift
    @goto :ArgCheckLoop_Unzip
)

 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=Unzip" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_Unzip
:Main_Unzip
@set head=
@set next=

if not "%delete_before%" == "1" goto :_Unzip
if exist "%ExtractTo%" (
    call :PrintMsg debug rmdir "%ExtractTo%"
    rd /Q /S "%ExtractTo%"
)

:_Unzip
if not exist "%ExtractTo%" (
    call :PrintMsg debug mkdir "%ExtractTo%"
    mkdir "%ExtractTo%"
)
call :PrintMsg info unzip %ExtractTo%
echo  set objShell = CreateObject("Shell.Application") > "%TEMP%\Unzip.vbs"
echo  set FilesInZip=objShell.NameSpace("!ZipFile!").items >> "%TEMP%\Unzip.vbs"
echo  objShell.NameSpace("!ExtractTo!").CopyHere(FilesInZip) >> "%TEMP%\Unzip.vbs"

"%TEMP%\Unzip.vbs"
if errorlevel 1  endlocal & ( set "ERROR_MSG=unzip failed. maybe is not a zip file" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof



:::　function UnpackMsi(MSI_FILE, MSI_UNPACK_DIR=)
    if "%MSI_UNPACK_DIR%" == ""  endlocal & ( set "ERROR_MSG=MSI_UNPACK_DIR undefined" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )

    msiexec /a "%MSI_FILE%" /qb TARGETDIR="%TARGETDIR%\unchecked-%NAME%"
    if errorlevel 1 (
        if exist "%TARGETDIR%\unchecked-%NAME%" rd /Q /S "%TARGETDIR%\unchecked-%NAME%"
         endlocal & ( set "ERROR_MSG=msiexec install failed" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    )
    if exist "%TARGETDIR%\%NAME%" rename "%TARGETDIR%\%NAME%" "padding-%NAME%"
    xcopy "%TARGETDIR%\unchecked-%NAME%%MSI_UNPACK_DIR%" "%TARGETDIR%\%NAME%\"> nul
    if errorlevel 1 (
        rd /Q /S "%TARGETDIR%\unchecked-%NAME%"
        if exist "%TARGETDIR%\padding-%NAME%" rename "%TARGETDIR%\padding-%NAME%" "%NAME%"
         endlocal & ( set "ERROR_MSG=xcopy failed" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    )
    if exist "%TARGETDIR%\unchecked-%NAME%" rd /Q /S "%TARGETDIR%\unchecked-%NAME%"
    if exist "%TARGETDIR%\padding-%NAME%" rd /Q /S "%TARGETDIR%\padding-%NAME%"
    call :PrintMsg normal msi success
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: endfunc

:::　function InstallMsi(MSI_FILE)
    msiexec /i "%MSI_FILE%" /qb
    if errorlevel 1  endlocal & ( set "ERROR_MSG=msiexec install failed" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    call :PrintMsg normal msi success
:::


::: function MoveFile(SRC, DST)
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_MoveFile %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:MoveFile
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=MoveFile %CALL_STACK%
goto :REALBODY_MoveFile
:REALBODY_MoveFile
set SRC=%~1
if "%SRC%" == "" endlocal & ( set "ERROR_MSG=Need argument SRC" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=MoveFile" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set DST=%~1
if "%DST%" == "" endlocal & ( set "ERROR_MSG=Need argument DST" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=MoveFile" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift

:ArgCheckLoop_MoveFile
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_MoveFile
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=MoveFile" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_MoveFile
:Main_MoveFile
@set head=
@set next=
if not exist "%SRC%"  endlocal & ( set "ERROR_MSG=source %SRC% not exist" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
if exist "%DST%"  endlocal & ( set "ERROR_MSG=destination %DST% exist" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
move "%SRC%" "%DST%" > nul
if errorlevel 1  endlocal & ( set "ERROR_MSG=An error occurred when move %SRC% to %DST%" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )

call :PrintMsg debug move "%SRC% %DST%"
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function FilenameFromUrl(Url)
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_FilenameFromUrl %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:FilenameFromUrl
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=FilenameFromUrl %CALL_STACK%
goto :REALBODY_FilenameFromUrl
:REALBODY_FilenameFromUrl
set Url=%~1
if "%Url%" == "" endlocal & ( set "ERROR_MSG=Need argument Url" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=FilenameFromUrl" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift

:ArgCheckLoop_FilenameFromUrl
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_FilenameFromUrl
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=FilenameFromUrl" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_FilenameFromUrl
:Main_FilenameFromUrl
@set head=
@set next=
for /f %%i in ("%Url%") do set Filename=%%~nxi
for /f "delims=?" %%a in ("%Filename%") do set Filename=%%a
for /f "delims=#" %%a in ("%Filename%") do set Filename=%%a
endlocal & (
    set Filename=%Filename%
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function BrickvBeforeInstall()
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_BrickvBeforeInstall %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:BrickvBeforeInstall
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=BrickvBeforeInstall %CALL_STACK%
goto :REALBODY_BrickvBeforeInstall
:REALBODY_BrickvBeforeInstall

:ArgCheckLoop_BrickvBeforeInstall
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_BrickvBeforeInstall
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=BrickvBeforeInstall" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_BrickvBeforeInstall
:Main_BrickvBeforeInstall
@set head=
@set next=

    if "%APPVER%" == "" set APPVER=%MATCH_VER%
    set TARGET_NAME=%APPNAME%-%APPVER%

    if not "%REQUEST_NAME%" == "" set TARGET_NAME=%REQUEST_NAME%

    if not "%REQUEST_TARGETDIR%" == "" set TARGETDIR=%REQUEST_TARGETDIR%
    if "%TARGETDIR%" == "" if "%REQUEST_LOCATION%" == "global" set TARGETDIR=%GLOBAL_DIR%
    if "%TARGETDIR%" == "" if "%REQUEST_LOCATION%" == "local" set TARGETDIR=%LOCAL_DIR%

    if not "%TARGET%" == "" for /f %%i in ("%TARGET%\..") do set TARGETDIR=%%~fi
    if not "%TARGET%" == "" for /f %%i in ("%TARGET%") do set TARGET_NAME=%%~ni
    if "%TARGETDIR%" == ""  endlocal & ( set "ERROR_MSG=TARGETDIR not specific" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )


    set TARGET=%TARGETDIR%\%TARGET_NAME%
    set REAL_TARGET=%TARGET%
    set BACK_TARGET=%TARGETDIR%\backupfor-%APPNAME%
    set FAIL_TARGET=%TARGETDIR%\failed-%APPNAME%
    if "%DRYRUN%" == "1" goto :BrickvBeforeInstall_retrun

    if not exist "%TARGETDIR%" mkdir "%TARGETDIR%"
    if exist "%BACK_TARGET%" rd /Q /S "%BACK_TARGET%"
    if not exist "%REAL_TARGET%" goto :BrickvBeforeInstall_retrun
    move "%REAL_TARGET%" "%BACK_TARGET%" > nul
    if errorlevel 1  endlocal & ( set "ERROR_MSG=%REAL_TARGET% can not move" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )

:BrickvBeforeInstall_retrun
endlocal & (
    set TARGET=%TARGET%
    set TARGETDIR=%TARGETDIR%
    set TARGET_NAME=%TARGET_NAME%
    set REAL_TARGET=%REAL_TARGET%
    set BACK_TARGET=%BACK_TARGET%
    set FAIL_TARGET=%FAIL_TARGET%
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof


::: function BrickvDone()
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_BrickvDone %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:BrickvDone
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=BrickvDone %CALL_STACK%
goto :REALBODY_BrickvDone
:REALBODY_BrickvDone

:ArgCheckLoop_BrickvDone
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_BrickvDone
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=BrickvDone" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_BrickvDone
:Main_BrickvDone
@set head=
@set next=

if not "%_ERROR_MSG%" == "" (
    if not "%DRYRUN%" == "1" (
        if exist "%FAIL_TARGET%" rd /Q /S "%FAIL_TARGET%"
        if exist "%REAL_TARGET%" move "%REAL_TARGET%" "%FAIL_TARGET%"
        if exist "%BACK_TARGET%" move "%BACK_TARGET%" "%REAL_TARGET%" > nul
    )
    call :PrintMsg error error "%_ERROR_MSG%"
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
) else (
    if exist "%BACK_TARGET%" rd /Q /S "%BACK_TARGET%"
)

if "%DRYRUN%" == "1" (
    call :PrintMsg normal skip %APPNAME%@%MATCH_VER% at %REAL_TARGET%
) else (
    call :PrintMsg normal installed %APPNAME%@%MATCH_VER% at %REAL_TARGET%
)
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof


::: function BrickvValidate()
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_BrickvValidate %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:BrickvValidate
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=BrickvValidate %CALL_STACK%
goto :REALBODY_BrickvValidate
:REALBODY_BrickvValidate

:ArgCheckLoop_BrickvValidate
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_BrickvValidate
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=BrickvValidate" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_BrickvValidate
:Main_BrickvValidate
@set head=
@set next=
set VAILDATE=1
if "%SETENV_TARGET%" == ""  endlocal & ( set "ERROR_MSG=SETENV_TARGET undefined" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
if not exist "%SETENV_TARGET%"  endlocal & ( set "ERROR_MSG=%SETENV_TARGET% not exist" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
call "%SETENV_TARGET%" --info
if not "%VA_INFO_APPNAME%" == "%APPNAME%"  endlocal & ( set "ERROR_MSG=the demand application is %APPNAME%, but %VA_INFO_APPNAME% installed" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
call "%SETENV_TARGET%" --validate --quiet
if errorlevel 1  endlocal & ( set "ERROR_MSG=%VA_INFO_APPNAME% validate failed" & set "ERROR_SOURCE=brickv_utils.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof





::: function BrickvGenEnv(TARGET, SETUPS=) delayedexpansion
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_BrickvGenEnv %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:BrickvGenEnv
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=BrickvGenEnv %CALL_STACK%
goto :REALBODY_BrickvGenEnv
:REALBODY_BrickvGenEnv
set TARGET=%~1
if "%TARGET%" == "" endlocal & ( set "ERROR_MSG=Need argument TARGET" & set "ERROR_SOURCE=brickv_genenv.cmd" & set "ERROR_BLOCK=BrickvGenEnv" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set test=%~1
if not "%test:~0,1%" == "-" (
    set SETUPS=%~1
    shift
)
set test=

:ArgCheckLoop_BrickvGenEnv
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_BrickvGenEnv
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=brickv_genenv.cmd" & set "ERROR_BLOCK=BrickvGenEnv" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_BrickvGenEnv
:Main_BrickvGenEnv
@set head=
@set next=

call :GenEnvInlines

set SETENV_TARGET=%TARGET%\set-env.cmd


if "%APPNAME%" == ""  endlocal & ( set "ERROR_MSG=APPNAME undefined" & set "ERROR_SOURCE=brickv_genenv.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
if "%APPVER%" == ""  endlocal & ( set "ERROR_MSG=APPVER undefined" & set "ERROR_SOURCE=brickv_genenv.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )

echo.> %SETENV_TARGET%
call :WriteScript SetEnvBeginTemplate
call :WriteScript SetEnvSetTemplate
call :WriteSetup set-env
echo @goto :eof>> "%SETENV_TARGET%"

call :WriteScript SetEnvClearTemplate
call :WriteSetup clear-env
echo @goto :eof>> "%SETENV_TARGET%"

call :WriteScript SetEnvValidateTemplate

if not "!%APPNAME%_Validate!" == "" call WriteText "!%APPNAME%_Validate!" "%TEMP%\code" --append
echo @goto :eof>> "%SETENV_TARGET%"

echo :BeforeMove>> "%SETENV_TARGET%"
if not "!%APPNAME%_BeforeMove!" == "" call WriteText "!%APPNAME%_BeforeMove!" "%TEMP%\code" --append
echo @goto :eof>> "%SETENV_TARGET%"

@echo :AfterMove>> "%SETENV_TARGET%"
if not "!%APPNAME%_AfterMove!" == "" call WriteText "!%APPNAME%_AfterMove!" "%TEMP%\code" --append
echo @goto :eof>> "%SETENV_TARGET%"


call :WriteScript SetEnvEndTemplate
@powershell -Command "(Get-Content '%SETENV_TARGET%') | ForEach-Object { $_ -replace '\$', '%%' } | Set-Content '%SETENV_TARGET%'"


endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function WriteText(VarName, TargetFile, Append=N) delayedexpansion
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_WriteText %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:WriteText
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=WriteText %CALL_STACK%
goto :REALBODY_WriteText
:REALBODY_WriteText
set VarName=%~1
if "%VarName%" == "" endlocal & ( set "ERROR_MSG=Need argument VarName" & set "ERROR_SOURCE=brickv_genenv.cmd" & set "ERROR_BLOCK=WriteText" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set TargetFile=%~1
if "%TargetFile%" == "" endlocal & ( set "ERROR_MSG=Need argument TargetFile" & set "ERROR_SOURCE=brickv_genenv.cmd" & set "ERROR_BLOCK=WriteText" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set Append=0

:ArgCheckLoop_WriteText
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_WriteText
if x%2x == xx set next=__NONE__

@if "%head%" == "--append" @(
    @set Append=1
    @shift
    @goto :ArgCheckLoop_WriteText
)

 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=brickv_genenv.cmd" & set "ERROR_BLOCK=WriteText" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_WriteText
:Main_WriteText
@set head=
@set next=
call (
    (echo:!%VarName%!)>%TMP%\_need_crlf
)
if "%Append%" == "1" (
    more %TMP%\_need_crlf>>%TargetFile%
) else (
    more %TMP%\_need_crlf>%TargetFile%
)
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function WriteScript(VarName)
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_WriteScript %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:WriteScript
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=WriteScript %CALL_STACK%
goto :REALBODY_WriteScript
:REALBODY_WriteScript
set VarName=%~1
if "%VarName%" == "" endlocal & ( set "ERROR_MSG=Need argument VarName" & set "ERROR_SOURCE=brickv_genenv.cmd" & set "ERROR_BLOCK=WriteScript" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift

:ArgCheckLoop_WriteScript
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_WriteScript
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=brickv_genenv.cmd" & set "ERROR_BLOCK=WriteScript" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_WriteScript
:Main_WriteScript
@set head=
@set next=
call :WriteText %VarName% "%TEMP%\%VarName%"
powershell -Command "(Get-Content '%TEMP%\%VarName%') | ForEach-Object { $_ -replace '\${APPNAME}', '%APPNAME%'.ToUpper() -replace '\${AppNameSmall}', '%APPNAME%' -replace '\${AppVersion}', '%APPVER%' -replace '\${CheckExist}', '%CHECK_EXIST%' -replace '\${CheckCmd}', '%CHECK_CMD%' -replace '\${CheckLineword}', '%CHECK_LINEWORD%' -replace '\${CheckOk}', '%CHECK_OK%' -replace '\${CheckScript}', '%CHECK_SCRIPT%'} | Add-Content '%SETENV_TARGET%'"
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof


:WriteSetup
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
@set KEY=%1
@set VALUE=%2
@if "%VALUE%" == "" @(
    @if "%OUTTYPE%" == "set-env" @echo @set PATH=%KEY%;$PATH$>> "%SETENV_TARGET%"
    @if "%OUTTYPE%" == "clear-env" @echo @call @set PATH=$$PATH:%KEY%;=$$>> "%SETENV_TARGET%"
) else @(
    @if "%OUTTYPE%" == "set-env" @echo @set %KEY%=%VALUE%>> "%SETENV_TARGET%"
    @if "%OUTTYPE%" == "clear-env" @echo @set %KEY%=>> "%SETENV_TARGET%"
)
@goto :eof














:GenEnvInlines
set SetEnvBeginTemplate=^

@if not ^"%%SCRIPT_FOLDER%%^" == ^"^" set _OLD_SCRIPT_FOLDER=%%SCRIPT_FOLDER%%^

@if not ^"%%SETENV_PATH%%^" == ^"^" set _OLD_SETENV_PATH=%%SETENV_PATH%%^

@if not ^"%%QUIET%%^" == ^"^" set _OLD_QUIET=%%QUIET%%^

@if not ^"%%VA_INFO_APPNAME%%^" == ^"^" set _OLD_VA_INFO_APPNAME=%%VA_INFO_APPNAME%%^

@if not ^"%%VA_INFO_VERSION%%^" == ^"^" set _OLD_VA_INFO_VERSION=%%VA_INFO_VERSION%%^

^

@set SCRIPT_FOLDER=%%~dp0^

@if ^"%%SCRIPT_FOLDER:~-1%%^"==^"\^" @set SCRIPT_FOLDER=%%SCRIPT_FOLDER:~0,-1%%^

@set SETENV_PATH=%%~0^

^

@if ^"%%~2^" == ^"--quiet^" @set QUIET=1^

@if ^"%%~1^" == ^"--info^" @call :GetInfo^

@if ^"%%~1^" == ^"^" @call :SetEnv^

@if ^"%%~1^" == ^"--set^" @call :SetEnv^

@if ^"%%~1^" == ^"--clear^" @call :ClearEnv^

@if ^"%%~1^" == ^"--check^" @call :Validate^

@if ^"%%~1^" == ^"--validate^" @call :Validate^

@if ^"%%~1^" == ^"--before-move^" @call :BeforeMove^

@if ^"%%~1^" == ^"--after-move^" @call :AfterMove^

^

@if ^"%%~1^" == ^"--info^" @goto :QuitInfo^

@if not ^"%%~1^" == ^"--validate^" @if not ^"%%~1^" == ^"--check^" @goto :Quit^

@goto :eof^

^

^

:GetInfo^

@if ^"%%2^" == ^"appname^" @(^

    @echo ${AppNameSmall}^

    @goto :eof^

)^

@if ^"%%2^" == ^"version^" @(^

    @echo ${AppVersion}^

    @goto :eof^

)^

@set VA_INFO_APPNAME=${AppNameSmall}^

@set VA_INFO_VERSION=${AppVersion}^

@goto :eof
set SetEnvSetTemplate=:SetEnv^

@if not ^"%%VA_${APPNAME}_BASE%%^" == ^"^" @call %%VA_${APPNAME}_BASE%%\set-env.cmd --clear^

@set VA_${APPNAME}_BASE=%%SCRIPT_FOLDER%%


set SetEnvClearTemplate=:ClearEnv^

@if not ^"%%VA_${APPNAME}_BASE%%^" == ^"%%SCRIPT_FOLDER%%^" @goto :eof^

@set VA_${APPNAME}_BASE=
set SetEnvValidateTemplate=^

:ValidateFailed^

@set FAILED=1^

@if not ^"%%QUIET%%^" == ^"1^" @echo ^"failed^"^

@goto :eof^

@rem TODO: use `@goto :Quit` for self test'^

@rem TODO: use `@call :ClearEnv` for self test^

^

:ValidateSuccess^

@if not ^"%%QUIET%%^" == ^"1^" @echo ^"ok^"^

@goto :eof^

@rem TODO: use `@goto :Quit` for self test^

@rem TODO: use `@call :ClearEnv` for self test^

^

:Validate^

@call :GetInfo^

@call :SetEnv^

@set CHECK_EXIST=${CheckExist}^

@set CHECK_CMD=${CheckCmd}^

@set CHECK_LINEWORD=${CheckLineword}^

@set CHECK_OK=${CheckOk}^

${CheckScript}^

@goto ValidateSuccess

set SetEnvPatchMovedTemplate=:PatchMoved

set SetEnvEndTemplate=:Quit^

@set CHECK_EXIST=^

@set CHECK_CMD=^

@set CHECK_LINEWORD=^

@set CHECK_OK=^

@set VA_INFO_APPNAME=%%_OLD_VA_INFO_APPNAME%%^

@set VA_INFO_VERSION=%%_OLD_VA_INFO_VERSION%%^

@set _OLD_VA_INFO_APPNAME=^

@set _OLD_VA_INFO_VERSION=^

^

:QuitInfo^

@set SCRIPT_FOLDER=%%_OLD_SCRIPT_FOLDER%%^

@set SETENV_PATH=%%_OLD_SETENV_PATH%%^

@set QUIET=%%_OLD_QUIET%%^

@set _OLD_SCRIPT_FOLDER=^

@set _OLD_SETENV_PATH=^

@set _OLD_QUIET=^

@if ^"%%FAILED%%^" == ^"1^" (@set FAILED=) ^& (@cmd /C exit /b 1) ^& (@goto :eof)^

@cmd /C exit /b 0

goto :eof

::: function BrickvDownload(Url, Output, Cookie=?, skip_exists=N) delayedexpansion
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_BrickvDownload %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:BrickvDownload
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=BrickvDownload %CALL_STACK%
goto :REALBODY_BrickvDownload
:REALBODY_BrickvDownload
set Url=%~1
if "%Url%" == "" endlocal & ( set "ERROR_MSG=Need argument Url" & set "ERROR_SOURCE=brickv_download.cmd" & set "ERROR_BLOCK=BrickvDownload" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set Output=%~1
if "%Output%" == "" endlocal & ( set "ERROR_MSG=Need argument Output" & set "ERROR_SOURCE=brickv_download.cmd" & set "ERROR_BLOCK=BrickvDownload" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set Cookie=
set skip_exists=0

:ArgCheckLoop_BrickvDownload
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_BrickvDownload
if x%2x == xx set next=__NONE__

@if "%head%" == "--cookie" @(
    @set Cookie=%next%
    @if "%next%" == "__NONE__" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_download.cmd" & set "ERROR_BLOCK=BrickvDownload" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @if "%next_prefix%" == "-" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_download.cmd" & set "ERROR_BLOCK=BrickvDownload" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @shift
    @shift
    @goto :ArgCheckLoop_BrickvDownload
)
@if "%head%" == "--skip-exists" @(
    @set skip_exists=1
    @shift
    @goto :ArgCheckLoop_BrickvDownload
)

 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=brickv_download.cmd" & set "ERROR_BLOCK=BrickvDownload" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_BrickvDownload
:Main_BrickvDownload
@set head=
@set next=
if not "%FORCE%" == "1"  if "%skip_exists%" == "1" set SkipExists=1

set err=
set ErrorFile=%TEMP%\download_error
del %ErrorFile% 2>nul

if "%Url%" == ""  endlocal & ( set "ERROR_MSG=Url not specific" & set "ERROR_SOURCE=brickv_download.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
if "%Output%" == ""  endlocal & ( set "ERROR_MSG=Output not specific" & set "ERROR_SOURCE=brickv_download.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )

if "%SkipExists%" == "1" if exist "%Output%" (
    call :PrintMsg normal cached %Output%
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
)
call :PrintMsg normal fetch %Url%

set ScriptText=$request = [System.Net.WebRequest]::Create($url)^

$request.UserAgent = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:46.0) Gecko/20100101 Firefox/46.0'^

^

$request.headers.Set('Cookie', $Cookie)^

try {^

    $response = $request.GetResponse()^

    $remoteHost = $request.headers.Get('Host')^

} catch {^

    $remoteHost = $request.headers.Get('Host')^

    $response = $null^

}^

if (^^!$response) {^

    Set-Content $errorFile ('[download] Unable connect to {0}' -f $remoteHost)^

    Exit 1^

}^

$responseStream = $response.GetResponseStream()^

if ($response.StatusDescription -eq 'OK') {^

    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $output, Create^

} else {^

    Set-Content $errorFile ('[download] Remote server reject, code: {0}' -f $response.StatusDescription)^

    Exit 1^

}^

if (^^!$targetStream) {^

    Set-Content $errorFile ('[download] Unable Create File: {0}' -f $output)^

    Exit 1^

}^

$totalLength = [System.Math]::Floor($response.ContentLength/1024)^

if ($totalLength -eq -1) { $totalLength = '?'; }^

^

^

$buffer = new-object byte[] 8KB^

$count = $responseStream.Read($buffer, 0, $buffer.length)^

$downloadedBytes = $count^

while ($count -gt 0) {^

    Write-Progress -activity $url `^

                   -status ('Downloaded Size {0}K / {1}K' `^

                            -f [System.Math]::Floor($downloadedBytes/1024), $totalLength)^

    #     [System.Console]::CursorLeft = 0^

    #     [System.Console]::Write('Downloaded {0}K / {1}K', [System.Math]::Floor($downloadedBytes/1024), $totalLength)^

    $targetStream.Write($buffer, 0, $count)^

    $count = $responseStream.Read($buffer, 0, $buffer.length)^

    $downloadedBytes = $downloadedBytes + $count^

}^

#     [System.Console]::CursorLeft = 0^

#     [System.Console]::Write('                                          ')^

#     [System.Console]::CursorLeft = 0^

$targetStream.Flush()^

$targetStream.Close()^

$targetStream.Dispose()^

$responseStream.Dispose()^


set PS_Args=$url='%Url%';$output='%Output%';$Cookie='%Cookie%';$SkipExists='%SkipExists%';$errorFile='%ErrorFile%'
PowerShell -Command "%PS_Args%;!ScriptText:"=!"
if errorlevel 1 set err=1
if exist "%ErrorFile%" set /P dl_error= < "%ErrorFile%"
if "%err%" == "1"  endlocal & ( set "ERROR_MSG=download %Url% is failed: %dl_error%" & set "ERROR_SOURCE=brickv_download.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )

call :PrintMsg info write %Output%

endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof




:gradle_init
	set _RELEASE_URL=https://services.gradle.org/distributions
	set ACCEPT=local global
    goto :eof

:gradle_versions
	call :BrickvDownload "%_RELEASE_URL%" "%VERSION_SOURCE_FILE%"
	if not "%ERROR_MSG%" == "" if "%CALL_STACK%" == "" goto :_Error
	if not "%ERROR_MSG%" == ""  endlocal & ( set "ERROR_MSG=%ERROR_MSG%" & set "ERROR_SOURCE=%ERROR_SOURCE%" & set "ERROR_BLOCK=%ERROR_BLOCK%" & set "ERROR_LINENO=%ERROR_LINENO%" & set "ERROR_CALLSTACK=%ERROR_CALLSTACK%" & goto :eof )
	for /F "tokens=* USEBACKQ" %%F IN (
            `FINDSTR  /R /C:"distributions/gradle" "%VERSION_SOURCE_FILE%"`) do (
	    for /F "delims=- tokens=2,3 USEBACKQ" %%G IN ('%%F') do (
	        set var1=%%H
	        if "!var1:~0,-2!" == "bin.zip" echo.gradle=%%G@any[bin] >> "%VERSION_SPCES_FILE%"
	    )
	)
    goto :eof

:gradle_prepare
	set APPVER=%MATCH_VER%
	if "%REQUEST_NAME%" == "" set REQUEST_NAME=gradle-%APPVER%
	set DOWNLOAD_URL=%_RELEASE_URL%/gradle-%APPVER%-bin.zip
	goto :eof

:gradle_unpack
	set SETENV=%SETENV%;GRADLE_HOME:$SCRIPT_FOLDER$
	set SETENV=%SETENV%;$GRADLE_HOME$\bin
	set UNPACK_METHOD=unzip
	goto :eof

:gradle_validate
	set CHECK_EXIST=
	set CHECK_CMD=gradle -v
	set CHECK_LINEWORD=Gradle
	set CHECK_OK=Gradle %%VA_INFO_VERSION%%
	goto:eof

:git_init
    set _RELEASE_URL=https://api.github.com/repos/git-for-windows/git/releases
    set ACCEPT=local global
    goto :eof

:git_versions
    set "regex=browser_download_url.*PortableGit-[0-9]*\.[0-9]*\.[0-9]*-%GIT_ARCH%"
    FOR /L %%G IN (1,1,2) DO (
        call :BrickvDownload "%_RELEASE_URL%?page=%%G" "%VERSION_SOURCE_FILE%"
        if not "%ERROR_MSG%" == "" if "%CALL_STACK%" == "" goto :_Error
        if not "%ERROR_MSG%" == ""  endlocal & ( set "ERROR_MSG=%ERROR_MSG%" & set "ERROR_SOURCE=%ERROR_SOURCE%" & set "ERROR_BLOCK=%ERROR_BLOCK%" & set "ERROR_LINENO=%ERROR_LINENO%" & set "ERROR_CALLSTACK=%ERROR_CALLSTACK%" & goto :eof )
        FOR /F "tokens=* USEBACKQ" %%F IN (
                `FINDSTR  /R /C:"%regex%" %VERSION_SOURCE_FILE%`) DO (
            for /F "delims=: tokens=3" %%P in ("%%F") do (
                set SFX_URL=https:%%P
            )

            for /F "delims=/ tokens=8" %%P in ("!SFX_URL!") do (
                set SFX_NAME=%%P
            )
            for /F "delims=- tokens=2,3" %%A in ("!SFX_NAME!") do (
                set GIT_VER=%%A
                set GIT_ARCH=%%B
            )
            if "!GIT_ARCH!" == "32" set GIT_ARCH=x86
            if "!GIT_ARCH!" == "64" set GIT_ARCH=x64
            echo.git=!GIT_VER!@!GIT_ARCH![.]$!SFX_URL:~0,-1!>> "%VERSION_SPCES_FILE%"
            echo.git=!GIT_VER!@!GIT_ARCH![ssh-stab]$!SFX_URL:~0,-1!>> "%VERSION_SPCES_FILE%"

        )
    )
    goto :eof

:git_prepare
    set APPVER=%MATCH_VER%
    if "%REQUEST_NAME%" == "" set REQUEST_NAME=git-%APPVER%-%MATCH_ARCH%
    set DOWNLOAD_URL=%MATCH_CARRY%
    goto :eof

:git_unpack
    set SETENV=%SETENV%;$SCRIPT_FOLDER$\cmd
    "%INSTALLER%" -y -InstallPath="%TARGET%"
    if errorlevel 1  endlocal & ( set "ERROR_MSG=7z SFX self unpack failed" & set "ERROR_SOURCE=install-2.cmd" & set "ERROR_BLOCK=" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    echo MATCH_PATCHES:%MATCH_PATCHES%
    for /F "delims=, tokens=*" %%P in ("%MATCH_PATCHES%") do (
        echo PATCHES: %%P
        if "%%P" == "ssh-stab" call :git_install_ssh_stab
    )
    goto :eof

:git_validate
    set CHECK_EXIST=
    set CHECK_CMD=git --version
    set CHECK_LINEWORD=git
    set CHECK_OK=git version %%VA_INFO_VERSION%%
    goto:eof


:git_install_ssh_stab
    move "%TARGET%\usr\bin\ssh.exe" "%TARGET%\usr\bin\realssh.exe"
    move "%TARGET%\usr\bin\scp.exe" "%TARGET%\usr\bin\realscp.exe"

set SSHScript=#^^!/usr/bin/env bash^

^

verbose=2^

^

# find the real ssh/scp executable^

program=$(basename ^"$0^")^

if [ ^"${program}^" == ssh ]; then^

    program=ssh^

    short_options=^"1246AaCfgKkMNnqsTtVvXxYy^"^

elif [ ^"${program}^" == scp ]; then^

    program=scp^

    short_options=^"12346BCpqrv^"^

else^

    echo unknown program ${program}^

    exit 1^

fi^

^

# parse arguments^

prefix_args=()^

suffix_args=()^

userhost=^

while test ${#} -gt 0^

do^

    arg=$1^

    if [[ ${arg} == -* ]]; then^

        arg=${arg#-}^

        if [[ ${short_options} == *${arg}* ]]; then^

            if [ ^"${arg}^" == ^"v^" ]; then^

                verbose=3^

            fi^

            prefix_args+=(^"-${arg}^")^

            shift^

        else^

            prefix_args+=(^"-${arg}^")^

            prefix_args+=(^"$2^")^

            shift^

            shift^

        fi^

    else^

        userhost=$1^

        first_arg=$1^

        shift^

        while test ${#} -gt 0^

        do^

            suffix_args+=(^"$1^")^

            shift^

        done^

    fi^

done^

^

^

^

# try to find the username^

if [[ ^^! ${userhost} == *^"@^"* ]]; then^

    if [ ^"${program}^" == scp ]; then^

        userhost=${suffix_args[@]: -1}^

    fi^

fi^

^

if [[ ${userhost} == *^"@^"* ]]; then^

^

    IFS='@' read -r -a array ^<^<^< ^"${userhost}^"^

    user=${array[0]}^

    host=${array[1]}^

    if [ ^"${program}^" == scp ]; then^

        IFS=':' read -r -a array ^<^<^< ^"${host}^"^

        host=${array[0]}^

    fi^

    if [ ^"${user}^" == ^"git^" ]; then^

        # github arguments: git@github.com git-receive-pack 'ranlempow/git-hooks.git'^

        IFS='/' read -r -a array ^<^<^< ^"${suffix_args[@]: -1}^"^

        user=${array[0]}^

        len=${#suffix_args[@]}^

        # add quote ^"'^"^

        suffix_args[${len} - 1]=^"'${suffix_args[${len} - 1]}'^"^

    fi^

^

    # find the key file on the disk^

    keypath=~/.ssh/namedkeys/${user}_rsa^

    keypath=^"$(cd ^"$(dirname ^"${keypath}^")^"; pwd)/$(basename ^"${keypath}^")^"^

^

^

    # echo ${prefix_args[@]}^

    # echo ${user}^

    # echo ${host}^

    # echo ${suffix_args[@]}^

    # echo ${ssh_exec}^

    # echo ${keypath}^

    # echo ${keypath}^

fi^

^

for _ssh_exec in $(type -ap ^"real${program}^"); do^

    if [ ${_ssh_exec} -ef $0 ]; then continue; fi^

    ssh_exec=${_ssh_exec}^

done^

if [ -z ${ssh_exec} ]; then^

    echo ssh executable ${ssh_exec} not found^

    exit 1^

fi^

^

if [ ${verbose} -gt 3 ]; then^

    echo user: ${user} 1^>^&2^

    echo host: ${host} 1^>^&2^

    echo ssh_exec: ${ssh_exec} 1^>^&2^

    echo keypath: ${keypath} 1^>^&2^

fi^

^

if [ -f ^"${keypath}^" ]; then^

    ${ssh_exec} -i ^"${keypath}^" ${prefix_args[@]} ${first_arg} ${suffix_args[@]}^

else^

    ${ssh_exec} ${prefix_args[@]} ${first_arg} ${suffix_args[@]}^

fi^

^


    echo.!SSHScript! > "%TARGET%\usr\bin\ssh"
    echo.!SSHScript! > "%TARGET%\usr\bin\scp"

    goto :eof


::: function brickv_CMD_list(spec=, args=....) delayedexpansion
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_brickv_CMD_list %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:brickv_CMD_list
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=brickv_CMD_list %CALL_STACK%
goto :REALBODY_brickv_CMD_list
:REALBODY_brickv_CMD_list
set test=%~1
if not "%test:~0,1%" == "-" (
    set spec=%~1
    shift
)
set test=
set args=

:ArgCheckLoop_brickv_CMD_list
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_brickv_CMD_list
if x%2x == xx set next=__NONE__

@goto :GetRestArgs_brickv_CMD_list

:GetRestArgs_brickv_CMD_list

@set args=%1
@shift
:GetRestArgsLoop_brickv_CMD_list
@if "%~1" == "" @goto :Main_brickv_CMD_list
@set args=%args% %1
@shift
@goto :GetRestArgsLoop_brickv_CMD_list
:Main_brickv_CMD_list
@set head=
@set next=
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

endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
::: function brickv_CMD_versions(spec, args=....) delayedexpansion
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_brickv_CMD_versions %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:brickv_CMD_versions
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=brickv_CMD_versions %CALL_STACK%
goto :REALBODY_brickv_CMD_versions
:REALBODY_brickv_CMD_versions
set spec=%~1
if "%spec%" == "" endlocal & ( set "ERROR_MSG=Need argument spec" & set "ERROR_SOURCE=brickv_CMD_list.cmd" & set "ERROR_BLOCK=brickv_CMD_versions" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set args=

:ArgCheckLoop_brickv_CMD_versions
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_brickv_CMD_versions
if x%2x == xx set next=__NONE__

@goto :GetRestArgs_brickv_CMD_versions

:GetRestArgs_brickv_CMD_versions

@set args=%1
@shift
:GetRestArgsLoop_brickv_CMD_versions
@if "%~1" == "" @goto :Main_brickv_CMD_versions
@set args=%args% %1
@shift
@goto :GetRestArgsLoop_brickv_CMD_versions
:Main_brickv_CMD_versions
@set head=
@set next=
call :BrickvPrepare --spec %spec% %args%
call :brickv_CMD_install --only-versions --spec %spec% %args%
FOR /F "delims=$ tokens=1 USEBACKQ" %%F IN ("%VERSION_SPCES_FILE%") do (
    echo %%F
)
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
::: function brickv_CMD_Update(specs, no_switch=N, no_install=N, args=....) delayedexpansion
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_brickv_CMD_Update %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:brickv_CMD_Update
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=brickv_CMD_Update %CALL_STACK%
goto :REALBODY_brickv_CMD_Update
:REALBODY_brickv_CMD_Update
set specs=%~1
if "%specs%" == "" endlocal & ( set "ERROR_MSG=Need argument specs" & set "ERROR_SOURCE=brickv_CMD_list.cmd" & set "ERROR_BLOCK=brickv_CMD_Update" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set no_switch=0
set no_install=0
set args=

:ArgCheckLoop_brickv_CMD_Update
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_brickv_CMD_Update
if x%2x == xx set next=__NONE__

@if "%head%" == "--no-switch" @(
    @set no_switch=1
    @shift
    @goto :ArgCheckLoop_brickv_CMD_Update
)
@if "%head%" == "--no-install" @(
    @set no_install=1
    @shift
    @goto :ArgCheckLoop_brickv_CMD_Update
)
@goto :GetRestArgs_brickv_CMD_Update

:GetRestArgs_brickv_CMD_Update

@set args=%1
@shift
:GetRestArgsLoop_brickv_CMD_Update
@if "%~1" == "" @goto :Main_brickv_CMD_Update
@set args=%args% %1
@shift
@goto :GetRestArgsLoop_brickv_CMD_Update
:Main_brickv_CMD_Update
@set head=
@set next=

set Installs=
set Switches=
set Faileds=
set PassToInstall=%args%

set NotFounds=
set targets=%specs: =#%

:brickv_CMD_Update_switch_loop
for /F "delims=# tokens=1*" %%A IN ("%targets%") do (
    call :brickv_CMD_Update_switch "%%~A"
    set targets=%%B
)
if not "%targets%" == "" goto :brickv_CMD_Update_switch_loop
if "%no_install%" == "1" (
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
)


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
endlocal & (
    set "%FailedsString%"=%"%FailedsString%"%
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof


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
call :brickv_CMD_install --spec "%~1" %PassToInstall%
if not "%ERROR_MSG%" == "" (
    call :PrintMsg error error %ERROR_MSG%
    if "%Faileds%" == "" (set Faileds=%~1) else (set Faileds=%Faileds%#%~1)
) else (
    if "%Installs%" == "" (set Installs=%REQUEST_NAME%) else (set Installs=%Installs%#%REQUEST_NAME%)
)

goto :eof
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
::: function brickv_CMD_switch(spec, internal=N, args=....) delayedexpansion
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_brickv_CMD_switch %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:brickv_CMD_switch
@setlocal  enabledelayedexpansion
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=brickv_CMD_switch %CALL_STACK%
goto :REALBODY_brickv_CMD_switch
:REALBODY_brickv_CMD_switch
set spec=%~1
if "%spec%" == "" endlocal & ( set "ERROR_MSG=Need argument spec" & set "ERROR_SOURCE=brickv_CMD_list.cmd" & set "ERROR_BLOCK=brickv_CMD_switch" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set internal=0
set args=

:ArgCheckLoop_brickv_CMD_switch
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_brickv_CMD_switch
if x%2x == xx set next=__NONE__

@if "%head%" == "--internal" @(
    @set internal=1
    @shift
    @goto :ArgCheckLoop_brickv_CMD_switch
)
@goto :GetRestArgs_brickv_CMD_switch

:GetRestArgs_brickv_CMD_switch

@set args=%1
@shift
:GetRestArgsLoop_brickv_CMD_switch
@if "%~1" == "" @goto :Main_brickv_CMD_switch
@set args=%args% %1
@shift
@goto :GetRestArgsLoop_brickv_CMD_switch
:Main_brickv_CMD_switch
@set head=
@set next=
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
endlocal & (
    set SwitchSuccess=%SwitchSuccess%
    set AppPath=%AppPath%
    set SWITCH_NAME=%SWITCH_NAME%
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
)
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function DiscoverApp()
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_DiscoverApp %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:DiscoverApp
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=DiscoverApp %CALL_STACK%
goto :REALBODY_DiscoverApp
:REALBODY_DiscoverApp

:ArgCheckLoop_DiscoverApp
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_DiscoverApp
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=brickv_CMD_list.cmd" & set "ERROR_BLOCK=DiscoverApp" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_DiscoverApp
:Main_DiscoverApp
@set head=
@set next=
copy /y NUL "%VERSION_SPCES_FILE%" >NUL
copy /y NUL "%MATCH_SPCES_FILE%" >NUL

for /D %%i in (%GLOBAL_DIR%\*) do if exist "%%i\set-env.cmd" (
    call :RecordApp "%%i" global --spec-file "%VERSION_SPCES_FILE%"
)
for /D %%i in (%LOCAL_DIR%\*) do if exist "%%i\set-env.cmd" (
    call :RecordApp "%%i" local --spec-file "%VERSION_SPCES_FILE%"
)
call :MatchVersion --output-format cmd --all --spec-match "%REQUEST_SPEC%"                   --specs-file "%VERSION_SPCES_FILE%" --output "%MATCH_SPCES_FILE%"
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof


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
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_RecordApp %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:RecordApp
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=RecordApp %CALL_STACK%
goto :REALBODY_RecordApp
:REALBODY_RecordApp
set TARGET=%~1
if "%TARGET%" == "" endlocal & ( set "ERROR_MSG=Need argument TARGET" & set "ERROR_SOURCE=brickv_CMD_list.cmd" & set "ERROR_BLOCK=RecordApp" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set Location=%~1
if "%Location%" == "" endlocal & ( set "ERROR_MSG=Need argument Location" & set "ERROR_SOURCE=brickv_CMD_list.cmd" & set "ERROR_BLOCK=RecordApp" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
shift
set Spec_File=

:ArgCheckLoop_RecordApp
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_RecordApp
if x%2x == xx set next=__NONE__

@if "%head%" == "--spec-file" @(
    @set Spec_File=%next%
    @if "%next%" == "__NONE__" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_CMD_list.cmd" & set "ERROR_BLOCK=RecordApp" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @if "%next_prefix%" == "-" endlocal & ( set "ERROR_MSG=Need value after %head%" & set "ERROR_SOURCE=brickv_CMD_list.cmd" & set "ERROR_BLOCK=RecordApp" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
    @shift
    @shift
    @goto :ArgCheckLoop_RecordApp
)

 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=brickv_CMD_list.cmd" & set "ERROR_BLOCK=RecordApp" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_RecordApp
:Main_RecordApp
@set head=
@set next=
for /f %%i in ("%TARGET%") do set Filename=%%~nxi
if "%Filename:~0,10%" == "backupfor-" (
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
)
if "%Filename:~0,7%" == "failed-" (
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof
)
call "%TARGET%\set-env.cmd" --info
call set _VA_BASE=%%VA_%VA_INFO_APPNAME%_BASE%%
set Activate=0
if "%_VA_BASE%" == "%TARGET%" set Activate=1
if not "%Spec_File%" == "" echo.%VA_INFO_APPNAME%=%VA_INFO_VERSION%                                    $%Activate%,%Location%,%TARGET%,%VA_INFO_VERSION%>> "%Spec_File%"
endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof



::: function CMD_exec()
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_CMD_exec %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:CMD_exec
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=CMD_exec %CALL_STACK%
goto :REALBODY_CMD_exec
:REALBODY_CMD_exec

:ArgCheckLoop_CMD_exec
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_CMD_exec
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=dev-sh.cmd" & set "ERROR_BLOCK=CMD_exec" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_CMD_exec
:Main_CMD_exec
@set head=
@set next=

endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof

::: function CMD_help()
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
call :REALBODY_CMD_help %*
if not "%ERROR_MSG%" == "" goto :_Error
goto :eof
:CMD_help
@setlocal  
@echo off
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
set CALL_STACK=CMD_help %CALL_STACK%
goto :REALBODY_CMD_help
:REALBODY_CMD_help

:ArgCheckLoop_CMD_help
set head=%~1
set next=%~2
set next_prefix=%next:~0,1%
if x%1x == xx goto :GetRestArgs_CMD_help
if x%2x == xx set next=__NONE__


 endlocal & ( set "ERROR_MSG=Unkwond option "%head%"" & set "ERROR_SOURCE=dev-sh.cmd" & set "ERROR_BLOCK=CMD_help" & set "ERROR_LINENO=" & set "ERROR_CALLSTACK=%CALL_STACK%" & goto :eof )
:GetRestArgs_CMD_help
:Main_CMD_help
@set head=
@set next=

echo.  dev clear      for backup or clean re-install
echo.  dev update     update development environment
echo.  dev setup      configure git for first using
echo.  dev sync       keep project sync through git

endlocal & (
    set ERROR_MSG=%ERROR_MSG%
    set ERROR_SOURCE=%ERROR_SOURCE%
    set ERROR_BLOCK=%ERROR_BLOCK%
    set ERROR_LINENO=%ERROR_LINENO%
    set ERROR_CALLSTACK=%ERROR_CALLSTACK%
)
goto :eof











:_ProtectError
@goto :eof

:_Error
@echo ERROR: %ERROR_MSG%^

    at %ERROR_SOURCE%:%ERROR_BLOCK%:%ERROR_LINENO%^

    stacktrace: %ERROR_CALLSTACK% 1>&2
@set ERROR_MSG=
@set ERROR_SOURCE=
@set ERROR_BLOCK=
@set ERROR_LINENO=
@set ERROR_CALLSTACK=
@exit /b 1


