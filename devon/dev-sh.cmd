
@rem SCRIPT_FOLDER
@rem SCRIPT_SOURCE

@rem protective execute
@rem if the execution is interrupted or exited, it run POST_SCIRPT to clean up
@rem POST_SCIRPT is also use to return variable to environment
@rem warning: POST_SCIRPT will not ran, if exit by ctrl+c, ctrl+break.
@rem          anwser 'yes' to first prompt, anwser 'no' to second,
@rem          then POST_SCIRPT may be ran.

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
@ncall :Main %*
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
                  args=....) delayedexpansion
if "%cmd%" == "" (
    rem TODO: if --help in args call CMD_help
    set _devcmd=shell
) else (
    set _devcmd=%cmd%
)
set _devargs=%args%
set _start_=
set cmd=
set args=
set DEVON_VERSION=1.0.1

rem 如果還沒進入shell則先進入臨時性的shell
if not "%_devcmd%" == "brickv" call :ActiveDevShell
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


::: function AddPathUnique(entry)
set found=0
set str=%PATH%
:AddPathUnique_IterStringLoop
For /F "tokens=1* delims=;" %%A IN ("%str%") DO @set "item=%%A" & set "str=%%B"
if "%entry%" == "%item%" set found=1
if not "%str%" == "" goto AddPathUnique_IterStringLoop
if "%found%" == "0" set PATH=%entry%;%PATH%
return %PATH%
::: endfunc



:ActiveDevShell

rem switch to dev-sh environment, if not in dev-sh

if "%DEVSH_ACTIVATE%" == "%SCRIPT_SOURCE%" goto :eof

call :BasicCheck
call :LoadConfigPaths
call :GetTitle %PRJ_ROOT%


rem add PRJ_BIN, PRJ_TOOLS to path
if exist "%PRJ_BIN%" set PATH=%PRJ_BIN%;%PATH%
if exist "%PRJ_TOOLS%" set PATH=%PRJ_TOOLS%;%PATH%
if exist "%PRJ_CONF%" set PATH=%PRJ_CONF%;%PATH%

rem add paths from config[path]
rem TODO: check empty args in function header
if not "%DEVON_CONFIG_PATH%" == "" call :GetIniArray "%DEVON_CONFIG_PATH%" "path"
call set str=%inival%
:ActiveDevShell_path_IterStringLoop
for /f "tokens=1* delims=;" %%A in ("%str%") do set "item=%%A" & set "str=%%B"
    set PATH=%item%;%PATH%
    if not "%str%" == "" goto ActiveDevShell_path_IterStringLoop


rem add environ variable from config[variable]
if not "%DEVON_CONFIG_PATH%" == "" call :GetIniArray "%DEVON_CONFIG_PATH%" "variable"
set str=%inival%
:ActiveDevShell_variable_IterStringLoop
for /f "tokens=1* delims=;" %%A in ("%str%") do set "item=%%A" & set "str=%%B"
for /f "tokens=1* delims==" %%A in ("%item%") do set "name=%%A" & set "value=%%B"
    call set "%name%=%value%"
    if not "%str%" == "" goto ActiveDevShell_variable_IterStringLoop


rem prepare temporary command stub folder
rmdir /S /Q "%PRJ_TMP%\command-pre" 1>nul 2>&1
md "%PRJ_TMP%\command-pre" 1>nul 2>&1


rem set-env
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

rem if exist "%PRJ_CONF%\hooks\set-env.cmd" (
rem     call "%PRJ_CONF%\hooks\set-env.cmd"
rem )

set PATH=%PRJ_TMP%\command;%PATH%
rmdir /S /Q "%PRJ_TMP%\command" 1>nul 2>&1
move "%PRJ_TMP%\command-pre" "%PRJ_TMP%\command" 1>nul 2>&1

rem TODO: check more
set inival=
set str=

set DEVSH_ACTIVATE=%SCRIPT_SOURCE%
goto :eof


::: function CMD_brickv(brickv_cmd, brickv_args=....)
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

    if not "%DEVON_CONFIG_PATH%" == "" call :GetIniPairs "%DEVON_CONFIG_PATH%" "alias"
    set str=%inival%
    :GenerateCommandStubs_IterStringLoop
    for /f "tokens=1* delims=;" %%A in ("%str%") do set "item=%%A" & set "str=%%B"
    for /f "tokens=1* delims==" %%A in ("%item%") do set "alias=%%A" & set "alias_cmd=%%B"
        echo.cmd.exe /C "%alias_cmd%" > %PRJ_TMP%\command-pre\%alias%.cmd
        if not "%str%" == "" goto GenerateCommandStubs_IterStringLoop

    rem (set Text=!inival!)&(set LoopCb=:create_alias_file)&(set ExitCb=:exit_create_alias_file)&(set Spliter=;)
    rem goto :SubString
    rem :create_alias_file
    rem     echo !substring!
    rem     for /f "tokens=1,2 delims==" %%a in ("!substring!") do (
    rem         set alias=%%a
    rem         set alias_cmd=%%b
    rem     )
    rem     echo.cmd.exe /C "%alias_cmd%" > %PRJ_TMP%\command-pre\%alias%.cmd
    rem     goto :NextSubString
    rem :exit_create_alias_file
    rem set inival=

    echo.@"%SCRIPT_SOURCE%" %%* > %PRJ_TMP%\command-pre\dev.cmd

    #include(GitHooksScript, "git-hooks")
    echo.!GitHooksScript! > %PRJ_TMP%\command-pre\git-hooks

    #include(GitBashScript, "bash.cmd")
    echo.!GitBashScript! > %PRJ_TMP%\command-pre\bash.cmd
    echo.!GitBashScript! > %PRJ_TMP%\command-pre\git-bash.cmd

::: endfunc

::: function CMD_shell(no_window=N, no_welcome=N) delayedexpansion
    rem create new shell window
    set CMDSCRIPT=
    set CMDSCRIPT=!CMDSCRIPT!^\n^
        (set no_window=)^&^\n^
        (set no_welcome=)^&^\n^
        (set CMDSCRIPT=)^&^\n^
        (set CALL_STACK=)^&^\n^
        (set SCRIPT_FOLDER=)^&^\n^
        (set SCRIPT_SOURCE=)^&^\n^
        (set DEVON_VERSION=)^&^\n^
        (set CTRA=)^&^\n^
        (set _devcmd=)^&^\n^
        (set _devargs=)^&

    rem force setup for newly cloned project
    rem set CMDSCRIPT=!CMDSCRIPT!(dev setup)^&


    rem ansicon feature
    where ansicon.exe 1>nul 2>&1
    if not errorlevel 1 (
        set "CMDSCRIPT=!CMDSCRIPT!(ansicon.exe -p)^&"
    )

    rem clink feature
    where clink.bat 1>nul 2>&1
    if not errorlevel 1 (
        set "CMDSCRIPT=!CMDSCRIPT!(clink.bat inject 1>nul)^&"
    )

    rem show welcome text and change prompt
    if not "%no_welcome%" == "1" (
        set "CMDSCRIPT=!CMDSCRIPT!(dev welcome)^&"
    )
    rem finish cmd script
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









