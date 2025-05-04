@echo off
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -NoExit -ExecutionPolicy Bypass -Command \"dotnet-core-uninstall remove --sdk --all-lower-patches --verbosity q --force --yes; dotnet-core-uninstall remove --runtime --all-lower-patches --verbosity q --force --yes\"'"
