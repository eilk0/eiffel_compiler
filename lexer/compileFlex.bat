@echo off
cd /d "%~dp0"
"..\bin\flex.exe" -omain.c eiffel.l
@echo on