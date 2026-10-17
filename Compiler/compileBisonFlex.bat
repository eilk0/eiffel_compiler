@echo off
cd /d "%~dp0"

del grammar.tab.c
del lex.yy.c

"..\bin\flex.exe" yylex.l
"..\bin\bison.exe" grammar.y
@echo on