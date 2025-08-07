@echo off
rem Admin Rights Checker
net session >nul 2>&1
if %errorLevel% neq 0 (
  rem Relaunch this script as admin
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

rem --- start
setlocal
rem --- replace x with app folder
set "TARGET=C:\inetpub\logs\LogFiles\X"
if not exist "%TARGET%" exit /b 0
pushd "%TARGET%"
for /d %%D in (*) do rd /s /q "%%D"
del /f /q *.*
del /s /f /q *.log
popd
endlocal
exit /b 0
