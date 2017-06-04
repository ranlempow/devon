
@set SCRIPT_SOURCE=%~f0
@set SCRIPT_FOLDER=%~dp0
@if "%SCRIPT_FOLDER:~-1%" == "\" @set SCRIPT_FOLDER=%SCRIPT_FOLDER:~0,-1%




@if "%~1" == "_start_" goto :NOPROTECT
@set POST_SCIRPT=%TEMP%\devon_post_script-%RANDOM%%TIME:~-2%.cmd
@set POST_ERRORLEVEL=0
@copy /y NUL "%POST_SCIRPT%" >NUL
@cmd /d /c "%~f0" _start_ %*
@call "%POST_SCIRPT%"
@del "%POST_SCIRPT%"
@if "%POST_ERRORLEVEL%" == "" set POST_ERRORLEVEL=0
@set POST_SCIRPT=
@set SCRIPT_FOLDER=
@set SCRIPT_SOURCE=
@exit /b %POST_ERRORLEVEL% & (set POST_ERRORLEVEL= )
@goto :eof


:NOPROTECT
@call :Main %*
@if not "%EMSG%" == "" if "%CTRA%" == "" goto :_Error
@if not "%EMSG%" == ""  endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
@goto :eof

:EnterPostScript
set _OLD_POST_SCIRPT=%POST_SCIRPT%
set POST_SCIRPT=%TEMP%\devon_post_script-%RANDOM%%TIME:~-2%.cmd
set POST_ERRORLEVEL=0
copy /y NUL "%POST_SCIRPT%" >NUL
goto :eof

:ExecutePostScript
call "%POST_SCIRPT%"
del "%POST_SCIRPT%"
set POST_SCIRPT=%_OLD_POST_SCIRPT%
set _OLD_POST_SCIRPT=
goto :eof

::: function Main(_start_, cmd=,
:::                   args=....) delayedexpansion
:Main
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=dev-sh.cmd Main" & set "CTRA=Main %CTRA%"
set cmd=
@( set _pos=0 & set _fmin=1)
set args=

:parg_Main
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_Main
@if %_pos% == 0 @(set "_start_=!_head!" & shift & set /a "_pos+=1" & goto :parg_Main)
@if %_pos% == 1 @(set "cmd=!_head!" & shift & set /a "_pos+=1" & goto :parg_Main)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_Main
:pargdone_Main
@if %_pos% LSS %_fmin% goto :parg_posunder_err
set "args=!_rest!"
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_Main
if "%cmd%" == "" (
    set _devcmd=shell
) else (
    set _devcmd=%cmd%
)
set _devargs=%args%
set _start_=
set cmd=
set args=
set DEVON_VERSION=1.0.1

if not "%_devcmd%" == "brickv" call :ActiveDevShell
call :CMD_%_devcmd% %_devargs%
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))




:SubString
    @if "%Text%" == "" goto :ENDSubString
    @for /F "delims=;" %%A in ("!Text!") do @set substring=%%A
    @call goto %LoopCb%
    @if not "%LoopBreak%" == "" goto :ENDSubString

:NextSubString
    @for /L %%I in (1, 1, 500) do @(
        @set headchar=!Text:~0,1!
        @set Text=!Text:~1!
        @if "!Text!" == "" goto :SubString
        @if "!headchar!" == "%Spliter%" goto :SubString
    )
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



:LoadIniRecursive

call :GetNormalizePath %1
call set "_INI_LOADED_DROP=%%INI_LOADED:%NORMALIZEPATH%=%%"
if not exist "%NORMALIZEPATH%" goto :LoadIniRecursive_Return
if not "%_INI_LOADED_DROP%" == "%INI_LOADED%" goto :LoadIniRecursive_Return

set "INI_LOADED=%INI_LOADED%;%NORMALIZEPATH%"
call :LoadIni %NORMALIZEPATH%

call :GetIniItems "import"
set str=%inival%
:LoadIniRecursive_IterStringLoop
For /F "tokens=1* delims=;" %%A IN ("%str%") DO @set "item=%%A" & set "str=%%B"
call :LoadIniRecursive "%item%"
if not "%str%" == "" goto LoadIniRecursive_IterStringLoop

:LoadIniRecursive_Return
set inival=
set str=
set item=
set NORMALIZEPATH=
set _INI_LOADED_DROP=
goto :eof




:LoadIni
set INI_AREALIST=
for /f "usebackq delims=" %%a in ("!NORMALIZEPATH!") do (
    for /f "tokens=* delims= " %%b in ("%%a") do set ln=%%b
    if not x!ln! == x if not "!ln:~0,1!" == ";" (
        if "!ln:~0,1!" == "[" if "!ln:~-1!" == "]" (
            set currarea=!ln:~1,-1!
            set platform=all
            if "!currarea:~-6!" == "-posix" set "platform=posix" & set currarea=!currarea:~0,-6!
            if "!currarea:~-6!" == "-linux" set "platform=linux" & set currarea=!currarea:~0,-6!
            if "!currarea:~-8!" == "-windows" set "platform=windows" & set currarea=!currarea:~0,-8!
            if "!currarea:~-6!" == "-macos" set "platform=macos" & set currarea=!currarea:~0,-6!
            if "!currarea:~-7!" == "-cygwin" set "platform=cygwin" & set currarea=!currarea:~0,-7!
            set INI_AREALIST=!INI_AREALIST!;!currarea!
        ) else (
            set curritem=!ln!
            call :AddIniItem

        )
    )
)

set file=
set ln=
set currarea=
set curritem=
set platform=

goto :eof




:AddIniItem
if x%currarea%x == xx goto :eof

call set "store=%%INIAREA_%currarea%_%platform%%%"
if x%store%x == xx (
    call set "INIAREA_%currarea%_%platform%=%%curritem%%"
) else (
    call set "INIAREA_%currarea%_%platform%=%%store%%;%%curritem%%"
)
goto :eof




:ClearIni
:ClearIni_IterStringLoop
set str=%INI_AREALIST%
For /F "tokens=1* delims=;" %%A IN ("%str%") DO @set "item=%%A" & set "str=%%B"
if not "%item%" == "" (
    call set INIAREA_%item%_all=
    call set INIAREA_%item%_linux=
    call set INIAREA_%item%_posix=
    call set INIAREA_%item%_windows=
    call set INIAREA_%item%_macos=
    call set INIAREA_%item%_cygwin=
)
if not "%str%" == "" goto ClearIni_IterStringLoop
set str=
set item=
set INI_AREALIST=
set INI_LOADED=
goto :eof


::: function GetIniItems(area, platform=all) extensions delayedexpansion
:GetIniItems
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=parseini.cmd GetIniItems" & set "CTRA=GetIniItems %CTRA%"
@( set _pos=0 & set _fmin=1)
set platform=all

:parg_GetIniItems
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_GetIniItems
@if "!_head!" == "--platform" @(set "platform=!_next!" & shift & shift & set _require=1 & goto :parg_GetIniItems)
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "area=!_head!" & shift & set /a "_pos+=1" & goto :parg_GetIniItems)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_GetIniItems
:pargdone_GetIniItems
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_GetIniItems

call set "inival=%%INIAREA_%item%_all%%"
if "%platform%" == "posix" if "%platform%" == "linux" if "%platform%" == "macos" if "%platform%" == "cygwin" (
    call set "inival=%%inival%%;%%INIAREA_%item%_posix%%"
)
if not "%platform%" == "all" if not "%platform%" == "posix" (
    call set "inival=%%inival%%;%%INIAREA_%item%_%platform%%%"
)

for /f "tokens=* delims=;" %%b in ("%inival%") do set inival=%%b
for /l %%a in (1,1,31) do if "!inival:~-1!"==";" set inival=!inival:~0,-1!

