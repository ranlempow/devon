

@for /f %%a in ('"prompt $e & for %%b in (1) do rem"') do set esc=%%a

@set write=%esc%[0m
@set red=%esc%[0;1;31;40m

@echo %red%aaa%write%