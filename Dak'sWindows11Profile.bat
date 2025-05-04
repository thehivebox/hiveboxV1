@echo off
powershell.exe -Command Set-ItemProperty -Path HKCU:\software\microsoft\windows\currentversion\explorer\advanced -Name 'TaskbarAl' -Type 'DWord' -Value 0
powershell.exe -Command Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Force
powershell.exe -Command reg add "HKLM\Software\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d "0" /f
powershell.exe -Command powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
powershell.exe -Command powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powershell.exe -Command powercfg /setdcvalueindex scheme_current sub_energysaver esbattthreshold 0
powershell.exe -Command powercfg /change standby-timeout-ac 0
powershell.exe -Command powercfg /change standby-timeout-dc 0
powershell.exe -Command powercfg /change monitor-timeout-ac 0
powershell.exe -Command powercfg /change monitor-timeout-dc 0
powershell.exe -Command powercfg /change hibernate-timeout-ac 0
powershell.exe -Command powercfg /change hibernate-timeout-dc 0
powershell.exe -Command powercfg /setdcvalueindex scheme_current sub_energysaver esbattthreshold 0
powershell.exe -Command Invoke-Expression "C:\Windows\Resources\Themes\dark.theme"
powershell.exe -Command Stop-Process -Name explorer -Force; Start-Process explorer