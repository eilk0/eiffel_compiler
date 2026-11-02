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

%start instruction_list

/* %left и %right указывает порядкок того, как нужно обрабатывать ряд однотипных операторов. */
/* Внутри одного %left или %right порядок не имеет никакого значения. */
/* Порядок строк %left или %right определяет приоритет оператров: чем номер строки больше, тем больше приоритет этих операций. */
%left "."
%left "+" "-" 
%left "*" "/" 
%right "^"

%%

/* Грамматическая структура арифметических, булевых и бинарных операций */
expression: expression_in_brackets
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
          | feature_reference
          | feature_reference_with_parameters
          | array_element_reference
          ;

expression_in_brackets: "(" expression ")";

          
/* FEATURE KINDS SECTION */


/* 

Проблема: болтаюющийся параметр в скобках

        action "(" parameter ")" "." action 

Может быть раскрыт двумя способами:

    1.  action
        "(" parameter ")" "." action 
    
    2.  action "(" parameter ")" "." action 

В оригинальном языке данный код всегда приводится к формату 2.

Решение: ограничить правила для инструкций.

Суть решения заключается в том, чтобы частично запретить инструкции начинаться с значениях в (скобках).

Тоесть, парсер должен обработать код так:

        action "(" parameter ")" "." action 

    1.  action -> instruction_without_parameters

        instruction_without_parameters "(" parameter ")" "." action 
    
    2.  instruction_without_parameters "(" parameter ")" -> instruction_with_parameters

        instructuin_wuth_parameters "." action

    3.  instructuin_wuth_parameters "." action -> instuction_without_parameters

        instuction_without_parameters

    Суть в том, что instuction_without_parameters может идти после instuction_without_parameters только если оно не начинается со скобок.

    При этом, instuction_without_parameters - ожидаемое продолжение после instruction_with_parameters

*/


multiple_expressions_list: expression "," expression
               | multiple_expressions_list "," expression;

multiple_expressions_in_brackets: "(" multiple_expressions_list ")";

feature_reference: TYPE_ID
                 | feature_reference "." TYPE_ID
                 | feature_reference_with_parameters "." TYPE_ID
                 | array_element_reference "." TYPE_ID
                 | expression_in_brackets "." TYPE_ID;

array_element_reference: feature_reference "[" expression "]";

feature_reference_with_parameters: feature_reference multiple_expressions_in_brackets
                                 | feature_reference expression_in_brackets
                                 | feature_reference "(" ")";



new_feature_reference_without_start_brackets: TYPE_ID
                     | new_feature_reference_without_start_brackets "." TYPE_ID;

new_feature_reference_in_brackets_group: "(" new_feature_reference ")"
                     | "(" new_feature_reference new_feature_reference_in_brackets_group ")"
                     | "(" new_feature_reference_in_brackets_group ")";

new_multiple_feature_reference_list: new_feature_reference "," new_feature_reference
                                   | new_multiple_feature_reference_list "," new_feature_reference;

new_multiple_feature_reference_in_brackets_group: "(" new_multiple_feature_reference_list ")";

new_feature_reference_with_start_brackets: new_feature_reference_in_brackets_group "." TYPE_ID;

new_feature_reference: new_feature_reference_without_start_brackets
                            | new_feature_reference_with_start_brackets;


/* 
   NPI = Not Parametrized Instruction
   PI = Parametrized Instruction
*/

instruction_list_ended_with_npi: new_feature_reference /* Создание списка */
                               | instruction_list_ended_with_npi new_feature_reference_without_start_brackets /* последовательно можно писать такие инструкции только тогда, когда следующая не начинается со скобок */
                               | instruction_list_ended_with_pi new_feature_reference /* такую инструкцию все же можно написать, но при условии, что перед ней идет инструкция с (параметрами)  */;

instruction_list_ended_with_pi: instruction_list_ended_with_npi          new_feature_reference_in_brackets_group
                              | instruction_list_ended_with_npi new_multiple_feature_reference_in_brackets_group
                              | instruction_list_ended_with_npi "(" ")";

instruction_list: %empty
                | instruction_list_ended_with_npi
                | instruction_list_ended_with_pi;



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