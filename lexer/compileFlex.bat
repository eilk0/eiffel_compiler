@echo off
cd /d "%~dp0"
"..\bin\flex.exe" -oyylex.h yylex.l
@echo on