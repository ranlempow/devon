


::: function brickv_CMD_install(ONLY_VERSIONS=N, args=....) delayedexpansion

set ACCEPT=1

call :BrickvPrepare %args%
set args=
set APPNAME=%REQUEST_APP%

rem init
call :ExistsLabel %APPNAME%_init
if "%LabelExists%" == "1" (
    call :%APPNAME%_Init
) else (
    error("%APPNAME% not in installable list")
)
rem detect
rem call :ExistsLabel %APPNAME%_detect
rem if "%LabelExists%" == 1 call :%APPNAME%_detect

rem versions
if not "%PRJ_TMP%" == "" set TEMP=%PRJ_TMP%
set VERSION_SOURCE_FILE=%TEMP%\source_%APPNAME%.ver.txt
set VERSION_SPCES_FILE=%TEMP%\spces-%APPNAME%.ver.txt

if exist "%VERSION_SOURCE_FILE%" del "%VERSION_SOURCE_FILE%" >nul
copy /y NUL "%VERSION_SOURCE_FILE%" >NUL
if exist "%VERSION_SPCES_FILE%" del "%VERSION_SPCES_FILE%" >nul
copy /y NUL "%VERSION_SPCES_FILE%" >NUL

call :ExistsLabel %APPNAME%_versions
if "%LabelExists%" == "1" call :%APPNAME%_versions
if exist "%RELEASE_URL%" call :BrickvDownload "%RELEASE_URL%" "%VERSION_SPCES_FILE%"
if "%ONLY_VERSIONS%" == "1" (
    return %VERSION_SPCES_FILE%
)

if exist "%VERSION_SPCES_FILE%" (
    pcall :MatchVersion --output-format env --spec-match "%REQUEST_SPEC%" --specs-file "%VERSION_SPCES_FILE%"
            if not "!ERROR_MSG!" == "" goto :brickv_CMD_install_Error
) else (
    error("release version list is empty")
    rem if "%RELEASE_LIST%" == "" error("release version list is empty")
    rem call :MatchVersion --output-format env --spec-match "%REQUEST_SPEC%" "%RELEASE_LIST%"
)


rem prepare: set APPNAME, APPVER, INSTALLER
call :ExistsLabel %APPNAME%_prepare
if "%LabelExists%" == "1" call :%APPNAME%_prepare
if not "%DOWNLOAD_URL_TEMPLATE%" == "" call set DOWNLOAD_URL=%DOWNLOAD_URL_TEMPLATE%


pcall :BrickvBeforeInstall
        if not "%ERROR_MSG%" == "" goto :brickv_CMD_install_Error

rem download
rem call :ExistsLabel %APPNAME%_download
rem if "%LabelExists%" == "1" pcall :%APPNAME%_download
rem     if not "%ERROR_MSG%" == "" goto :brickv_CMD_install_Error
if not "%DOWNLOAD_URL%" == "" if "%INSTALLER%" == "" call :FilenameFromUrl "%DOWNLOAD_URL%"
if not "%DOWNLOAD_URL%" == "" if "%INSTALLER%" == "" set INSTALLER=%TEMP%\%Filename%
set Filename=
call :PrintTaskInfo
if "%DRYRUN%" == "1" goto :BrickvInstallFinal

if not "%DOWNLOAD_URL%" == "" (
    pcall :BrickvDownload "%DOWNLOAD_URL%" "%INSTALLER%" --skip-exists
)
        if not "%ERROR_MSG%" == "" goto :brickv_CMD_install_Error

rem unpack
call :ExistsLabel %APPNAME%_unpack
if "%LabelExists%" == "1" pcall :%APPNAME%_unpack
        if not "%ERROR_MSG%" == "" goto :brickv_CMD_install_Error
if not "%INSTALLER%" == "" (
    if "%UNPACK_METHOD%" == "msi-install" pcall :InstallMsi "%INSTALLER%"
            if not "!ERROR_MSG!" == "" goto :brickv_CMD_install_Error
    if "%UNPACK_METHOD%" == "msi-unpack" pcall :UnpackMsi "%INSTALLER%" "%TARGET%"
            if not "!ERROR_MSG!" == "" goto :brickv_CMD_install_Error
    if "%UNPACK_METHOD%" == "unzip" pcall :Unzip "%INSTALLER%" "%TARGETDIR%"
            if not "!ERROR_MSG!" == "" goto :brickv_CMD_install_Error
)


rem validate
set ValidateFailed=0
call :ExistsLabel %APPNAME%_validate
if "%LabelExists%" == "1" call :%APPNAME%_validate
if "%ValidateFailed%" == "1" (
    set ERROR_MSG="extra validate failed"
    goto :brickv_CMD_install_Error
)
pcall :BrickvGenEnv "%TARGET%" "%SETENV%"
        if not "%ERROR_MSG%" == "" goto :brickv_CMD_install_Error

pcall :BrickvValidate
if not "%ERROR_MSG%" == "" (
    call :PrintMsg warning warning validate error: %ERROR_MSG%
) else (
    call :PrintMsg noraml validate succeed
)

:BrickvInstallFinal
set ERROR_MSG=
ncall :BrickvDone
cmd /C exit /b 0
return %DRYRUN%, %REQUEST_NAME%


:brickv_CMD_install_Error
set _ERROR_MSG=%ERROR_MSG%
ncall :BrickvDone
cmd /C exit /b 1
::: endfunc


::: function BrickvValidate() delayedexpansion
    rem set CHECK_EXIST=
    rem set CHECK_CMD=gradle -v
    rem set CHECK_LINEWORD=Gradle
    rem set CHECK_OK=Gradle %VA_INFO_VERSION%
    call "%TARGET%\set-env.cmd" --validate --quiet

    if errorlevel 1 error("self validate failed")

    if not "%CHECK_EXIST%" == "" if not exist "%SCRIPT_FOLDER%\%CHECK_EXIST%" (
        error("exist validate failed %SCRIPT_FOLDER%\%CHECK_EXIST%")
    )

    if "%CHECK_LINEWORD%" == "" if "%CHECK_OK%" == "" (
        if "%CHECK_CMD%" == "" (
            rem echo nocheck
            return
        )
        cmd /C "%CHECK_CMD%"
        if errorlevel 1 error("validate command failed")
        rem echo cmd ok
        return
    )
    if "%CHECK_LINEWORD%" == "" (
        for /F "tokens=* USEBACKQ" %%F in (`cmd /C %CHECK_CMD%`) do @set CHECK_STRING=%%F
    ) else (
        for /F "tokens=* USEBACKQ" %%F in (`cmd /C %CHECK_CMD% ^| findstr %CHECK_LINEWORD%`) do @set CHECK_STRING=%%F
    )
    rem echo version ok
    rem if not "%CHECK_STRING%" == "%CHECK_OK%"
    if "!CHECK_STRING:%CHECK_OK%=!" == "%CHECK_STRING%" error("validate failed not match %CHECK_STRING% != %CHECK_OK%")
    return

::: endfunc


:ExistsLabel
set LabelExists=1
findstr /i /r /c:"^[ ]*:%~1\>" "%SCRIPT_SOURCE%" >nul 2>nul
if errorlevel 1 set LabelExists=
goto :eof

#include("brickv_prepare.cmd")
#include("brickv_utils.cmd")
#include("brickv_genenv.cmd")
#include("brickv_download.cmd")


#include("..\larges\gradle\install-global-new2.cmd")
#include("..\larges\git\install-2.cmd")
