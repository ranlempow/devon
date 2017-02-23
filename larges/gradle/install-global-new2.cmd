:gradle_init
	set _RELEASE_URL=https://services.gradle.org/distributions
	set DOWNLOAD_URL=%RELEASE_URL%
	set ACCEPT=local global
    goto :eof

:gradle_versions
	ncall :BrickvDownload "%_RELEASE_URL%" "%VERSION_SOURCE_FILE%"
	for /F "tokens=* USEBACKQ" %%F IN (
            `FINDSTR  /R /C:"distributions/gradle" "%VERSION_SOURCE_FILE%"`) do (
	    for /F "delims=- tokens=2,3 USEBACKQ" %%G IN ('%%F') do (
	        set var1=%%H
	        if "!var1:~0,-2!" == "bin.zip" echo.gradle=%%G@any[bin] >> "%VERSION_SPCES_FILE%"
	    )
	)
    goto :eof

:gradle_prepare
	set APPVER=%MATCH_VER%
	if "%REQUEST_NAME%" == "" set REQUEST_NAME=gradle-%APPVER%
	set DOWNLOAD_URL=%_RELEASE_URL%/gradle-%APPVER%-bin.zip
	goto :eof

:gradle_unpack
	set SETENV=%SETENV%;GRADLE_HOME:$SCRIPT_SOURCE$
	set SETENV=%SETENV%;$GRADLE_HOME$\bin
	set UNPACK_METHOD=unzip
	goto :eof

:gradle_validate
	set CHECK_EXIST=
	set CHECK_CMD=gradle -v
	set CHECK_LINEWORD=Gradle
	set CHECK_OK=Gradle %%VA_INFO_VERSION%%
	goto:eof