endlocal & (if "%EMSG%" == "" (
set "inival=%inival%"
goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


:: 讀取ini檔案的方法, 將取得的值寫入%inival%
:: GetIniArray(file, area)
::   inival = "v1;v2"
:: GetIniPairs(file, area)
::   inival = "k1=v1;k2=v2"
:: GetIniValue(file, area, key)
::   inival = "v"


::: function GetIniArray(file, area) extensions delayedexpansion
:GetIniArray
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=parseini.cmd GetIniArray" & set "CTRA=GetIniArray %CTRA%"
@( set _pos=0 & set _fmin=2)

:parg_GetIniArray
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_GetIniArray
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "file=!_head!" & shift & set /a "_pos+=1" & goto :parg_GetIniArray)
@if %_pos% == 1 @(set "area=!_head!" & shift & set /a "_pos+=1" & goto :parg_GetIniArray)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_GetIniArray
:pargdone_GetIniArray
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_GetIniArray
set inival=
if not exist "%file%" goto :return_GetIniArray
set area=[%area%]
set currarea=
for /f "usebackq delims=" %%a in ("!file!") do (
    set ln=%%a
    for /f "tokens=* delims= " %%a in ("!ln!") do set ln=%%a
    if not x!ln! == x if not "!ln:~0,1!" == "#" (
        if "!ln:~0,1!" == "[" (
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
endlocal & (if "%EMSG%" == "" (
set "inival=%inival%"
goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


::: function GetIniPairs(file, area) extensions delayedexpansion
:GetIniPairs
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=parseini.cmd GetIniPairs" & set "CTRA=GetIniPairs %CTRA%"
@( set _pos=0 & set _fmin=2)

:parg_GetIniPairs
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_GetIniPairs
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "file=!_head!" & shift & set /a "_pos+=1" & goto :parg_GetIniPairs)
@if %_pos% == 1 @(set "area=!_head!" & shift & set /a "_pos+=1" & goto :parg_GetIniPairs)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_GetIniPairs
:pargdone_GetIniPairs
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_GetIniPairs
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
endlocal & (if "%EMSG%" == "" (
set "inival=%inival%"
goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


::: function GetIniValue(file, area, key) extensions delayedexpansion
:GetIniValue
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=parseini.cmd GetIniValue" & set "CTRA=GetIniValue %CTRA%"
@( set _pos=0 & set _fmin=3)

:parg_GetIniValue
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_GetIniValue
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "file=!_head!" & shift & set /a "_pos+=1" & goto :parg_GetIniValue)
@if %_pos% == 1 @(set "area=!_head!" & shift & set /a "_pos+=1" & goto :parg_GetIniValue)
@if %_pos% == 2 @(set "key=!_head!" & shift & set /a "_pos+=1" & goto :parg_GetIniValue)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_GetIniValue
:pargdone_GetIniValue
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_GetIniValue
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
endlocal & (if "%EMSG%" == "" (
set "inival=%inival%"
goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))

:GetNormalizePath
    SET NORMALIZEPATH=%~dpfn1
    goto :eof


::: function GetPrjRoot()
:GetPrjRoot
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=project-paths.cmd GetPrjRoot" & set "CTRA=GetPrjRoot %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_GetPrjRoot
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_GetPrjRoot
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_GetPrjRoot
:pargdone_GetPrjRoot
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_GetPrjRoot
call :get_dir %SCRIPT_SOURCE%
set PRJ_ROOT=
pushd %dir%
set PRJ_ROOT=%cd%
popd
endlocal & (if "%EMSG%" == "" (
set "PRJ_ROOT=%PRJ_ROOT%"
goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
:get_dir
    set dir=%~dp0
goto :eof
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


::: function GetTitle(titlePath)
:GetTitle
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=project-paths.cmd GetTitle" & set "CTRA=GetTitle %CTRA%"
@( set _pos=0 & set _fmin=1)

:parg_GetTitle
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_GetTitle
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "titlePath=!_head!" & shift & set /a "_pos+=1" & goto :parg_GetTitle)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_GetTitle
:pargdone_GetTitle
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_GetTitle
set SPLITSTR=%titlePath%
:nextVar
   for /F tokens^=1*^ delims^=^\ %%a in ("%SPLITSTR%") do (
      set LAST=%%a
      set SPLITSTR=%%b
   )
if defined SPLITSTR goto nextVar
set TITLE=%LAST%
endlocal & (if "%EMSG%" == "" (
set "TITLE=%TITLE%"
goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


::: function LoadConfigPaths()
:LoadConfigPaths
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=project-paths.cmd LoadConfigPaths" & set "CTRA=LoadConfigPaths %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_LoadConfigPaths
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_LoadConfigPaths
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_LoadConfigPaths
:pargdone_LoadConfigPaths
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_LoadConfigPaths
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


endlocal & (if "%EMSG%" == "" (
set "DEVON_CONFIG_PATH=%DEVON_CONFIG_PATH%"
set "PRJ_ROOT=%PRJ_ROOT%"
set "PRJ_BIN=%PRJ_BIN%"
set "PRJ_VAR=%PRJ_VAR%"
set "PRJ_LOG=%PRJ_LOG%"
set "PRJ_TMP=%PRJ_TMP%"
set "PRJ_CONF=%PRJ_CONF%"
goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


::: function BasicCheck()
:BasicCheck
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=dev-sh.cmd BasicCheck" & set "CTRA=BasicCheck %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_BasicCheck
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_BasicCheck
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_BasicCheck
:pargdone_BasicCheck
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_BasicCheck
if not "%~d0" == "C:" (
     endlocal & (set "EMSG=folder must in C:" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
)
echo %~dp0| findstr /R /C:"^[a-zA-Z0-9~.\\:_-]*$">nul 2>&1
if errorlevel 1 (
     endlocal & (set "EMSG=folder path contains illegal characters" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
)
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


::: function AddPathUnique(entry)
:AddPathUnique
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=dev-sh.cmd AddPathUnique" & set "CTRA=AddPathUnique %CTRA%"
@( set _pos=0 & set _fmin=1)

:parg_AddPathUnique
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_AddPathUnique
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "entry=!_head!" & shift & set /a "_pos+=1" & goto :parg_AddPathUnique)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_AddPathUnique
:pargdone_AddPathUnique
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_AddPathUnique
set found=0
set str=%PATH%
:AddPathUnique_IterStringLoop
For /F "tokens=1* delims=;" %%A IN ("%str%") DO @set "item=%%A" & set "str=%%B"
if "%entry%" == "%item%" set found=1
if not "%str%" == "" goto AddPathUnique_IterStringLoop
if "%found%" == "0" set PATH=%entry%;%PATH%
endlocal & (if "%EMSG%" == "" (
set "PATH=%PATH%"
goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))



:ActiveDevShell


if "%DEVSH_ACTIVATE%" == "%SCRIPT_SOURCE%" goto :eof

call :BasicCheck
call :LoadConfigPaths
call :GetTitle %PRJ_ROOT%


if exist "%PRJ_BIN%" set PATH=%PRJ_BIN%;%PATH%
if exist "%PRJ_TOOLS%" set PATH=%PRJ_TOOLS%;%PATH%
if exist "%PRJ_CONF%" set PATH=%PRJ_CONF%;%PATH%

if not "%DEVON_CONFIG_PATH%" == "" call :GetIniArray "%DEVON_CONFIG_PATH%" "path"
call set str=%inival%
:ActiveDevShell_path_IterStringLoop
for /f "tokens=1* delims=;" %%A in ("%str%") do set "item=%%A" & set "str=%%B"
    set PATH=%item%;%PATH%
    if not "%str%" == "" goto ActiveDevShell_path_IterStringLoop


if not "%DEVON_CONFIG_PATH%" == "" call :GetIniArray "%DEVON_CONFIG_PATH%" "variable"
set str=%inival%
:ActiveDevShell_variable_IterStringLoop
for /f "tokens=1* delims=;" %%A in ("%str%") do set "item=%%A" & set "str=%%B"
for /f "tokens=1* delims==" %%A in ("%item%") do set "name=%%A" & set "value=%%B"
    call set "%name%=%value%"
    if not "%str%" == "" goto ActiveDevShell_variable_IterStringLoop


rmdir /S /Q "%PRJ_TMP%\command-pre" 1>nul 2>&1
md "%PRJ_TMP%\command-pre" 1>nul 2>&1


set inival=
if not "%DEVON_CONFIG_PATH%" == "" call :GetIniArray %DEVON_CONFIG_PATH% "dotfiles"
set str=%inival%
:ActiveDevShell_dotfiles_IterStringLoop
for /f "tokens=1* delims=;" %%A in ("%str%") do set "item=%%A" & set "str=%%B"
    pushd "%PRJ_ROOT%"
    if exist "!item!.cmd" call call "!item!.cmd"
    popd
    if not "%str%" == "" goto ActiveDevShell_dotfiles_IterStringLoop


call :GenerateCommandStubs

if not "%DEVON_CONFIG_PATH%" == "" call :GetIniPairs %DEVON_CONFIG_PATH% "require"
if not "%inival%" == "" set specs=%inival:;= %

call :EnterPostScript
if "%BRICKV_GLOBAL_DIR%" == ""set BRICKV_GLOBAL_DIR=%LOCALAPPDATA%\Programs
if "%BRICKV_LOCAL_DIR%" == "" set BRICKV_LOCAL_DIR=%PRJ_BIN%

call :brickv_CMD_Update "%specs% ansicon clink" --no-install
call :ExecutePostScript


set PATH=%PRJ_TMP%\command;%PATH%
rmdir /S /Q "%PRJ_TMP%\command" 1>nul 2>&1
move "%PRJ_TMP%\command-pre" "%PRJ_TMP%\command" 1>nul 2>&1

set inival=
set str=

set DEVSH_ACTIVATE=%SCRIPT_SOURCE%
goto :eof


::: function CMD_brickv(brickv_cmd, brickv_args=....)
:CMD_brickv
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=dev-sh.cmd CMD_brickv" & set "CTRA=CMD_brickv %CTRA%"
@( set _pos=0 & set _fmin=1)
set brickv_args=

:parg_CMD_brickv
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_CMD_brickv
@if %_pos% == 0 @(set "brickv_cmd=!_head!" & shift & set /a "_pos+=1" & goto :parg_CMD_brickv)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_CMD_brickv
:pargdone_CMD_brickv
@if %_pos% LSS %_fmin% goto :parg_posunder_err
set "brickv_args=!_rest!"
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_CMD_brickv
call :brickv_CMD_%brickv_cmd% %brickv_args%
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))

::: function CMD_welcome()
:CMD_welcome
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=dev-sh.cmd CMD_welcome" & set "CTRA=CMD_welcome %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_CMD_welcome
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_CMD_welcome
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_CMD_welcome
:pargdone_CMD_welcome
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_CMD_welcome
if not "%ANSICON%" == "" call :ImportColor
echo %BW%Devone%NN% v%DEVON_VERSION% [project %DC%%TITLE%%NN%]
call :GetIniValue %DEVON_CONFIG_PATH% "help" "*"
if not "%inival%" == "" call echo %inival%
echo.@set PROMPT=$C%DC%!TITLE!%NN%$F$S$P$G > "%POST_SCIRPT%"
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))

::: function CMD_version()
:CMD_version
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=dev-sh.cmd CMD_version" & set "CTRA=CMD_version %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_CMD_version
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_CMD_version
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_CMD_version
:pargdone_CMD_version
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_CMD_version
echo v%DEVON_VERSION%
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


::: function GenerateCommandStubs()
:GenerateCommandStubs
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=dev-sh.cmd GenerateCommandStubs" & set "CTRA=GenerateCommandStubs %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_GenerateCommandStubs
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_GenerateCommandStubs
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_GenerateCommandStubs
:pargdone_GenerateCommandStubs
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_GenerateCommandStubs

if not "%DEVON_CONFIG_PATH%" == "" call :GetIniPairs "%DEVON_CONFIG_PATH%" "alias"
set str=%inival%
:GenerateCommandStubs_IterStringLoop
for /f "tokens=1* delims=;" %%A in ("%str%") do set "item=%%A" & set "str=%%B"
for /f "tokens=1* delims==" %%A in ("%item%") do set "alias=%%A" & set "alias_cmd=%%B"
    echo.cmd.exe /C "%alias_cmd%" > %PRJ_TMP%\command-pre\%alias%.cmd
    if not "%str%" == "" goto GenerateCommandStubs_IterStringLoop


echo.@"%SCRIPT_SOURCE%" %%* > %PRJ_TMP%\command-pre\dev.cmd

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


echo.!GitHooksScript! > %PRJ_TMP%\command-pre\git-hooks

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


echo.!GitBashScript! > %PRJ_TMP%\command-pre\bash.cmd
echo.!GitBashScript! > %PRJ_TMP%\command-pre\git-bash.cmd

endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))

::: function CMD_shell(no_window=N, no_welcome=N) delayedexpansion
:CMD_shell
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=dev-sh.cmd CMD_shell" & set "CTRA=CMD_shell %CTRA%"
@( set _pos=0 & set _fmin=0)
set no_window=
set no_welcome=

:parg_CMD_shell
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_CMD_shell
@if "!_head!" == "--no-window" @(set "no_window=1" & shift & goto :parg_CMD_shell)
@if "!_head!" == "--no-welcome" @(set "no_welcome=1" & shift & goto :parg_CMD_shell)
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_CMD_shell
:pargdone_CMD_shell
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_CMD_shell
set CMDSCRIPT=
set CMDSCRIPT=!CMDSCRIPT!        (set no_window=)^&        (set no_welcome=)^&        (set CMDSCRIPT=)^&        (set CALL_STACK=)^&        (set SCRIPT_FOLDER=)^&        (set SCRIPT_SOURCE=)^&        (set DEVON_VERSION=)^&        (set CTRA=)^&        (set _devcmd=)^&        (set _devargs=)^&



where ansicon.exe 1>nul 2>&1
if not errorlevel 1 (
    set "CMDSCRIPT=!CMDSCRIPT!(ansicon.exe -p)^&"
)

where clink.bat 1>nul 2>&1
if not errorlevel 1 (
    set "CMDSCRIPT=!CMDSCRIPT!(clink.bat inject 1>nul)^&"
)

if not "%no_welcome%" == "1" (
    set "CMDSCRIPT=!CMDSCRIPT!(dev welcome)^&"
)
set "CMDSCRIPT=!CMDSCRIPT!(call)"
pushd "%PRJ_ROOT%"
echo on
@if "%no_window%" == "1" @(
    @%ComSpec% /K "!CMDSCRIPT!"
) else @(
    @start "[%TITLE%]" %ComSpec% /K "!CMDSCRIPT!"
)
@echo off
popd
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))

::: function CMD_setup(UserName=?, GithubToken=?)
:CMD_setup
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=CMD_setup.cmd CMD_setup" & set "CTRA=CMD_setup %CTRA%"
@( set _pos=0 & set _fmin=0)
set UserName=
set GithubToken=

:parg_CMD_setup
if defined _require (
    if "!_next!" == "" goto :parg_noarg_err
    if "!_next:~0,1!" == "-" goto :parg_noarg_err
    set _require=
)
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_CMD_setup
@if "!_head!" == "--username" @(set "UserName=!_next!" & shift & shift & set _require=1 & goto :parg_CMD_setup)
@if "!_head!" == "--githubtoken" @(set "GithubToken=!_next!" & shift & shift & set _require=1 & goto :parg_CMD_setup)
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_CMD_setup
:pargdone_CMD_setup
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_CMD_setup


git rev-parse 1>nul 1>&2
if errorlevel 1  endlocal & (set "EMSG=Not a git repository" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)

for /f %%i in ('git rev-parse --git-dir') do set GitDir=%%i
if exist "%GitDir%/.devon" (
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
)

if "%UserName%" == "" set /P UserName=Enter your name (or input 'global' use global config):
if "%GithubToken%" == "" set /P GithubToken=Enter the secret token:

for /f "tokens=1,2 delims==" %%a in ("%GithubToken%") do (
    set LoginName=%%a
    set LoginPassword=%%b
)

if "%UserName%" == ""  endlocal & (set "EMSG=User name undefined" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
if "%LoginName%" == ""  endlocal & (set "EMSG=Login name undefined" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
if "%LoginPassword%" == ""  endlocal & (set "EMSG=Login password undefined" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)

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

git hooks --install

echo. > "%GitDir%/.devon"

endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


::: function CMD_sync(MOST_CLEAN=N) delayedexpansion
:CMD_sync
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=CMD_sync.cmd CMD_sync" & set "CTRA=CMD_sync %CTRA%"
@( set _pos=0 & set _fmin=0)
set MOST_CLEAN=

:parg_CMD_sync
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_CMD_sync
@if "!_head!" == "--most-clean" @(set "MOST_CLEAN=1" & shift & goto :parg_CMD_sync)
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_CMD_sync
:pargdone_CMD_sync
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_CMD_sync





set MAIN_BRANCH=master
set CURRENT_CHANGES=
for /f %%i in ('git status --porcelain') do set CURRENT_CHANGES=%%i
for /f %%i in ('git symbolic-ref -q --short HEAD') do set CURRENT_BRANCH=%%i

if "%MOST_CLEAN%" == "1" if not "%CURRENT_CHANGES%" == ""  endlocal & (set "EMSG=status most clean" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
if not "%CURRENT_CHANGES%" == "" git stash --include-untracked
if not "%CURRENT_BRANCH%" == "%MAIN_BRANCH%" git checkout %MAIN_BRANCH%

git fetch origin --progress
if errorlevel 1  endlocal & (set "EMSG=cannot fetch, maybe your network is offline" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)


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

endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


::: function PreparePrint(PRINT_LEVEL, MSG_TITLE)
:PreparePrint
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=print.cmd PreparePrint" & set "CTRA=PreparePrint %CTRA%"
@( set _pos=0 & set _fmin=2)

:parg_PreparePrint
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_PreparePrint
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "PRINT_LEVEL=!_head!" & shift & set /a "_pos+=1" & goto :parg_PreparePrint)
@if %_pos% == 1 @(set "MSG_TITLE=!_head!" & shift & set /a "_pos+=1" & goto :parg_PreparePrint)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_PreparePrint
:pargdone_PreparePrint
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_PreparePrint
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

endlocal & (if "%EMSG%" == "" (
set "PRINT_LEVEL=%PRINT_LEVEL%"
set "LOG_LEVEL=%LOG_LEVEL%"
set "THISNAME=%THISNAME%"
set "MSG_TITLE_F=%MSG_TITLE_F%"
goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))

::: function PrintMsg(PRINT_LEVEL, MSG_TITLE, MSG_BODY=....)
:PrintMsg
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=print.cmd PrintMsg" & set "CTRA=PrintMsg %CTRA%"
@( set _pos=0 & set _fmin=2)
set MSG_BODY=

:parg_PrintMsg
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_PrintMsg
@if %_pos% == 0 @(set "PRINT_LEVEL=!_head!" & shift & set /a "_pos+=1" & goto :parg_PrintMsg)
@if %_pos% == 1 @(set "MSG_TITLE=!_head!" & shift & set /a "_pos+=1" & goto :parg_PrintMsg)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_PrintMsg
:pargdone_PrintMsg
@if %_pos% LSS %_fmin% goto :parg_posunder_err
set "MSG_BODY=!_rest!"
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_PrintMsg
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
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


::: function PrintVersion(PRINT_LEVEL, MSG_TITLE, PV_APP, PV_VER=, PV_ARCH=, PV_PATCHES=)
:PrintVersion
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=print.cmd PrintVersion" & set "CTRA=PrintVersion %CTRA%"
set PV_VER=
set PV_ARCH=
set PV_PATCHES=
@( set _pos=0 & set _fmin=3)

:parg_PrintVersion
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_PrintVersion
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "PRINT_LEVEL=!_head!" & shift & set /a "_pos+=1" & goto :parg_PrintVersion)
@if %_pos% == 1 @(set "MSG_TITLE=!_head!" & shift & set /a "_pos+=1" & goto :parg_PrintVersion)
@if %_pos% == 2 @(set "PV_APP=!_head!" & shift & set /a "_pos+=1" & goto :parg_PrintVersion)
@if %_pos% == 3 @(set "PV_VER=!_head!" & shift & set /a "_pos+=1" & goto :parg_PrintVersion)
@if %_pos% == 4 @(set "PV_ARCH=!_head!" & shift & set /a "_pos+=1" & goto :parg_PrintVersion)
@if %_pos% == 5 @(set "PV_PATCHES=!_head!" & shift & set /a "_pos+=1" & goto :parg_PrintVersion)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_PrintVersion
:pargdone_PrintVersion
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_PrintVersion
call :PreparePrint "%PRINT_LEVEL%" "%MSG_TITLE%"
call :ImportColor

:: request, match, newest
set OUTPUT=%THISNAME% %DP%%MSG_TITLE_F%%NN% %BW%%PV_APP%%NN%^=%PV_VER%%BW%%NN%@%PV_ARCH%[%PV_PATCHES%]
call :_Print
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


:PrintTaskInfo
::: function PrintTaskInfo()
:PrintTaskInfo
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=print.cmd PrintTaskInfo" & set "CTRA=PrintTaskInfo %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_PrintTaskInfo
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_PrintTaskInfo
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_PrintTaskInfo
:pargdone_PrintTaskInfo
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_PrintTaskInfo
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
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))



:_Print
if %PRINT_LEVEL% GEQ %LOG_LEVEL% echo.%OUTPUT%
goto :eof


:ImportColor
if not "%NN%" == "" goto :eof
if "%NO_COLOR%" == "1" goto :eof
if "%TEST_SHELL%" == "1" goto :eof
if "%ANSICON%" == "" goto :eof

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
:MakeColorTable
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=color.cmd MakeColorTable" & set "CTRA=MakeColorTable %CTRA%"
@( set _pos=0 & set _fmin=1)

:parg_MakeColorTable
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_MakeColorTable
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "ColorTable=!_head!" & shift & set /a "_pos+=1" & goto :parg_MakeColorTable)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_MakeColorTable
:pargdone_MakeColorTable
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_MakeColorTable
for /f %%a in ('"prompt $e & for %%b in (1) do rem"') do @set esc=%%a

set count=0
for %%A IN (K,R,G,Y,B,P,C,W) do call :SetAtomColor %%A

echo @set NN=%esc%[0m> "%ColorTable%"
for %%A IN (_FDK,_FDR,_FDG,_FDY,_FDB,_FDP,_FDC,_FDW, _FBK,_FBR,_FBG,_FBY,_FBB,_FBP,_FBC,_FBW) do (
    for %%B IN ("","") do call :SetColor %%A %%B
)

endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


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
:CMD_update
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=CMD_update.cmd CMD_update" & set "CTRA=CMD_update %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_CMD_update
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_CMD_update
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_CMD_update
:pargdone_CMD_update
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_CMD_update


set inival=
call :GetIniPairs %DEVON_CONFIG_PATH% "require"
if not "%inival%" == "" set specs=%inival:;= %

if exist "%PRJ_CONF%\hooks\update.cmd" (
    call "%PRJ_CONF%\hooks\update.cmd"
)

endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


::: function CMD_bootstrap(git_remote)
:CMD_bootstrap
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=CMD_update.cmd CMD_bootstrap" & set "CTRA=CMD_bootstrap %CTRA%"
@( set _pos=0 & set _fmin=1)

:parg_CMD_bootstrap
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_CMD_bootstrap
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "git_remote=!_head!" & shift & set /a "_pos+=1" & goto :parg_CMD_bootstrap)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_CMD_bootstrap
:pargdone_CMD_bootstrap
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_CMD_bootstrap
call :EnterPostScript
call :brickv_CMD_Update "git=2.x" --vv
call :ExecutePostScript

git clone %git_remote% > "%TEMP%\git-clone-stdout.txt"
if errorlevel 1  endlocal & (set "EMSG=git clone failed" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
for /F "tokens=1-3 usebackq" %%A IN ("%TEMP%\git-clone-stdout.txt") do (
    if "%%A" == "Cloning" if "%%B" == "into" set ProjectRoot=%%C
)
set ProjectRoot=%ProjectRoot:~1, -4%
echo %ProjectRoot%

if not exist "%ProjectRoot%\dev-sh.cmd"  endlocal & (set "EMSG=project not exist" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
call "%ProjectRoot%\dev-sh.cmd" init
call "%ProjectRoot%\dev-sh.cmd" update
call "%ProjectRoot%\dev-sh.cmd" shell


endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))



::: function CMD_clear()
:CMD_clear
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=CMD_clear.cmd CMD_clear" & set "CTRA=CMD_clear %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_CMD_clear
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_CMD_clear
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_CMD_clear
:pargdone_CMD_clear
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_CMD_clear




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

endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))





