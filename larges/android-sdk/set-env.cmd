set SCRIPT_SOURCE=%~dp0
:: Does string have a trailing slash? if so remove it 
if %SCRIPT_SOURCE:~-1%==\ set SCRIPT_SOURCE=%SCRIPT_SOURCE:~0,-1%

set ANDROID_SDK_HOME=%SCRIPT_SOURCE%
set PATH=%ANDROID_SDK_HOME%\tools;%PATH%
set PATH=%ANDROID_SDK_HOME%\platform-tools;%PATH%

set SCRIPT_SOURCE=
