@where git 1>nul
@if errorlevel 1 (
    echo git not found
    exit /b 1
)
@setlocal enabledelayedexpansion
@set GIT_PATH=
@for /f "tokens=*" %%i in ('where git') do @if "!GIT_PATH!" == "" set GIT_PATH=%%i
@for /f "tokens=*" %%i in ("%GIT_PATH%\..\..\bin") do @set GIT_BIN=%%~fi
@for /f "tokens=*" %%i in ("%GIT_PATH%\..\..\etc") do @set GIT_ETC=%%~fi
@del /Q "%GIT_ETC%\bash.bash_logout" 2>nul
@"%GIT_BIN%\bash" --login -i %*
@endlocal
