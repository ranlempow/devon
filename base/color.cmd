@if not "%NN%" == "" @goto :eof
@if "%ANSICON%" == "" @goto :eof
@if not exist "%TEMP%\colortable.cmd" @call :MakeColorTable
@call "%TEMP%\colortable.cmd"
@goto :eof


:MakeColorTable
@for /f %%a in ('"prompt $e & for %%b in (1) do rem"') do @set esc=%%a


@setlocal EnableDelayedExpansion
@set count=0
@for %%A IN (K,R,G,Y,B,P,C,W) do @call :SetAtomColor %%A

@echo @set NN=%esc%[0m> "%TEMP%\colortable.cmd"
@for %%A IN (_FDK,_FDR,_FDG,_FDY,_FDB,_FDP,_FDC,_FDW, _FBK,_FBR,_FBG,_FBY,_FBB,_FBP,_FBC,_FBW) do @(
    @for %%B IN ("","") do @call :SetColor %%A %%B     
)
@REM @for %%A IN (_FDK,_FDR,_FDG,_FDY,_FDB,_FDP,_FDC,_FDW, _FBK,_FBR,_FBG,_FBY,_FBB,_FBP,_FBC,_FBW) do @(
@REM    @for %%B IN (_BDK,_BDR,_BDG,_BDY,_BDB,_BDP,_BDC,_BDW, _BBK,_BBR,_BBG,_BBY,_BBB,_BBP,_BBC,_BBW,"") do @call :SetColor %%A %%B     
@REM )

@endlocal
@set esc=
@goto :eof

:SetColor
@set Front=%~1
@set Back=%~2

@if "%Back%" == "" @(
    @echo @set %Front:~2%=%esc%[0;!%Front%!;40m>> "%TEMP%\colortable.cmd"
) else @(
    @echo @set %Front:~1%%Back:~1%=%esc%[0;!%Front%!;!%Back%!m>> "%TEMP%\colortable.cmd"
)
@goto :eof

:SetAtomColor
@set _FD%1=3%count%
@set _FB%1=1;3%count%
@set _BD%1=4%count%
@set _BB%1=4;4%count%
@set /A count+=1
@goto :eof

