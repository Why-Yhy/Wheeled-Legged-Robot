@echo off
cd /d "E:\Wheeled-Legged-Robot\NEW CODE"
powershell -NoProfile -ExecutionPolicy Bypass -STA -File "E:\Wheeled-Legged-Robot\NEW CODE\git-gui.ps1" %*
if errorlevel 1 pause
