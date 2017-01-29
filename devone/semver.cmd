@rem TODO: Need test (simple test is passed)

@rem require: VERSION_SPCES_FILE, REQUEST_SPEC
@rem output: MATCH_*
@rem example: app[@ver[#arch]] app@...
@rem example: app1@3.1.X#x86 app2@3.1.X#x86

::: function MatchVersion(
                          default_args=N,
                          specs_file=?, spec_match==x,
                          all=N, output_format=?, output=?,
                          specs_string=.....) delayedexpansion

#include(SemverScriptText, "semver.ps1")

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

set best_match=1
if "%all%" == "1" set best_match=

set output_env=
if "%output_format%" == "env" (
    set output_env=1
    set output_format=cmd
)

@set PSScriptText=
@set PSScriptText=%PSScriptText%$specsString='%specs_string%';
@set PSScriptText=%PSScriptText%$specsFile='%specs_file%';
@set PSScriptText=%PSScriptText%$specMatch='%spec_match%';
@set PSScriptText=%PSScriptText%$bestMatch='%best_match%';
@set PSScriptText=%PSScriptText%$outputFormat='%output_format%';
@set PSScriptText=%PSScriptText%$output='%output%';
@set PSScriptText=%PSScriptText%

rem @set MATCH_APP=
rem @set MATCH_MAJOR=
rem @set MATCH_MINOR=
rem @set MATCH_PATCH=
rem @set MATCH_ARCH=
rem @set MATCH_PATCHES=

if "%output_env%" == "1" goto :ToEnv
PowerShell -Command "%PSScriptText%;!SemverScriptText:"=!"
return


:ToEnv
rm "%TEMP%\matched_versions.txt" 2>nul
1>"%TEMP%\matched_versions.txt" PowerShell -Command "%PSScriptText%;!SemverScriptText:"=!"
for /F "tokens=1-6 usebackq" %%A IN ("%TEMP%\matched_versions.txt") do (
    set MATCH_APP=%%A
    set MATCH_MAJOR=%%B
    set MATCH_MINOR=%%C
    set MATCH_PATCH=%%D
    set MATCH_ARCH=%%E
    set MATCH_PATCHES=%%F
)

set MATCH_VER=%MATCH_MAJOR%
if not "%MATCH_MINOR%" == "x" if not "%MATCH_MINOR%" == "" set MATCH_VER=%MATCH_VER%.%MATCH_MINOR%
if not "%MATCH_PATCH%" == "x" if not "%MATCH_PATCH%" == "" set MATCH_VER=%MATCH_VER%.%MATCH_PATCH%
if "%MATCH_VER%" == "" error("request version %spec_match% not found")
call :PrintVersion info match "%MATCH_APP%" "%MATCH_VER%" "%MATCH_ARCH%" "%MATCH_PATCHES%"
return %MATCH_APP%, %MATCH_VER%, %MATCH_MAJOR%, %MATCH_MINOR%, %MATCH_PATCH%, %MATCH_ARCH%, %MATCH_PATCHES%

::: endfunc

#include("print.cmd")
