%{
    #include <stdio.h>
    #include <errno.h>
    #include <math.h>
    #include "upper_lower.h"
    #include "unicode_parser.h"
    #define YY_NO_UNISTD_H
%}

%option noyywrap
%option never-interactive
%option yylineno

%x STRING
%x CHARACTER

DIGIT   [0-9]
BIN (0[bB][0-1][0-1_]+[0-1])|(0[bB][0-1][0-1]?)
OCT (0[cC][0-7][0-7_]+[0-7])|(0[cC][0-7][0-7]?)
HEX (0[xX][0-9a-fA-F][0-9a-fA-F_]+[0-9a-fA-F])|(0[xX][0-9a-fA-F][0-9a-fA-F]?)
INTWB ([0-9][0-9_]+[0-9]|[0-9][0-9]?)

BIN_INVALID_DECL 0[bB][^_][0-9a-zA-Z_]*
OCT_INVALID_DECL 0[cC][^_][0-9a-zA-Z_]*
HEX_INVALID_DECL 0[xX][^_][0-9a-zA-Z_]*

ID  [a-zA-Z][a-zA-Z0-9_]*

UTF8_1 [\000-\011\013-\177]
UTF8_2 [\300-\337][\200-\277]
UTF8_3 [\340-\357][\200-\277][\200-\277]
UTF8_4 [\360-\367][\200-\277][\200-\277][\200-\277]

%{
    #include "tokens.h"
    void printToken(char* token, char* str);
    void removeUnderscores(char* str);
    int removeCharFromString(char* str, int pos);

    typedef enum {
        LEX_SYNTAX_IN_LINE_ERROR,
        LEX_INVALID_INT_DECLARATION_ERROR,
        LEX_INVATID_CHAR_ERROR, 
        LEX_INCOMPLITE_STRNG_MISS_FINAL_QUOTE_ERROR,
        LEX_UNKNOWN_SYMB_ERROR,
        LEX_OTHER_ERROR
    } LexerErrorType;

    typedef struct{
        const char* file_name;
        int line;
        int position;
        char* prev_line;
        char* line_text;
        char* next_line;
        char* lexeme;
        LexerErrorType type;
    } LexerError;
    
    void saveLexerError(LexerErrorType type, const char* lexeme);
    void generateLexErrorMessage(LexerError* e);
%}

%%

    // Local variables
    int stringLength;
    int characterLength;
    char stringBuffer[4096];
    struct ParsedChar c;

[ \t\r]+    {/* do nothing */}
\n(--[^\n]*|[\t \n\r]*)*    {printf("NEWLINE\n"); return ENDL;}

"--"[^\r\n]* {/*idk if commentary should be mentioned; 
                Eiffel does not support multiline comments*/}

    /* Reserved words */
