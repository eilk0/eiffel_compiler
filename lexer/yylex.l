%{
    #include <stdio.h>
    #include "colors.h"
    #include "upper_lower.h"
    #define YY_NO_UNISTD_H
%}

%option noyywrap
%option never-interactive
%option stack

%x STRING
%x CHARACTER
%x CHARACTER_END

DIGIT   [0-9]
ID  [a-zA-Z][a-zA-Z0-9_]*

%%
    // Local variables
    int stringLength;
    char stringBuffer[4096];
    int yylineno = 0;

[ \t\r]+    {printf("%s", yytext);}
[\n]    {yylineno++; printf("\n%5d\t", yylineno);}

"--"[^\r\n]* {printf(GRAY "%s" RESET, yytext);}

    /* Reserved words */
(?i:across)  |
(?i:agent)   |
(?i:alias)   |
(?i:all) |
(?i:as)  |
(?i:assign)  |
(?i:attribute)   |
(?i:check)   |
(?i:class)   |
(?i:convert) |
(?i:create)  |
(?i:Current) |
(?i:debug)   |
(?i:deffered)    |
(?i:do)  |
(?i:else)    |
(?i:elseif)  |
(?i:end) |
(?i:ensure)  |
(?i:expanded)    |
(?i:export)  |
(?i:external) 
(?i:feature) |
(?i:from)    |
(?i:frozen)  |
(?i:if)  |
(?i:implies) |
(?i:inherit) |
(?i:inspect) |
(?i:invariant)   |
(?i:like)    |
(?i:local)   |
(?i:loop)    |
(?i:not) |
(?i:note)    |
(?i:obsolete)    |
(?i:old) |
(?i:once)    |
(?i:only)    |
(?i:Precursor)   |
(?i:redefine)    |
(?i:rename)  |
(?i:require) |
(?i:rescue)  |
(?i:Result)  |
(?i:retry)   |
(?i:select)  |
(?i:separate)    |
(?i:then)    |
(?i:TUPLE)   |
(?i:undefine)    |
(?i:until)   |
(?i:variant) |
(?i:Void)    |
(?i:when) {printf(CYAN "%s" RESET, lower(yytext));}


    /*Operators*/
">" |
"<" |
":="    |
"/="    |
"<="    |
">="    |
"=" |
"+" |
"-" |
"*" |
"/" |
"(" |
")" |
"[" |
"]" |
"{" |
"}" |
"," |
":" |
";" |
"." |
"@" |
"?" |
"~" |
"!" |
"#" |
"$" |
"%" |
"&" |
"|" |
"^" |
(?i:and)\s+(?i:then)   |
(?i:and) |
(?i:or)\s+(?i:else)   |
(?i:or)  |
(?i:xor) {printf(BRIGHT_RED "%s" RESET, lower(yytext));}

    /**/

{ID}    {printf(WHITE "%s" RESET, upper(yytext));}
{DIGIT}+    {printf(BRIGHT_MAGENTA "%s" RESET, yytext);}
({DIGIT}+.{DIGIT}+)([eE][+-]?{DIGIT}+)? {printf(BRIGHT_MAGENTA "%s" RESET, yytext);}
    /*TODO: a rule for strings*/


    /* STRINGS */