::: function brickv_CMD_install(ONLY_VERSIONS=N, args=....) delayedexpansion
:brickv_CMD_install
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_CMD_install.cmd brickv_CMD_install" & set "CTRA=brickv_CMD_install %CTRA%"
@( set _pos=0 & set _fmin=0)
set ONLY_VERSIONS=
set args=

:parg_brickv_CMD_install
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_brickv_CMD_install
@if "!_head!" == "--only-versions" @(set "ONLY_VERSIONS=1" & shift & goto :parg_brickv_CMD_install)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_brickv_CMD_install
:pargdone_brickv_CMD_install
set "args=!_rest!"
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_brickv_CMD_install
:: function brickv_CMD_install(spec, reinstall=N, dry=N, no_check=N, newest=N, targetdir=?)

set ACCEPT=1

set REQUEST_TARGETDIR=%targetdir%

if "%dry%" == "1" set DRYRUN=1

if "%reinstall%" == "1" set REINSTALL=1

call :BrickvPrepare "%spec%" %args%

call :MatchVersion --output-format env "%spec%"
set REQUEST_APP=%MATCH_APP%
set REQUEST_MAJOR=%MATCH_MAJOR%
set REQUEST_MINOR=%MATCH_MINOR%
set REQUEST_PATCH=%MATCH_PATCH%
set REQUEST_ARCH=%MATCH_ARCH%
set REQUEST_PATCHES=%MATCH_PATCHES%
set REQUEST_VER=%MATCH_VER%
if "%REQUEST_ARCH%" == "" (
    if "%PROCESSOR_ARCHITECTURE%" == "x86" (
        set REQUEST_ARCH=x86
    ) else (
        set REQUEST_ARCH=x64
    )
)
call :PrintVersion info request "%REQUEST_APP%" "%REQUEST_VER%" "%REQUEST_ARCH%" "%REQUEST_PATCHES%"



set args=
set APPNAME=%REQUEST_APP%

