@echo off
setlocal

call :InstallDependencies
call :SetProfileEnv
goto :EOF

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:InstallDependencies
set webpicmd="%ProgramFiles%\Microsoft\Web Platform Installer\WebPiCmd.exe"
if exist %webpicmd% (
	%webpicmd% /Install  /SuppressReboot /Products:KuduDevSetup /Log:"%~dp0WebPiCmdSetup.log" /Feeds:"%~dp0KuduSetupCustomWebPiFeed.xml"
) else (
	call :ColorText 0c "Microsoft Web Platform Installer is not installed."
	echo Please install Microsoft Web Platform Installer from http://www.microsoft.com/web/downloads/platform.aspx
)
goto :EOF

:SetProfileEnv
echo.
:: set "setProfileEnvironment" to be true or remote if current OS is Windows 8/1 (https://github.com/projectkudu/kudu/wiki/Getting-started#additional-prerequisites-to-run-the-functional-tests)
set Version=
for /f "skip=1" %%v in ('wmic os get version') do if not defined Version set Version=%%v
for /f "delims=. tokens=1-3" %%a in ("%Version%") do (
  set Version.Major=%%a
  set Version.Minor=%%b
  set Version.Build=%%c
)

set GTR_EQ_WIN_81=
if %Version.Major%==6 if %Version.Minor% GTR 2 set GTR_EQ_WIN_81=1
if %Version.Major% GTR 6 set GTR_EQ_WIN_81=1

if defined GTR_EQ_WIN_81 (
	echo Removing applicationPoolDefaults.processModel.setProfileEnvironment attribute, since you are running on Windows 8.1
	%systemroot%\system32\inetsrv\APPCMD clear config -section:system.applicationHost/applicationPools /applicationPoolDefaults.processModel.setProfileEnvironment /commit:apphost
) else (
	:: set setProfileEnvironment to be true
	echo Updating 'applicationPoolDefaults.processModel.setProfileEnvironment' to be true
	%systemroot%\system32\inetsrv\APPCMD set config -section:system.applicationHost/applicationPools /applicationPoolDefaults.processModel.setProfileEnvironment:"true" /commit:apphost
)
goto :EOF

:ColorText
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)

<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
echo.
goto :EOF

:EOF
