@REM parse args
@set dp0=%~dp0
@set Url=%~1
@set Output=%~2
@shift
@shift

:Loop
@set head=%~1
@set parm=%~2

@if "%head%" == "" @goto :Main
@if "%parm%" == "" @set parm=__NONE__

@if "%head%" == "--cookie" @(
    @set Cookie=%parm%
    @goto :Parse2
)

@if "%head%" == "--skip-exists" @(
	@if "%FORCE%" == "" @set SkipExists=1
	@goto :Parse1
)
@goto :_BadOption


:Parse1
@shift
@goto :Loop
:Parse2
@if "%parm%" == "__NONE__" @goto :_BadArgument
@if "%parm:~0,1%" == "-" @goto :_BadArgument
@shift
@shift
@goto :Loop
:_BadArgument
@set ERROR_MSG=Bad argument after "%head%"
@goto :_Error
:_BadOption
@set ERROR_MSG=Unkwond option "%head%"
@goto :_Error


:Main
@set head=
@set parm=

@set ScriptText=
@for /f "delims=" %%x in (%dp0%psdownloader.ps1) do @call :_AppendText "%%x"

@PowerShell -Command "$url='%Url%';$output='%Output%';$Cookie='%Cookie%';$SkipExists='%SkipExists%';%ScriptText%"
@if errorlevel 1 @(
	@set /P ERROR_MSG=< "%TEMP%\download_error"
	@goto :_Error
) else @(
	@goto :_Quit
)

:_BadArgument
@set ERROR_MSG=[download] Bad argument after "%head%"
@goto :_Error


:_AppendText
@set ScriptText=%ScriptText%;%~1
@goto :eof


:_Error
@call :_Quit
@cmd /C exit /b 1
@goto :eof

:_Quit
@set ScriptText=
@set Url=
@set Output=
@set SkipExists=
@goto :eof

