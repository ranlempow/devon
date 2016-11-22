@setlocal
@set MSI_ACTION=%~1
@set MSI_FILE=%~2
@set MSI_UNPACK_DIR=%~3

@if "%MSI_ACTION%" == "unpack" @goto :Unpack
@if "%MSI_ACTION%" == "install" @goto :Install
@set ERROR_MSG=argumnet MSI_ACTION most set
@goto :_Error


:Unpack
@msiexec /a "%MSI_FILE%" /qb TARGETDIR="%TARGETDIR%\uncheck-%NAME%"
@if errorlevel 1 @(
    @set ERROR_MSG=MSI install failed
    @goto :_Error
)
@if exist "%TARGETDIR%\%NAME%" @rename "%TARGETDIR%\%NAME%" "padding-%NAME%"
@xcopy "%TARGETDIR%\uncheck-%NAME%%MSI_UNPACK_DIR%" "%TARGETDIR%\%NAME%\"> nul
@if errorlevel 1 @(
    @rd /Q /S "%TARGETDIR%\uncheck-%NAME%"
    @if exist "%TARGETDIR%\padding-%NAME%" @rename "%TARGETDIR%\padding-%NAME%" "%NAME%"
    @set ERROR_MSG=xcopy failed
    @goto :_Error
)
@rd /Q /S "%TARGETDIR%\uncheck-%NAME%"
@if exist "%TARGETDIR%\padding-%NAME%" @rd /Q /S "%TARGETDIR%\padding-%NAME%"
@goto :_Done


:Install
@msiexec /i "%MSI_FILE%" /qb
@if errorlevel 1 @(
    @set ERROR_MSG=MSI install failed
    @goto :_Error
)
@goto :_Done


:_Error
@cmd /C exit /b 1
@endlocal
@goto :eof


:_Done
@cmd /C exit /b 0
@call "%VA_HOME%\base\print.cmd" normal message msi success
@endlocal
@goto :eof
