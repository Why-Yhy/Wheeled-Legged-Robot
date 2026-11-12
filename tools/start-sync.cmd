@echo off
cd /d "E:\Wheeled-Legged-Robot\NEW CODE"
powershell -NoProfile -ExecutionPolicy Bypass -File "E:\Wheeled-Legged-Robot\NEW CODE\tools\auto-sync.ps1"
if errorlevel 1 pause