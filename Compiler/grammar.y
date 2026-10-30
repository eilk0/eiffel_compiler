%{
#include <stdio.h>
#include <stdlib.h>
#include "colors.h"

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
%token KW_LIKE KW_LOCAL "local" KW_LOOP KW_NOT KW_NOTE "note"
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

%printer {fprintf(yyo, GRAMMAR_PRINTER_COLOR "%d" RESET, $$);} <integer>
%printer {fprintf(yyo, GRAMMAR_PRINTER_COLOR "%.*e" RESET, $$);} <real>
%printer {fprintf(yyo, GRAMMAR_PRINTER_COLOR "'%c'" RESET, $$);} <character>
%printer {fprintf(yyo, GRAMMAR_PRINTER_COLOR "\"%s\"" RESET, $$);} <string>
%printer {if($$) fprintf(yyo, GRAMMAR_PRINTER_COLOR "TRUE" RESET); else fprintf(yyo, GRAMMAR_PRINTER_COLOR "FALSE" RESET);} <boolean>
%printer {fprintf(yyo, GRAMMAR_PRINTER_COLOR "%s" RESET, $$);} <identifier>

%start eiffel_code

/* %left и %right указывает порядкок того, как нужно обрабатывать ряд однотипных операторов. */
/* Внутри одного %left или %right порядок не имеет никакого значения. */
/* Порядок строк %left или %right определяет приоритет оператров: чем номер строки больше, тем больше приоритет этих операций. */
%left "+" "-" 
%left "*" "/" 
%right "^"

%%

/* Грамматическая структура арифметических, булевых и бинарных операций */
expression: "(" expression ")"
          | expression "+" expression
          | expression "-" expression
          | expression "*" expression
          | expression "/" expression
          | expression "^" expression
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

/* Полному идентификатору ячейки памяти (переменной, поля, или ячейки в массиве) */
feature: TYPE_ID
       | feature "." TYPE_ID
       | feature "[" expression "]"
       | feature_call; /* Вызов рутины может возвращать значение, которое может использоваться в выражениях. */



/* Инструкция = команда = стейтмент = одна строчка кода.*/
instruction: feature ":=" expression /* Приравнивание является инструкцией */ /* БАГ: feature может быть feature_call, а ему не может быть присвоено значение! Исправить. */
           | KW_RESULT ":=" expression
           | "create" TYPE_ID "." TYPE_ID "(" parameters_list ")" /* Вызов конструктора является инструкцией */
           | feature_call; /* Вызов рутины МОЖЕТ быть не только в выражении, но и быть один - как инструкция */

/* Грамматическая структура вызова фичи. */ /* БАГОВАННАЯ, так как сам вызов может быть в feature и выйдет something(1,2)(3)(4,5) чего в языке быть не может */
feature_call: feature "(" ")"
            | feature "(" parameters_list ")";

/* Список параметров функции (значений/выражений) */
parameters_list: expression
               | parameters_list "," expression;

/* реализация структуры: "следование". Последовательность инструкций к выполнению. */
instruction_list: %empty
                | instruction_list instruction;



/* CLASS DESCRIPTION SECTION */

do_end_section: "do" instruction_list "end";

/** Заголовок метода/рутины */
feature_method_header: TYPE_ID
                     | TYPE_ID "(" ")"
                     | TYPE_ID "(" variables_definition_list ")"
                     | TYPE_ID ":" TYPE_ID
                     | TYPE_ID "(" ")" ":" TYPE_ID
                     | TYPE_ID "(" variables_definition_list ")" ":" TYPE_ID;

/* Секция локальных переменных метода/рутины */
feature_method_local_section: "local" variables_definition_list;

/* Полная структура объявления метода/рутины. */
feature_method_definition: feature_method_header do_end_section
                         | feature_method_header feature_method_local_section do_end_section;

/* последовательность объявлений локальных переменных неизвестной длинны. */
variables_definition_list: field_definition
                         | variables_definition_list ";" field_definition;

/* Объявление атрибута/локальной переменной рутины */
field_definition: TYPE_ID ":" TYPE_ID;

/* Последовательное перечисление фич класса, будь то рутина или атрибут. */
feature_list: feature_method_definition
            | field_definition
            | feature_list feature_method_definition
            | feature_list field_definition;

/* Список идентификаторов произвольной длинны. Через запятую, т.к. используется в указании доступов. */
identifier_list: TYPE_ID
               | identifier_list "," TYPE_ID;

/* Заголовок объявления класса */
class_definition_header: "class" TYPE_ID;

/* Описание секции о наследовании в классе */
class_inheritance_section:  %empty | "inherit" identifier_list;

/* Описание секции перечисления конструкторов класса */
class_constructors_section:  %empty | "create" identifier_list;

/* Описание секции фич класса */
class_features_section: %empty
                      | "feature" feature_list
                      | "feature" "{" identifier_list "}" feature_list;

/* Полное описание объявления класса */
class_definition: class_definition_header class_inheritance_section class_constructors_section class_features_section "end";


/* EIFFEL LANGUAGE FILE STRUCTURE */

/* ПРИМИТИВНЕЙШАЯ реализация секции заметок */
note_section: "note" note_fields_list;

/* Список полей заметок произвольной длинны. */
note_fields_list: note_field
                | note_fields_list note_field;

/* Одно поле из заметок. TODO: А там только строки могут быть? */
note_field: TYPE_ID ":" TYPE_STRING;

/* Корневая сущность, являющаяся всем кодом в файле эйфеля. */
eiffel_code: class_definition
           | note_section class_definition;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}