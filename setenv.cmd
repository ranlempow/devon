For /F %%G in ('dir /b %~dp0apps\*') do (
 IF EXIST "%~dp0apps\%%G\setenv.cmd" call "%~dp0apps\%%G\setenv.cmd"
)