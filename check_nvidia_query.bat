@echo off
REM needs:
REM C:\Program Files\NSClient++\nsclient.ini: check_nvidia_query=check_nvidia\check_nvidia_query.bat
REM Check Nvidia License Status
REM Nvidia License Status can be Licensed / Unlicensed
"C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi" -q | findstr "License.Status.*Licensed"

REM echo Errorlevel: %ERRORLEVEL%
if %ERRORLEVEL% == 0 goto EndOK
if %ERRORLEVEL% == 1 goto EndNOK
if %ERRORLEVEL% >= 2 goto EndUNKNOWN

:EndUNKOWN
echo License Status is Unknown
exit 3

:EndNOK
echo Critical: License Status is Unlicensed
exit 2

:EndOK
REM echo OK: License Status is licensed
exit 0
