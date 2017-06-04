:python_init
    set _RELEASE_URL=https://www.python.org/ftp/python/
    set ACCEPT=global
    set ALLOW_EMPTY_LOCATION=1
    goto :eof


rem <a href="3.4.6/">3.4.6/</a>                                             17-Jan-2017 08:14
rem https://www.python.org/ftp/python/2.4/python-2.4.ia64.msi
rem https://www.python.org/ftp/python/3.4.4/python-3.4.4.amd64.msi
rem https://www.python.org/ftp/python/3.4.4/python-3.4.4.msi
rem https://www.python.org/ftp/python/3.5.3/python-3.5.3-amd64.exe
rem https://www.python.org/ftp/python/3.5.3/python-3.5.3.exe

:python_versions
    set "regex=[0-9]*\.[0-9]*\.[0-9]*\/"
    rem set VERSION_SOURCE_FILE2=%VERSION_SOURCE_FILE%.2
    rem type "%VERSION_SPCES_FILE%.3" > "%VERSION_SPCES_FILE%"
    rem goto :eof
    echo %VERSION_SOURCE_FILE%
    ncall :BrickvDownload "%_RELEASE_URL%" "%VERSION_SOURCE_FILE%"
    FOR /F "tokens=* USEBACKQ" %%F IN (
            `FINDSTR  /R /C:"%regex%" %VERSION_SOURCE_FILE%`) DO (
        for /F delims^=^"^ tokens^=2 %%P in ("%%F") do (
            set TARGET_VER=%%P
        )
        for /F "delims=. tokens=1,2,3" %%P in ("!TARGET_VER:~0,-1!") do (
            set TARGET_MAJOR=%%P
            set TARGET_MINOR=%%Q
            set TARGET_PACTH=%%R
        )

        set skip=
        if !TARGET_MAJOR! EQU 2 if !TARGET_MINOR! LSS 4 set skip=1

        if "!skip!" == "" (
            ncall :BrickvDownload "%_RELEASE_URL%!TARGET_VER!" "%VERSION_SOURCE_FILE2%"
            set FOUND_VER=!TARGET_MAJOR!.!TARGET_MINOR!.!TARGET_PACTH!
            set WIN86=
            set WIN64=
            FOR /F "tokens=* USEBACKQ" %%G IN (
                    `FINDSTR  /R /C:"\python-!FOUND_VER!\.msi" %VERSION_SOURCE_FILE2%`) DO (
                    set WIN86=.msi
            )
                    FOR /F "tokens=* USEBACKQ" %%G IN (
                    `FINDSTR  /R /C:"\python-!FOUND_VER!\-webinstall\.exe" %VERSION_SOURCE_FILE2%`) DO (
                    set WIN86=-webinstall.exe
            )
            FOR /F "tokens=* USEBACKQ" %%G IN (
                    `FINDSTR  /R /C:"python-!FOUND_VER!\.ia64\.msi" %VERSION_SOURCE_FILE2%`) DO (
                    set WIN64=.ia64.msi
            )
            FOR /F "tokens=* USEBACKQ" %%G IN (
                    `FINDSTR  /R /C:"python-!FOUND_VER!\.amd64\.msi" %VERSION_SOURCE_FILE2%`) DO (
                    set WIN64=.amd64.msi
            )
            FOR /F "tokens=* USEBACKQ" %%G IN (
                    `FINDSTR  /R /C:"python-!FOUND_VER!\-amd64\-webinstall\.exe" %VERSION_SOURCE_FILE2%`) DO (
                    set WIN64=-amd64-webinstall.exe
            )

            rem echo !TARGET_MAJOR!+!TARGET_MINOR!+!TARGET_PACTH!
            rem echo !WIN86!, !WIN64!

            set WIN86_URL=%_RELEASE_URL%!FOUND_VER!/python-!FOUND_VER!!WIN86!
            set WIN64_URL=%_RELEASE_URL%!FOUND_VER!/python-!FOUND_VER!!WIN64!
            if not "!WIN86!" == "" echo.python=!FOUND_VER!@x86[.]$!WIN86_URL!>> "%VERSION_SPCES_FILE%"
            if not "!WIN64!" == "" echo.python=!FOUND_VER!@x64[.]$!WIN64_URL!>> "%VERSION_SPCES_FILE%"
        )
    )

    goto :eof

:python_prepare
    set APPVER=%MATCH_VER%
    if "%REQUEST_NAME%" == "" set REQUEST_NAME=python-%APPVER%-%MATCH_ARCH%
    set DOWNLOAD_URL=%MATCH_CARRY%
    goto :eof

:python_unpack
    set SETENV=%SETENV%;$SCRIPT_FOLDER$
    set SETENV=%SETENV%;$SCRIPT_FOLDER$\Scripts

    if "%DOWNLOAD_URL:~-4%" == ".msi" (
        set UNPACK_METHOD=msi-unpack
    ) else (
        set LAYOUT=%TEMP%\python-%APPVER%-%MATCH_ARCH%-msi-layout
        echo call "%INSTALLER%" /quiet /layout "!LAYOUT!"
        call "%INSTALLER%" /quiet /layout "!LAYOUT!"
        FOR %%F IN (!LAYOUT!\*.msi) DO @(
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
    )
    set GETPIP_URL=https://bootstrap.pypa.io/get-pip.py
    ncall :BrickvDownload "%GETPIP_URL%" "%TEMP%\get-pip.py"
    call "%TARGET%\python.exe" "%TEMP%\get-pip.py"
    call "%TARGET%\Scripts\pip.exe" install virtualenv
    goto :eof

:python_validate
    set CHECK_EXIST=
    set CHECK_CMD=python --version
    set CHECK_LINEWORD=Python
    set CHECK_OK=Python %%VA_INFO_VERSION%%
    goto:eof