(?i:across)  {printToken("KW_ACROSS", yytext); return KW_ACROSS;}
(?i:agent)   {printToken("KW_AGENT", yytext); return KW_AGENT;}
(?i:alias)   {printToken("KW_ALIAS", yytext); return KW_ALIAS;}
(?i:all) {printToken("KW_ALL", yytext); return KW_ALL;}
(?i:as)  {printToken("KW_AS", yytext); return KW_AS;}
(?i:assign)  {printToken("KW_ASSIGN", yytext); return KW_ASSIGN;}
(?i:attribute)   {printToken("KW_ATTRIBUTE", yytext); return KW_ATTRIBUTE;}
(?i:check)   {printToken("KW_CHECK", yytext); return KW_CHECK;}
(?i:class)   {printToken("KW_CLASS", yytext); return KW_CLASS;}
(?i:convert) {printToken("KW_CONVERT", yytext); return KW_CONVERT;}
(?i:create)  {printToken("KW_CREATE", yytext); return KW_CREATE;}
(?i:Current) {printToken("KW_CURRENT", yytext); return KW_CURRENT;}
(?i:debug)   {printToken("KW_DEBUG", yytext); return KW_DEBUG;}
(?i:deferred)    {printToken("KW_DEFERRED", yytext); return KW_DEFERRED;}
(?i:do)  {printToken("KW_DO", yytext); return KW_DO;}
(?i:else)    {printToken("KW_ELSE", yytext); return KW_ELSE;}
(?i:elseif)  {printToken("KW_ELSEIF", yytext); return KW_ELSEIF;}
(?i:end) {printToken("KW_END", yytext); return KW_END;}
(?i:ensure)  {printToken("KW_ENSURE", yytext); return KW_ENSURE;}
(?i:expanded)    {printToken("KW_EXPANDED", yytext); return KW_EXPANDED;}
(?i:export)  {printToken("KW_EXPANDED", yytext); return KW_EXPORT;}
(?i:external)  {printToken("KW_EXTERNAL", yytext); return KW_EXTERNAL;}
(?i:feature) {printToken("KW_FEATURE", yytext); return KW_FEATURE;}
(?i:from)    {printToken("KW_FROM", yytext); return KW_FROM;}
(?i:frozen)  {printToken("KW_FROZEN", yytext); return KW_FROZEN;}
(?i:if)  {printToken("KW_IF", yytext); return KW_IF;}
(?i:implies) {printToken("KW_IMPLIES", yytext); return KW_IMPLIES;}
(?i:inherit) {printToken("KW_INHERIT", yytext); return KW_INHERIT;}
(?i:inspect) {printToken("KW_INSPECT", yytext); return KW_INSPECT;}
(?i:invariant)   {printToken("KW_INVARIANT", yytext); return KW_INVARIANT;}
(?i:like)    {printToken("KW_LIKE", yytext); return KW_LIKE;}
(?i:local)   {printToken("KW_LOCAL", yytext); return KW_LOCAL;}
(?i:loop)    {printToken("KW_LOOP", yytext); return KW_LOOP;}
(?i:not) {printToken("KW_NOT", yytext); return KW_NOT;}
(?i:note)    {printToken("KW_NOTE", yytext); return KW_NOTE;}
(?i:obsolete)    {printToken("KW_OBSOLETE", yytext); return KW_OBSOLETE;}
(?i:old) {printToken("KW_OLD", yytext); return KW_OLD;}
(?i:once)    {printToken("KW_ONCE", yytext); return KW_ONCE;}
(?i:only)    {printToken("KW_ONLY", yytext); return KW_ONLY;}
(?i:Precursor)   {printToken("KW_PRECURSOR", yytext); return KW_PRECURSOR;}
(?i:redefine)    {printToken("KW_REDEFINE", yytext); return KW_REDEFINE;}
(?i:rename)  {printToken("KW_RENAME", yytext); return KW_RENAME;}
(?i:require) {printToken("KW_REQUIRE", yytext); return KW_REQUIRE;}
(?i:rescue)  {printToken("KW_RESCUE", yytext); return KW_RESCUE;}
(?i:Result)  {printToken("KW_RESULT", yytext); return KW_RESULT;}
(?i:retry)   {printToken("KW_RETRY", yytext); return KW_RETRY;}
(?i:select)  {printToken("KW_SELECT", yytext); return KW_SELECT;}
(?i:separate)    {printToken("KW_SEPARATE", yytext); return KW_SEPARATE;}
(?i:then)    {printToken("KW_THEN", yytext); return KW_THEN;}
(?i:TUPLE)   {printToken("KW_TUPLE", yytext); return KW_TUPLE;}
(?i:undefine)    {printToken("KW_UNDEFINE", yytext); return KW_UNDEFINE;}
(?i:until)   {printToken("KW_UNTIL", yytext); return KW_UNTIL;}
(?i:variant) {printToken("KW_VARIANT", yytext); return KW_VARIANT;}
(?i:Void)    {printToken("KW_VOID", yytext); return KW_VOID;}
(?i:when) {printToken("KW_WHEN", yytext); return KW_WHEN;}


    /*Boolean constants*/
(?i:true)  {printToken("TYPE_TRUE", yytext); return TYPE_TRUE;}
(?i:false) {printToken("TYPE_FALSE", yytext); return TYPE_FALSE;}


    /*Operators*/
