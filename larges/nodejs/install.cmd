:nodejs_init
    set _RELEASE_URL=https://nodejs.org/dist/index.json
    set ACCEPT=local global
    set ALLOW_EMPTY_LOCATION=1
    goto :eof

rem {"version":"v0.6.21","date":"2012-08-03","files":["osx-x64-pkg","src","win-x64-exe","win-x86-exe"],"npm":"1.1.37","v8":"3.6.6.25","uv":"0.6","zlib":"1.2.3","openssl":"0.9.8r","modules":"1","lts":false},
:nodejs_versions
    ncall :BrickvDownload "%_RELEASE_URL%" "%VERSION_SOURCE_FILE%"
    FOR /F "tokens=* USEBACKQ" %%F IN (
            `FINDSTR  /R /C:"win-x64-exe" %VERSION_SOURCE_FILE%`) DO (
        for /F "delims=, tokens=1" %%Q in ("%%F") do (
            for /F "delims=: tokens=2" %%R in ("%%Q") do (
                set TARGET_VER==%%R
        ))
        for /F "delims=] tokens=2" %%P in ("%%F") do (
            for /F "delims=, tokens=1" %%Q in ("%%P") do (
                for /F "delims=: tokens=2" %%R in ("%%Q") do (
                    set NPM_VER=%%R
        )))
        set FOUND_VER=!TARGET_VER:~3,-1!
        set FOUND_NPM_VER=!NPM_VER:~1,-1!
        echo !FOUND_VER!--!FOUND_NPM_VER!
        echo.nodejs=!FOUND_VER!@x64[.]$!FOUND_NPM_VER!>> "%VERSION_SPCES_FILE%"
        echo.nodejs=!FOUND_VER!@x86[.]$!FOUND_NPM_VER!>> "%VERSION_SPCES_FILE%"

    )

    goto :eof

:nodejs_prepare
	set APPVER=%MATCH_VER%
    if "%REQUEST_NAME%" == "" set REQUEST_NAME=node-%APPVER%-%MATCH_ARCH%
    set NPM_VER=%MATCH_CARRY%
	set NPM_URL=https://github.com/npm/npm/archive/v%NPM_VER%.zip
    set NPM_INSTALLER=%TEMP%\npm-%NPM_VER%.zip
    pcall :BrickvDownload "%NPM_URL%" "%NPM_INSTALLER%" --skip-exists
    set DOWNLOAD_URL=https://nodejs.org/dist/v%MATCH_VER%/win-%MATCH_ARCH%/node.exe
	goto :eof

:nodejs_unpack
    set SETENV=%SETENV%;$SCRIPT_FOLDER$
    set SETENV=%SETENV%;$PRJ_ROOT$\node_modules\.bin
    set _INSTALL_DIR=%TARGETDIR%\%REQUEST_NAME%
    md "%_INSTALL_DIR%" 1>nul 2>&1
    md "%_INSTALL_DIR%\node_modules" 1>nul 2>&1
    pcall :Unzip "%NPM_INSTALLER%" "%_INSTALL_DIR%\node_modules"
    move "%INSTALLER%" "%_INSTALL_DIR%\node.exe" 1>nul 2>&1

    move "%_INSTALL_DIR%\node_modules\npm-%NPM_VER%" "%_INSTALL_DIR%\node_modules\npm"
    xcopy "%_INSTALL_DIR%\node_modules\npm\bin\npm" "%_INSTALL_DIR%\npm*" /K /Y
    xcopy "%_INSTALL_DIR%\node_modules\npm\bin\npm.cmd" "%_INSTALL_DIR%\npm.cmd*" /K /Y

	goto :eof

:ansicon_validate
	set CHECK_EXIST=
	set CHECK_CMD=npm --version
	set CHECK_LINEWORD=node
	set CHECK_OK=node: '%%VA_INFO_VERSION%%'
	goto:eof
