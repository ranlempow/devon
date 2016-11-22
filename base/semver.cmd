@rem require: VERSION_SPCES_FILE, REQUEST_SPEC
@rem output: MATCH_*


@REM app[@ver[#arch]] app@...
@REM app1@3.1.X#x86 app2@3.1.X#x86

@REM parse args
@set dp0=%~dp0

@REM init args
@set specsString=
@set specsFile=
@set bestMatch=1
@set specMatch==x
@set outputFormat=
@set output=
@set logging=

:Loop
@set head=%~1
@set parm=%~2

@if "%head%" == "" @goto :Main
@if "%parm%" == "" @set parm=__NONE__

@if "%head%" == "--default-args" @(
    @rem --specs-file "%VERSION_SPCES_FILE%" --match "%REQUEST_SPEC%" --output-format env --logging
    @set specsFile=%VERSION_SPCES_FILE%
    @set specMatch=%REQUEST_SPEC%
    @set outputFormat=env
    @set logging=1
    @goto :Parse1
)
@if "%head%" == "--specs" @(
    @shift
    @goto :ParseSpecsString
)
@if "%head%" == "--specs-file" @(
    @set specsFile=%parm%
    @goto :Parse2
)
@if "%head%" == "--match" @(
    @set specMatch=%parm%
    @goto :Parse2
)
@if "%head%" == "--all" @(
    @set bestMatch=
    @goto :Parse1
)
@if "%head%" == "--output-format" @(
    @set outputFormat=%parm%
    @goto :Parse2
)
@if "%head%" == "--output" @(
    @set output=%parm%
    @goto :Parse2
)
@if "%head%" == "--logging" @(
    @set logging=1
    @goto :Parse1
)
@goto :_BadOption

:ParseSpecsString
@set parm=%~1
@if "%parm%" == "__NONE__" @goto :Main
@if "%parm:~0,1%" == "-" @goto :Loop
@set specsString=%specsString% %parm%
@shift
@goto :ParseSpecsString

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

@set SemverScriptText=
@for /f "delims=" %%x in (%dp0%semver.ps1) do @call :_AppendText "%%x"

@set outputEnv=
@if "%outputFormat%" == "env" (
    @set outputEnv=1
    @set outputFormat=cmd
)

@set PSScriptText=
@set PSScriptText=%PSScriptText%$specsString='%specsString%';
@set PSScriptText=%PSScriptText%$specsFile='%specsFile%';
@set PSScriptText=%PSScriptText%$specMatch='%specMatch%';
@set PSScriptText=%PSScriptText%$bestMatch='%bestMatch%';
@set PSScriptText=%PSScriptText%$outputFormat='%outputFormat%';
@set PSScriptText=%PSScriptText%$output='%output%';
@set PSScriptText=%PSScriptText%

@set MATCH_APP=
@set MATCH_MAJOR=
@set MATCH_MINOR=
@set MATCH_PATCH=
@set MATCH_ARCH=
@set MATCH_PATCHES=

@if "%outputEnv%" == "1" goto :ToEnv
@PowerShell -Command "%PSScriptText%%SemverScriptText:"=%"

@goto :_Done


:ToEnv
@for /F "tokens=1-6 USEBACKQ" %%A IN (`@PowerShell -Command "%PSScriptText%%SemverScriptText:"=%"`) do @(
    @set MATCH_APP=%%A
    @set MATCH_MAJOR=%%B
    @set MATCH_MINOR=%%C
    @set MATCH_PATCH=%%D
    @set MATCH_ARCH=%%E
    @set MATCH_PATCHES=%%F
)
@set MATCH_VER=%MATCH_MAJOR%
@if not "%MATCH_MINOR%" == "x" @if not "%MATCH_MINOR%" == "" @set MATCH_VER=%MATCH_VER%.%MATCH_MINOR%
@if not "%MATCH_PATCH%" == "x" @if not "%MATCH_PATCH%" == "" @set MATCH_VER=%MATCH_VER%.%MATCH_PATCH%
@if "%MATCH_VER%" == "" @(
    @set ERROR_MSG=request version %specMatch% not found
    @goto :_Error
)
@if "%logging%" == "1" @(
    @call "%VA_HOME%\base\print.cmd" info version match %MATCH_APP% %MATCH_VER% %MATCH_ARCH% %MATCH_PATCHES%
)
@goto :_Done



:_AppendText
@set SemverScriptText=%SemverScriptText%;"%~1"
@goto :eof


:_Error
@call :_Quit
@cmd /C exit /b 1
@goto :eof

:_Done
@call :_Quit
@cmd /C exit /b 0
@goto :eof

:_Quit
@set head=
@set parm=
@goto :eof
