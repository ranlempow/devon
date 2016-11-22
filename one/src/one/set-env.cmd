@call %~dp0base.cmd
set _SET_ENV=%PROJECT_BASE%\bin\apps\set-env.cmd
if exist "%_SET_ENV%" (
    @call "%_SET_ENV%"
)
set _SET_ENV=%PROJECT_BASE%\config\one\set-env.cmd
if exist "%_SET_ENV%" (
    @call "%_SET_ENV%"
)
set _SET_ENV=
