@rem require: VERSION_SPCES_FILE, REQUEST_SPEC
@rem output: MATCH_*
@rem example: app[@ver[#arch]] app@...
@rem example: app1@3.1.X#x86 app2@3.1.X#x86

::: function MatchVersion(
                          default_args=N,
                          specs_file=?, spec_match==x,
                          all=N, output_format=?, output=?,
                          specs_string=.....) delayedexpansion

#include(SemverScriptText, "semver3.vbs")

if "%default_args%" == "1" (
    rem using following default parameters
    rem --specs-file "%VERSION_SPCES_FILE%" --match "%REQUEST_SPEC%" --output-format env
    set specs_file=%VERSION_SPCES_FILE%
    set spec_match=%REQUEST_SPEC%
    set output_format=env
)

if not exist "%specs_file%" if "%specs_string%" == "" (
    error("no version specific, use --specs_file or [specs_string...]")
)

set bestMatch=1
if "%all%" == "1" set bestMatch=

set specMatch=%spec_match%
set specsFile=%specs_file%
set specsString=%specs_string%


set outputFormat=%output_format%
echo !SemverScriptText! > "%TEMP%\semver.vbs"
if "%output_format%" == "env" (
    set outputFormat=cmd
    goto :ToEnv
)

cscript /nologo "%TEMP%\semver.vbs"
return


:ToEnv
rem rm "%TEMP%\matched_versions.txt" 2>nul
rem 1>"%TEMP%\matched_versions.txt" cscript /nologo "%TEMP%\semver.vbs"
rem 1>&2 echo %specMatch%
rem 1>&2 echo %specsFile%
rem 1>&2 cscript /nologo "%TEMP%\semver.vbs"

for /F "tokens=1-9 usebackq" %%A IN (`cscript /nologo "%TEMP%\semver.vbs"`) do (
    set MATCH_NAME=%%A
    set MATCH_APP=%%B
    set MATCH_MAJOR=%%C
    set MATCH_MINOR=%%D
    set MATCH_PATCH=%%E
    set MATCH_ARCH=%%F
    set MATCH_PATCHES=%%~G
    set MATCH_OPTIONS=%%~H
    set MATCH_CARRY=%%~I
)

set MATCH_VER=%MATCH_MAJOR%
if not "%MATCH_MINOR%" == "x" if not "%MATCH_MINOR%" == "" set MATCH_VER=%MATCH_VER%.%MATCH_MINOR%
if not "%MATCH_PATCH%" == "x" if not "%MATCH_PATCH%" == "" set MATCH_VER=%MATCH_VER%.%MATCH_PATCH%

if "%MATCH_VER%" == "" error("request version %spec_match% not found")
call :PrintVersion info match "%MATCH_APP%" "%MATCH_VER%" "%MATCH_ARCH%" "%MATCH_PATCHES%"

return %MATCH_NAME%, %MATCH_APP%, %MATCH_VER%, ^\n^
       %MATCH_MAJOR%, %MATCH_MINOR%, %MATCH_PATCH%, ^\n^
       %MATCH_ARCH%, %MATCH_PATCHES%, %MATCH_OPTIONS%, %MATCH_CARRY%

::: endfunc

#include("print.cmd")
