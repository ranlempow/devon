@if "%VA_HOME%" == "" @set VA_HOME=%~dp0..
@set ZipFile=%~1
@set ExtractTo=%~2
@if not "%ERROR_MSG%" == "" @goto :Error

@if "%~3" == "--delete-before" goto :_DeleteBeforeUnzip

:_Unzip
@if not exist %ExtractTo% (
	@call "%VA_HOME%\base\print.cmd" info message mkdir %ExtractTo%
	@mkdir %ExtractTo%
)
@call "%VA_HOME%\base\print.cmd" info message unzip %ExtractTo%
@setlocal EnableDelayedExpansion
@rem Extract the contants of the zip file.
@ECHO  set objShell = CreateObject("Shell.Application") > "%temp%\Unzip.vbs"
@ECHO  set FilesInZip=objShell.NameSpace("!ZipFile!").items >> "%temp%\Unzip.vbs"
@ECHO  objShell.NameSpace("!ExtractTo!").CopyHere(FilesInZip) >> "%temp%\Unzip.vbs"
@endlocal
::DisableDelayedExpansion

@"%temp%\Unzip.vbs"
@if errorlevel 1 @(
    @set "ERROR_MSG=啟動錯誤: 解壓縮失敗, 也許這不是正確的壓縮檔."
    @goto :_Error
)
@goto :_Done


:_DeleteBeforeUnzip
@if exist %ExtractTo% @(
	@call "%VA_HOME%\base\print.cmd" info message rmdir %ExtractTo%
    @rd /Q /S %ExtractTo%
)
@call :_Unzip
@goto :_Done


:_Done
@set ZipFile=
@set ExtractTo=
@goto :eof
