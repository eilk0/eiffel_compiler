@echo off
cd /d "%~dp0"
"..\bin\flex.exe" yylex.l
@echo on