
rem SCRIPT_SOURCE
rem SCRIPT_FOLDER

@call :Main %*
@if not "%SetEnvFile%" == "" @call "%SetEnvFile%" --set
@set SetEnvFile=
@goto :eof


::: function Main(cmd=shell,
                  args=...)
@set _devcmd=%cmd%
@set _devargs=%args%
@set cmd=
@set args=
@call :ExcuteCommand
return %SetEnvFile%
::: endfunc

#include("spilt-string.cmd")
#include("parseini.cmd")
#include("project-paths.cmd")

::: inline(VAR)
::: endinline

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


:ActiveDevShell
rem switch to dev-sh environment, if not in dev-sh
if not "%DEVSH_ACTIVATE%" == "" goto :eof

call :BasicCheck
call :LoadConfigPaths
call :GetTitle !PRJ_ROOT!

rem add PRJ_BIN, PRJ_TOOLS to path
set PATH=!PRJ_BIN!;!PRJ_TOOLS!;!PATH!

rem add paths from config[path]
call :GetIniArray %DEVONE_CONFIG_PATH% "path"
set PATH=!inival!;!PATH!

if "%HOME%" == "" set HOME=PRJ_ROOT/.home
set PROMPT=$C!TITLE!$F$S$P$G

rem prepare temporary command stub folder
rmdir /S /Q !PRJ_TMP!\command
md !PRJ_TMP!\command
set PATH=!PRJ_TMP!\command;!PATH!

rem set-env
rem TODO: 注意相對路徑之間的問題
set inival=
call :GetIniArray %DEVONE_CONFIG_PATH% "dotfiles"
(set Text=!inival!)&(set LoopCb=:call_dotfile)&(set ExitCb=:exit_call_dotfile)&(set Spliter=;)
goto :SubString
:call_dotfile
    if exist "!substring!.cmd" call call "!substring!.cmd"
    goto :NextSubString
:exit_call_dotfile
set inival=

if exist "%PRJ_CONF%\hooks\set-env.cmd" (
    call "%PRJ_CONF%\hooks\set-env.cmd"
)


rem create temporary command stub
call :GetIniPairs %DEVONE_CONFIG_PATH% "alias"
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
set alias=
set alias_cmd=
set inival=

echo.@"%SCRIPT_SOURCE%" --cmd %%* > %PRJ_TMP%\command\dev.cmd


set GitShellScript=#^^!/usr/bin/env bash^

"C:\\Program Files (x86)\\Git\\bin\\sh.exe" --login -i

echo.!GitShellScript! > %PRJ_TMP%\command\git-shell

#include(GitHooksScript, "git-hooks")
echo.!GitHooksScript! > %PRJ_TMP%\command\git-hooks

set DEVSH_ACTIVATE=1
goto :eof




::: function ExcuteCommand() delayedexpansion
    :: 如果還沒進入shell則先進入臨時性的shell
    call :ActiveDevShell
    call :CMD_%_devcmd% %_devargs%
    return %SetEnvFile%
::: endfunc

rem ::: function ExcuteBrickvCommand() delayedexpansion
rem     :: 如果還沒進入shell則先進入臨時性的shell
rem     call :ActiveDevShell
rem     call :brickv_CMD_%_devcmd% %_devargs%
rem ::: endfunc

::: function CMD_brickv(brickv_cmd, brickv_args=...)
    call :ActiveDevShell
    call :brickv_CMD_%brickv_cmd% %brickv_args%
    return %SetEnvFile%
::: endfunc

::: function CMD_shell(no_window=N, no_welcom=N, args=...) delayedexpansion
    rem create new shell window
    set CMDSCRIPT=
    set CMDSCRIPT=!CMDSCRIPT!(set cmd_args=)^&(set cmd_executable=)^&(set command=)^&(set CMDSCRIPT=)^&

    rem create welcome text
    if "%no_welcom%" == "1" goto :no_welcome_text
    set welcome1=Devone v1.0.0 [project !TITLE!]
    set CMDSCRIPT=!CMDSCRIPT!(echo.!welcome1!)^&
    set welcome1=
    call :GetIniValue %DEVONE_CONFIG_PATH% "help" "*"
    if not "!inival!" == "" set CMDSCRIPT=!CMDSCRIPT!(echo.!inival!)^&
    set inival=
    :no_welcome_text

    rem force setup for newly cloned project
    rem set CMDSCRIPT=!CMDSCRIPT!(dev setup)^&

    rem ansicon feature
    where ansicon.exe 2> nul
    if not errorlevel 1 (
        set cmd_executable=ansicon.exe %ComSpec%
    ) else (
        set cmd_executable=%ComSpec%
    )

    rem clink feature
    where clink.bat 2> nul
    if not errorlevel 1 (
        set CMDSCRIPT=!CMDSCRIPT!clink.bat inject
    )

    set cmd_args=/K "!CMDSCRIPT!"
    pushd %PRJ_ROOT%
    echo on
    @if "%no_window%" == "1" @(
        @%cmd_executable% %cmd_args%
    ) else @(
        @start "[%TITLE%]" %cmd_executable% %cmd_args%
    )
    @echo off
    popd
::: endfunc

#include("CMD_setup.cmd")
#include("CMD_sync.cmd")
#include("CMD_update.cmd")
#include("CMD_clear.cmd")

#include("brickv_CMD_install.cmd")
#include("brickv_CMD_list.cmd")

::: function CMD_exec()

::: endfunc


::: function CMD_help()

echo.  dev clear      for backup or clean re-install
echo.  dev update     update development environment
echo.  dev setup      configure git for first using
echo.  dev sync       keep project sync through git

::: endfunc