">"	{printToken("OP_GREATER", yytext); return OP_GREATER;}
"<"	{printToken("OP_LESS", yytext); return OP_LESS;}
":="	{printToken("OP_ASSIGN", yytext); return OP_ASSIGN;}
"/="	{printToken("OP_NE", yytext); return OP_NE;}
"<="	{printToken("OP_LE", yytext); return OP_LE;}
">="	{printToken("OP_GE", yytext); return OP_GE;}
"="	{printToken("OP_EQUAL", yytext); return OP_EQUAL;}
"+"	{printToken("OP_PLUS", yytext); return OP_PLUS;}
"-"	{printToken("OP_MINUS", yytext); return OP_MINUS;}
"*"	{printToken("OP_MULT", yytext); return OP_MULT;}
"/"	{printToken("OP_DIV", yytext); return OP_DIV;}
"("	{printToken("OP_LPARENTHESIS", yytext); return OP_LPARENTHESIS;}
")"	{printToken("OP_RPARENTHESIS", yytext); return OP_RPARENTHESIS;}
"["	{printToken("OP_LSQBRACKET", yytext); return OP_LSQBRACKET;}
"]"	{printToken("OP_RSQBRACKET", yytext); return OP_RSQBRACKET;}
"{"	{printToken("OP_LBRACE", yytext); return OP_LBRACE;}
"}"	{printToken("OP_RBRACE", yytext); return OP_RBRACE;}
","	{printToken("OP_COMMA", yytext); return OP_COMMA;}
":"	{printToken("OP_COLON", yytext); return OP_COLON;}
";"	{printToken("OP_SEMICOLON", yytext); return OP_SEMICOLON;}
"."	{printToken("OP_POINT", yytext); return OP_POINT;}
"@"	{printToken("OP_ATSIGN", yytext); return OP_ATSIGN;}
"?"	{printToken("OP_QUESTION", yytext); return OP_QUESTION;}
"~"	{printToken("OP_TILDE", yytext); return OP_TILDE;}
"!"	{printToken("OP_EXCLAMATION", yytext); return OP_EXCLAMATION;}
"#"	{printToken("OP_HASH", yytext); return OP_HASH;}
"$"	{printToken("OP_DOLLAR", yytext); return OP_DOLLAR;}
"%"	{printToken("OP_PERCENT", yytext); return OP_PERCENT;}
"&"	{printToken("OP_AMPERSAND", yytext); return OP_AMPERSAND;}
"|"	{printToken("OP_VBAR", yytext); return OP_VBAR;}
"^"	{printToken("OP_CARET", yytext); return OP_CARET;}
(?i:and)\s+(?i:then)	{printToken("OP_ANDTHEN", yytext); return OP_ANDTHEN;}
(?i:and)	{printToken("OP_AND", yytext); return OP_AND;}
(?i:or)\s+(?i:else)	{printToken("OP_ORELSE", yytext); return OP_ORELSE;}
(?i:or)	{printToken("OP_OR", yytext); return OP_OR;}
(?i:xor) {printToken("OP_XOR", yytext); return OP_XOR;}

    /**/


    /* REAL */

[0-9]+\.[0-9]+([eE][+-]?[0-9]+)? |
[0-9]+\.([eE][+-]?[0-9]+)? |
\.[0-9]+([eE][+-]?[0-9]+)? |
(([0-9]{1,3}(_[0-9]{3})+))\.(([0-9]{3}_)*[0-9]{1,3})([eE][+-]?[0-9]+)? |
(([0-9]{1,3}(_[0-9]{3})+))\.([eE][+-]?[0-9]+)? |
\.(([0-9]{3}_)*[0-9]{1,3})([eE][+-]?[0-9]+)? {
        if ((size_t)yyleng >= sizeof(stringBuffer)) {
            fprintf(stderr, "REAL literal is too long at line %d\n", yylineno);
            return 0;
        } 
        strcpy(stringBuffer, yytext);
        removeUnderscores(stringBuffer);
        char* end;
        errno = 0;
        double num = strtod(stringBuffer, &end);
        if (end == stringBuffer || *end != '\0') {
            fprintf(stderr, "Failed to parse REAL: %s at line %d\n", yytext, yylineno);
            return 0;
        }
        if (errno == ERANGE || !isfinite(num)) {
            fprintf(stderr, "REAL out of range: %s at line %d\n", yytext, yylineno);
            return 0;
        }
        printf("DETECTED TYPE_REAL: %lf\n", num);
        return TYPE_REAL;
    }

    /*integer v2*/

    /*Binary base*/
{BIN} {
    stringBuffer[0] = 0;
    strcpy(stringBuffer, yytext);
    removeUnderscores(stringBuffer);
    long num =  strtol(stringBuffer + 2, NULL, 2);
    if(LONG_MAX == num || LONG_MIN == num) {
        fprintf(stderr, "Failed to parse integer: '%s' at line %d\n",yytext, yylineno);
        return 0;
    }
    printf("DETECTED TYPE_INT2: %d\n", num);
    return TYPE_INT2; // не уверена, нужны ли прям такие отдельные токены или просто TYPE_INT
    }

