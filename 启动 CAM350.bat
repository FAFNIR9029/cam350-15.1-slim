@echo off
setlocal
chcp 936 >nul
cd /d "%~dp0"
set "ACT_INC_LICENSE_FILE=%~dp0act_inc.lic"
start "" "%~dp0CAM350 15.1\camnt95.exe" -s -w -Disable3D
exit /b 0