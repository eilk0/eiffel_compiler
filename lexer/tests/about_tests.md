# Lexer testing
This directory contains .e files that can be used to check the validity of rules described in the flex scanner.

## ./simple_project
Contains the simple Eiffel project, consiting of 3 .e file (aka classes), including the main *application.e* file. Shows basic functionality.

## ./distinct_feats
The subdirectory contains .e files for testing specific features of the language: ids, strings, etc.

## .
Currently has two files: *big_test.e* and *edge_cases.e*.
big_test.e presents syntactically correct code in Eiffel, complex enough to cover most of the language syntax.
edge_cases.e also presents syntactically correct code, but tries to cover cases that may cause confusion during scanning.