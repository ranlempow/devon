rem Test Ok

:ImportColor
if not "%NN%" == "" goto :eof
if "%NO_COLOR%" == "1" goto :eof
if "%TEST_SHELL%" == "1" goto :eof
if "%ANSICON%" == "" goto :eof

for /F "skip=1 delims=" %%F in ('
    wmic PATH Win32_LocalTime GET Day^,Month^,Year /FORMAT:TABLE
') do (
    for /F "tokens=1-3" %%L in ("%%F") do (
        set Day=0%%L
        set Month=0%%M
        set Year=%%N
    )
)
set Day=%Day:~-2%
set Month=%Month:~-2%

set ColorTable="%TEMP%\colortable%Year%%Month%%Day%.cmd"
if not exist "%ColorTable%" call :MakeColorTable "%ColorTable%"
call "%ColorTable%"

set Day=
set Month=
set Year=
set ColorTable=
goto :eof


::: function MakeColorTable(ColorTable) delayedexpansion
for /f %%a in ('"prompt $e & for %%b in (1) do rem"') do @set esc=%%a

set count=0
for %%A IN (K,R,G,Y,B,P,C,W) do call :SetAtomColor %%A

echo @set NN=%esc%[0m> "%ColorTable%"
for %%A IN (_FDK,_FDR,_FDG,_FDY,_FDB,_FDP,_FDC,_FDW, _FBK,_FBR,_FBG,_FBY,_FBB,_FBP,_FBC,_FBW) do (
    for %%B IN ("","") do call :SetColor %%A %%B
)
REM @for %%A IN (_FDK,_FDR,_FDG,_FDY,_FDB,_FDP,_FDC,_FDW, _FBK,_FBR,_FBG,_FBY,_FBB,_FBP,_FBC,_FBW) do @(
REM    @for %%B IN (_BDK,_BDR,_BDG,_BDY,_BDB,_BDP,_BDC,_BDW, _BBK,_BBR,_BBG,_BBY,_BBB,_BBP,_BBC,_BBW,"") do @call :SetColor %%A %%B
REM )

::: endfunc


:SetColor
@set Front=%~1
@set Back=%~2
@if "%Back%" == "" @(
    @echo @set %Front:~2%=%esc%[0;!%Front%!;40m>> "%ColorTable%"
) else @(
    @echo @set %Front:~1%%Back:~1%=%esc%[0;!%Front%!;!%Back%!m>> "%ColorTable%"
)
@goto :eof


:SetAtomColor
@set _FD%1=3%count%
@set _FB%1=1;3%count%
@set _BD%1=4%count%
@set _BB%1=4;4%count%
@set /A count+=1
@goto :eof

