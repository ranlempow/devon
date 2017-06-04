:choco_init
    set _RELEASE_URL=https://api.github.com/repos/adoxa/ansicon/releases
    set ACCEPT=local global
    set ALLOW_EMPTY_LOCATION=1
    goto :eof

:choco_versions
    echo.choco=x[.]>> "%VERSION_SPCES_FILE%"

:choco_prepare
	if "%REQUEST_NAME%" == "" set REQUEST_NAME=choco
	set DOWNLOAD_URL=https://chocolatey.org/install.ps1
	goto :eof

:choco_unpack

    set SETENV=%SETENV%;$SCRIPT_FOLDER$\bin
    set ChocolateyInstall=%TARGET%
    setx ChocolateyInstall %TARGET%

    set POWERSH=%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe
    set PSEXEC="%POWERSH%" -NoProfile -ExecutionPolicy Bypass -Command
    :: run installer
    %PSEXEC% "& '%INSTALLER%' %*"

    :: delete user environment that choco-install created
    REG delete HKCU\Environment /F /V ChocolateyInstall
    REG delete HKCU\Environment /F /V ChocolateyLastPathUpdate
    set REG_PATH=
    for /f "tokens=2,* USEBACKQ" %%A in (`reg query HKCU\Environment /v PATH ^| findstr PATH`) do (
        set REG_PATH=%%B
    )
    :: delete user path that choco-install added
    if not "%REG_PATH%" == "" (
        call set ORIGIN_PATH=%%REG_PATH:%TARGET%\bin;=%%
        setx PATH !ORIGIN_PATH!
    )

    :: determine what APPVER is
    :: or use <version>0.10.5</version> in lib\chocolatey\chocolatey.nupkg\chocolatey.nuspec
    for /f "delims=v tokens=2 USEBACKQ" %%A in (`"%TARGET%\bin\choco" ^| findstr Chocolate`) do (
        set APPVER=%%A
    )
    goto :eof

:choco_validate
	set CHECK_EXIST=choco.exe
	set CHECK_CMD=
	set CHECK_LINEWORD=
	set CHECK_OK=
	goto:eof