{BIN_INVALID_DECL} {saveLexerError(LEX_INVALID_INT_DECLARATION_ERROR, yytext); return 0;}

    /*Octal base*/
{OCT} {
    stringBuffer[0] = 0;
    strcpy(stringBuffer, yytext);
    removeUnderscores(stringBuffer);
    long num =  strtol(stringBuffer + 2, NULL, 8);
    if(LONG_MAX == num || LONG_MIN == num) {
        fprintf(stderr, "Failed to parse integer: '%s' at line %d\n",yytext, yylineno);
        return 0;
    }
    printf("DETECTED TYPE_INT8: %d\n", num);
    return TYPE_INT8;
    }

{OCT_INVALID_DECL} {saveLexerError(LEX_INVALID_INT_DECLARATION_ERROR, yytext); return 0;}

    /*Hexadecimal base*/
{HEX} {
    stringBuffer[0] = 0;
    strcpy(stringBuffer, yytext);
    removeUnderscores(stringBuffer);
    long num =  strtol(stringBuffer + 2, NULL, 16);
    if(LONG_MAX == num || LONG_MIN == num) {
        fprintf(stderr, "Failed to parse integer: '%s' at line %d\n",yytext, yylineno);
        return 0;
    }
    printf("DETECTED TYPE_INT16: %d\n", num);
    return TYPE_INT16;
    }

{HEX_INVALID_DECL} {saveLexerError(LEX_INVALID_INT_DECLARATION_ERROR, yytext); return 0;}

    /*Integer without base*/
{INTWB} {
    stringBuffer[0] = 0;
    strcpy(stringBuffer, yytext);
    removeUnderscores(stringBuffer);
    long num =  strtol(stringBuffer, NULL, 10);
    if(LONG_MAX == num || LONG_MIN == num) {
        fprintf(stderr, "Failed to parse integer: '%s' at line %d\n",yytext, yylineno);
        return 0;
    }
    printf("DETECTED TYPE_INT: %d\n", num);
    return TYPE_INT;
}

{ID}    {printToken("TYPE_ID", yytext); return TYPE_ID; /*перенесено после интов для отлова ошибки непсовпадения основания инта*/}

    /* STRINGS */

\"  {printf("STRING BEGIN DETECTED\n"); BEGIN(STRING); stringLength = 0;}
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

<STRING>\%\/{BIN}\/ {
    c = parseUnicode(yytext, yyleng, 2);
    if(!c.success) {
        fprintf(stderr, "Failed to parse ENCODED char: '%s' at line %d\n",yytext, yylineno);
        return 0;
    }
    stringBuffer[stringLength++] = c.character; }
<STRING>\%\/{OCT}\/ {
    c = parseUnicode(yytext, yyleng, 8);
    if(!c.success) {
        fprintf(stderr, "Failed to parse ENCODED char: '%s' at line %d\n",yytext, yylineno);
        return 0;
    }
    stringBuffer[stringLength++] = c.character;}
<STRING>\%\/{HEX}\/ {
    c = parseUnicode(yytext, yyleng, 16);
    if(!c.success) {
        fprintf(stderr, "Failed to parse ENCODED char: '%s' at line %d\n",yytext, yylineno);
        return 0;
    }
    stringBuffer[stringLength++] = c.character; }
<STRING>\%\/{INTWB}\/ {
    c = parseUnicode(yytext, yyleng, 10);
    if(!c.success) {
        fprintf(stderr, "Failed to parse ENCODED char: '%s' at line %d\n",yytext, yylineno);
        return 0;
    }
    stringBuffer[stringLength++] = c.character; }

