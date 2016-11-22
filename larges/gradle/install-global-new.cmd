@set RELEASE_URL=https://services.gradle.org/distributions
@set DOWNLOAD_URL=%RELEASE_URL%
@set ACCEPT=local global

:versions
	%VA_CALL% download "%RELEASE_URL%" "%VERSION_LIST_SOURCE%"
	@for /F "tokens=* USEBACKQ" %%F IN (`FINDSTR  /R /C:"distributions/gradle" "%VERSION_LIST_SOURCE%"`) do @(
	    @for /F "delims=- tokens=2,3 USEBACKQ" %%G IN ('%%F') do @(
	        @set var1=%%H
	        @if "!var1:~0,-2!" == "bin.zip" %VA_CALL% verlist "gradle=%%G@any[bin]"
	    )
	)

:prepare
	@set APPVER=%MATCH_VER%
	@set INSTALLER=gradle-%APPVER%-bin.zip

@rem :download
@rem %VA_CALL% download "%RELEASE_URL%/%INSTALLER%" "%TEMP%\%INSTALLER%"  --skip-exists

:unpack
	::%VA_CALL% env set GRADLE_HOME=$SCRIPT_SOURCE$
	::%VA_CALL% env path $GRADLE_HOME$\bin
	$env set GRADLE_HOME=$SCRIPT_SOURCE$
	$env path $GRADLE_HOME$\bin

	%VA_CALL% unzip "%TEMP%\%INSTALLER%" "%REAL_TARGETDIR%" --extract_dir "gradle-%APPVER%" --delete-before

:validate
	@set CHECK_CMD=gradle -v
	@set CHECK_LINEWORD=Gradle
	@set CHECK_OK=Gradle %VA_INFO_VERSION%
	
	@chcek --cmd "gradle -v" --line-word "Gradle" --match "Gradle %VA_INFO_VERSION%"

	::@for /F "tokens=* USEBACKQ" %%F in (`cmd /C gradle -v ^| findstr Gradle`) do @set CHECK_STRING=%%F
	::@if not "%CHECK_STRING%" == "Gradle %VA_INFO_VERSION%" @goto :ValidateFailed

