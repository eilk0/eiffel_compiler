@echo off
cd /d "%~dp0"
"..\bin\flex.exe" yylex.l
"..\bin\bison.exe" grammar.y
@echo on