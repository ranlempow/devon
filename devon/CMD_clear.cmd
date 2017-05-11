

::: function CMD_clear()

rem TODO: check submodule status is clean
rem TODO: remove submodule dir
rem pushd %subdir%
rem git diff-index --quiet HEAD
rem if not errorlevel 1 del .\*
rem popd


rem TODO: remove default removable dir
rem if exist "%PRJ_LOG%" del /Q "%PRJ_LOG%\*"
rem if exist "%PRJ_TMP%" del /Q "%PRJ_TMP%\*"
rem if exist "%PRJ_VAR%" del /Q "%PRJ_VAR%\*"

rem clear from devon.ini[clear]
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

::: endfunc
