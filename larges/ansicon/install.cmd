:ansicon_init
    set _RELEASE_URL=https://api.github.com/repos/adoxa/ansicon/releases
    set ACCEPT=local global
    set ALLOW_EMPTY_LOCATION=1
    goto :eof

rem "browser_download_url": "https://github.com/adoxa/ansicon/releases/download/v1.66/ansi166.zip"
:ansicon_versions
    set "regex=browser_download_url.*download\/v[0-9]*\.[0-9]*\/ansi[0-9]*\.zip"
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
            set ANSICON_VER=!TARGET_VER:~1!
            echo.ansicon=!ANSICON_VER![.]$!TARGET_URL:~0,-1!>> "%VERSION_SPCES_FILE%"

        )
    )
    goto :eof

:ansicon_prepare
	set APPVER=%MATCH_VER%
	if "%REQUEST_NAME%" == "" set REQUEST_NAME=ansicon-%APPVER%
	set DOWNLOAD_URL=%MATCH_CARRY%
	goto :eof

:ansicon_unpack
	set SETENV=%SETENV%;$SCRIPT_FOLDER$\x86-x64??
	set UNPACK_METHOD=unzip
	goto :eof

:ansicon_validate
	set CHECK_EXIST=
	set CHECK_CMD=clink_x86
	set CHECK_LINEWORD=Copyright
	set CHECK_OK=Clink v%%VA_INFO_VERSION%%
	goto:eof
