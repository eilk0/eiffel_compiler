%{
    #include <stdio.h>
%}

%option noyywrap
%option never-interactive

%x STRING
%x CHARACTER
%x CHARACTER_END

DIGIT   [0-9]
ID  [a-zA-Z][a-zA-Z0-9_]*

%%
    // Local variables
    int stringLength;
    char[4096] stringBuffer;

[ \t\r\n]+    {}

"--"[^\r\n]* {/*idk if commentary should be mentioned; 
                Eiffel does not support multiline comments*/}

    /* Reserved words */
across  {printf("KEYWORD DETECTED: across\n");}
agent   {printf("KEYWORD DETECTED: feature\n");}
alias   {printf("KEYWORD DETECTED: alias\n");}
all {printf("KEYWORD DETECTED: all\n");}
and {printf("KEYWORD DETECTED: and\n");}
    /*возможно стоит выделить and, or, и т.п. в отдельную категорию логических операторов?*/
as  {printf("KEYWORD DETECTED: as\n");}
assign  {printf("KEYWORD DETECTED: assign\n");}
attribute   {printf("KEYWORD DETECTED: attribute\n");}

check   {printf("KEYWORD DETECTED: check\n");}
class   {printf("KEYWORD DETECTED: class\n");}
convert {printf("KEYWORD DETECTED: convert\n");}
create  {printf("KEYWORD DETECTED: create\n");}
Current {printf("KEYWORD DETECTED: current\n");}

debug   {printf("KEYWORD DETECTED: debug\n");}
deffered    {printf("KEYWORD DETECTED: deffered\n");}
do  {printf("KEYWORD DETECTED: do\n");}
else    {printf("KEYWORD DETECTED: else\n");}
elseif  {printf("KEYWORD DETECTED: elseif\n");}
end {printf("KEYWORD DETECTED: end\n");}
ensure  {printf("KEYWORD DETECTED: ensure\n");}
expanded    {printf("KEYWORD DETECTED: expanded\n");}
export  {printf("KEYWORD DETECTED: export\n");}
external    {printf("KEYWORD DETECTED: external\n");}

False   {printf("KEYWORD DETECTED: False\n");}
feature {printf("KEYWORD DETECTED: feature\n");}
from    {printf("KEYWORD DETECTED: from\n");}
frozen  {printf("KEYWORD DETECTED: frozen\n");}

if  {printf("KEYWORD DETECTED: if\n");}
implies {printf("KEYWORD DETECTED: implies\n");}
inherit {printf("KEYWORD DETECTED: inherit\n");}
inspect {printf("KEYWORD DETECTED: inspect\n");}
invariant   {printf("KEYWORD DETECTED: invariant\n");}

like    {printf("KEYWORD DETECTED: like\n");}
local   {printf("KEYWORD DETECTED: local\n");}
loop    {printf("KEYWORD DETECTED: loop\n");}
not {printf("KEYWORD DETECTED: not\n");}
note    {printf("KEYWORD DETECTED: note\n");}

obsolete    {printf("KEYWORD DETECTED: obsolete\n");}
old {printf("KEYWORD DETECTED: old\n");}
once    {printf("KEYWORD DETECTED: once\n");}
only    {printf("KEYWORD DETECTED: only\n");}
or  {printf("KEYWORD DETECTED: or\n");}

Precursor   {printf("KEYWORD DETECTED: Precursor\n");}

redefine    {printf("KEYWORD DETECTED: redefine\n");}
rename  {printf("KEYWORD DETECTED: rename\n");}
require {printf("KEYWORD DETECTED: require\n");}
rescue  {printf("KEYWORD DETECTED: rescue\n");}
Result  {printf("KEYWORD DETECTED: Result\n");}
retry   {printf("KEYWORD DETECTED: retry\n");}

select  {printf("KEYWORD DETECTED: select\n");}
separate    {printf("KEYWORD DETECTED: separate\n");}

then    {printf("KEYWORD DETECTED: then\n");}
True    {printf("KEYWORD DETECTED: True\n");}
TUPLE   {printf("KEYWORD DETECTED: TUPLE\n");}

undefine    {printf("KEYWORD DETECTED: undefine\n");}
until   {printf("KEYWORD DETECTED: until\n");}

variant {printf("KEYWORD DETECTED: variant\n");}
Void    {printf("KEYWORD DETECTED: Void\n");}

when    {printf("KEYWORD DETECTED: when\n");}

xor {printf("KEYWORD DETECTED: xor\n");}

    /*Operators*/
":="    {printf("OPERATOR DETECTED: %s\n", yytext);}
"/="    {printf("OPERATOR DETECTED: %s\n", yytext)}
"<="    {printf("OPERATOR DETECTED: %s\n", yytext)}
">="    {printf("OPERATOR DETECTED: %s\n", yytext)}

"=" {printf("OPERATOR DETECTED: %s\n", yytext)}
"+" {printf("OPERATOR DETECTED: %s\n", yytext)}
"-" {printf("OPERATOR DETECTED: %s\n", yytext)}
"*" {printf("OPERATOR DETECTED: %s\n", yytext)}
"/" {printf("OPERATOR DETECTED: %s\n", yytext)}

"(" {printf("OPERATOR DETECTED: %s\n", yytext)}
")" {printf("OPERATOR DETECTED: %s\n", yytext)}
"[" printf("OPERATOR DETECTED: %s\n", yytext){}
"]" {printf("OPERATOR DETECTED: %s\n", yytext)}
"," {printf("OPERATOR DETECTED: %s\n", yytext)}
":" {printf("OPERATOR DETECTED: %s\n", yytext)}
";" {printf("OPERATOR DETECTED: %s\n", yytext)}
"." {printf("OPERATOR DETECTED: %s\n", yytext)}

    /**/

{ID}    {printf("IDENTIFIER DETECTED: %s\n", yytext);}
{DIGIT}+    {printf("INTEGER DETECTED: %s\n", yytext);}
({DIGIT}+.{DIGIT}+)([eE][+-]?{DIGIT}+)? {printf("REAL DETECTED: %s\n", yytext);}
    /*TODO: a rule for strings*/


    /* STRINGS */

\"  {printf("STRING BEGIN DETECTED\n"); yy_push_state(STRING); stringLength = 0;}
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
<STRING>\" {yy_pop_state(); stringBuffer[stringLength] = 0; printf("STRING FOUND: %s", stringBuffer);}


    /* CHARACTERS */
    
\'  {printf("CHARACTER BEGIN DETECTED\n"); yy_push_state(CHARACTER); stringLength = 0;}
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
<CHARACTER_END>\'   {printf("CHARACTER DETECTED: %c", stringBuffer)}
<CHARACTER_END>.    {fprintf(stderr, "Invalid CHARACTER: '%s' at line %d\n",yytext, yylineno); yy_pop_state();}


    /*For any exceptions*/
.                   {fprintf(stderr, "Unknown character: '%s' at line %d\n",yytext, yylineno);}

%%

int main(void)
{
    yylex();
    return 0;
}