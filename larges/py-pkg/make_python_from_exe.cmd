
@setlocal  enabledelayedexpansion

set LAYOUT=%~dp0py3
set TARGET=%~dp0pypack12
call "py2\python-3.5.1-webinstall.exe" /quiet /layout "%LAYOUT%"
FOR %%F IN (%LAYOUT%\*.msi) DO @(
    set MSI_FILE=%%F
    for /F %%I in ("!MSI_FILE!") do set MSI_NAME=%%~nxI
    set Break=
    if "!MSI_NAME:~-6!" == "_d.msi" set Break=1
    if "!MSI_NAME:~-8!" == "_pdb.msi" set Break=1
    if "!MSI_NAME!" == "launcher.msi" set Break=1
    if "!MSI_NAME!" == "path.msi" set Break=1
    if "!MSI_NAME!" == "pip.msi" set Break=1
    if not "!Break!" == "1" (
        echo !MSI_FILE!, !MSI_NAME!
        msiexec /a "!MSI_FILE!" /qb TARGETDIR=%TARGET%
        del %TARGET%\!MSI_NAME!
    )
)
set GETPIP_URL=https://bootstrap.pypa.io/get-pip.py
powershell -Command "(New-Object Net.WebClient).DownloadFile('%GETPIP_URL%', ' %TEMP%\get-pip.py')"
call "%TARGET%\python.exe" "%TEMP%\get-pip.py"
call "%TARGET%\Scripts\pip.exe" install virtualenv
@endlocal
@goto :eof