call :ExistsLabel %APPNAME%_init
if "%LabelExists%" == "1" (
    call :%APPNAME%_init
) else (
     endlocal & (set "EMSG=%APPNAME% not in installable list" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
)
if "%ALLOW_EMPTY_LOCATION%" == "1" if "%REQUEST_LOCATION%" == "" set REQUEST_LOCATION=global



if not "%PRJ_TMP%" == "" set TEMP=%PRJ_TMP%
set VERSION_SOURCE_FILE=%TEMP%\source-%APPNAME%.ver.txt
set VERSION_SPCES_FILE=%TEMP%\spces-%APPNAME%.ver.txt

if exist "%VERSION_SOURCE_FILE%" del "%VERSION_SOURCE_FILE%" >nul
copy /y NUL "%VERSION_SOURCE_FILE%" >NUL
if exist "%VERSION_SPCES_FILE%" del "%VERSION_SPCES_FILE%" >nul
copy /y NUL "%VERSION_SPCES_FILE%" >NUL

call :ExistsLabel %APPNAME%_versions
if "%LabelExists%" == "1" call :%APPNAME%_versions
if exist "%RELEASE_URL%" call :BrickvDownload "%RELEASE_URL%" "%VERSION_SPCES_FILE%"
if "%ONLY_VERSIONS%" == "1" (
endlocal & (if "%EMSG%" == "" (
set "VERSION_SPCES_FILE=%VERSION_SPCES_FILE%"
goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
)

if exist "%VERSION_SPCES_FILE%" (
    call :MatchVersion --output-format env --spec-match "%REQUEST_SPEC%" --specs-file "%VERSION_SPCES_FILE%"
            if not "!ERROR_MSG!" == "" goto :brickv_CMD_install_Error
) else (
     endlocal & (set "EMSG=release version list is empty" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
    rem if "%RELEASE_LIST%" == ""  endlocal & (set "EMSG=release version list is empty" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
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


set NoCheckTarget=0
call :ExistsLabel %APPNAME%_validate
if "%LabelExists%" == "1" call :%APPNAME%_validate

if "%NoCheckTarget%" == "0" (
    if not exist "%TARGET%"  endlocal & (set "EMSG=unpack failed, cannot unpack installer" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
)
call :BrickvGenEnv "%TARGET%" "%APPNAME%" "%APPVER%" "%SETENV%"
        if not "%ERROR_MSG%" == "" goto :brickv_CMD_install_Error
call :BrickvValidate
if not "%ERROR_MSG%" == "" (
    call :PrintMsg error validate failed: %ERROR_MSG%
    goto :brickv_CMD_install_Error
) else (
    call :PrintMsg noraml validate succeed
)

:BrickvInstallFinal
set ERROR_MSG=
call :BrickvDone
if not "%EMSG%" == "" if "%CTRA%" == "" goto :_Error
if not "%EMSG%" == ""  endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
cmd /C exit /b 0
endlocal & (if "%EMSG%" == "" (
set "DRYRUN=%DRYRUN%"
set "REQUEST_NAME=%REQUEST_NAME%"
goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


:brickv_CMD_install_Error
set _ERROR_MSG=%ERROR_MSG%
call :BrickvDone
if not "%EMSG%" == "" if "%CTRA%" == "" goto :_Error
if not "%EMSG%" == ""  endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
cmd /C exit /b 1
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


::: function BrickvValidate2() delayedexpansion
:BrickvValidate2
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_CMD_install.cmd BrickvValidate2" & set "CTRA=BrickvValidate2 %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_BrickvValidate2
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_BrickvValidate2
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_BrickvValidate2
:pargdone_BrickvValidate2
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_BrickvValidate2

if exist "%TARGET%\set-env.cmd" (
    call "%TARGET%\set-env.cmd" --validate --quiet
) else (
     endlocal & (set "EMSG=missing %TARGET%\set-env.cmd" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
)
if errorlevel 1  endlocal & (set "EMSG=self validate failed" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)

if not "%CHECK_EXIST%" == "" if not exist "%SCRIPT_FOLDER%\%CHECK_EXIST%" (
     endlocal & (set "EMSG=exist validate failed %SCRIPT_FOLDER%\%CHECK_EXIST%" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
)
if not "%CHECK_EXEC%" == "" (
    if not exist "%SCRIPT_FOLDER%\%CHECK_EXEC%" (
         endlocal & (set "EMSG=validate failed, because %SCRIPT_FOLDER%\%CHECK_EXIST% not exist" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
    ) else (
        "%SCRIPT_FOLDER%\%CHECK_EXEC%" %CHECK_EXEC_ARGS%
        if errorlevel 1  endlocal & (set "EMSG=execute validate failed" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
    )
)
if "%CHECK_LINEWORD%" == "" if "%CHECK_OK%" == "" (
    if "%CHECK_CMD%" == "" (
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
    )
    cmd /C "%CHECK_CMD%"
    if errorlevel 1  endlocal & (set "EMSG=validate command failed" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
)
if "%CHECK_LINEWORD%" == "" (
    for /F "tokens=* USEBACKQ" %%F in (`cmd /C %CHECK_CMD%`) do @set CHECK_STRING=%%F
) else (
    for /F "tokens=* USEBACKQ" %%F in (`cmd /C %CHECK_CMD% ^| findstr %CHECK_LINEWORD%`) do @set CHECK_STRING=%%F
)
if "!CHECK_STRING:%CHECK_OK%=!" == "%CHECK_STRING%"  endlocal & (set "EMSG=validate failed not match %CHECK_STRING% != %CHECK_OK%" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))

endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


::: function BrickvValidate() delayedexpansion
:BrickvValidate
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_CMD_install.cmd BrickvValidate" & set "CTRA=BrickvValidate %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_BrickvValidate
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_BrickvValidate
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_BrickvValidate
:pargdone_BrickvValidate
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_BrickvValidate
if exist "%TARGET%\set-env.cmd" (
    call "%TARGET%\set-env.cmd" --validate --quiet
) else (
     endlocal & (set "EMSG=missing %TARGET%\set-env.cmd" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
)
if errorlevel 1 (
    if defined VALID_ERR (
        error(%VALID_ERR%)
    ) else (
         endlocal & (set "EMSG=validation failed, but reason is not given" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
    )
)
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))




:ExistsLabel
set LabelExists=1
findstr /i /r /c:"^[ ]*:%~1\>" "%SCRIPT_SOURCE%" >nul 2>nul
if errorlevel 1 set LabelExists=
goto :eof

::: function BrickvPrepare(spec,
:::                                global_dir=?, local_dir=?, global=N, local=N,
:::                                silent=N, quiet=N, verobse=N, debug=N
:::                                )
:BrickvPrepare
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_prepare.cmd BrickvPrepare" & set "CTRA=BrickvPrepare %CTRA%"
@( set _pos=0 & set _fmin=1)
set global_dir=
set local_dir=
set global=
set local=
set silent=
set quiet=
set verobse=
set debug=

:parg_BrickvPrepare
if defined _require (
    if "!_next!" == "" goto :parg_noarg_err
    if "!_next:~0,1!" == "-" goto :parg_noarg_err
    set _require=
)
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_BrickvPrepare
@if "!_head!" == "--global-dir" @(set "global_dir=!_next!" & shift & shift & set _require=1 & goto :parg_BrickvPrepare)
@if "!_head!" == "--local-dir" @(set "local_dir=!_next!" & shift & shift & set _require=1 & goto :parg_BrickvPrepare)
@if "!_head!" == "--global" @(set "global=1" & shift & goto :parg_BrickvPrepare)
@if "!_head!" == "--local" @(set "local=1" & shift & goto :parg_BrickvPrepare)
@if "!_head!" == "--silent" @(set "silent=1" & shift & goto :parg_BrickvPrepare)
@if "!_head!" == "--quiet" @(set "quiet=1" & shift & goto :parg_BrickvPrepare)
@if "!_head!" == "--verobse" @(set "verobse=1" & shift & goto :parg_BrickvPrepare)
@if "!_head!" == "--debug" @(set "debug=1" & shift & goto :parg_BrickvPrepare)
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "spec=!_head!" & shift & set /a "_pos+=1" & goto :parg_BrickvPrepare)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_BrickvPrepare
:pargdone_BrickvPrepare
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_BrickvPrepare

set REQUEST_SPEC=%spec%

if "%global%" == "1" set REQUEST_LOCATION=global
if "%local%" == "1" set REQUEST_LOCATION=local

if "%BRICKV_GLOBAL_DIR%" == "" set BRICKV_LOCAL_DIR=%global_dir%
if "%BRICKV_GLOBAL_DIR%" == "" set BRICKV_GLOBAL_DIR=%LOCALAPPDATA%\Programs
if "%BRICKV_LOCAL_DIR%" == "" set BRICKV_LOCAL_DIR=%local_dir%
if "%BRICKV_LOCAL_DIR%" == "" set BRICKV_LOCAL_DIR=%cd%

set LOG_LEVEL=3
if "%silent%" == "1" set LOG_LEVEL=5
if "%quiet%" == "1" set LOG_LEVEL=4
if "%verbose%" == "1" set /A LOG_LEVEL-=1
if "%debug%" == "1" set /A LOG_LEVEL-=2



endlocal & (if "%EMSG%" == "" (
set "LOG_LEVEL=%LOG_LEVEL%"
set "REQUEST_SPEC=%REQUEST_SPEC%"
set "REQUEST_LOCATION=%REQUEST_LOCATION%"
set "BRICKV_LOCAL_DIR=%BRICKV_LOCAL_DIR%"
set "BRICKV_GLOBAL_DIR=%BRICKV_GLOBAL_DIR%"
goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))

endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))




::: function Unzip(ZipFile, ExtractTo, delete_before=N) delayedexpansion
:Unzip
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_utils.cmd Unzip" & set "CTRA=Unzip %CTRA%"
@( set _pos=0 & set _fmin=2)
set delete_before=

:parg_Unzip
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_Unzip
@if "!_head!" == "--delete-before" @(set "delete_before=1" & shift & goto :parg_Unzip)
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "ZipFile=!_head!" & shift & set /a "_pos+=1" & goto :parg_Unzip)
@if %_pos% == 1 @(set "ExtractTo=!_head!" & shift & set /a "_pos+=1" & goto :parg_Unzip)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_Unzip
:pargdone_Unzip
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_Unzip

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
if errorlevel 1  endlocal & (set "EMSG=unzip failed. maybe is not a zip file" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))



:::　function UnpackMsi(MSI_FILE, MSI_UNPACK_DIR=)
    if "%MSI_UNPACK_DIR%" == ""  endlocal & (set "EMSG=MSI_UNPACK_DIR undefined" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)

    msiexec /a "%MSI_FILE%" /qb TARGETDIR="%TARGETDIR%\unchecked-%NAME%"
    if errorlevel 1 (
        if exist "%TARGETDIR%\unchecked-%NAME%" rd /Q /S "%TARGETDIR%\unchecked-%NAME%"
         endlocal & (set "EMSG=msiexec install failed" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
    )
    if exist "%TARGETDIR%\%NAME%" rename "%TARGETDIR%\%NAME%" "padding-%NAME%"
    xcopy "%TARGETDIR%\unchecked-%NAME%%MSI_UNPACK_DIR%" "%TARGETDIR%\%NAME%\"> nul
    if errorlevel 1 (
        rd /Q /S "%TARGETDIR%\unchecked-%NAME%"
        if exist "%TARGETDIR%\padding-%NAME%" rename "%TARGETDIR%\padding-%NAME%" "%NAME%"
         endlocal & (set "EMSG=xcopy failed" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
    )
    if exist "%TARGETDIR%\unchecked-%NAME%" rd /Q /S "%TARGETDIR%\unchecked-%NAME%"
    if exist "%TARGETDIR%\padding-%NAME%" rd /Q /S "%TARGETDIR%\padding-%NAME%"
    call :PrintMsg normal msi success
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))

::: endfunc

:::　function InstallMsi(MSI_FILE)
    msiexec /i "%MSI_FILE%" /qb
    if errorlevel 1  endlocal & (set "EMSG=msiexec install failed" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
    call :PrintMsg normal msi success
:::



::: function MoveFile(SRC, DST)
:MoveFile
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_utils.cmd MoveFile" & set "CTRA=MoveFile %CTRA%"
@( set _pos=0 & set _fmin=2)

:parg_MoveFile
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_MoveFile
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "SRC=!_head!" & shift & set /a "_pos+=1" & goto :parg_MoveFile)
@if %_pos% == 1 @(set "DST=!_head!" & shift & set /a "_pos+=1" & goto :parg_MoveFile)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_MoveFile
:pargdone_MoveFile
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_MoveFile
if not exist "%SRC%"  endlocal & (set "EMSG=source %SRC% not exist" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
if exist "%DST%"  endlocal & (set "EMSG=destination %DST% exist" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
move "%SRC%" "%DST%" > nul
if errorlevel 1  endlocal & (set "EMSG=An error occurred when move %SRC% to %DST%" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)

call :PrintMsg debug move "%SRC% %DST%"
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


::: function FilenameFromUrl(Url)
:FilenameFromUrl
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_utils.cmd FilenameFromUrl" & set "CTRA=FilenameFromUrl %CTRA%"
@( set _pos=0 & set _fmin=1)

:parg_FilenameFromUrl
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_FilenameFromUrl
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "Url=!_head!" & shift & set /a "_pos+=1" & goto :parg_FilenameFromUrl)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_FilenameFromUrl
:pargdone_FilenameFromUrl
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_FilenameFromUrl
for /f %%i in ("%Url%") do set Filename=%%~nxi
for /f "delims=?" %%a in ("%Filename%") do set Filename=%%a
for /f "delims=#" %%a in ("%Filename%") do set Filename=%%a
endlocal & (if "%EMSG%" == "" (
set "Filename=%Filename%"
goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


::: function BrickvBeforeInstall()
:BrickvBeforeInstall
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_utils.cmd BrickvBeforeInstall" & set "CTRA=BrickvBeforeInstall %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_BrickvBeforeInstall
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_BrickvBeforeInstall
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_BrickvBeforeInstall
:pargdone_BrickvBeforeInstall
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_BrickvBeforeInstall

    if "%APPVER%" == "" set APPVER=%MATCH_VER%
    set TARGET_NAME=%APPNAME%-%APPVER%

    if not "%REQUEST_NAME%" == "" set TARGET_NAME=%REQUEST_NAME%

    if not "%REQUEST_TARGETDIR%" == "" set TARGETDIR=%REQUEST_TARGETDIR%
    if "%TARGETDIR%" == "" if "%REQUEST_LOCATION%" == "global" set TARGETDIR=%BRICKV_GLOBAL_DIR%
    if "%TARGETDIR%" == "" if "%REQUEST_LOCATION%" == "local" set TARGETDIR=%BRICKV_LOCAL_DIR%

    if not "%TARGET%" == "" for /f %%i in ("%TARGET%\..") do set TARGETDIR=%%~fi
    if not "%TARGET%" == "" for /f %%i in ("%TARGET%") do set TARGET_NAME=%%~ni
    if "%TARGETDIR%" == ""  endlocal & (set "EMSG=TARGETDIR not specific" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)


    set TARGET=%TARGETDIR%\%TARGET_NAME%
    set REAL_TARGET=%TARGET%
    set BACK_TARGET=%TARGETDIR%\backupfor-%APPNAME%
    set FAIL_TARGET=%TARGETDIR%\failed-%APPNAME%
    if "%DRYRUN%" == "1" goto :BrickvBeforeInstall_retrun

    if not exist "%TARGETDIR%" mkdir "%TARGETDIR%"
    if exist "%BACK_TARGET%" rd /Q /S "%BACK_TARGET%"
    if not exist "%REAL_TARGET%" goto :BrickvBeforeInstall_retrun
    move "%REAL_TARGET%" "%BACK_TARGET%" > nul
    if errorlevel 1  endlocal & (set "EMSG=%REAL_TARGET% can not move" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)

:BrickvBeforeInstall_retrun
endlocal & (if "%EMSG%" == "" (
set "TARGET=%TARGET%"
set "TARGETDIR=%TARGETDIR%"
set "TARGET_NAME=%TARGET_NAME%"
set "REAL_TARGET=%REAL_TARGET%"
set "BACK_TARGET=%BACK_TARGET%"
set "FAIL_TARGET=%FAIL_TARGET%"
goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))



::: function BrickvDone()
:BrickvDone
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_utils.cmd BrickvDone" & set "CTRA=BrickvDone %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_BrickvDone
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_BrickvDone
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_BrickvDone
:pargdone_BrickvDone
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_BrickvDone

if not "%_ERROR_MSG%" == "" (
    if not "%DRYRUN%" == "1" (
        if exist "%FAIL_TARGET%" rd /Q /S "%FAIL_TARGET%"
        if exist "%REAL_TARGET%" move "%REAL_TARGET%" "%FAIL_TARGET%"
        if exist "%BACK_TARGET%" move "%BACK_TARGET%" "%REAL_TARGET%" > nul
    )
    call :PrintMsg error error "%_ERROR_MSG%"
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
) else (
    if exist "%BACK_TARGET%" rd /Q /S "%BACK_TARGET%"
)

if "%DRYRUN%" == "1" (
    call :PrintMsg normal skip %APPNAME%@%MATCH_VER% at %REAL_TARGET%
) else (
    call :PrintMsg normal installed %APPNAME%@%MATCH_VER% at %REAL_TARGET%
)
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))



::: function BrickvValidate()
:BrickvValidate
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_utils.cmd BrickvValidate" & set "CTRA=BrickvValidate %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_BrickvValidate
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_BrickvValidate
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_BrickvValidate
:pargdone_BrickvValidate
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_BrickvValidate
set VAILDATE=1
if "%SETENV_TARGET%" == ""  endlocal & (set "EMSG=SETENV_TARGET undefined" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
if not exist "%SETENV_TARGET%"  endlocal & (set "EMSG=%SETENV_TARGET% not exist" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
call "%SETENV_TARGET%" --info
if not "%VA_INFO_APPNAME%" == "%APPNAME%"  endlocal & (set "EMSG=the demand application is %APPNAME%, but %VA_INFO_APPNAME% installed" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
call "%SETENV_TARGET%" --validate --quiet
if errorlevel 1  endlocal & (set "EMSG=%VA_INFO_APPNAME% validate failed" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))






::: function BrickvGenEnv(TARGET, APPNAME, APPVER, SETUPS=) delayedexpansion
:BrickvGenEnv
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_genenv.cmd BrickvGenEnv" & set "CTRA=BrickvGenEnv %CTRA%"
set SETUPS=
@( set _pos=0 & set _fmin=3)

:parg_BrickvGenEnv
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_BrickvGenEnv
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "TARGET=!_head!" & shift & set /a "_pos+=1" & goto :parg_BrickvGenEnv)
@if %_pos% == 1 @(set "APPNAME=!_head!" & shift & set /a "_pos+=1" & goto :parg_BrickvGenEnv)
@if %_pos% == 2 @(set "APPVER=!_head!" & shift & set /a "_pos+=1" & goto :parg_BrickvGenEnv)
@if %_pos% == 3 @(set "SETUPS=!_head!" & shift & set /a "_pos+=1" & goto :parg_BrickvGenEnv)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_BrickvGenEnv
:pargdone_BrickvGenEnv
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_BrickvGenEnv

call :GenEnvInlines
set SETENV_TARGET=%TARGET%\set-env.cmd

echo.> %SETENV_TARGET%
call :WriteTextEnv SetEnvBeginTemplate

call :WriteTextEnv SetEnvSetTemplate
call :WriteSetup set-env
if not defined %APPNAME%_setenv_script set %APPNAME%_setenv_script=@goto :eof
call :WriteTextEnv %APPNAME%_setenv_script

call :WriteTextEnv SetEnvClearTemplate
call :WriteSetup clear-env
if not defined %APPNAME%_clearenv_script set %APPNAME%_clearenv_script=@goto :eof
call :WriteTextEnv %APPNAME%_clearenv_script


call :WriteTextEnv SetEnvValidateTemplate
if not defined %APPNAME%_validate_script set %APPNAME%_validate_script=@goto :eof
if defined CHECK_EXIST call :WriteTextEnv CHECK_EXIST_TEMPLATE
if defined CHECK_EXEC call :WriteTextEnv CHECK_EXEC_TEMPLATE
if defined CHECK_CMD call :WriteTextEnv CHECK_CMD_TEMPLATE
call :WriteTextEnv %APPNAME%_validate_script

echo :BeforeMove>> "%SETENV_TARGET%"
if not defined %APPNAME%_beforemove_script set %APPNAME%_beforemove_script=@goto :eof
call :WriteTextEnv %APPNAME%_beforemove_script

@echo :AfterMove>> "%SETENV_TARGET%"
if not defined %APPNAME%_aftermove_script set %APPNAME%_aftermove_script=@goto :eof
call :WriteTextEnv %APPNAME%_aftermove_script

@echo :Remove>> "%SETENV_TARGET%"
if not defined %APPNAME%_remove_script set %APPNAME%_remove_script=@goto :eof
call :WriteTextEnv %APPNAME%_remove_script

call :WriteTextEnv SetEnvEndTemplate
call :WriteScriptFinal
call :PrintMsg debug setenv %SETENV_TARGET%
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))

:WriteTextEnv
call :WriteText %~1 "%SETENV_TARGET%" --append
goto :eof


::: function WriteText(VarName, TargetFile, Append=N) delayedexpansion
:WriteText
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_genenv.cmd WriteText" & set "CTRA=WriteText %CTRA%"
@( set _pos=0 & set _fmin=2)
set Append=

:parg_WriteText
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_WriteText
@if "!_head!" == "--append" @(set "Append=1" & shift & goto :parg_WriteText)
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "VarName=!_head!" & shift & set /a "_pos+=1" & goto :parg_WriteText)
@if %_pos% == 1 @(set "TargetFile=!_head!" & shift & set /a "_pos+=1" & goto :parg_WriteText)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_WriteText
:pargdone_WriteText
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_WriteText
call (
    (echo,!%VarName%!)>%TMP%\_need_crlf
)
if "%Append%" == "1" (
    more %TMP%\_need_crlf>>%TargetFile%
) else (
    more %TMP%\_need_crlf>%TargetFile%
)
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))

::: function WriteScriptFinal()
:WriteScriptFinal
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_genenv.cmd WriteScriptFinal" & set "CTRA=WriteScriptFinal %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_WriteScriptFinal
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_WriteScriptFinal
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_WriteScriptFinal
:pargdone_WriteScriptFinal
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_WriteScriptFinal
powershell -Command "(Get-Content '%SETENV_TARGET%') | ForEach-Object { $_ -replace '\${APPNAME}', '%APPNAME%'.ToUpper() -replace '\${AppNameSmall}', '%APPNAME%' -replace '\${AppCustomName}', '%APPCUSTOMNAME%' -replace '\${AppVersion}', '%APPVER%' -replace '\${CheckExist}', '%CHECK_EXIST%' -replace '\${CheckExec}', '%CHECK_EXEC%' -replace '\${CheckExecArgs}', '%CHECK_EXEC_ARGS%' -replace '\${CheckCmd}', '%CHECK_CMD%' -replace '\${CheckLineword}', '%CHECK_LINEWORD%' -replace '\${CheckOk}', '%CHECK_OK%' -replace '\$', '%%'} | Set-Content '%SETENV_TARGET%'"
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


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
    @if "%OUTTYPE%" == "set-env" @echo.@set PATH=%KEY%;$PATH$>> "%SETENV_TARGET%"
    @if "%OUTTYPE%" == "clear-env" @echo.@set PATH=^!PATH:%KEY%;=^!>> "%SETENV_TARGET%"
) else @(
    @if "%OUTTYPE%" == "set-env" @echo.@set %KEY%=%VALUE%>> "%SETENV_TARGET%"
    @if "%OUTTYPE%" == "clear-env" @echo.@set %KEY%=>> "%SETENV_TARGET%"
    @echo.@set RET_VAR=%%RET_VAR%% %KEY%>> "%SETENV_TARGET%"
)
@goto :eof














:GenEnvInlines


set SetEnvBeginTemplate=@setlocal enabledelayedexpansion^

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

@if ^"%%~1^" == ^"--validate^" @call :Validate^

@if ^"%%~1^" == ^"--before-move^" @call :BeforeMove^

@if ^"%%~1^" == ^"--after-move^" @call :AfterMove^

^

@if defined VALID_ERR (^

    if defined QUIET echo Validate Failed: %%VALID_ERR%%^

    set FAILED=1^

)^

@set ^"FINAL_RET_SCRIPT=if [%%FAILED%%] == [1] cmd /C exit /b 1^"^

@if defined RET_SCRIPT set ^"FINAL_RET_SCRIPT=^^!RET_SCRIPT^^! ^^^^^& ^^!FINAL_RET_SCRIPT^^!^"^

@for %%%%x in (%%RET_VAR%%) do @(^

    call set ^"value=%%%%%%%%x%%%%^"^

    set ^"FINAL_RET_SCRIPT=call set ^^^^^"%%%%x=^^!value^^!^^^^^" ^^^^^& ^^!FINAL_RET_SCRIPT^^!^"^

)^

@endlocal ^& %%FINAL_RET_SCRIPT%%^

@goto :eof^

^

^

:GetInfo^

@set VA_INFO_APPNAME=${AppNameSmall}^

@set VA_INFO_VERSION=${AppVersion}^

@set VA_INFO_CUSTOMNAME=${AppCustomName}^

@if defined QUIET (^

    echo APPNAME=%%VA_INFO_APPNAME%%^

    echo VERSION=%%VA_INFO_VERSION%%^

    echo CUSTOMNAME=%%VA_INFO_CUSTOMNAME%%^

)^

@set RET_VAR=VA_INFO_APPNAME VA_INFO_VERSION VA_INFO_CUSTOMNAME^

@goto :eof

set SetEnvSetTemplate=:SetEnv^

@if not ^"%%VA_${APPNAME}_BASE%%^" == ^"^" @call %%VA_${APPNAME}_BASE%%\set-env.cmd --clear^

@set VA_${APPNAME}_BASE=%%SCRIPT_FOLDER%%^

@set RET_VAR=VA_${APPNAME}_BASE PATH


set SetEnvClearTemplate=:ClearEnv^

@if not ^"%%VA_${APPNAME}_BASE%%^" == ^"%%SCRIPT_FOLDER%%^" @goto :eof^

@set VA_${APPNAME}_BASE=^

@set RET_VAR=VA_${APPNAME}_BASE PATH^




set SetEnvValidateTemplate=:Validate^

@call :GetInfo^

@call :SetEnv^

@set RET_VAR=VALID_ERR^

@set VALID_ERR=


set CHECK_EXIST_TEMPLATE=    @set CHECK_EXIST=${CheckExist}^

    @if not exist ^"%%SCRIPT_FOLDER%%\%%CHECK_EXIST%%^" @(^

        set ^"VALID_ERR=%%SCRIPT_FOLDER%%\%%CHECK_EXIST%% not exist^" ^& goto :eof^

    )

set CHECK_EXEC_TEMPLATE=    @set CHECK_EXEC=${CheckExec}^

    @set CHECK_EXEC_ARGS=${CheckExecArgs}^

    @if not exist ^"%%SCRIPT_FOLDER%%\%%CHECK_EXEC%%^" @(^

        set ^"VALID_ERR=%%SCRIPT_FOLDER%%\%%CHECK_EXEC%% not exist^" ^& goto :eof^

    ) else (^

        ^"%%SCRIPT_FOLDER%%\%%CHECK_EXEC%%^" %%CHECK_EXEC_ARGS%%^

        if errorlevel 1 (set ^"VALID_ERR=%%SCRIPT_FOLDER%%\%%CHECK_EXEC%% execute failed^" ^& goto :eof)^

    )

set CHECK_CMD_TEMPLATE=    @set CHECK_CMD=${CheckCmd}^

    @set CHECK_LINEWORD=${CheckLineword}^

    @set CHECK_OK=${CheckOk}^

    @if not ^"%%CHECK_OK%%^" == ^"^" @(^

        if ^"%%CHECK_LINEWORD%%^" == ^"^" (^

            for /F ^"tokens=* USEBACKQ^" %%%%F in (`cmd /C %%CHECK_CMD%%`) do @set CHECK_STRING=%%%%F^

        ) else (^

            for /F ^"tokens=* USEBACKQ^" %%%%F in (`cmd /C %%CHECK_CMD%% ^^^^^| findstr %%CHECK_LINEWORD%%`) do @set CHECK_STRING=%%%%F^

        )^

        if ^"^^!CHECK_STRING:%%CHECK_OK%%=^^!^" == ^"%%CHECK_STRING%%^" (^

            set ^"VALID_ERR=validate failed not match %%CHECK_STRING%% ^^!= %%CHECK_OK%%^"^

            goto :eof^

        )^

    ) else (^

        cmd /C /D %%CHECK_CMD%%^

        if errorlevel 1 (set ^"VALID_ERR=execute validate command failed^" ^& goto :eof)^

    )



::: inline(SetEnvEndTemplate)
::: endinline

goto :eof


::: function BrickvDownload(Url, Output, Cookie=?, skip_exists=N) delayedexpansion
:BrickvDownload
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_download.cmd BrickvDownload" & set "CTRA=BrickvDownload %CTRA%"
@( set _pos=0 & set _fmin=2)
set Cookie=
set skip_exists=

:parg_BrickvDownload
if defined _require (
    if "!_next!" == "" goto :parg_noarg_err
    if "!_next:~0,1!" == "-" goto :parg_noarg_err
    set _require=
)
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_BrickvDownload
@if "!_head!" == "--cookie" @(set "Cookie=!_next!" & shift & shift & set _require=1 & goto :parg_BrickvDownload)
@if "!_head!" == "--skip-exists" @(set "skip_exists=1" & shift & goto :parg_BrickvDownload)
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "Url=!_head!" & shift & set /a "_pos+=1" & goto :parg_BrickvDownload)
@if %_pos% == 1 @(set "Output=!_head!" & shift & set /a "_pos+=1" & goto :parg_BrickvDownload)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_BrickvDownload
:pargdone_BrickvDownload
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_BrickvDownload
if not "%FORCE%" == "1"  if "%skip_exists%" == "1" set SkipExists=1

set err=
set ErrorFile=%TEMP%\download_error
del %ErrorFile% 2>nul

if "%Url%" == ""  endlocal & (set "EMSG=Url not specific" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
if "%Output%" == ""  endlocal & (set "EMSG=Output not specific" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)

if "%SkipExists%" == "1" if exist "%Output%" (
    call :PrintMsg normal cached %Output%
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
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
if "%err%" == "1"  endlocal & (set "EMSG=download %Url% is failed: %dl_error%" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)

call :PrintMsg info write %Output%

endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))



:gradle_init
	set _RELEASE_URL=https://services.gradle.org/distributions
	set ACCEPT=local global
    goto :eof

:gradle_versions
	call :BrickvDownload "%_RELEASE_URL%" "%VERSION_SOURCE_FILE%"
	if not "%EMSG%" == "" if "%CTRA%" == "" goto :_Error
	if not "%EMSG%" == ""  endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
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
        if not "%EMSG%" == "" if "%CTRA%" == "" goto :_Error
        if not "%EMSG%" == ""  endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
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
    if errorlevel 1  endlocal & (set "EMSG=7z SFX self unpack failed" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)
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

:clink_init
    set _RELEASE_URL=https://api.github.com/repos/mridgers/clink/releases
    set ACCEPT=local global
    set ALLOW_EMPTY_LOCATION=1
    goto :eof

:clink_versions
    set "regex=browser_download_url.*download\/[0-9]*\.[0-9]*\.[0-9]*\/clink_[0-9]*\.[0-9]*\.[0-9]*\.zip"
    FOR /L %%G IN (1,1,2) DO (
        call :BrickvDownload "%_RELEASE_URL%?page=%%G" "%VERSION_SOURCE_FILE%"
        if not "%EMSG%" == "" if "%CTRA%" == "" goto :_Error
        if not "%EMSG%" == ""  endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
        FOR /F "tokens=* USEBACKQ" %%F IN (
                `FINDSTR  /R /C:"%regex%" %VERSION_SOURCE_FILE%`) DO (
            for /F "delims=: tokens=3" %%P in ("%%F") do (
                set TARGET_URL=https:%%P
            )
            for /F "delims=/ tokens=8" %%P in ("!TARGET_URL!") do (
                set TARGET_NAME=%%P
            )
            for /F "delims=_ tokens=2" %%A in ("!TARGET_NAME!") do (
                set CLINK_VER=%%A
            )
            echo.clink=!CLINK_VER![.]$!TARGET_URL:~0,-1!>> "%VERSION_SPCES_FILE%"

        )
    )
    goto :eof

:clink_prepare
	set APPVER=%MATCH_VER%
	if "%REQUEST_NAME%" == "" set REQUEST_NAME=clink-%APPVER%
	set DOWNLOAD_URL=%MATCH_CARRY%
	goto :eof

:clink_unpack
	set SETENV=%SETENV%;$SCRIPT_FOLDER$
	set UNPACK_METHOD=unzip
	goto :eof

:clink_validate
	set CHECK_EXIST=
	set CHECK_CMD=clink_x86
	set CHECK_LINEWORD=Copyright
	set CHECK_OK=Clink v%%VA_INFO_VERSION%%
	goto:eof

:ansicon_init
    set _RELEASE_URL=https://api.github.com/repos/adoxa/ansicon/releases
    set ACCEPT=local global
    set ALLOW_EMPTY_LOCATION=1
    goto :eof

:ansicon_versions
    set "regex=browser_download_url.*download\/v[0-9]*\.[0-9]*\/ansi[0-9]*\.zip"
    FOR /L %%G IN (1,1,2) DO (
        call :BrickvDownload "%_RELEASE_URL%?page=%%G" "%VERSION_SOURCE_FILE%"
        if not "%EMSG%" == "" if "%CTRA%" == "" goto :_Error
        if not "%EMSG%" == ""  endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
        FOR /F "tokens=* USEBACKQ" %%F IN (
                `FINDSTR  /R /C:"%regex%" %VERSION_SOURCE_FILE%`) DO (
            for /F "delims=: tokens=3" %%P in ("%%F") do (
                set TARGET_URL=https:%%P
            )
            for /F "delims=/ tokens=7" %%P in ("!TARGET_URL!") do (
                set TARGET_VER=%%P
            )
            set FOUND_VER=!TARGET_VER:~1!
            echo.ansicon=!FOUND_VER![.]$!TARGET_URL:~0,-1!>> "%VERSION_SPCES_FILE%"

        )
    )
    goto :eof

:ansicon_prepare
	set APPVER=%MATCH_VER%
    if "%REQUEST_ARCH%" == "." set REQUEST_ARCH=x64

	if "%REQUEST_NAME%" == "" set REQUEST_NAME=ansicon-%APPVER%-%REQUEST_ARCH%
	set DOWNLOAD_URL=%MATCH_CARRY%
	goto :eof

:ansicon_unpack
    if "%REQUEST_ARCH%" == "x86" (
	    set SETENV=%SETENV%;$SCRIPT_FOLDER$\x86
    ) else (
        set SETENV=%SETENV%;$SCRIPT_FOLDER$\x64
    )
    md "%TARGETDIR%\%REQUEST_NAME%" 1>nul 2>&1
	call :Unzip "%INSTALLER%" "%TARGETDIR%\%REQUEST_NAME%"
	goto :eof

:ansicon_validate
	set CHECK_EXIST=
	set CHECK_CMD=ansicon.exe --help
	set CHECK_LINEWORD=Freeware
	set CHECK_OK=Version %%VA_INFO_VERSION%%
	goto:eof

:nodejs_init
    set _RELEASE_URL=https://nodejs.org/dist/index.json
    set ACCEPT=local global
    set ALLOW_EMPTY_LOCATION=1
    goto :eof

:nodejs_versions
    call :BrickvDownload "%_RELEASE_URL%" "%VERSION_SOURCE_FILE%"
    if not "%EMSG%" == "" if "%CTRA%" == "" goto :_Error
    if not "%EMSG%" == ""  endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
    FOR /F "tokens=* USEBACKQ" %%F IN (
            `FINDSTR  /R /C:"win-x64-exe" %VERSION_SOURCE_FILE%`) DO (
        for /F "delims=, tokens=1" %%Q in ("%%F") do (
            for /F "delims=: tokens=2" %%R in ("%%Q") do (
                set TARGET_VER==%%R
        ))
        for /F "delims=] tokens=2" %%P in ("%%F") do (
            for /F "delims=, tokens=1" %%Q in ("%%P") do (
                for /F "delims=: tokens=2" %%R in ("%%Q") do (
                    set NPM_VER=%%R
        )))
        set FOUND_VER=!TARGET_VER:~3,-1!
        set FOUND_NPM_VER=!NPM_VER:~1,-1!
        echo !FOUND_VER!--!FOUND_NPM_VER!
        echo.nodejs=!FOUND_VER!@x64[.]$!FOUND_NPM_VER!>> "%VERSION_SPCES_FILE%"
        echo.nodejs=!FOUND_VER!@x86[.]$!FOUND_NPM_VER!>> "%VERSION_SPCES_FILE%"

    )

    goto :eof

:nodejs_prepare
	set APPVER=%MATCH_VER%
    if "%REQUEST_NAME%" == "" set REQUEST_NAME=node-%APPVER%-%MATCH_ARCH%
    set NPM_VER=%MATCH_CARRY%
	set NPM_URL=https://github.com/npm/npm/archive/v%NPM_VER%.zip
    set NPM_INSTALLER=%TEMP%\npm-%NPM_VER%.zip
    call :BrickvDownload "%NPM_URL%" "%NPM_INSTALLER%" --skip-exists
    set DOWNLOAD_URL=https://nodejs.org/dist/v%MATCH_VER%/win-%MATCH_ARCH%/node.exe
	goto :eof

:nodejs_unpack
    set SETENV=%SETENV%;$SCRIPT_FOLDER$
    set SETENV=%SETENV%;$PRJ_ROOT$\node_modules\.bin
    set _INSTALL_DIR=%TARGETDIR%\%REQUEST_NAME%
    md "%_INSTALL_DIR%" 1>nul 2>&1
    md "%_INSTALL_DIR%\node_modules" 1>nul 2>&1
    call :Unzip "%NPM_INSTALLER%" "%_INSTALL_DIR%\node_modules"
    move "%INSTALLER%" "%_INSTALL_DIR%\node.exe" 1>nul 2>&1

    move "%_INSTALL_DIR%\node_modules\npm-%NPM_VER%" "%_INSTALL_DIR%\node_modules\npm"
    xcopy "%_INSTALL_DIR%\node_modules\npm\bin\npm" "%_INSTALL_DIR%\npm*" /K /Y
    xcopy "%_INSTALL_DIR%\node_modules\npm\bin\npm.cmd" "%_INSTALL_DIR%\npm.cmd*" /K /Y

	goto :eof

:ansicon_validate
	set CHECK_EXIST=
	set CHECK_CMD=npm --version
	set CHECK_LINEWORD=node
	set CHECK_OK=node: '%%VA_INFO_VERSION%%'
	goto:eof

:python_init
    set _RELEASE_URL=https://www.python.org/ftp/python/
    set ACCEPT=global
    set ALLOW_EMPTY_LOCATION=1
    goto :eof



:python_versions
    set "regex=[0-9]*\.[0-9]*\.[0-9]*\/"
    echo %VERSION_SOURCE_FILE%
    call :BrickvDownload "%_RELEASE_URL%" "%VERSION_SOURCE_FILE%"
    if not "%EMSG%" == "" if "%CTRA%" == "" goto :_Error
    if not "%EMSG%" == ""  endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
    FOR /F "tokens=* USEBACKQ" %%F IN (
            `FINDSTR  /R /C:"%regex%" %VERSION_SOURCE_FILE%`) DO (
        for /F delims^=^"^ tokens^=2 %%P in ("%%F") do (
            set TARGET_VER=%%P
        )
        for /F "delims=. tokens=1,2,3" %%P in ("!TARGET_VER:~0,-1!") do (
            set TARGET_MAJOR=%%P
            set TARGET_MINOR=%%Q
            set TARGET_PACTH=%%R
        )

        set skip=
        if !TARGET_MAJOR! EQU 2 if !TARGET_MINOR! LSS 4 set skip=1

        if "!skip!" == "" (
            call :BrickvDownload "%_RELEASE_URL%!TARGET_VER!" "%VERSION_SOURCE_FILE2%"
            if not "%EMSG%" == "" if "%CTRA%" == "" goto :_Error
            if not "%EMSG%" == ""  endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
            set FOUND_VER=!TARGET_MAJOR!.!TARGET_MINOR!.!TARGET_PACTH!
            set WIN86=
            set WIN64=
            FOR /F "tokens=* USEBACKQ" %%G IN (
                    `FINDSTR  /R /C:"\python-!FOUND_VER!\.msi" %VERSION_SOURCE_FILE2%`) DO (
                    set WIN86=.msi
            )
                    FOR /F "tokens=* USEBACKQ" %%G IN (
                    `FINDSTR  /R /C:"\python-!FOUND_VER!\-webinstall\.exe" %VERSION_SOURCE_FILE2%`) DO (
                    set WIN86=-webinstall.exe
            )
            FOR /F "tokens=* USEBACKQ" %%G IN (
                    `FINDSTR  /R /C:"python-!FOUND_VER!\.ia64\.msi" %VERSION_SOURCE_FILE2%`) DO (
                    set WIN64=.ia64.msi
            )
            FOR /F "tokens=* USEBACKQ" %%G IN (
                    `FINDSTR  /R /C:"python-!FOUND_VER!\.amd64\.msi" %VERSION_SOURCE_FILE2%`) DO (
                    set WIN64=.amd64.msi
            )
            FOR /F "tokens=* USEBACKQ" %%G IN (
                    `FINDSTR  /R /C:"python-!FOUND_VER!\-amd64\-webinstall\.exe" %VERSION_SOURCE_FILE2%`) DO (
                    set WIN64=-amd64-webinstall.exe
            )


            set WIN86_URL=%_RELEASE_URL%!FOUND_VER!/python-!FOUND_VER!!WIN86!
            set WIN64_URL=%_RELEASE_URL%!FOUND_VER!/python-!FOUND_VER!!WIN64!
            if not "!WIN86!" == "" echo.python=!FOUND_VER!@x86[.]$!WIN86_URL!>> "%VERSION_SPCES_FILE%"
            if not "!WIN64!" == "" echo.python=!FOUND_VER!@x64[.]$!WIN64_URL!>> "%VERSION_SPCES_FILE%"
        )
    )

    goto :eof

:python_prepare
    set APPVER=%MATCH_VER%
    if "%REQUEST_NAME%" == "" set REQUEST_NAME=python-%APPVER%-%MATCH_ARCH%
    set DOWNLOAD_URL=%MATCH_CARRY%
    goto :eof

:python_unpack
    set SETENV=%SETENV%;$SCRIPT_FOLDER$
    set SETENV=%SETENV%;$SCRIPT_FOLDER$\Scripts

    if "%DOWNLOAD_URL:~-4%" == ".msi" (
        set UNPACK_METHOD=msi-unpack
    ) else (
        set LAYOUT=%TEMP%\python-%APPVER%-%MATCH_ARCH%-msi-layout
        echo call "%INSTALLER%" /quiet /layout "!LAYOUT!"
        call "%INSTALLER%" /quiet /layout "!LAYOUT!"
        FOR %%F IN (!LAYOUT!\*.msi) DO @(
            set MSI_FILE=%%F
            for /F %%I in ("!MSI_FILE!") do set MSI_NAME=%%~nxI
            set Break=
            if "!MSI_NAME:~-6!" == "_d.msi" set Break=1
            if "!MSI_NAME:~-8!" == "_pdb.msi" set Break=1
            if "!MSI_NAME!" == "launcher.msi" set Break=1
            if "!MSI_NAME!" == "path.msi" set Break=1
            if "!MSI_NAME!" == "pip.msi" set Break=1
            if not "!Break!" == "1" (
                echo !MSI_FILE!, !MSI_NAME!
                msiexec /a "!MSI_FILE!" /qb TARGETDIR=%TARGET%
                del %TARGET%\!MSI_NAME!
            )
        )
    )
    set GETPIP_URL=https://bootstrap.pypa.io/get-pip.py
    call :BrickvDownload "%GETPIP_URL%" "%TEMP%\get-pip.py"
    if not "%EMSG%" == "" if "%CTRA%" == "" goto :_Error
    if not "%EMSG%" == ""  endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
    call "%TARGET%\python.exe" "%TEMP%\get-pip.py"
    call "%TARGET%\Scripts\pip.exe" install virtualenv
    goto :eof

:python_validate
    set CHECK_EXIST=
    set CHECK_CMD=python --version
    set CHECK_LINEWORD=Python
    set CHECK_OK=Python %%VA_INFO_VERSION%%
    goto:eof

:choco_init
    set _RELEASE_URL=https://api.github.com/repos/adoxa/ansicon/releases
    set ACCEPT=local global
    set ALLOW_EMPTY_LOCATION=1
    goto :eof

:choco_versions
    echo.choco=x[.]>> "%VERSION_SPCES_FILE%"

:choco_prepare
	if "%REQUEST_NAME%" == "" set REQUEST_NAME=choco
	set DOWNLOAD_URL=https://chocolatey.org/install.ps1
	goto :eof

:choco_unpack

    set SETENV=%SETENV%;$SCRIPT_FOLDER$\bin
    set ChocolateyInstall=%TARGET%
    setx ChocolateyInstall %TARGET%

    set POWERSH=%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe
    set PSEXEC="%POWERSH%" -NoProfile -ExecutionPolicy Bypass -Command
    :: run installer
    %PSEXEC% "& '%INSTALLER%' %*"

    :: delete user environment that choco-install created
    REG delete HKCU\Environment /F /V ChocolateyInstall
    REG delete HKCU\Environment /F /V ChocolateyLastPathUpdate
    set REG_PATH=
    for /f "tokens=2,* USEBACKQ" %%A in (`reg query HKCU\Environment /v PATH ^| findstr PATH`) do (
        set REG_PATH=%%B
    )
    :: delete user path that choco-install added
    if not "%REG_PATH%" == "" (
        call set ORIGIN_PATH=%%REG_PATH:%TARGET%\bin;=%%
        setx PATH !ORIGIN_PATH!
    )

    :: determine what APPVER is
    :: or use <version>0.10.5</version> in lib\chocolatey\chocolatey.nupkg\chocolatey.nuspec
    for /f "delims=v tokens=2 USEBACKQ" %%A in (`"%TARGET%\bin\choco" ^| findstr Chocolate`) do (
        set APPVER=%%A
    )
    goto :eof

:choco_validate
	set CHECK_EXIST=choco.exe
	set CHECK_CMD=
	set CHECK_LINEWORD=
	set CHECK_OK=
	goto:eof



::: function brickv_CMD_list(spec=, args=....) delayedexpansion
:brickv_CMD_list
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_CMD_list.cmd brickv_CMD_list" & set "CTRA=brickv_CMD_list %CTRA%"
set spec=
@( set _pos=0 & set _fmin=0)
set args=

:parg_brickv_CMD_list
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_brickv_CMD_list
@if %_pos% == 0 @(set "spec=!_head!" & shift & set /a "_pos+=1" & goto :parg_brickv_CMD_list)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_brickv_CMD_list
:pargdone_brickv_CMD_list
set "args=!_rest!"
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_brickv_CMD_list
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

endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))

