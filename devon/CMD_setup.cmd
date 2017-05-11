::: function CMD_setup(UserName=?, GithubToken=?)
rem TODO: force option

rem for /f %%i in ('git config --local user.name') do set AlreadySetup=%%i
rem if not "%AlreadySetup%" == "" (
rem    return
rem )

git rev-parse 1>nul 1>&2
if errorlevel 1 error("Not a git repository")

for /f %%i in ('git rev-parse --git-dir') do set GitDir=%%i
rem already setup
if exist "%GitDir%/.devon" (
    return
)

if "%UserName%" == "" set /P UserName=Enter your name (or input 'global' use global config):
if "%GithubToken%" == "" set /P GithubToken=Enter the secret token:

for /f "tokens=1,2 delims==" %%a in ("%GithubToken%") do (
    set LoginName=%%a
    set LoginPassword=%%b
)

if "%UserName%" == "" error("User name undefined")
if "%LoginName%" == "" error("Login name undefined")
if "%LoginPassword%" == "" error("Login password undefined")

if not exist "%HOME%" mkdir "%HOME%"

echo.machine github.com>> %HOME%/_netrc
echo.login %LoginName%>> %HOME%/_netrc
echo.password %LoginPassword%>> %HOME%/_netrc
echo.>> %HOME%/_netrc

echo.machine api.github.com>> %HOME%/_netrc
echo.login %LoginName%>> %HOME%/_netrc
echo.password %LoginPassword%>> %HOME%/_netrc
echo.>> %HOME%/_netrc


rem TODO: custom git configs
if not "%UserName%" == "global" (
	git config --local user.name %UserName%
	git config --local user.email %UserName%@users.noreply.github.com
)
git config --local core.autocrlf true
git config --local push.default simple

git hooks --install

echo. > "%GitDir%/.devon"

::: endfunc

