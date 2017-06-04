
:LoadIniRecursive

call :GetNormalizePath %1
call set "_INI_LOADED_DROP=%%INI_LOADED:%NORMALIZEPATH%=%%"
if not exist "%NORMALIZEPATH%" goto :LoadIniRecursive_Return
if not "%_INI_LOADED_DROP%" == "%INI_LOADED%" goto :LoadIniRecursive_Return

set "INI_LOADED=%INI_LOADED%;%NORMALIZEPATH%"
call :LoadIni %NORMALIZEPATH%

call :GetIniItems "import"
set str=%inival%
:LoadIniRecursive_IterStringLoop
For /F "tokens=1* delims=;" %%A IN ("%str%") DO @set "item=%%A" & set "str=%%B"
call :LoadIniRecursive "%item%"
if not "%str%" == "" goto LoadIniRecursive_IterStringLoop

:LoadIniRecursive_Return
set inival=
set str=
set item=
set NORMALIZEPATH=
set _INI_LOADED_DROP=
goto :eof




:LoadIni
set INI_AREALIST=
for /f "usebackq delims=" %%a in ("!NORMALIZEPATH!") do (
    @rem strip left
    for /f "tokens=* delims= " %%b in ("%%a") do set ln=%%b
    if not x!ln! == x if not "!ln:~0,1!" == ";" (
        if "!ln:~0,1!" == "[" if "!ln:~-1!" == "]" (
            set currarea=!ln:~1,-1!
            set platform=all
            if "!currarea:~-6!" == "-posix" set "platform=posix" & set currarea=!currarea:~0,-6!
            if "!currarea:~-6!" == "-linux" set "platform=linux" & set currarea=!currarea:~0,-6!
            if "!currarea:~-8!" == "-windows" set "platform=windows" & set currarea=!currarea:~0,-8!
            if "!currarea:~-6!" == "-macos" set "platform=macos" & set currarea=!currarea:~0,-6!
            if "!currarea:~-7!" == "-cygwin" set "platform=cygwin" & set currarea=!currarea:~0,-7!
            set INI_AREALIST=!INI_AREALIST!;!currarea!
        ) else (
            set curritem=!ln!
            call :AddIniItem

        )
    )
)

set file=
set ln=
set currarea=
set curritem=
set platform=

goto :eof




:AddIniItem
if x%currarea%x == xx goto :eof

call set "store=%%INIAREA_%currarea%_%platform%%%"
if x%store%x == xx (
    call set "INIAREA_%currarea%_%platform%=%%curritem%%"
) else (
    call set "INIAREA_%currarea%_%platform%=%%store%%;%%curritem%%"
)
goto :eof




:ClearIni
:ClearIni_IterStringLoop
set str=%INI_AREALIST%
For /F "tokens=1* delims=;" %%A IN ("%str%") DO @set "item=%%A" & set "str=%%B"
if not "%item%" == "" (
    call set INIAREA_%item%_all=
    call set INIAREA_%item%_linux=
    call set INIAREA_%item%_posix=
    call set INIAREA_%item%_windows=
    call set INIAREA_%item%_macos=
    call set INIAREA_%item%_cygwin=
)
if not "%str%" == "" goto ClearIni_IterStringLoop
set str=
set item=
set INI_AREALIST=
set INI_LOADED=
goto :eof


::: function GetIniItems(area, platform=all) extensions delayedexpansion
rem set need_load=
rem if not "%INI_LOADED%" == "1" set need_load=1
rem if "%need_load%" == 1 call :LoadIni

call set "inival=%%INIAREA_%item%_all%%"
if "%platform%" == "posix" ^\n^
if "%platform%" == "linux" ^\n^
if "%platform%" == "macos" ^\n^
if "%platform%" == "cygwin" (
    call set "inival=%%inival%%;%%INIAREA_%item%_posix%%"
)
if not "%platform%" == "all" if not "%platform%" == "posix" (
    call set "inival=%%inival%%;%%INIAREA_%item%_%platform%%%"
)