<STRING>[^\"] {stringBuffer[stringLength++] =  yytext[0];}
<STRING>\" {BEGIN(INITIAL); 
        stringBuffer[stringLength] = 0;
        printf("STRING FOUND: %s\n", stringBuffer);
        return TYPE_STRING;}

<STRING><<EOF>> {
    fprintf(stderr, "Unterminated STRING at line %d\n", yylineno);
    saveLexerError(LEX_INCOMPLITE_STRNG_MISS_FINAL_QUOTE_ERROR, stringBuffer);
    BEGIN(INITIAL);
    return 0;
}

    /* CHARACTERS */

\'  {printf("CHARACTER BEGIN DETECTED\n"); BEGIN(CHARACTER); stringLength = 0; characterLength = 0;}
<CHARACTER>\%\% {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '%';}
<CHARACTER>\%A {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '@';}
<CHARACTER>\%B {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '\b';}
<CHARACTER>\%С {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '^';}
<CHARACTER>\%D {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '$';}
<CHARACTER>\%F {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '\f';}
<CHARACTER>\%H {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '\\';}
<CHARACTER>\%L {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '~';}
<CHARACTER>\%N {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '\n';}
<CHARACTER>\%Q {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '`';}
<CHARACTER>\%R {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '\r';}
<CHARACTER>\%S {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '#';}
<CHARACTER>\%T {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '\t';}
<CHARACTER>\%U {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '\0';}
<CHARACTER>\%V {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '|';}
<CHARACTER>\%\' {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '\'';}
<CHARACTER>\%\" {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '"';}
<CHARACTER>\%\( {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '(';}
<CHARACTER>\%\) {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = ')';}
<CHARACTER>\%\< {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = '<';}
<CHARACTER>\%\> {characterLength++; if (characterLength == 1) stringBuffer[stringLength++] =  '>';}

<CHARACTER>\%\/{BIN}\/ {
    c = parseUnicode(yytext, yyleng, 2);
    if(!c.success) {
        fprintf(stderr, "Failed to parse ENCODED char: '%s' at line %d\n",yytext, yylineno);
        return 0;
    }
    characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = c.character; }
<CHARACTER>\%\/{OCT}\/ {
    c = parseUnicode(yytext, yyleng, 8);
    if(!c.success) {
        fprintf(stderr, "Failed to parse ENCODED char: '%s' at line %d\n",yytext, yylineno);
        return 0;
    }
    characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = c.character;}
<CHARACTER>\%\/{HEX}\/ {
    c = parseUnicode(yytext, yyleng, 16);
    if(!c.success) {
        fprintf(stderr, "Failed to parse ENCODED char: '%s' at line %d\n",yytext, yylineno);
        return 0;
    }
    characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = c.character; }
<CHARACTER>\%\/{INTWB}\/ {
    c = parseUnicode(yytext, yyleng, 10);
    if(!c.success) {
        fprintf(stderr, "Failed to parse ENCODED char: '%s' at line %d\n",yytext, yylineno);
        return 0;
    }
    characterLength++; if (characterLength == 1) stringBuffer[stringLength++] = c.character; }

<CHARACTER>{UTF8_2} |
<CHARACTER>{UTF8_3} |
<CHARACTER>{UTF8_4} { characterLength++;
    if (characterLength == 1) {
        for (int i = 0; i < yyleng; i++) {
            stringBuffer[stringLength++] = yytext[i];
        }
    }
}

<CHARACTER>[^\'] {
    characterLength++;
    if (characterLength == 1) stringBuffer[stringLength++] = yytext[0];
}
<CHARACTER>\' {
    BEGIN(INITIAL);
    if (characterLength != 1) {
        fprintf(stderr, "Invalid CHARACTER length: %d (expected 1) at line %d\n", characterLength, yylineno);
        saveLexerError(LEX_INVATID_CHAR_ERROR, stringBuffer);
        return 0;
    }
    stringBuffer[stringLength] = 0;
    printf("CHARACTER DETECTED:%s\n", stringBuffer);
    return TYPE_CHAR;
}

