# Eiffel compiler
A simple compiler for Eiffel programming language. Made as a part of Formal Language Theory course.

# Tools

## Visual Studio 
[Visual Studio](https://visualstudio.microsoft.com/ru/) (*MSVC*) is current build system for project.

*Visual Studio* can be used for development of *any* module of the compiler, but `*.l` files has no highlights or suggestions.

*Everyting is configured, just open `EiffelCompiler.sln`.*

## VSCode + Bison/Flex Language Support (optional)

[Bison/Flex Language Support](https://marketplace.visualstudio.com/items?itemName=theodevelop.bison-flex-lang) is an extension for *VSCode* that enables hints and highlights for lexer `*.l` files. 

Used primarily for convinient editing of lexer rules in `*.l` files.

Exactly: `./lexer/yylex.l`.

*To properly load configs for VSCode, open **root folder** of that repository as project.*


## GNU Flex Lexer Generator
GNU Flex is a dependency that already included in that repository.

It configured to compile `./lexer/yylex.l` into `./lexer/yylex.h`.

You have multiple ways to use it:
1) Hit `CTRL+SHIFT+B` in *VSCode*
2) Rebuild project in *Visual Studio*
3) Use batch file `./lexer/compileFlex.bat`
