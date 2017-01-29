::: function CMD_sync(MOST_CLEAN=N) delayedexpansion

rem TODO: 在commit之前先偵查status, 如果有任何已經commit的紀錄則不commit

set MAIN_BRANCH=master
set CURRENT_CHANGES=
for /f %%i in ('git status --porcelain') do set CURRENT_CHANGES=%%i
for /f %%i in ('git symbolic-ref -q --short HEAD') do set CURRENT_BRANCH=%%i

if "%MOST_CLEAN%" == "1" if not "%CURRENT_CHANGES%" == "" error("status most clean")
if not "%CURRENT_CHANGES%" == "" git stash --include-untracked
if not "%CURRENT_BRANCH%" == "%MAIN_BRANCH%" git checkout %MAIN_BRANCH%

git fetch origin --progress
if errorlevel 1 error("cannot fetch, maybe your network is offline")

rem detect conflict for merge with FETCH_HEAD
rem see http://stackoverflow.com/questions/6335717/can-git-tell-me-if-a-merge-will-conflict-without-actually-merging

for /f %%i in ('git merge-base FETCH_HEAD %MAIN_BRANCH%') do set CommonCommit=%%i
git format-patch %CommonCommit%..FETCH_HEAD --stdout > .patchtest

rem no need to patch when .patchtest is a empty file
for /f %%i in (".patchtest") do set filesize=%%~zi
if "%filesize%" == "0" (
    call :PrintMsg normal gitsync no change
    del .patchtest
    return
)

git apply --check .patchtest 2>nul
set errorlevel_save=%errorlevel%
del .patchtest

if "%errorlevel_save%" == "0" (
	rem if no conflict
	rem try fast forward first
	call :PrintMsg normal gitsync fast forward
  	git merge -v FETCH_HEAD --ff-only
  	if not "!errorlevel!" == "0" (
		rem if can't fast forward, but it still no conflict
	    rem use rebase for simple history
	    call :PrintMsg normal gitsync rebase
	    git rebase FETCH_HEAD
  	)
) else (
	rem use ours recursive strategy to resolve conflict
	call :PrintMsg normal gitsync merge ours
	git merge -v FETCH_HEAD -s recursive -Xours
)

if not errorlevel 1 (
    git push -v origin --progress --tags
) else (
	call :PrintMsg error gitsync merge failed
)

if not "%CURRENT_BRANCH%" == "%MAIN_BRANCH%" git checkout %CURRENT_BRANCH%
if not "%CURRENT_BRANCH%" == "%MAIN_BRANCH%" git rebase %MAIN_BRANCH%
if not "%CURRENT_CHANGES%" == "" git stash pop

::: endfunc

#include("print.cmd")
