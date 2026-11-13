@echo off
rem Lokalne CI Aquili, opis w tools\local_ci\local_ci.py
chcp 65001 >nul
call "%~dp0..\bootstrap\python.bat" "%~dp0local_ci.py" %*
