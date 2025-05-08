REM This registry key addition will add the old, Windows 10 "Power Management" (S3) Tab within the Wireless Network Adapter (Realek | Intel tested as working with WiFi 6) settings [Device Manager]. This will disable the "Modern Standby" power setting.
REM Restart the machine after adding the registry key for satisfactory result(s). 
@echo off
reg add HKLM\System\CurrentControlSet\Control\Power /v PlatformAoAcOverride /t REG_DWORD /d 0 /f >nul 2>&1
exit /b
