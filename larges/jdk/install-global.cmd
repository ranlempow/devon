@call %~dp0..\..\base\getargs.cmd %*
@if errorlevel 1 @goto :_Error

@if [%REQUEST_ARCH%] == [] @set REQUEST_ARCH=x32
@if "%REQUEST_ARCH%" == "x32" @set JDK_ARCH=i586
@if "%REQUEST_ARCH%" == "x64" @set JDK_ARCH=x64

@if [%REQUEST_VAR%] == [] @(
    @REM default version
    @set JDK_VER=8u91
) else @(
    @set JDK_VER=%REQUEST_VAR%
)

@set JDK_NAME=jdk-%JDK_VER%-windows-%JDK_ARCH%
@set JDK_URL=http://download.oracle.com/otn-pub/java/jdk/%JDK_VER%/%JDK_NAME%.exe
@if [%REQUEST_TARGETDIR%] == [] @(
    @set TARGETDIR=%LOCALAPPDATA%\Programs\%JDK_NAME%
) else @(
    @set TARGETDIR=%REQUEST_TARGETDIR%
)
@set JDK_FILE=%TEMP%\%JDK_NAME%.exe
@set JDK_BUILD=0

@del %JDK_FILE%

@echo finding jdk download url...
:TryDownload
@if not %JDK_BUILD% == 0 @(
    @set JDK_URL=http://download.oracle.com/otn-pub/java/jdk/%JDK_VER%-b%JDK_BUILD%/%JDK_NAME%.exe
)
@if not %JDK_BUILD% geq 30 @goto :DownloadJDKorRetry

:DownloadJDKorRetry
@call %~dp0..\..\base\psdownloader.cmd "%JDK_URL%" "%JDK_FILE%" --skip-exists --cookie "oraclelicense=accept-securebackup-cookie"
@if not exist "%JDK_FILE%" @(
    @set /A JDK_BUILD+=1
    @goto :TryDownload
)

:UnzipJDK
@echo install %JDK_FILE% to %TARGETDIR%
@call :_DeleteBeforeUnzip "%JDK_FILE%" "%TEMP%\jdk"
@if errorlevel 1 goto :eof
@call :_DeleteBeforeUnzip "%TEMP%\jdk\tools.zip" "%TARGETDIR%"
@if errorlevel 1 goto :eof

:MakeJDKPortable
@pushd "%TARGETDIR%"
@for /r %%x in (*.pack) do .\bin\unpack200 -r "%%x" "%%~dx%%~px%%~nx.jar"
@popd
@goto :_Done



:_Unzip
set ZipFile=%~1
set ExtractTo=%~2
"C:\Program Files\7-Zip\7z" x -o"%ExtractTo%" "%ZipFile%" 
@if errorlevel 1 @(
    @set "ERROR_MSG=啟動錯誤: 解壓縮失敗, 也許這不是正確的壓縮檔."
    @goto :_Error
)
@goto :eof


:_DeleteBeforeUnzip
set ZipFile=%~1
set ExtractTo=%~2
if exist %ExtractTo% (
    rd /Q /S %ExtractTo%
)
mkdir %ExtractTo%
call :_Unzip "%~1" "%~2"
goto :eof


:_Error
@echo.
@echo ==========================
@echo.
@echo %ERROR_MSG%
@echo.
@cmd /C exit /b 1
@goto :eof


:_Done
@echo.
@echo Done.
@cmd /C exit /b 0
@goto :eof
