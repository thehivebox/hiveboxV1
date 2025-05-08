@echo off
reg add HKLM\System\CurrentControlSet\Control\Power /v PlatformAoAcOverride /t REG_DWORD /d 0 /f >nul 2>&1
exit /b
