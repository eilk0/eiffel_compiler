%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char* s);
%}

%code requires {
#define MAX_TEXT_TOKEN 4096
}

%token KW_ACROSS KW_AGENT KW_ALIAS KW_ALL KW_AS
%token KW_ASSIGN KW_ATTRIBUTE KW_CHECK KW_CLASS "class" KW_CONVERT
%token KW_CREATE "create" KW_CURRENT KW_DEBUG KW_DEFERRED KW_DO "do"
%token KW_ELSE KW_ELSEIF KW_END "end" KW_ENSURE KW_EXPANDED
%token KW_EXPORT KW_EXTERNAL KW_FEATURE "feature" KW_FROM KW_FROZEN
%token KW_IF KW_IMPLIES KW_INHERIT "inherit" KW_INSPECT KW_INVARIANT
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
%start class_definition

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
           | KW_RESULT ":=" expression
           | feature_call;

feature_call: feature "(" ")"
            | feature "(" parameters_list ")";

parameters_list: expression
               | parameters_list "," expression;

instruction_list: %empty
                | instruction_list instruction;



/* CLASS DESCRIPTION SECTION */

do_end_section: "do" instruction_list "end";

feature_method_header: TYPE_ID
                     | TYPE_ID "(" ")"
                     | TYPE_ID "(" variables_definition_list ")"
                     | TYPE_ID ":" TYPE_ID
                     | TYPE_ID "(" ")" ":" TYPE_ID
                     | TYPE_ID "(" variables_definition_list ")" ":" TYPE_ID;

feature_method_definition: feature_method_header do_end_section;

variables_definition_list: field_definition
                         | variables_definition_list ";" field_definition;

field_definition: TYPE_ID ":" TYPE_ID;

feature_list: feature_method_definition
            | field_definition
            | feature_list feature_method_definition
            | feature_list field_definition;

identifier_list: TYPE_ID
               | identifier_list "," TYPE_ID;


class_definition_header: "class" TYPE_ID;

class_inheritance_section: "inherit" identifier_list;

class_constructors_section: "create" identifier_list;

class_features_section: "feature" feature_list;
class_definition: class_definition_header class_features_section "end"
                | class_definition_header class_constructors_section class_features_section "end"
                | class_definition_header class_inheritance_section class_features_section "end"
                | class_definition_header class_inheritance_section class_constructors_section class_features_section "end";

%%

void yyerror(const char* s) {
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}