::: function brickv_CMD_versions(spec, args=....) delayedexpansion
:brickv_CMD_versions
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_CMD_list.cmd brickv_CMD_versions" & set "CTRA=brickv_CMD_versions %CTRA%"
@( set _pos=0 & set _fmin=1)
set args=

:parg_brickv_CMD_versions
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_brickv_CMD_versions
@if %_pos% == 0 @(set "spec=!_head!" & shift & set /a "_pos+=1" & goto :parg_brickv_CMD_versions)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_brickv_CMD_versions
:pargdone_brickv_CMD_versions
@if %_pos% LSS %_fmin% goto :parg_posunder_err
set "args=!_rest!"
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_brickv_CMD_versions
call :brickv_CMD_install %spec% --only-versions %args%
FOR /F "delims=$ tokens=1 USEBACKQ" %%F IN ("%VERSION_SPCES_FILE%") do (
    echo %%F
)
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))

::: function brickv_CMD_Update(specs, no_switch=N, no_install=N, args=....) delayedexpansion
:brickv_CMD_Update
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_CMD_list.cmd brickv_CMD_Update" & set "CTRA=brickv_CMD_Update %CTRA%"
@( set _pos=0 & set _fmin=1)
set no_switch=
set no_install=
set args=

:parg_brickv_CMD_Update
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_brickv_CMD_Update
@if "!_head!" == "--no-switch" @(set "no_switch=1" & shift & goto :parg_brickv_CMD_Update)
@if "!_head!" == "--no-install" @(set "no_install=1" & shift & goto :parg_brickv_CMD_Update)
@if %_pos% == 0 @(set "specs=!_head!" & shift & set /a "_pos+=1" & goto :parg_brickv_CMD_Update)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_brickv_CMD_Update
:pargdone_brickv_CMD_Update
@if %_pos% LSS %_fmin% goto :parg_posunder_err
set "args=!_rest!"
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_brickv_CMD_Update