<CHARACTER><<EOF>> {
    fprintf(stderr, "Unterminated CHARACTER at line %d\n", yylineno);
    saveLexerError(LEX_INVATID_CHAR_ERROR, stringBuffer);
    BEGIN(INITIAL);
    return 0;
}

    /*For any exceptions*/
.                   {fprintf(stderr, "Unknown character: '%s' at line %d\n",yytext, yylineno); 
                        saveLexerError(LEX_UNKNOWN_SYMB_ERROR, yytext);
                        return 0;}

%%

void printToken(char* token, char* str) {
    printf("DETECTED %s: %s\n", token, str);
}

void removeUnderscores(char* str){
    char* underscore = strchr(str, '_');
    while ((underscore = strchr(str, '_')) != NULL) {
        memmove(underscore, underscore + 1, strlen(underscore));
    }
}

int removeCharFromString(char* str, int pos) {
    int length = strlen(str);
    if (pos >= length || pos < 0) { return 0; }
    for (int i = pos; i < pos; i++)
    str[i] = str[i + 1];
    return 1;
}

#define MAX_LEXER_ERRORS 100

LexerError lexerErrors[MAX_LEXER_ERRORS];
int lexerErrorCount = 0;


void saveLexerError(LexerErrorType type, const char* lexeme)
{
    if (lexerErrorCount >= MAX_LEXER_ERRORS)
        return;

    LexerError* error = &lexerErrors[lexerErrorCount];

    error->file_name = NULL;
    error->line = yylineno;

    error->prev_line = NULL;
    error->line_text = NULL;
    error->next_line = NULL;

    error->lexeme = lexeme;

    if (lexeme != NULL) {
        error->lexeme = _strdup(lexeme);
    }

    error->type = type;

    lexerErrorCount++;
}

void generateLexErrorMessage(LexerError* e)
{
    switch (e->type)
    {
        case LEX_SYNTAX_IN_LINE_ERROR:
            printf(
                "Syntax error at line %d in class TEST_ID\n\n",
                e->line
            );

            if (e->line_text != NULL)
                printf("%s\n", e->prev_line);

           if (e->line_text != NULL)
                printf("%s\n", e->line_text);

           if (e->next_line != NULL)
                printf("%s\n", e->next_line);

            break;


        case LEX_INVALID_INT_DECLARATION_ERROR:
            printf(
                "Invalid integer declaration at line %d\n",
                e->line
            );

            if (e->line_text != NULL)
                printf("%s\n", e->prev_line);

            if (e->line_text != NULL)
                printf("%s\n", e->line_text);

            if (e->next_line != NULL)
                printf("%s\n", e->next_line);

            break;


        case LEX_INVATID_CHAR_ERROR:
            printf(
                "Invalid CHARACTER at line %d\n",
                e->line
            );

            if (e->line_text != NULL)
                printf("%s\n", e->prev_line);

            if (e->line_text != NULL)
                printf("%s\n", e->line_text);

            if (e->next_line != NULL)
                printf("%s\n", e->next_line);

            break;


        case LEX_INCOMPLITE_STRNG_MISS_FINAL_QUOTE_ERROR:
            printf(
                "Unterminated STRING at line %d\n",
                e->line
            );

            if (e->line_text != NULL)
                printf("%s\n", e->prev_line);

            if (e->line_text != NULL)
                printf("%s\n", e->line_text);

            if (e->next_line != NULL)
                printf("%s\n", e->next_line);

            break;


        case LEX_UNKNOWN_SYMB_ERROR:
            printf(
                "Unknown symbol at line %d\n",
                e->line
            );

             if (e->line_text != NULL)
                printf("%s\n", e->prev_line);

             if (e->line_text != NULL)
                printf("%s\n", e->line_text);

            if (e->next_line != NULL)
                printf("%s\n", e->next_line);
            break;


        case LEX_OTHER_ERROR:
            printf(
                "Lexer error at line %d\n",
                e->line
            );
            if (e->line_text != NULL)
                printf("%s\n", e->prev_line);

            if (e->line_text != NULL)
                printf("%s\n", e->line_text);

            if (e->next_line != NULL)
                printf("%s\n", e->next_line);

            break;
    }
}
