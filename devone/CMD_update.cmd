
::: function CMD_update()



rem update git hooks
for %%F in ("applypatch-msg"
            "pre-applypatch"
            "post-applypatch"
            "pre-commit"
            "prepare-commit-msg"
            "commit-msg"
            "post-commit"
            "pre-rebase"
            "post-checkout"
            "post-merge"
            "pre-push"
            "pre-receive"
            "update"
            "post-receive"
            "post-update"
            "push-to-checkout"
            "pre-auto-gc"
            "post-rewrite") do (
    if exist "%PRJ_CONF%\hooks\%%~F" copy /Y "%PRJ_CONF%\hooks\%%~F" "%PRJ_ROOT%\.git\hooks\%%~F"
)


rem TODO: brickv install


if exist "%PRJ_CONF%\hooks\update.cmd" (
    call "%PRJ_CONF%\hooks\update.cmd"
)

::: endfunc