set Installs=
set Switches=
set Faileds=

set NotFounds=
set targets=%specs: =#%

call :BrickvPrepare "=x" %args%
if not "%EMSG%" == "" if "%CTRA%" == "" goto :_Error
if not "%EMSG%" == ""  endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
call :ImportColor
set VERSION_SPCES_FILE=%TEMP%\spces-list.ver.txt
set MATCH_SPCES_FILE=%TEMP%\spces-match.ver.txt
call :DiscoverApp

:brickv_CMD_Update_switch_loop
for /F "delims=# tokens=1*" %%A IN ("%targets%") do (
    call :brickv_CMD_Update_switch "%%~A"
    set targets=%%B
)
if not "%targets%" == "" goto :brickv_CMD_Update_switch_loop
if "%no_install%" == "1" (
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
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
endlocal & (if "%EMSG%" == "" (
set "FailedsString=%FailedsString%"
goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


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
call :brickv_CMD_install "%~1" %args%
if not "%ERROR_MSG%" == "" (
    call :PrintMsg error error %ERROR_MSG%
    if "%Faileds%" == "" (set Faileds=%~1) else (set Faileds=%Faileds%#%~1)
) else (
    if "%Installs%" == "" (set Installs=%REQUEST_NAME%) else (set Installs=%Installs%#%REQUEST_NAME%)
)

goto :eof
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))

::: function brickv_CMD_switch(spec, internal=N, args=....) delayedexpansion
:brickv_CMD_switch
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_CMD_list.cmd brickv_CMD_switch" & set "CTRA=brickv_CMD_switch %CTRA%"
@( set _pos=0 & set _fmin=1)
set internal=
set args=

:parg_brickv_CMD_switch
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_brickv_CMD_switch
@if "!_head!" == "--internal" @(set "internal=1" & shift & goto :parg_brickv_CMD_switch)
@if %_pos% == 0 @(set "spec=!_head!" & shift & set /a "_pos+=1" & goto :parg_brickv_CMD_switch)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_brickv_CMD_switch
:pargdone_brickv_CMD_switch
@if %_pos% LSS %_fmin% goto :parg_posunder_err
set "args=!_rest!"
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_brickv_CMD_switch
call :BrickvPrepare "%spec%" %args%
set args=
set AppPath=
if "%internal%" == "0" (
    call :ImportColor
    set VERSION_SPCES_FILE=%TEMP%\spces-list.ver.txt
    set MATCH_SPCES_FILE=%TEMP%\spces-match.ver.txt
    call :DiscoverApp
)
copy /y NUL "%MATCH_SPCES_FILE%" >NUL
call :MatchVersion --output-format cmd --all --spec-match "%REQUEST_SPEC%"                   --specs-file "%VERSION_SPCES_FILE%" --output "%MATCH_SPCES_FILE%"
call :IterMatchVersion "" 1
set "SWITCH_NAME=%MATCH_APP%=%AppInfoVersion%"
set SwitchSuccess=0

if not "%AppPath%" == "" (
    echo.@call "%AppPath%\set-env.cmd" --set>> "%POST_SCIRPT%"
    call :PrintMsg normal switch enable "%BW%!MATCH_APP!%NN%=!AppInfoVersion!" at %AppPath%
    set SwitchSuccess=1
) else (
    if not "%internal%" == "1" echo.@set "POST_ERRORLEVEL=1">> "%POST_SCIRPT%"
)
if "%internal%" == "1" (
endlocal & (if "%EMSG%" == "" (
set "SwitchSuccess=%SwitchSuccess%"
set "AppPath=%AppPath%"
set "SWITCH_NAME=%SWITCH_NAME%"
goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
)
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


::: function DiscoverApp()
:DiscoverApp
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_CMD_list.cmd DiscoverApp" & set "CTRA=DiscoverApp %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_DiscoverApp
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_DiscoverApp
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_DiscoverApp
:pargdone_DiscoverApp
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_DiscoverApp
copy /y NUL "%VERSION_SPCES_FILE%" >NUL
copy /y NUL "%MATCH_SPCES_FILE%" >NUL
for /D %%i in (%BRICKV_GLOBAL_DIR%\*) do if exist "%%i\set-env.cmd" (
    call :RecordApp "%%i" global --spec-file "%VERSION_SPCES_FILE%"
)
for /D %%i in (%BRICKV_LOCAL_DIR%\*) do if exist "%%i\set-env.cmd" (
    call :RecordApp "%%i" local --spec-file "%VERSION_SPCES_FILE%"
)
call :MatchVersion --output-format cmd --all --spec-match "%REQUEST_SPEC%"                   --specs-file "%VERSION_SPCES_FILE%" --output "%MATCH_SPCES_FILE%"
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


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
:RecordApp
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=brickv_CMD_list.cmd RecordApp" & set "CTRA=RecordApp %CTRA%"
@( set _pos=0 & set _fmin=2)
set Spec_File=

:parg_RecordApp
if defined _require (
    if "!_next!" == "" goto :parg_noarg_err
    if "!_next:~0,1!" == "-" goto :parg_noarg_err
    set _require=
)
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_RecordApp
@if "!_head!" == "--spec-file" @(set "Spec_File=!_next!" & shift & shift & set _require=1 & goto :parg_RecordApp)
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if %_pos% == 0 @(set "TARGET=!_head!" & shift & set /a "_pos+=1" & goto :parg_RecordApp)
@if %_pos% == 1 @(set "Location=!_head!" & shift & set /a "_pos+=1" & goto :parg_RecordApp)
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_RecordApp
:pargdone_RecordApp
@if %_pos% LSS %_fmin% goto :parg_posunder_err
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_RecordApp
for /f %%i in ("%TARGET%") do set Filename=%%~nxi
if "%Filename:~0,10%" == "backupfor-" (
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
)
if "%Filename:~0,7%" == "failed-" (
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))
)
call "%TARGET%\set-env.cmd" --info
call set _VA_BASE=%%VA_%VA_INFO_APPNAME%_BASE%%
set Activate=0
if "%_VA_BASE%" == "%TARGET%" set Activate=1
if not "%Spec_File%" == "" echo.%VA_INFO_APPNAME%=%VA_INFO_VERSION%                                    $%Activate%,%Location%,%TARGET%,%VA_INFO_VERSION%>> "%Spec_File%"
endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))






::: function CMD_exec()
:CMD_exec
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=dev-sh.cmd CMD_exec" & set "CTRA=CMD_exec %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_CMD_exec
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_CMD_exec
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_CMD_exec
:pargdone_CMD_exec
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_CMD_exec

endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))


