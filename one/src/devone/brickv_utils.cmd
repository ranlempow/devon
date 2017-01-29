::: function Unzip(ZipFile, ExtractTo, delete_before=N) delayedexpansion
    rem Extract the contants of the zip file.

    if not "%delete_before%" == "1" goto :_Unzip
    if exist "%ExtractTo%" (
        call :PrintMsg debug rmdir "%ExtractTo%"
        rd /Q /S "%ExtractTo%"
    )

    :_Unzip
    if not exist "%ExtractTo%" (
        call :PrintMsg debug mkdir "%ExtractTo%"
        mkdir "%ExtractTo%"
    )
    call :PrintMsg info unzip %ExtractTo%
    echo  set objShell = CreateObject("Shell.Application") > "%TEMP%\Unzip.vbs"
    echo  set FilesInZip=objShell.NameSpace("!ZipFile!").items >> "%TEMP%\Unzip.vbs"
    echo  objShell.NameSpace("!ExtractTo!").CopyHere(FilesInZip) >> "%TEMP%\Unzip.vbs"

    "%TEMP%\Unzip.vbs"
    if errorlevel 1 error("unzip failed. maybe is not a zip file")
::: endfunc



:::　function UnpackMsi(MSI_FILE, MSI_UNPACK_DIR=)
    if "%MSI_UNPACK_DIR%" == "" error("MSI_UNPACK_DIR undefined")

    msiexec /a "%MSI_FILE%" /qb TARGETDIR="%TARGETDIR%\unchecked-%NAME%"
    if errorlevel 1 (
        if exist "%TARGETDIR%\unchecked-%NAME%" rd /Q /S "%TARGETDIR%\unchecked-%NAME%"
        error("msiexec install failed")
    )
    if exist "%TARGETDIR%\%NAME%" rename "%TARGETDIR%\%NAME%" "padding-%NAME%"
    xcopy "%TARGETDIR%\unchecked-%NAME%%MSI_UNPACK_DIR%" "%TARGETDIR%\%NAME%\"> nul
    if errorlevel 1 (
        rem rollback
        rd /Q /S "%TARGETDIR%\unchecked-%NAME%"
        if exist "%TARGETDIR%\padding-%NAME%" rename "%TARGETDIR%\padding-%NAME%" "%NAME%"
        error("xcopy failed")
    )
    rem cleanup
    if exist "%TARGETDIR%\unchecked-%NAME%" rd /Q /S "%TARGETDIR%\unchecked-%NAME%"
    if exist "%TARGETDIR%\padding-%NAME%" rd /Q /S "%TARGETDIR%\padding-%NAME%"
    call :PrintMsg normal msi success
    return

::: endfunc

:::　function InstallMsi(MSI_FILE)
    msiexec /i "%MSI_FILE%" /qb
    if errorlevel 1 error("msiexec install failed")
    call :PrintMsg normal msi success
:::



::: function MoveFile(SRC, DST)
    if not exist "%SRC%" error("source %SRC% not exist")
    if exist "%DST%" error("destination %DST% exist")
    move "%SRC%" "%DST%" > nul
    if errorlevel 1 error("An error occurred when move %SRC% to %DST%")

    call :PrintMsg debug message move "%SRC% %DST%"
::: endfunc



::: function BrickvBeforeInstall()
    @rem require: REQUEST_*, APPNAME, APPVER, INSTALLER
    @rem output: TARGETDIR, REAL_TARGET, BACK_TARGET, NAME
    rem @if not "%ERROR_MSG%" == "" @goto :Error


    if "%APPVER%" == "" set APPVER=%MATCH_VER%
    if "%REQUEST_NAME%" == "" set REQUEST_NAME=%APPNAME%-%APPVER%

    if not "%TARGET%" == "" call :NormalizePath "%TARGET%\.."
    if not "%TARGET%" == "" set TARGETDIR=%Normalized%

    if not "%REQUEST_TARGETDIR%" == "" set TARGETDIR=%REQUEST_TARGETDIR%
    if "%TARGETDIR%" == "" if "%REQUEST_LOCATION%" == "global" set TARGETDIR=%LOCALAPPDATA%\brickv\apps
    if "%TARGETDIR%" == "" if "%REQUEST_LOCATION%" == "local" set TARGETDIR=%PRJ_BIN%

    if "%TARGET%" == "" if not "%TARGETDIR%" == "" set TARGET=%TARGETDIR%\%REQUEST_NAME%

    if "%TARGET%" == "" error("TARGET not specific")
    if "%TARGETDIR%" == "" error("TARGETDIR not specific")


    set TARGETDIR=%REQUEST_TARGETDIR%
    @if "%REQUEST_NAME%" == "" @(
        @set NAME=%APPNAME%-%APPVER%
    ) else @(
        @set NAME=%REQUEST_NAME%
    )

    call :PrintTaskInfo

    set REAL_TARGET=%TARGETDIR%\%NAME%
    set BACK_TARGET=%TARGETDIR%\backupfor-%APPNAME%
    if not "%DRYRUN%" == "1" (
        if exist "%REAL_TARGET%" call :MoveFile "%REAL_TARGET%" "%BACK_TARGET%"
    )
    return %TARGETDIR%, %REAL_TARGET%, %BACK_TARGET%, %NAME%
::: endfunc



::: function BrickvDone()
    @rem require: REAL_TARGET, BACK_TARGET, APPNAME, MATCH_VER

    @if not "%ERROR_MSG%" == "" @(
        @if not "%DRYRUN%" == "1" @(
            rem rollback
            if exist "%REAL_TARGET%" rd /Q /S "%REAL_TARGET%"
            if exist "%BACK_TARGET%" move "%BACK_TARGET%" "%REAL_TARGET%" > null
            rem @goto :Error
        )
    ) else @(
        @REM commit
        @if exist "%BACK_TARGET%" @rd /Q /S "%BACK_TARGET%"
    )

    if "%DRYRUN%" == "1" @(
        call :PrintMsg normal message skip "%APPNAME%@%MATCH_VER% at %REAL_TARGET%"
    ) else @(
        call :PrintMsg normal message installed "%APPNAME%@%MATCH_VER% at %REAL_TARGET%"
    )
::: endfunc



::: function BrickvVaildate()
    set VAILDATE=1
    if "%SETENV_TARGET%" == "" error("SETENV_TARGET undefined")
    if not exist "%SETENV_TARGET%" error("%SETENV_TARGET% not exist")
    call "%SETENV_TARGET%" --info
    if not "%VA_INFO_APPNAME%" == "%APPNAME%" error("the demand application is %APPNAME%, but %VA_INFO_APPNAME% installed")
    call "%SETENV_TARGET%" --vaildate --quiet
    if errorlevel 1 error("%VA_INFO_APPNAME% vaildate failed")
::: endfunc




rem @cmd /C exit /b 0
rem @goto :eof
rem :Error
rem @call "%VA_HOME%\base\print.cmd" error message error "%ERROR_MSG%"
rem @cmd /C exit /b 1
rem @goto :eof