\"  {yy_push_state(STRING); stringLength = 0;}
<STRING>\%\% {stringBuffer[stringLength++] = '%';}
<STRING>\%A {stringBuffer[stringLength++] = '@';}
<STRING>\%B {stringBuffer[stringLength++] = '\b';}
<STRING>\%С {stringBuffer[stringLength++] = '^';}
<STRING>\%D {stringBuffer[stringLength++] = '$';}
<STRING>\%F {stringBuffer[stringLength++] = '\f';}
<STRING>\%H {stringBuffer[stringLength++] = '\\';}
<STRING>\%L {stringBuffer[stringLength++] = '~';}
<STRING>\%N {stringBuffer[stringLength++] = '\n';}
<STRING>\%Q {stringBuffer[stringLength++] = '`';}
<STRING>\%R {stringBuffer[stringLength++] = '\r';}
<STRING>\%S {stringBuffer[stringLength++] = '#';}
<STRING>\%T {stringBuffer[stringLength++] = '\t';}
<STRING>\%U {stringBuffer[stringLength++] = '\0';}
<STRING>\%V {stringBuffer[stringLength++] = '|';}
<STRING>\%\' {stringBuffer[stringLength++] = '\'';}
<STRING>\%\" {stringBuffer[stringLength++] = '"';}
<STRING>\%\( {stringBuffer[stringLength++] = '(';}
<STRING>\%\) {stringBuffer[stringLength++] = ')';}
<STRING>\%\< {stringBuffer[stringLength++] = '<';}
<STRING>\%\> {stringBuffer[stringLength++] =  '>';}
<STRING>[^\"] {stringBuffer[stringLength++] =  yytext[0];}
<STRING>\" {yy_pop_state(); stringBuffer[stringLength] = 0; printf(BRIGHT_GREEN "\"%s\"" RESET, stringBuffer);}


    /* CHARACTERS */
    
\'  {yy_push_state(CHARACTER); stringLength = 0;}
<CHARACTER>\%\% {stringBuffer[0] = '%'; BEGIN(CHARACTER_END);}
<CHARACTER>\%A {stringBuffer[0] = '@'; BEGIN(CHARACTER_END);}
<CHARACTER>\%B {stringBuffer[0] = '\b'; BEGIN(CHARACTER_END);}
<CHARACTER>\%С {stringBuffer[0] = '^'; BEGIN(CHARACTER_END);}
<CHARACTER>\%D {stringBuffer[0] = '$'; BEGIN(CHARACTER_END);}
<CHARACTER>\%F {stringBuffer[0] = '\f'; BEGIN(CHARACTER_END);}
<CHARACTER>\%H {stringBuffer[0] = '\\'; BEGIN(CHARACTER_END);}
<CHARACTER>\%L {stringBuffer[0] = '~'; BEGIN(CHARACTER_END);}
<CHARACTER>\%N {stringBuffer[0] = '\n'; BEGIN(CHARACTER_END);}
<CHARACTER>\%Q {stringBuffer[0] = '`'; BEGIN(CHARACTER_END);}
<CHARACTER>\%R {stringBuffer[0] = '\r'; BEGIN(CHARACTER_END);}
<CHARACTER>\%S {stringBuffer[0] = '#'; BEGIN(CHARACTER_END);}
<CHARACTER>\%T {stringBuffer[0] = '\t'; BEGIN(CHARACTER_END);}
<CHARACTER>\%U {stringBuffer[0] = '\0'; BEGIN(CHARACTER_END);}
<CHARACTER>\%V {stringBuffer[0] = '|'; BEGIN(CHARACTER_END);}
<CHARACTER>\%\' {stringBuffer[0] = '\''; BEGIN(CHARACTER_END);}
<CHARACTER>\%\" {stringBuffer[0] = '"'; BEGIN(CHARACTER_END);}
<CHARACTER>\%\( {stringBuffer[0] = '('; BEGIN(CHARACTER_END);}
<CHARACTER>\%\) {stringBuffer[0] = ')'; BEGIN(CHARACTER_END);}
<CHARACTER>\%\< {stringBuffer[0] = '<'; BEGIN(CHARACTER_END);}
<CHARACTER>\%\> {stringBuffer[0] =  '>'; BEGIN(CHARACTER_END);}
<CHARACTER>\'   {fprintf(stderr, "Empty CHARACTER: '%s' at line %d\n",yytext, yylineno); yy_pop_state();}
<CHARACTER>.    {stringBuffer[0] = yytext[0]; BEGIN(CHARACTER_END);}
<CHARACTER_END>\'   {printf(YELLOW "\'%c\'" RESET, stringBuffer);}
<CHARACTER_END>.    {printf(ERROR "'%s%s" RESET, stringBuffer, yytext);}


    /*For any exceptions*/
.                   {printf(ERROR "%s" RESET, yytext);}

%%