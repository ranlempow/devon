
@set _devsh=%~f0

::: function Main(cmd=shell, args=...)
@set _devcmd=%cmd%
@set _devargs=%args%
@set cmd=
@set args=
@call :ExcuteCommand
rem @set _devsh=
::: endfunc

#include("spilt-string.cmd")
#include("parseini.cmd")
#include("project-paths.cmd")


::: function BasicCheck()
    if not "%~d0" == "C:" (
        rem python venv 必須被安裝在C槽, 否則他不執行
        error("folder must in C:")
    )
    rem 確定資料夾是否含有非英文路徑
    echo %~dp0| findstr /R /C:"^[a-zA-Z0-9~.\\:_-]*$">nul 2>&1
    if errorlevel 1 (
        error("folder path contains illegal characters")
    )
::: endfunc


::: function ExcuteCommand() delayedexpansion
    :: 如果還沒進入shell則先進入臨時性的shell
    call :ActiveDevShell
    call :CMD_%_devcmd% %_devargs%

    rem if "%DEVSH_ACTIVATE%" == "" (
    rem     call :CMD_shell %_devcmd% %_devargs%
    rem ) else (
    rem     call :CMD_%_devcmd% %_devargs%
    rem )

::: endfunc



::: inline(VAR)
::: endinline



:ActiveDevShell
rem switch to dev-sh environment, if not in dev-sh
if not "%DEVSH_ACTIVATE%" == "" goto :eof

call :BasicCheck
call :LoadConfigPaths
call :GetTitle !PRJ_ROOT!

rem add PRJ_BIN, PRJ_TOOLS to path
set PATH=!PRJ_BIN!;!PRJ_TOOLS!;!PATH!

rem add paths from config[path]
call :GetIniArray DEVONE_CONFIG_PATH "path"
set PATH=!inival!;!PATH!

set PROMPT=$C!TITLE!$F$S$P$G

rem prepare temporary command stub folder
rmdir /S /Q !PRJ_TMP!\command
md !PRJ_TMP!\command
set PATH=!PRJ_TMP!\command;!PATH!

rem set-env
rem TODO: 注意相對路徑之間的問題
set inival=
call :GetIniArray DEVONE_CONFIG_PATH "dotfiles"
(set Text=!inival!)&(set LoopCb=:call_dotfile)&(set ExitCb=:exit_call_dotfile)&(set Spliter=;)
goto :SubString
:call_dotfile
    if exist !substring!.cmd call call !substring!.cmd
    goto :NextSubString
:exit_call_dotfile
set inival=

if exist %PRJ_CONF%\hooks\set-env.cmd (
    call %PRJ_CONF%\hooks\set-env.cmd
)


rem create temporary command stub
call :GetIniArray DEVONE_CONFIG_PATH "alias"
(set Text=!inival!)&(set LoopCb=:create_alias_file)&(set ExitCb=:exit_create_alias_file)&(set Spliter=;)
goto :SubString
:create_alias_file
    for /f "tokens=1,2 delims==" %%a in ("!substring!") do (
        set alias=%%a
        set alias_cmd=%%b
    )
    echo.@%alias_cmd% > %PRJ_TMP%\command\%alias%.cmd
    goto :NextSubString
:exit_create_alias_file
set alias=
set alias_cmd=
set inival=

echo.@"%_devsh%" --cmd %%* > %PRJ_TMP%\command\dev.cmd

set DEVSH_ACTIVATE=1
goto :eof


::: function CMD_shell(cmd=, no_window=N, args=...) delayedexpansion

    rem create new shell window
    set CMDSCRIPT=

    rem create welcome text
    if not "%cmd%" == "" goto :no_welcome_text
    set welcome1=Devone v1.0.0 [project !TITLE!]
    set CMDSCRIPT=!CMDSCRIPT!(echo !welcome1!)^&
    set welcome1=
    call :GetIniValue DEVONE_CONFIG_PATH "help" "*"
    if not "!inival!" == "" set CMDSCRIPT=!CMDSCRIPT!(echo !inival!)^&
    set inival=
    :no_welcome_text

    set CMDSCRIPT=!CMDSCRIPT!(set cmd_args=)^&(set cmd_executable=)^&(set cmd=)^&(set command=)^&(set CMDSCRIPT=)^&

    where ansicon.exe 2> nul
    if %errorlevel% == 0 (
        set cmd_executable=ansicon.exe %ComSpec%
    ) else (
        set cmd_executable=%ComSpec%
    )

    if "%cmd%" == "" (
        set cmd_args=/K "!CMDSCRIPT!"
    ) else (
        set CMDSCRIPT=!CMDSCRIPT!"%_devsh%" --cmd %cmd%
        set cmd_args=/C "!CMDSCRIPT!"
    )
    pushd %PRJ_ROOT%

    rem TODO: no_window
    if "%no_window%" == "1" (
        %cmd_executable% %cmd_args%
    ) else (
        echo on
        @start "[%TITLE%]" %cmd_executable% %cmd_args%
        @echo off
    )
    popd
::: endfunc


::: function CMD_exec()
::: endfunc



::: function CMD_update()

if exist %PRJ_CONF%\hooks\update.cmd (
    call %PRJ_CONF%\hooks\update.cmd
)
::: endfunc

::: function CMD_clear()

if exist %PRJ_CONF%\hooks\clear.cmd (
    call %PRJ_CONF%\hooks\clear.cmd
)
::: endfunc

::: function CMD_sync()
::: endfunc

::: function CMD_setup()
::: endfunc


::: function CMD_help()
::: endfunc









