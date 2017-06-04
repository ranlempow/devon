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

    call :PrintMsg debug move "%SRC% %DST%"
::: endfunc


::: function FilenameFromUrl(Url)
for /f %%i in ("%Url%") do set Filename=%%~nxi
for /f "delims=?" %%a in ("%Filename%") do set Filename=%%a
for /f "delims=#" %%a in ("%Filename%") do set Filename=%%a
return %Filename%
::: endfunc


::: function BrickvBeforeInstall()
    @rem require: REQUEST_*, APPNAME, APPVER
    @rem output: TARGETDIR, REAL_TARGET, BACK_TARGET, TARGET_NAME

    if "%APPVER%" == "" set APPVER=%MATCH_VER%
    set TARGET_NAME=%APPNAME%-%APPVER%

    if not "%REQUEST_NAME%" == "" set TARGET_NAME=%REQUEST_NAME%

    if not "%REQUEST_TARGETDIR%" == "" set TARGETDIR=%REQUEST_TARGETDIR%
    if "%TARGETDIR%" == "" if "%REQUEST_LOCATION%" == "global" set TARGETDIR=%BRICKV_GLOBAL_DIR%
    if "%TARGETDIR%" == "" if "%REQUEST_LOCATION%" == "local" set TARGETDIR=%BRICKV_LOCAL_DIR%
    rem echo TARGET_NAME:%TARGET_NAME%
    rem echo TARGETDIR:%TARGETDIR%
    rem echo REQUEST_LOCATION:%REQUEST_LOCATION%

    if not "%TARGET%" == "" for /f %%i in ("%TARGET%\..") do set TARGETDIR=%%~fi
    if not "%TARGET%" == "" for /f %%i in ("%TARGET%") do set TARGET_NAME=%%~ni
    if "%TARGETDIR%" == "" error("TARGETDIR not specific")


    set TARGET=%TARGETDIR%\%TARGET_NAME%
    set REAL_TARGET=%TARGET%
    set BACK_TARGET=%TARGETDIR%\backupfor-%APPNAME%
    set FAIL_TARGET=%TARGETDIR%\failed-%APPNAME%
    if "%DRYRUN%" == "1" goto :BrickvBeforeInstall_retrun

    if not exist "%TARGETDIR%" mkdir "%TARGETDIR%"
    if exist "%BACK_TARGET%" rd /Q /S "%BACK_TARGET%"
    if not exist "%REAL_TARGET%" goto :BrickvBeforeInstall_retrun
    move "%REAL_TARGET%" "%BACK_TARGET%" > nul
    if errorlevel 1 error("%REAL_TARGET% can not move")

:BrickvBeforeInstall_retrun
    return %TARGET%, %TARGETDIR%, %TARGET_NAME%, %REAL_TARGET%, %BACK_TARGET%, %FAIL_TARGET%
::: endfunc



::: function BrickvDone()
    rem require: REAL_TARGET, BACK_TARGET, APPNAME, MATCH_VER

    if not "%_ERROR_MSG%" == "" (
        if not "%DRYRUN%" == "1" (
            rem rollback
            if exist "%FAIL_TARGET%" rd /Q /S "%FAIL_TARGET%"
            if exist "%REAL_TARGET%" move "%REAL_TARGET%" "%FAIL_TARGET%"
            if exist "%BACK_TARGET%" move "%BACK_TARGET%" "%REAL_TARGET%" > nul
        )
        pcall :PrintMsg error error "%_ERROR_MSG%"
        return
    ) else (
        rem commit
        if exist "%BACK_TARGET%" rd /Q /S "%BACK_TARGET%"
    )

    if "%DRYRUN%" == "1" (
        call :PrintMsg normal skip %APPNAME%@%MATCH_VER% at %REAL_TARGET%
    ) else (
        call :PrintMsg normal installed %APPNAME%@%MATCH_VER% at %REAL_TARGET%
    )
::: endfunc



::: function BrickvValidate()
    set VAILDATE=1
    if "%SETENV_TARGET%" == "" error("SETENV_TARGET undefined")
    if not exist "%SETENV_TARGET%" error("%SETENV_TARGET% not exist")
    call "%SETENV_TARGET%" --info
    if not "%VA_INFO_APPNAME%" == "%APPNAME%" error("the demand application is %APPNAME%, but %VA_INFO_APPNAME% installed")
    call "%SETENV_TARGET%" --validate --quiet
    if errorlevel 1 error("%VA_INFO_APPNAME% validate failed")
::: endfunc




rem @cmd /C exit /b 0
rem @goto :eof
rem :Error
rem @call "%VA_HOME%\base\print.cmd" error message error "%ERROR_MSG%"
rem @cmd /C exit /b 1
rem @goto :eof
