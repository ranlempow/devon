@set REQUEST_VAR=%1
@set REQUEST_ARCH=%2

@if [%REQUEST_ARCH%] == [] @(
    @set REQUEST_ARCH=x32
)

@if "%REQUEST_VAR%" == "x32" @(
    @set REQUEST_VAR=3.5
    @set REQUEST_ARCH=x32
)
@if "%REQUEST_VAR%" == "x64" @(
    @set REQUEST_VAR=3.5
    @set REQUEST_ARCH=x64
)


for /F "delims=. tokens=1,2,3" %%A in ("%REQUEST_VAR%") do (
    set PYVER_MAJOR=%%A
    set PYVER_MINOR=%%B
    set PYVER_HOTFIX=%%C
)

if %PYVER_MAJOR% geq 3 (
    if %PYVER_MINOR% leq 2 (
        echo ERROR: Support for Python 3.0-3.2 has been dropped.
        @goto :ERROR
    )
)

set VERFILE_URL=https://raw.githubusercontent.com/python/cpython/%PYVER_MAJOR%.%PYVER_MINOR%/Include/patchlevel.h
if "%PYVER_HOTFIX%" == "" (
    powershell -Command "(New-Object Net.WebClient).DownloadFile('%VERFILE_URL%', '%TEMP%\patchlevel.h')"
    goto MatchVersion
) else (
    goto DownloadPython
)

:MatchVersion
FOR /F "tokens=* USEBACKQ" %%F IN (`FINDSTR  /R /C:"#define PY_VERSION[ ]^*" %TEMP%\patchlevel.h`) DO (
    set var=%%F
)
for /F delims^=^"^ tokens^=2 %%M in ("%var%") do (
    set var2=%%M
)
for /F "delims=. tokens=3" %%P in ("%var2%") do (
   set PYVER_HOTFIX=%%P
)
if "%PYVER_HOTFIX:~-1%" == "+" (
    set PYVER_HOTFIX=%PYVER_HOTFIX:~0,-1%
)


:DownloadPython

set PYTHON_VERSION=%PYVER_MAJOR%.%PYVER_MINOR%.%PYVER_HOTFIX%
if "%REQUEST_ARCH%" == "x32" (
    set PY_ARCH=
) else (
    set PY_ARCH=-amd64
)
set PYTHON_NAME=python-%PYTHON_VERSION%%PY_ARCH%
set TARGETDIR=%LOCALAPPDATA%\Programs\%PYTHON_NAME%
if not exist "%LOCALAPPDATA%\Programs" (
    mkdir "%LOCALAPPDATA%\Programs"
)

if %PYVER_MAJOR% geq 3 (
    if %PYVER_MINOR% geq 5 (
        goto DownloadPythonZip
    )
)



:DownloadPythonMSI
if "%REQUEST_ARCH%" == "x32" (
    set PY_ARCH=
) else (
    set PY_ARCH=.amd64
)
set PYTHON_DOWNLOAD_SITE=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%%PY_ARCH%.msi
set PYTHON_MSI=%TEMP%\python-%PYTHON_VERSION%%PY_ARCH%.msi

IF NOT EXIST %PYTHON_MSI% (
    powershell -Command "(New-Object Net.WebClient).DownloadFile('%PYTHON_DOWNLOAD_SITE%', '%PYTHON_MSI%')"
)
if errorlevel 1 (
    if %PYVER_HOTFIX% geq 1 (
        set /A PYVER_HOTFIX-=1
        goto DownloadPython
    )
)
msiexec /a %PYTHON_MSI% /qb TARGETDIR=%TARGETDIR%
goto BaseInstallDone


:DownloadPythonZip

set PYTHON_DOWNLOAD_SITE=https://www.python.org/ftp/python/%PYTHON_VERSION%/%PYTHON_NAME%.exe
set PYTHON_INSTALLER=%TEMP%\%PYTHON_NAME%.exe

IF NOT EXIST %PYTHON_INSTALLER% (
    powershell -Command "(New-Object Net.WebClient).DownloadFile('%PYTHON_DOWNLOAD_SITE%', '%PYTHON_INSTALLER%')"
)
if errorlevel 1 (
    if %PYVER_HOTFIX% geq 1 (
        set /A PYVER_HOTFIX-=1
        goto DownloadPython
    )
)
%PYTHON_INSTALLER% /passive TargetDir="%TARGETDIR%-temp" AssociateFiles=0 Shortcuts=0 InstallLauncherAllUsers=0 Include_launcher=0 Include_pip=0
if not exist "%TARGETDIR%-temp" (
   echo ERROR: Python %PYVER_MAJOR%.%PYVER_MINOR% already installed, please uninstall first.
   @goto :ERROR
)
xcopy "%TARGETDIR%-temp" "%TARGETDIR%" /K /E /Y /I /H
%PYTHON_INSTALLER% /passive /uninstall
goto BaseInstallDone


:BaseInstallDone

set GETPIP_URL=https://bootstrap.pypa.io/get-pip.py
powershell -Command "(New-Object Net.WebClient).DownloadFile('%GETPIP_URL%', ' %TEMP%\get-pip.py')"
%TARGETDIR%\python.exe %TEMP%\get-pip.py

if %PYVER_MAJOR% geq 3 (
    if %PYVER_MINOR% geq 3 (
        goto PyvenvDone
    )
)

%TARGETDIR%\Scripts\pip.exe install virtualenv

:PyvenvDone
@cmd /c "exit /b 0"
goto :eof


:ERROR
@cmd /c "exit /b 1"
@goto :eof

