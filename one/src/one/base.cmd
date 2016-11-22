
@if not %~d0 == C: (
    @REM python venv 必須被安裝在C槽, 否則他不執行
    @set ONE_ERROR=啟動失敗: 必須是在C槽
    @goto IF_ERROR
)

:: 確定資料夾是否含有非英文路徑
@ECHO %~dp0| findstr /R /C:"^[a-zA-Z0-9~.\\:_-]*$">nul 2>&1
@IF errorlevel 1 (
    @set ONE_ERROR=啟動失敗: 所在的路徑不能有中文或是特殊標點符號
    @goto IF_ERROR
)

@pushd %~dp0..
@set ONE_BASE=%cd%
@popd

@pushd %~dp0..\..\..
@set PROJECT_BASE=%cd%
@pushd config\one
@set ONE_CONFIG_BASE=%cd%
@popd
@popd



:IF_ERROR
