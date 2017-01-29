
::: function CMD_clear()

rem TODO: check submodule status is clean
rem TODO: remove submodule dir

rem TODO: remove default removable dir

rem clear from devone.ini[clear]
set inival=
call :GetIniArray DEVONE_CONFIG_PATH "clear"
(set Text=!inival!)&(set LoopCb=:clear_prject)&(set ExitCb=:exit_clear_prject)&(set Spliter=;)
goto :SubString
:clear_prject
    if exist "!PRJ_ROOT!\!substring!" call del "!PRJ_ROOT!\!substring!"
    goto :NextSubString
:exit_clear_prject
set inival=

if exist "%PRJ_CONF%\hooks\clear.cmd" (
    call "%PRJ_CONF%\hooks\clear.cmd"
)

::: endfunc
