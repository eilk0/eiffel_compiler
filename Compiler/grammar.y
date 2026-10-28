%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char* s);
%}

%code requires {
#define MAX_TEXT_TOKEN 4096
}

%token KW_ACROSS  KW_AGENT KW_ALIAS KW_ALL KW_AS
%token KW_ASSIGN KW_ATTRIBUTE KW_CHECK KW_CLASS KW_CONVERT
%token KW_CREATE KW_CURRENT KW_DEBUG KW_DEFERRED KW_DO
%token KW_ELSE KW_ELSEIF KW_END KW_ENSURE KW_EXPANDED
%token KW_EXPORT KW_EXTERNAL KW_FEATURE KW_FROM KW_FROZEN
%token KW_IF KW_IMPLIES KW_INHERIT KW_INSPECT KW_INVARIANT
%token KW_LIKE KW_LOCAL KW_LOOP KW_NOT KW_NOTE
%token KW_OBSOLETE KW_OLD KW_ONCE KW_ONLY KW_PRECURSOR
%token KW_REDEFINE KW_RENAME KW_REQUIRE KW_RESCUE KW_RESULT
%token KW_RETRY KW_SELECT KW_SEPARATE KW_THEN KW_TUPLE
%token KW_UNDEFINE KW_UNTIL KW_VARIANT KW_VOID KW_WHEN

%token OP_GREATER ">" OP_LESS "<" OP_ASSIGN ":=" OP_EQUAL "=" OP_NE "/="
%token OP_LE "<=" OP_GE ">=" OP_PLUS "+" OP_MINUS "-" OP_MULT "*"
%token OP_DIV "/" OP_LPARENTHESIS "(" OP_RPARENTHESIS ")" OP_LSQBRACKET "[" OP_RSQBRACKET "]"
%token OP_LBRACE "{" OP_RBRACE "}" OP_COMMA "," OP_COLON ":" OP_SEMICOLON ";"
%token OP_POINT "." OP_ATSIGN "@" OP_QUESTION "?" OP_TILDE "~" OP_EXCLAMATION "!"
%token OP_HASH "#" OP_DOLLAR "$" OP_PERCENT "%" OP_AMPERSAND "&" OP_VBAR "|"
%token OP_CARET "^" OP_AND OP_OR OP_XOR

%union {
    int integer;
    double real;
    char character;
    struct {char data[MAX_TEXT_TOKEN]; int length;} string;
    char boolean;
    struct {char data[MAX_TEXT_TOKEN]; int length;} identifier;
}

%token <integer> TYPE_INT TYPE_INT2 TYPE_INT8 TYPE_INT16
%token <real> TYPE_REAL
%token <character> TYPE_CHAR
%token <string> TYPE_STRING
%token <boolean> TYPE_BOOLEAN
%token <identifier> TYPE_ID
%token ENDL
%start instruction_list

/* %left и %right указывает порядкок того, как нужно обрабатывать ряд однотипных операторов. */
/* Внутри одного %left или %right порядок не имеет никакого значения. */
/* Порядок строк %left или %right определяет приоритет оператров: чем номер строки больше, тем больше приоритет этих операций. */
%left "+" "-" 
%left "*" "/" 
%left "^"

%%

expression: "(" expression ")"
          | operand "+" operand
          | operand "-" operand
          | operand "*" operand
          | operand "/" operand
          | operand "^" operand
          | TYPE_INT
          | TYPE_INT16
          | TYPE_INT2
          | TYPE_INT8
          | TYPE_REAL
          | TYPE_CHAR
          | TYPE_STRING
          | TYPE_BOOLEAN
          | feature
          ;

operand: expression;

feature: TYPE_ID
       | feature "." TYPE_ID
       | feature "[" expression "]"
       | feature_call;

instruction: feature ":=" expression
           | feature_call;

feature_call: feature "(" ")"
            | feature "(" parameters_list ")";

parameters_list: expression
               | parameters_list "," expression;

instruction_list: %empty
                | instruction_list instruction;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}