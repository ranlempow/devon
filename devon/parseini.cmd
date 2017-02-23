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
