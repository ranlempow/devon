@set command=%~1
@shift
@if not exist "%VA_HOME%\base\%command%.cmd" @(
	@set ERROR_MSG=%command%.cmd not found
    @goto :Error
)

@set restvar=
:loop1
@if "%~1" == "" @if [%1] == [] @goto after_loop
@set restvar=%restvar% %1
@shift
@goto loop1

:after_loop
@call "%VA_HOME%\base\%command%.cmd" %restvar%


:Error

