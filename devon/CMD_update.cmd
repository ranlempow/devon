
::: function CMD_update()


rem brickv install
set inival=
call :GetIniPairs %DEVON_CONFIG_PATH% "dependencies"
if not "%inival%" == "" set specs=%inival:;= %
rem cmd /C "%SCRIPT_SOURCE%" :brickv_CMD_Update "%specs%" --vvv

if exist "%PRJ_CONF%\hooks\update.cmd" (
    call "%PRJ_CONF%\hooks\update.cmd"
)

::: endfunc


::: function CMD_bootstrap(git_remote)
call :EnterPostScript
call :brickv_CMD_Update "git=2.x" --vv
call :ExecutePostScript

git clone %git_remote% > "%TEMP%\git-clone-stdout.txt"
rem Cloning into 'devon2/abc'...
if errorlevel 1 error("git clone failed")
for /F "tokens=1-3 usebackq" %%A IN ("%TEMP%\git-clone-stdout.txt") do (
    if "%%A" == "Cloning" if "%%B" == "into" set ProjectRoot=%%C
)
set ProjectRoot=%ProjectRoot:~1, -4%
echo %ProjectRoot%

if not exist "%ProjectRoot%\dev-sh.cmd" error("project not exist")
call "%ProjectRoot%\dev-sh.cmd" init
call "%ProjectRoot%\dev-sh.cmd" update
call "%ProjectRoot%\dev-sh.cmd" shell


::: endfunc
