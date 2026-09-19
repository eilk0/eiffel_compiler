@echo off
cd /d "%~dp0"
"..\bin\flex.exe" -oyylex.h eiffel.l
@echo on