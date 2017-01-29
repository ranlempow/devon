


::: function brickv_CMD_install(args=...)

set ACCEPT=1

call :BrickvPrepare %args%
rem call :PCALL_BrickvPrepare %args%
rem if not "%ERROR_MSG%" == "" XXXXX
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
if exist "%VERSION_SPCES_FILE%" del "%VERSION_SPCES_FILE%" >nul
call :ExistsLabel %APPNAME%_versions
if "%LabelExists%" == "1" call :%APPNAME%_versions
if exist "%RELEASE_URL%" call :BrickvDownload "%RELEASE_URL%" "%VERSION_SPCES_FILE%"
if exist "%VERSION_SPCES_FILE%" (
    call :MatchVersion --output-format env --spec-match "%REQUEST_SPEC%" --specs-file "%VERSION_SPCES_FILE%"
) else (
    if "%RELEASE_LIST%" == "" error("release version list is empty")
    call :MatchVersion --output-format env --spec-match "%REQUEST_SPEC%" "%RELEASE_LIST%"
)


rem prepare: set APPNAME, APPVER, INSTALLER
call :ExistsLabel %APPNAME%_prepare
if "%LabelExists%" == "1" call :%APPNAME%_prepare
if not "%DOWNLOAD_URL_TEMPLATE%" == "" call set DOWNLOAD_URL=%DOWNLOAD_URL_TEMPLATE%


call :PCALL_BrickvBeforeInstall

rem download
call :ExistsLabel %APPNAME%_download
if "%LabelExists%" == "1" call :%APPNAME%_download
if "%DOWNLOAD_URL%" call :PCALL_BrickvDownload "%DOWNLOAD_URL%" "%DOWNLOAD_FILE%"

rem unpack
call :ExistsLabel %APPNAME%_unpack
if "%LabelExists%" == "1" call :%APPNAME%_unpack
if not "%INSTALLER%" == "" (
    if "%UNPACK_METHOD%" == "msi-install" call :PCALL_InstallMsi "%INSTALLER%"
    if "%UNPACK_METHOD%" == "msi-unpack" call :PCALL_UnpackMsi "%INSTALLER%" "%TARGET%"
    if "%UNPACK_METHOD%" == "unzip" call :PCALL_Unzip "%INSTALLER%" "%TARGET%"
)

rem vaildate
call :ExistsLabel %APPNAME%_vaildate
if "%LabelExists%" == "1" call :%APPNAME%_vaildate
call :PCALL_BrickvGenEnv
call :PCALL_BrickvVaildate
if not "%ERROR_MSG%" == "" call :PrintMsg warning vaildate %ERROR_MSG%
if "%ERROR_MSG%" == "" call :PrintMsg noraml vaildate succeed
set ERROR_MSG=



call :PCALL_BrickvDone
cmd /C exit /b 0
return


:Error
call :PrintMsg error message error "%ERROR_MSG%"
call :PCALL_BrickvDone
cmd /C exit /b 1
::: endfunc


:NormalizePath
    set Normalized=%~dpfn1
    goto :eof


:ExistsLabel
set LabelExists=1
findstr /i /r /c:"^[ ]*:%~1\>" "%SCRIPT_SOURCE%" >nul 2>nul
if errorlevel 1 set LabelExists=
goto :eof

#include("brickv_prepare.cmd")
#include("brickv_utils.cmd")
#include("brickv_genenv.cmd")

:appxxx_init:
goto :eof

:appxxx_versions:
set RELEASE_LIST=appxxx=1.0
goto :eof
