@pushd %~dp0
@set VA_HOME=%CD%
@popd


set ALL_ARGS=%*
set processed=

:Loop
set origin_head=%1
set origin_parm=%1
set head=%~1
set parm=%~2

if "%processed%" == "" (
    set REST_ARGS=ALL_ARGS
) else (
    call set REST_ARGS=%%ALL_ARGS:%processed%=%%
)

if "%head%" == "" goto :Break
if "%parm%" == "" set parm=__NONE__

if "%head%" == "-v" set head=--version
if "%head%" == "--version" (
    if "%parm%" == "__NONE__" goto :_BadArgument
    if "%parm:~0,1%" == "-" goto :_BadArgument
    set REQUEST_VER=%parm%
    goto :Parse2
)






:Parse1
set processed=%processed%%1 
shift
goto :Loop


:Parse2
set processed=%processed%%1 %2 
shift
shift
goto :Loop

:Break

goto :eof

