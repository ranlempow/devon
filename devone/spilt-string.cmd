@rem usage:
@rem (set Text=%inival%)&(set LoopCb=:getstring)&(set ExitCb=:exit_getstring)&(set Spliter=;)
@rem goto :SubString
@rem :getstring
@rem echo %substring%
@rem goto :NextSubString
@rem :exit_getstring
@rem goto :eof


@REM Do something with each substring
:SubString
    @REM Stop when the string is empty
    @if "%Text%" EQU "" goto :ENDSubString
    @for /f "delims=;" %%a in ("!Text!") do @set substring=%%a
    @call goto %LoopCb%
    @if not "%LoopBreak%" == "" goto :ENDSubString

@REM Now strip off the leading substring
:NextSubString
    @set headchar=!Text:~0,1!
    @set Text=!Text:~1!

    @if "!Text!" EQU "" goto :SubString
    @if "!headchar!" NEQ "%Spliter%" goto :NextSubString
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
