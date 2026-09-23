%{
    #include <stdio.h>
    #include "upper_lower.h"
    #define YY_NO_UNISTD_H
%}

%option noyywrap
%option never-interactive
%option stack
%option yylineno

%x STRING
%x CHARACTER
%x CHARACTER_END

DIGIT   [0-9]
ID  [a-zA-Z][a-zA-Z0-9_]*

UTF8_1 [\000-\011\013-\177]
UTF8_2 [\300-\337][\200-\277]
UTF8_3 [\340-\357][\200-\277][\200-\277]
UTF8_4 [\360-\367][\200-\277][\200-\277][\200-\277]

%{
    #include "tokens.h"
%}

%%
    // Local variables
    int stringLength;
    int characterLength;
    char stringBuffer[4096];

[ \t\r]+    {}
\n(--[^\n]*|[\t \n\r]*)*    {printf("LINE BREAK DETECTED\n");}

"--"[^\r\n]* {/*idk if commentary should be mentioned; 
                Eiffel does not support multiline comments*/}

    /* Reserved words */
(?i:across)  {return KW_ACROSS;}
(?i:agent)   {return KW_AGENT;}
(?i:alias)   {return KW_ALIAS;}
(?i:all) {return KW_ALL;}
(?i:as)  {return KW_AS;}
(?i:assign)  {return KW_ASSIGN;}
(?i:attribute)   {return KW_ATTRIBUTE;}
(?i:check)   {return KW_CHECK;}
(?i:class)   {return KW_CLASS;}
(?i:convert) {return KW_CONVERT;}
(?i:create)  {return KW_CREATE;}
(?i:Current) {return KW_CURRENT;}
(?i:debug)   {return KW_DEBUG;}
(?i:deferred)    {return KW_DEFERRED;}
(?i:do)  {return KW_DO;}
(?i:else)    {return KW_ELSE;}
(?i:elseif)  {return KW_ELSEIF;}
(?i:end) {return KW_END;}
(?i:ensure)  {return KW_ENSURE;}
(?i:expanded)    {return KW_EXPANDED;}
(?i:export)  {return KW_EXPORT;}
(?i:external)  {return KW_EXTERNAL;}
(?i:feature) {return KW_FEATURE;}
(?i:from)    {return KW_FROM;}
(?i:frozen)  {return KW_FROZEN;}
(?i:if)  {return KW_IF;}
(?i:implies) {return KW_IMPLIES;}
(?i:inherit) {return KW_INHERIT;}
(?i:inspect) {return KW_INSPECT;}
(?i:invariant)   {return KW_INVARIANT;}
(?i:like)    {return KW_LIKE;}
(?i:local)   {return KW_LOCAL;}
(?i:loop)    {return KW_LOOP;}
(?i:not) {return KW_NOT;}
(?i:note)    {return KW_NOTE;}
(?i:obsolete)    {return KW_OBSOLETE;}
(?i:old) {return KW_OLD;}
(?i:once)    {return KW_ONCE;}
(?i:only)    {return KW_ONLY;}
(?i:Precursor)   {return KW_PRECURSOR;}
(?i:redefine)    {return KW_REDEFINE;}
(?i:rename)  {return KW_RENAME;}
(?i:require) {return KW_REQUIRE;}
(?i:rescue)  {return KW_RESCUE;}
(?i:Result)  {return KW_RESULT;}
(?i:retry)   {return KW_RETRY;}
(?i:select)  {return KW_SELECT;}
(?i:separate)    {return KW_SEPARATE;}
(?i:then)    {return KW_THEN;}
(?i:TUPLE)   {return KW_TUPLE;}
(?i:undefine)    {return KW_UNDEFINE;}
(?i:until)   {return KW_UNTIL;}
(?i:variant) {return KW_VARIANT;}
(?i:Void)    {return KW_VOID;}
(?i:when) {return KW_WHEN;}


    /*Boolean constants*/
(?i:true)  {return TYPE_BOOLEAN;}
(?i:false) {return TYPE_BOOLEAN;}


    /*Operators*/
