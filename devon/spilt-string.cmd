
rem set str=a:1;b:2 c:3
rem :FORLOOP
rem @For /F "tokens=1* delims=;" %%A IN ("%str%") DO @set "item=%%A" & set "str=%%B"
rem @For /F "tokens=1* delims=:" %%A IN ("%item%") DO @set "key=%%A" & set "value=%%B"
rem @echo %key%,%value%
rem @if not "%str%" == "" goto FORLOOP

@rem usage:
@rem (set Text=%inival%)&(set LoopCb=:getstring)&(set ExitCb=:exit_getstring)&(set Spliter=;)
@rem goto :SubString
@rem :getstring
@rem echo %substring%
@rem goto :NextSubString
@rem :exit_getstring
@rem goto :eof

:SubString
    @REM Stop when the string is empty
    @if "%Text%" == "" goto :ENDSubString
    @for /F "delims=;" %%A in ("!Text!") do @set substring=%%A
    @call goto %LoopCb%
    @if not "%LoopBreak%" == "" goto :ENDSubString

:NextSubString
    @for /L %%I in (1, 1, 500) do @(
        @set headchar=!Text:~0,1!
        @set Text=!Text:~1!
        @if "!Text!" == "" goto :SubString
        @if "!headchar!" == "%Spliter%" goto :SubString
    )
    @goto :SubString

:ENDSubString
@set Text=
@set Spliter=
@set headchar=
@set substring=
@set LoopBreak=
@set LoopCb=
@(set ExitCb=)& call goto %ExitCb%
@goto :eof

