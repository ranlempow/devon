:: function brickv_CMD_install(ONLY_VERSIONS=N, args=....) delayedexpansion
::: function brickv_CMD_install(spec, reinstall=N, dry=N, no_check=N, newest=N, targetdir=?)

set ACCEPT=1

@rem 安裝的父目錄所在地
@rem 這個會複寫localdir, globaldir的設定
set REQUEST_TARGETDIR=%targetdir%

@rem 不真正下載與執行, 只顯示相關參數
if "%dry%" == "1" set DRYRUN=1

@rem 強迫重新下載與安裝
if "%reinstall%" == "1" set REINSTALL=1

call :BrickvPrepare "%spec%" %args%
set args=

ncall :brickv_install_init
ncall :brickv_install_versions

rem prepare: set APPNAME, APPVER, INSTALLER
call :ExistsLabel %APPNAME%_prepare
if defined LabelExists call :%APPNAME%_prepare
if not "%DOWNLOAD_URL_TEMPLATE%" == "" call set DOWNLOAD_URL=%DOWNLOAD_URL_TEMPLATE%


pcall :BrickvBeforeInstall
if defined ERROR_MSG goto :brickv_CMD_install_Error

call :brickv_install_predownload
if defined ERROR_MSG goto :brickv_CMD_install_Error

call :PrintTaskInfo
if "%DRYRUN%" == "1" goto :BrickvInstallFinal
if defined DOWNLOAD_URL pcall :BrickvDownload "%DOWNLOAD_URL%" "%INSTALLER%" --skip-exists
if defined ERROR_MSG goto :brickv_CMD_install_Error


