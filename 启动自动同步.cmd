@echo off
chcp 65001 >nul
title ????? GitHub?????????
cd /d "E:\Wheeled-Legged-Robot\NEW CODE"
powershell -NoProfile -ExecutionPolicy Bypass -File "E:\Wheeled-Legged-Robot\NEW CODE\auto-sync.ps1"
pause