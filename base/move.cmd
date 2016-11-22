@if not "%ERROR_MSG%" == "" @goto :Error
@if not exist "%~1" @(
	@set ERROR_MSG=src folder %~1 not exist
    @goto :Error
)
@if exist "%~2" @(
	@set ERROR_MSG=dst folder %~2 already exist
    @goto :Error
)
@move "%~1" "%~2" > nul
@call "%VA_HOME%\base\print.cmd" debug message move "%~1 %~2"

@if errorlevel 1 @(
    @set ERROR_MSG=can not move folder
    @goto :Error
)
:Error