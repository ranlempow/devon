:jq_init
    set _RELEASE_URL=https://api.github.com/repos/stedolan/jq/releases
    set ACCEPT=local global
    set ALLOW_EMPTY_LOCATION=1
    goto :eof

rem "browser_download_url": "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-win32.exe"
rem "browser_download_url": "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-win64.exe"
:jq_versions
    set "regex=browser_download_url.*download\/jq-[0-9]*\.[0-9]*\/jq-win[3264]*\.exe"
    FOR /L %%G IN (1,1,2) DO (
        ncall :BrickvDownload "%_RELEASE_URL%?page=%%G" "%VERSION_SOURCE_FILE%"
        FOR /F "tokens=* USEBACKQ" %%F IN (
                `FINDSTR  /R /C:"%regex%" %VERSION_SOURCE_FILE%`) DO (
            for /F "delims=: tokens=3" %%P in ("%%F") do (
                set TARGET_URL=https:%%P
            )
            for /F "delims=/ tokens=7" %%P in ("!TARGET_URL!") do (
                set TARGET_VER=%%P
            )
            for /F "delims=/ tokens=8" %%P in ("!TARGET_URL!") do (
                set TARGET_ARCH=%%P
            )
            set FOUND_VER=!TARGET_VER:~3!
            set FOUND_ARCH=!TARGET_ARCH:~6,2!
            if "!FOUND_ARCH!" == "32" set FOUND_ARCH=x86
            if "!FOUND_ARCH!" == "64" set FOUND_ARCH=x64
            echo.jq=!FOUND_VER![!FOUND_ARCH!]$!TARGET_URL:~0,-1!>> "%VERSION_SPCES_FILE%"

        )
    )
    goto :eof

:jq_prepare
	set APPVER=%MATCH_VER%
	if "%REQUEST_NAME%" == "" set REQUEST_NAME=jq-%APPVER%-%REQUEST_ARCH%
	set DOWNLOAD_URL=%MATCH_CARRY%
	goto :eof

:jq_unpack
    rem if "%MATCH_ARCH%" == "x86" set _APP_NAME=jq-win32.exe
    rem if "%MATCH_ARCH%" == "x64" set _APP_NAME=jq-win64.exe

    md "%TARGETDIR%\%REQUEST_NAME%" 1>nul 2>&1
	move "%INSTALLER%" "%TARGETDIR%\%REQUEST_NAME%\jq.exe"
    rem pcall :Unzip "%INSTALLER%" "%TARGETDIR%\%REQUEST_NAME%"
	goto :eof

:jq_validate
	set CHECK_EXIST=
	set CHECK_CMD=ansicon.exe --help
	set CHECK_LINEWORD=Freeware
	set CHECK_OK=Version %%VA_INFO_VERSION%%
	goto:eof