::: function CMD_help()
:CMD_help
@setlocal enableextensions enabledelayedexpansion
@echo off
@set "EMSG=" & set "ESRC=" & set "ETRA="
@set "CSRC=dev-sh.cmd CMD_help" & set "CTRA=CMD_help %CTRA%"
@( set _pos=0 & set _fmin=0)

:parg_CMD_help
set _head=%~1
set _next=%~2
@if not defined _head goto :pargdone_CMD_help
@if "!_head:~0,1!" == "-" goto :parg_optover_err
@if defined _rest @(    set _rest=!_rest! %1) else (    set _rest=%1)
@shift
@goto :parg_CMD_help
:pargdone_CMD_help
@if defined _rest goto :parg_posover_err
@( set "_head=" & set "_next=" & set "_require=" & set "_pos=" & set "_fmin=" & set "_rest=")
:Main_CMD_help

echo.  dev clear      for backup or clean re-install
echo.  dev update     update development environment
echo.  dev setup      configure git for first using
echo.  dev sync       keep project sync through git

endlocal & (if "%EMSG%" == "" (goto :eof) else (set "EMSG=%EMSG%" & set "ESRC=%ESRC%" & set "ETRA=%ETRA%" & goto :eof))










:parg_noarg_err
endlocal & (set "EMSG=option requires an argument -- %_head%" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)

:parg_posunder_err
endlocal & (set "EMSG=takes %_fmin% positional arguments but %_pos% were given" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)

:parg_posover_err
endlocal & (set "EMSG=too many positional arguments -- %_rest%" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)

:parg_optover_err
endlocal & (set "EMSG=unrecognized option -- %_head%" & set "ESRC=%CSRC%" & set "ETRA=%CTRA%" & goto :eof)



:_ProtectError
@goto :eof

:_Error
@echo ERROR: %EMSG%^

    at %ESRC%^

    stacktrace: %ETRA% 1>&2
@set "EMSG=" & set "ESRC=" & set "ETRA="
@cmd /s /c exit /b 1
@goto :eof


