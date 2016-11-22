@rem simply redirect to dev-XXX.cmd


@if [%1] EQU [] goto ShowHelp

:RedirectCall
@call %~dp0dev-%1.cmd
@goto :eof

:ShowHelp
@call %~dp0dev-help.cmd