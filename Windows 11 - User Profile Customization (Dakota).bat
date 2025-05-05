@echo off
REM Disable taskbar alignment to the center and set it to the left
powershell.exe -Command Set-ItemProperty -Path HKCU:\software\microsoft\windows\currentversion\explorer\advanced -Name 'TaskbarAl' -Type 'DWord' -Value 0

REM Hide the Task View button on the taskbar
powershell.exe -Command Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Force

REM Disable the News and Interests feature on the taskbar
powershell.exe -Command reg add "HKLM\Software\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d "0" /f

REM Duplicate the Ultimate Performance power scheme
powershell.exe -Command powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61

REM Set the active power scheme to High Performance
powershell.exe -Command powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

REM Set the battery threshold for energy saver to 0%
powershell.exe -Command powercfg /setdcvalueindex scheme_current sub_energysaver esbattthreshold 0

REM Set the standby timeout for AC power to 0 (never standby)
powershell.exe -Command powercfg /change standby-timeout-ac 0

REM Set the standby timeout for DC power to 0 (never standby)
powershell.exe -Command powercfg /change standby-timeout-dc 0

REM Set the monitor timeout for AC power to 0 (never turn off monitor)
powershell.exe -Command powercfg /change monitor-timeout-ac 0

REM Set the monitor timeout for DC power to 0 (never turn off monitor)
powershell.exe -Command powercfg /change monitor-timeout-dc 0

REM Set the hibernate timeout for AC power to 0 (never hibernate)
powershell.exe -Command powercfg /change hibernate-timeout-ac 0

REM Set the hibernate timeout for DC power to 0 (never hibernate)
powershell.exe -Command powercfg /change hibernate-timeout-dc 0

REM Set the battery threshold for energy saver to 0% (duplicate command, can be removed if not needed)
powershell.exe -Command powercfg /setdcvalueindex scheme_current sub_energysaver esbattthreshold 0

REM Apply the dark theme
powershell.exe -Command Invoke-Expression "C:\Windows\Resources\Themes\dark.theme"

REM Restart the explorer process to apply changes
powershell.exe -Command Stop-Process -Name explorer -Force; Start-Process explorer