@rem strip left ";"
for /f "tokens=* delims=;" %%b in ("%inival%") do set inival=%%b
@rem strip right ";"
for /l %%a in (1,1,31) do if "!inival:~-1!"==";" set inival=!inival:~0,-1!

rem if "%need_load%" == 1 call :ClearIni
return %inival%
::: endfunc


:: 讀取ini檔案的方法, 將取得的值寫入%inival%
:: GetIniArray(file, area)
::   inival = "v1;v2"
:: GetIniPairs(file, area)
::   inival = "k1=v1;k2=v2"
:: GetIniValue(file, area, key)
::   inival = "v"


::: function GetIniArray(file, area) extensions delayedexpansion
set inival=
if not exist "%file%" goto :return_GetIniArray
set area=[%area%]
set currarea=
for /f "usebackq delims=" %%a in ("!file!") do (
    set ln=%%a
    rem strip left
    for /f "tokens=* delims= " %%a in ("!ln!") do set ln=%%a
    if not x!ln! == x if not "!ln:~0,1!" == "#" (
        if "!ln:~0,1!" == "[" (
            set currarea=!ln!
        ) else (
            for /f "tokens=1,2 delims==" %%b in ("!ln!") do (
                set currkey=%%b
                set currval=%%c

                rem ^^^^ TEMPLATE ^^^^
                if "x!area!"=="x!currarea!" (
                    if "x!inival!" == "x" (
                        set "inival=!currkey!"
                    ) else (
                        set "inival=!inival!;!currkey!"
                    )
                )
                rem ---- TEMPLATE ----
            )
        )
    )
)
:return_GetIniArray
return %inival%
::: endfunc


::: function GetIniPairs(file, area) extensions delayedexpansion
set inival=
if not exist "%file%" goto :return_GetIniPairs
set area=[%area%]
set currarea=
for /f "usebackq delims=" %%a in ("!file!") do (
    set ln=%%a
    rem strip left
    for /f "tokens=* delims= " %%a in ("!ln!") do set ln=%%a
    if not "x!ln!" == "x" (
        if "x!ln:~0,1!"=="x[" (
            set currarea=!ln!
        ) else (
            for /f "tokens=1,2 delims==" %%b in ("!ln!") do (
                set currkey=%%b
                set currval=%%c

                rem ^^^^ TEMPLATE ^^^^
                if "x!area!"=="x!currarea!" (
                    if "x!inival!" == "x" (
                        set "inival=!currkey!=!currval!"
                    ) else (
                        set "inival=!inival!;!currkey!=!currval!"
                    )
                )
                rem ---- TEMPLATE ----
            )
        )
    )
)
:return_GetIniPairs
return %inival%
::: endfunc


::: function GetIniValue(file, area, key) extensions delayedexpansion
set inival=
if not exist "%file%" goto :return_GetIniValue
set area=[%area%]
set currarea=

for /f "usebackq delims=" %%a in ("!file!") do (
    set ln=%%a
    rem strip left
    for /f "tokens=* delims= " %%a in ("!ln!") do set ln=%%a
    if not "x!ln!" == "x" (
        if "x!ln:~0,1!"=="x[" (
            set currarea=!ln!
        ) else (
            for /f "tokens=1,2 delims==" %%b in ("!ln!") do (
                set currkey=%%b
                set currval=%%c

                rem ^^^^ TEMPLATE ^^^^
                if "x!area!"=="x!currarea!" if "x!key!"=="x!currkey!" (
                    set inival=!currval!
                    goto :return_GetIniValue
                )
                rem ---- TEMPLATE ----
            )
        )
    )
)
:return_GetIniValue
return %inival%
::: endfunc

:GetNormalizePath
    SET NORMALIZEPATH=%~dpfn1
    goto :eof
