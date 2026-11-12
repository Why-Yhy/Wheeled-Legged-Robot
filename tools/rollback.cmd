@echo off
chcp 65001 >nul
cd /d "E:\Wheeled-Legged-Robot\NEW CODE"
powershell -NoProfile -ExecutionPolicy Bypass -File "E:\Wheeled-Legged-Robot\NEW CODE\tools\rollback.ps1"
