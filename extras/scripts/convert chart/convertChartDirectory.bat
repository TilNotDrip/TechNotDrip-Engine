@echo off
echo Converting all legacy charts to TechNotDrip charts...
setlocal
set "CHART_PATH=.\old charts"
set "CONVERTED_CHART_PATH=.\converted charts"
for /D %%d in ("%CHART_PATH%\*") do (
	echo Converting %%~nxd
    haxe --main ConvertChart --library json2object --run ConvertChart %%d %CONVERTED_CHART_PATH%\%%~nxd
)
endlocal
echo Converting all legacy charts to TechNotDrip charts!
