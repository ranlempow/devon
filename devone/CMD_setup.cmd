::: function CMD_setup(UserName=?, GithubToken=?)

rem TODO: write default untrack dir to gitignore
rem TODO: write default not-work-tree dir to .git\exclude

for /f %%i in ('git config --local user.name') do set AlreadySetup=%%i
if not "%AlreadySetup%" == "" (
   return
)

git rev-parse 1>nul 1>&2
if errorlevel 1 error("Not a git repository")

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

if not "%UserName%" == "global" (
	git config --local user.name %UserName%
	git config --local user.email %UserName%@users.noreply.github.com
	git config --local core.autocrlf true
	git config --local push.default simple
)

::: endfunc

