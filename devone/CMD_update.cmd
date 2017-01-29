
::: function CMD_update()

if exist "%PRJ_CONF%\hooks\update.cmd" (
    call "%PRJ_CONF%\hooks\update.cmd"
)

::: endfunc
