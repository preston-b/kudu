@echo Off
set config=%1
if "%config%" == "" (
   set config=Release
)

:: use MSBuild from .net framework by default
set MsBuildExe="%WINDIR%\Microsoft.NET\Framework\v4.0.30319\msbuild"

:: if there is MSBuild from vs2013, use MSBuild from vs2013 instead
if exist "%PROGRAMFILES%\MSBuild\12.0\Bin\MsBuild.exe" (
	set MsBuildExe="%PROGRAMFILES%\MSBuild\12.0\Bin\MsBuild.exe"
) else if exist "%ProgramFiles(x86)%\MSBuild\12.0\Bin\MsBuild.exe" (
	set MsBuildExe="%ProgramFiles(x86)%\MSBuild\12.0\Bin\MsBuild.exe"
)

:: work around for npm bug that it doesn`t create npm folder under user folder
set npmUserPath="C:\Users\%username%\AppData\Roaming\npm"
if not exist %npmUserPath% (
	md %npmUserPath%
)

%MsBuildExe% Build\Build.proj /p:Configuration="%config%";ExcludeXmlAssemblyFiles=false /v:M /fl /flp:LogFile=msbuild.log;Verbosity=Normal /nr:false /m