call :brickv_install_unpack
if defined ERROR_MSG goto :brickv_CMD_install_Error
call :brickv_install_genenv
if defined ERROR_MSG goto :brickv_CMD_install_Error
call :brickv_install_validate
if defined ERROR_MSG (
    call :PrintMsg error validate failed: %ERROR_MSG%
    goto :brickv_CMD_install_Error
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
    rem set CHECK_EXEC=gradle
    rem set CHECK_EXEC_ARGS=
    rem set CHECK_CMD=gradle -v
    rem set CHECK_LINEWORD=Gradle
    rem set CHECK_OK=Gradle %VA_INFO_VERSION%
    if exist "%TARGET%\set-env.cmd" (
        call "%TARGET%\set-env.cmd" --validate --quiet
    ) else (
        error("missing %TARGET%\set-env.cmd")
    )
    if errorlevel 1 (
        if defined VALID_ERR (
            error(%VALID_ERR%)
        ) else (
            error("validation failed, but reason is not given")
        )
    )
::: endfunc


:ExistsLabel
set LabelExists=1
findstr /i /r /c:"^[ ]*:%~1\>" "%SCRIPT_SOURCE%" >nul 2>nul
if errorlevel 1 set LabelExists=
goto :eof



:brickv_install_init
call :MatchVersion --output-format env "%spec%"
set REQUEST_APP=%MATCH_APP%
set REQUEST_MAJOR=%MATCH_MAJOR%
set REQUEST_MINOR=%MATCH_MINOR%
set REQUEST_PATCH=%MATCH_PATCH%
set REQUEST_ARCH=%MATCH_ARCH%
set REQUEST_PATCHES=%MATCH_PATCHES%
set REQUEST_VER=%MATCH_VER%
rem set REQUEST_SPEC=%REQUEST_APP%=%REQUEST_VER%@%REQUEST_ARCH%[%REQUEST_PATCHES%]
if "%REQUEST_ARCH%" == "" (
    if "%PROCESSOR_ARCHITECTURE%" == "x86" (
        set REQUEST_ARCH=x86
    ) else (
        set REQUEST_ARCH=x64
    )
)
call :PrintVersion info request "%REQUEST_APP%" "%REQUEST_VER%" "%REQUEST_ARCH%" "%REQUEST_PATCHES%"

set APPNAME=%REQUEST_APP%

call :ExistsLabel %APPNAME%_init
if defined LabelExists (
    call :%APPNAME%_init
) else (
    error("%APPNAME% not in installable list")
)
if "%REQUEST_LOCATION%" == "" set REQUEST_LOCATION=global
set LabelExists=
goto :eof




:brickv_install_versions
if not "%PRJ_TMP%" == "" set TEMP=%PRJ_TMP%
set VERSION_SOURCE_FILE=%TEMP%\source-%APPNAME%.ver.txt
set VERSION_SPCES_FILE=%TEMP%\spces-%APPNAME%.ver.txt

if exist "%VERSION_SOURCE_FILE%" del "%VERSION_SOURCE_FILE%" >nul
copy /y NUL "%VERSION_SOURCE_FILE%" >NUL
if exist "%VERSION_SPCES_FILE%" del "%VERSION_SPCES_FILE%" >nul
copy /y NUL "%VERSION_SPCES_FILE%" >NUL

call :ExistsLabel %APPNAME%_versions
if defined LabelExists call :%APPNAME%_versions
if exist "%RELEASE_URL%" call :BrickvDownload "%RELEASE_URL%" "%VERSION_SPCES_FILE%"
rem if "%ONLY_VERSIONS%" == "1" (
rem     return %VERSION_SPCES_FILE%
rem )

if exist "%VERSION_SPCES_FILE%" (
    ncall :MatchVersion --output-format env --spec-match "%REQUEST_SPEC%" --specs-file "%VERSION_SPCES_FILE%"
) else (
    error("release version list is empty")
)
set LabelExists=
goto :eof




:brickv_install_predownload
call :ExistsLabel %APPNAME%_download
if defined LabelExists pcall :%APPNAME%_download
        if defined ERROR_MSG goto :eof
if defined DOWNLOAD_URL if "%INSTALLER%" == "" (
    call :FilenameFromUrl "%DOWNLOAD_URL%"
    set INSTALLER=%TEMP%\!Filename!
    set Filename=
)
goto :eof




:brickv_install_unpack
call :ExistsLabel %APPNAME%_unpack
if defined LabelExists pcall :%APPNAME%_unpack
        if defined ERROR_MSG goto :eof
if defined INSTALLER (
    if "%UNPACK_METHOD%" == "msi-install" pcall :InstallMsi "%INSTALLER%"
            if defined ERROR_MSG goto :eof
    if "%UNPACK_METHOD%" == "msi-unpack" pcall :UnpackMsi "%INSTALLER%" "%TARGET%"
            if defined ERROR_MSG goto :eof
    if "%UNPACK_METHOD%" == "unzip" pcall :Unzip "%INSTALLER%" "%TARGETDIR%"
            if defined ERROR_MSG goto :eof
)
if not defined NoCheckTarget (
    if not exist "%TARGET%" set "ERROR_MSG=unpack failed, cannot unpack installer"
    goto :eof
)
goto :eof




:brickv_install_genenv
call :ExistsLabel %APPNAME%_validate
if defined LabelExists call :%APPNAME%_validate
pcall :BrickvGenEnv "%TARGET%" "%APPNAME%" "%APPVER%" "%SETENV%"
        if defined ERROR_MSG goto :eof
goto :eof



:brickv_install_validate
rem set CHECK_EXIST=
rem set CHECK_EXEC=gradle
rem set CHECK_EXEC_ARGS=
rem set CHECK_CMD=gradle -v
rem set CHECK_LINEWORD=Gradle
rem set CHECK_OK=Gradle %VA_INFO_VERSION%
if exist "%TARGET%\set-env.cmd" (
    call "%TARGET%\set-env.cmd" --validate --quiet
) else (
    set "ERROR_MSG=missing %TARGET%\set-env.cmd" & goto :eof
)
if errorlevel 1 (
    if defined VALID_ERR (
        set "ERROR_MSG=%VALID_ERR%" & goto :eof
    ) else (
        set "ERROR_MSG=validation failed, but reason is not given" & goto :eof
    )
)
goto :eof


#include("semver3.cmd")
#include("brickv_prepare.cmd")
#include("brickv_utils.cmd")
#include("brickv_genenv.cmd")
#include("brickv_download.cmd")
#include("brickv_builtin_repo.cmd")
