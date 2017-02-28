:git_init
    set _RELEASE_URL=https://api.github.com/repos/git-for-windows/git/releases
    rem if "%REQUEST_ARCH%" == "x86" set GIT_ARCH=32
    rem if "%REQUEST_ARCH%" == "x64" set GIT_ARCH=64
    set ACCEPT=local global
    goto :eof

rem "browser_download_url": "https://github.com/git-for-windows/git/releases/download/v2.11.0.windows.3/PortableGit-2.11.0.3-32-bit.7z.exe"
rem "browser_download_url": "https://github.com/git-for-windows/git/releases/download/v2.11.0.windows.3/PortableGit-2.11.0.3-64-bit.7z.exe"
:git_versions
    set "regex=browser_download_url.*PortableGit-[0-9]*\.[0-9]*\.[0-9]*-%GIT_ARCH%"
    FOR /L %%G IN (1,1,2) DO (
        ncall :BrickvDownload "%_RELEASE_URL%?page=%%G" "%VERSION_SOURCE_FILE%"
        FOR /F "tokens=* USEBACKQ" %%F IN (
                `FINDSTR  /R /C:"%regex%" %VERSION_SOURCE_FILE%`) DO (
            for /F "delims=: tokens=3" %%P in ("%%F") do (
                set SFX_URL=https:%%P
            )

            for /F "delims=/ tokens=8" %%P in ("!SFX_URL!") do (
                set SFX_NAME=%%P
            )
            for /F "delims=- tokens=2,3" %%A in ("!SFX_NAME!") do (
                set GIT_VER=%%A
                set GIT_ARCH=%%B
            )
            if "!GIT_ARCH!" == "32" set GIT_ARCH=x86
            if "!GIT_ARCH!" == "64" set GIT_ARCH=x64
            echo.git=!GIT_VER!@!GIT_ARCH![.]$!SFX_URL:~0,-1!>> "%VERSION_SPCES_FILE%"
            echo.git=!GIT_VER!@!GIT_ARCH![ssh-stab]$!SFX_URL:~0,-1!>> "%VERSION_SPCES_FILE%"

        )
    )
    goto :eof

:git_prepare
    set APPVER=%MATCH_VER%
    rem set APPNAME=git-%MATCH_VER%-%MATCH_ARCH%
    if "%REQUEST_NAME%" == "" set REQUEST_NAME=git-%APPVER%-%MATCH_ARCH%
    set DOWNLOAD_URL=%MATCH_CARRY%
    goto :eof

:git_unpack
    rem set SETENV=%SETENV%;GRADLE_HOME:$SCRIPT_SOURCE$
    set SETENV=%SETENV%;$SCRIPT_FOLDER$\cmd
    "%INSTALLER%" -y -InstallPath="%TARGET%"
    if errorlevel 1 error("7z SFX self unpack failed")
    echo MATCH_PATCHES:%MATCH_PATCHES%
    for /F "delims=, tokens=*" %%P in ("%MATCH_PATCHES%") do (
        echo PATCHES: %%P
        if "%%P" == "ssh-stab" call :git_install_ssh_stab
    )
    goto :eof

:git_validate
    set CHECK_EXIST=
    set CHECK_CMD=git --version
    set CHECK_LINEWORD=git
    set CHECK_OK=git version %%VA_INFO_VERSION%%
    goto:eof


:git_install_ssh_stab
    move "%TARGET%\usr\bin\ssh.exe" "%TARGET%\usr\bin\realssh.exe"
    move "%TARGET%\usr\bin\scp.exe" "%TARGET%\usr\bin\realscp.exe"

    #include(SSHScript, "ssh")
    echo.!SSHScript! > "%TARGET%\usr\bin\ssh"
    echo.!SSHScript! > "%TARGET%\usr\bin\scp"

    goto :eof