">"	{return OP_GREATER;}
"<"	{return OP_LESS;}
":="	{return OP_ASSIGN;}
"/="	{return OP_NE;}
"<="	{return OP_LE;}
">="	{return OP_GE;}
"="	{return OP_EQUAL;}
"+"	{return OP_PLUS;}
"-"	{return OP_MINUS;}
"*"	{return OP_MULT;}
"/"	{return OP_DIV;}
"("	{return OP_LPARENTHESIS;}
")"	{return OP_RPARENTHESIS;}
"["	{return OP_LSQBRACKET;}
"]"	{return OP_RSQBRACKET;}
"{"	{return OP_LBRACE;}
"}"	{return OP_RBRACE;}
","	{return OP_COMMA;}
":"	{return OP_COLON;}
";"	{return OP_SEMICOLON;}
"."	{return OP_POINT;}
"@"	{return OP_ATSIGN;}
"?"	{return OP_QUESTION;}
"~"	{return OP_TILDE;}
"!"	{return OP_EXCLAMATION;}
"#"	{return OP_HASH;}
"$"	{return OP_DOLLAR;}
"%"	{return OP_PERCENT;}
"&"	{return OP_AMPERSAND;}
"|"	{return OP_VBAR;}
"^"	{return OP_CARET;}
(?i:and)\s+(?i:then)	{return OP_ANDTHEN;}
(?i:and)	{return OP_AND;}
(?i:or)\s+(?i:else)	{return OP_ORELSE;}
(?i:or)	{return OP_OR;}
(?i:xor) {return OP_XOR;}

    /**/

{ID}    {printf("IDENTIFIER DETECTED: %s\n", upper(yytext));}
(({DIGIT}+(\.{DIGIT}*)?)|(\.{DIGIT}+))([eE][+-]?{DIGIT}+)? {printf("REAL DETECTED: %s\n", yytext);}

    /*integer v2*/

    /*Binary base*/
0[bB][0-1][0-1]? |
0[bB][0-1][0-1_]+[0-1] {printf("INTEGER_2 DETECTED: %s\n", yytext);}

    /*Octal base*/
0[cC][0-7][0-7]? |
0[cC][0-7][0-7_]+[0-7] {printf("INTEGER_8 DETECTED: %s\n", yytext);}

    /*Hexadecimal base*/
0[xX][0-9a-fA-F][0-9a-fA-F]? |
0[xX][0-9a-fA-F][0-9a-fA-F_]+[0-9a-fA-F] {printf("INTEGER_16 DETECTED: %s\n", yytext);}

    /*Integer without base*/
[0-9][0-9]? |
[0-9][0-9_]+[0-9] {printf("INTEGER DETECTED: %s\n", yytext);}

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
<STRING>\" {yy_pop_state(); stringBuffer[stringLength] = 0; printf("STRING FOUND: %s\n", stringBuffer);}


    /* CHARACTERS */
    
\'  {printf("CHARACTER BEGIN DETECTED\n"); yy_push_state(CHARACTER); stringLength = 0; characterLength=0;}
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

    /*UTF-8 characters*/

<CHARACTER>{UTF8_2} |
<CHARACTER>{UTF8_3} |
<CHARACTER>{UTF8_4} {
    characterLength = yyleng;
    for(int i = 0; i < yyleng ; i++){stringBuffer[i] = yytext[i];}
    BEGIN(CHARACTER_END);
}

    /*ASCII character*/

<CHARACTER>.    { characterLength = 1; stringBuffer[0] = yytext[0]; BEGIN(CHARACTER_END);}

<CHARACTER>\'   {fprintf(stderr, "Empty CHARACTER: '%s' at line %d\n",yytext, yylineno); yy_pop_state();}
<CHARACTER_END>\'   {printf("CHARACTER DETECTED:"); 
                        for(int i = 0; i < characterLength; i++){printf("%02X",(unsigned char)stringBuffer[i]);}
                        printf("\n");
                        yy_pop_state();}
<CHARACTER_END>.    {fprintf(stderr, "Invalid CHARACTER: '%s' at line %d\n",yytext, yylineno); yy_pop_state();}


    /*For any exceptions*/
.                   {fprintf(stderr, "Unknown character: '%s' at line %d\n",yytext, yylineno); return 0;}

%%