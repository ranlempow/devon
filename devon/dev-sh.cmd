
@rem SCRIPT_FOLDER
@rem SCRIPT_SOURCE

@rem protective execute
@rem if the execution is interrupted or exited, it run POST_SCIRPT to clean up
@rem POST_SCIRPT is also use to return variable to environment
@if not "%~1" == "_start_" (
    set POST_SCIRPT=%TEMP%\devon_post_script-%RANDOM%.cmd
    set POST_ERRORLEVEL=0
)
@if not "%~1" == "_start_" (
    echo.>"%POST_SCIRPT%"
    cmd /c "%~f0" _start_ %*
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
    cmd /c exit /b %POST_ERRORLEVEL%
    goto :eof
)

@call :Main %*
@goto :eof


::: function Main(_start_, cmd=shell,
                  args=...) delayedexpansion
set _devcmd=%cmd%
set _devargs=%args%
set _start_=
set cmd=
set args=
set DEVON_VERSION=1.0.0

rem 如果還沒進入shell則先進入臨時性的shell
call :ActiveDevShell
call :CMD_%_devcmd% %_devargs%
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


:ActiveDevShell
rem switch to dev-sh environment, if not in dev-sh
if "%DEVSH_ACTIVATE%" == "%SCRIPT_SOURCE%" goto :eof

call :BasicCheck
call :LoadConfigPaths
call :GetTitle %PRJ_ROOT%

rem start set PATH
set PATH=C:\__dev_setpath;%PATH%

rem add PRJ_BIN, PRJ_TOOLS to path
if exist "%PRJ_BIN%" set PATH=%PRJ_BIN%;%PATH%
if exist "%PRJ_TOOLS%" set PATH=%PRJ_TOOLS%;%PATH%
if exist "%PRJ_CONF%" set PATH=%PRJ_CONF%;%PATH%

rem add paths from config[path]
call :GetIniArray %DEVON_CONFIG_PATH% "path"
call set inival=%inival%
set PATH=%inival%;%PATH%


rem prepare temporary command stub folder
rmdir /S /Q %PRJ_TMP%\command
md %PRJ_TMP%\command
set PATH=%PRJ_TMP%\command;%PATH%

rem set-env
rem TODO: 注意相對路徑之間的問題
set inival=
call :GetIniArray %DEVON_CONFIG_PATH% "dotfiles"
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

rem end set PATH
set PATH=C:\__dev_endpath;%PATH%

call :GenerateCommandStubs

set DEVSH_ACTIVATE=%SCRIPT_SOURCE%
goto :eof


::: function CMD_brickv(brickv_cmd, brickv_args=...)
    call :brickv_CMD_%brickv_cmd% %brickv_args%
::: endfunc

::: function CMD_welcome()
    if not "%ANSICON%" == "" call :ImportColor
    echo %BW%Devone%NN% v%DEVON_VERSION% [project %DC%%TITLE%%NN%]
    call :GetIniValue %DEVON_CONFIG_PATH% "help" "*"
    if not "%inival%" == "" call echo %inival%
    echo.@set PROMPT=$C%DC%!TITLE!%NN%$F$S$P$G > "%POST_SCIRPT%"
::: endfunc

::: function CMD_version()
    echo v%DEVON_VERSION%
::: endfunc


::: function GenerateCommandStubs()
    rem create temporary command stub
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


    #include(GitHooksScript, "git-hooks")
    echo.!GitHooksScript! > %PRJ_TMP%\command\git-hooks

    #include(SSHScript, "ssh")
    echo.!SSHScript! > %PRJ_TMP%\command\ssh
    echo.!SSHScript! > %PRJ_TMP%\command\scp

    #include(GitBashScript, "bash.cmd")
    echo.!GitBashScript! > %PRJ_TMP%\command\bash.cmd
    echo.!GitBashScript! > %PRJ_TMP%\command\git-bash.cmd
    rem echo.@bash -c ssh %* > %PRJ_TMP%\command\ssh.cmd
    rem echo.@bash -c scp %* > %PRJ_TMP%\command\scp.cmd

    #include(BashProfileScript, "bash_profile")
    echo.!BashProfileScript! > %HOMEPATH%\.bashrc

::: endfunc

::: function CMD_shell(no_window=N, no_welcom=N) delayedexpansion
    rem create new shell window
    set CMDSCRIPT=
    set CMDSCRIPT=!CMDSCRIPT!^\n^
        (set no_window=)^&^\n^
        (set no_welcom=)^&^\n^
        (set CMDSCRIPT=)^&^\n^
        (set CALL_STACK=)^&^\n^
        (set SCRIPT_FOLDER=)^&^\n^
        (set SCRIPT_SOURCE=)^&^\n^
        (set DEVON_VERSION=)^&^\n^
        (set _devcmd=)^&^\n^
        (set _devargs=)^&

    rem force setup for newly cloned project
    rem set CMDSCRIPT=!CMDSCRIPT!(dev setup)^&

    rem ansicon feature
    where ansicon.exe 2>&1 1>nul
    if not errorlevel 1 (
        set "CMDSCRIPT=!CMDSCRIPT!(ansicon.exe -p)^&"
    )

    rem clink feature
    where clink.bat 2>&1 1>nul
    if not errorlevel 1 (
        set "CMDSCRIPT=!CMDSCRIPT!(clink.bat inject)^&"
    )

    rem show welcome text and change prompt
    if not "%no_welcom%" == "1" (
        set "CMDSCRIPT=!CMDSCRIPT!(dev welcome)^&"
    )
    rem finish cmd script
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









