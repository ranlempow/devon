


::: function brickv_CMD_install(ONLY_VERSIONS=N, args=....) delayedexpansion
:: function brickv_CMD_install(spec, reinstall=N, dry=N, no_check=N, newest=N, targetdir=?)

set ACCEPT=1

@rem 安裝的父目錄所在地
@rem 這個會複寫localdir, globaldir的設定
set REQUEST_TARGETDIR=%targetdir%

@rem 不真正下載與執行, 只顯示相關參數
if "%dry%" == "1" set DRYRUN=1

@rem 強迫重新下載與安裝
if "%reinstall%" == "1" set REINSTALL=1

call :BrickvPrepare "%spec%" %args%

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



set args=
set APPNAME=%REQUEST_APP%

rem init
call :ExistsLabel %APPNAME%_init
if "%LabelExists%" == "1" (
    call :%APPNAME%_init
) else (
    error("%APPNAME% not in installable list")
)
@rem TODO: x
if "%ALLOW_EMPTY_LOCATION%" == "1" if "%REQUEST_LOCATION%" == "" set REQUEST_LOCATION=global


rem detect
rem call :ExistsLabel %APPNAME%_detect
rem if "%LabelExists%" == 1 call :%APPNAME%_detect

rem versions
if not "%PRJ_TMP%" == "" set TEMP=%PRJ_TMP%
set VERSION_SOURCE_FILE=%TEMP%\source-%APPNAME%.ver.txt
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
set NoCheckTarget=0
rem set ValidateFailed=0
call :ExistsLabel %APPNAME%_validate
if "%LabelExists%" == "1" call :%APPNAME%_validate
rem if "%ValidateFailed%" == "1" (
rem     set ERROR_MSG="extra validate failed"
rem     goto :brickv_CMD_install_Error
rem )

if "%NoCheckTarget%" == "0" (
    if not exist "%TARGET%" error("unpack failed, cannot unpack installer")
)
pcall :BrickvGenEnv "%TARGET%" "%APPNAME%" "%APPVER%" "%SETENV%"
        if not "%ERROR_MSG%" == "" goto :brickv_CMD_install_Error
pcall :BrickvValidate
if not "%ERROR_MSG%" == "" (
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


::: function BrickvValidate2() delayedexpansion
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
    if errorlevel 1 error("self validate failed")

    if not "%CHECK_EXIST%" == "" if not exist "%SCRIPT_FOLDER%\%CHECK_EXIST%" (
        error("exist validate failed %SCRIPT_FOLDER%\%CHECK_EXIST%")
    )
    if not "%CHECK_EXEC%" == "" (
        if not exist "%SCRIPT_FOLDER%\%CHECK_EXEC%" (
            error("validate failed, because %SCRIPT_FOLDER%\%CHECK_EXIST% not exist")
        ) else (
            "%SCRIPT_FOLDER%\%CHECK_EXEC%" %CHECK_EXEC_ARGS%
            if errorlevel 1 error("execute validate failed")
        )
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


::: function BrickvValidate() delayedexpansion
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

#include("brickv_prepare.cmd")
#include("brickv_utils.cmd")
#include("brickv_genenv.cmd")
#include("brickv_download.cmd")

#include("..\larges\gradle\install-global-new2.cmd")
#include("..\larges\git\install-2.cmd")
#include("..\larges\clink\install.cmd")
#include("..\larges\ansicon\install.cmd")
#include("..\larges\nodejs\install.cmd")
#include("..\larges\python\install.cmd")
#include("..\larges\choco\install.cmd")
