%{
#include <stdio.h>
#include <stdlib.h>
#include "colors.h"

void yyerror(const char* s);
%}

%code requires {
#define MAX_TEXT_TOKEN 4096
}

%token KW_ACROSS KW_AGENT KW_ALIAS KW_ALL KW_AS "as"
%token KW_ASSIGN KW_ATTRIBUTE KW_CHECK KW_CLASS "class" KW_CONVERT
%token KW_CREATE "create" KW_CURRENT KW_DEBUG KW_DEFERRED KW_DO "do"
%token KW_ELSE KW_ELSEIF KW_END "end" KW_ENSURE KW_EXPANDED
%token KW_EXPORT "export" KW_EXTERNAL KW_FEATURE "feature" KW_FROM KW_FROZEN
%token KW_IF KW_IMPLIES KW_INHERIT "inherit" KW_INSPECT KW_INVARIANT
%token KW_LIKE KW_LOCAL "local" KW_LOOP KW_NOT KW_NOTE "note"
%token KW_OBSOLETE KW_OLD KW_ONCE KW_ONLY KW_PRECURSOR
%token KW_REDEFINE "redefine" KW_RENAME "rename" KW_REQUIRE KW_RESCUE KW_RESULT
%token KW_RETRY KW_SELECT "select" KW_SEPARATE KW_THEN KW_TUPLE
%token KW_UNDEFINE "undefine" KW_UNTIL KW_VARIANT KW_VOID KW_WHEN

%token OP_GREATER ">" OP_LESS "<" OP_ASSIGN ":=" OP_EQUAL "=" OP_NE "/="
%token OP_LE "<=" OP_GE ">=" OP_PLUS "+" OP_MINUS "-" OP_MULT "*"
%token OP_DIV "/" OP_LPARENTHESIS "(" OP_RPARENTHESIS ")" OP_LSQBRACKET "[" OP_RSQBRACKET "]"
%token OP_LBRACE "{" OP_RBRACE "}" OP_COMMA "," OP_COLON ":" OP_SEMICOLON ";"
%token OP_POINT "." OP_ATSIGN "@" OP_QUESTION "?" OP_TILDE "~" OP_EXCLAMATION "!"
%token OP_HASH "#" OP_DOLLAR "$" OP_PERCENT "%" OP_AMPERSAND "&" OP_VBAR "|"
%token OP_CARET "^" OP_AND OP_OR OP_XOR
%token OP_RANGE ".."

%union {
    long integer;
    double real;
    char character;
    struct {char data[MAX_TEXT_TOKEN]; int length;} string;
    char boolean;
    struct {char data[MAX_TEXT_TOKEN]; int length;} identifier;
}

%token <integer> TYPE_INT
%token <real> TYPE_REAL
%token <character> TYPE_CHAR
%token <string> TYPE_STRING
%token <boolean> TYPE_BOOLEAN
%token <identifier> TYPE_ID
%token ENDL

%printer {fprintf(yyo, GRAMMAR_PRINTER_COLOR "%ld" RESET, $$);} <integer>
%printer {fprintf(yyo, GRAMMAR_PRINTER_COLOR "%.*e" RESET, $$);} <real>
%printer {fprintf(yyo, GRAMMAR_PRINTER_COLOR "'%c'" RESET, $$);} <character>
%printer {fprintf(yyo, GRAMMAR_PRINTER_COLOR "\"%s\"" RESET, $$);} <string>
%printer {if($$) fprintf(yyo, GRAMMAR_PRINTER_COLOR "TRUE" RESET); else fprintf(yyo, GRAMMAR_PRINTER_COLOR "FALSE" RESET);} <boolean>
%printer {fprintf(yyo, GRAMMAR_PRINTER_COLOR "%s" RESET, $$);} <identifier>

%start eiffel_code

/* %left и %right указывает порядкок того, как нужно обрабатывать ряд однотипных операторов. */
/* Внутри одного %left или %right порядок не имеет никакого значения. */
/* Порядок строк %left или %right определяет приоритет оператров: чем номер строки больше, тем больше приоритет этих операций. */
%left OP_OR OP_XOR "|"
%left OP_AND "&"
%nonassoc "=" "/=" "<" ">" "<=" ">="
%left "+" "-" 
%left "*" "/" 
%right "^"
%precedence KW_NOT "!" UPLUS UMINUS /* это обозначения чисто для порядка, если что */

%%

/* Грамматическая структура арифметических, булевых и бинарных операций */
expression: "(" expression ")"
          | expression OP_OR expression
          | expression OP_OR KW_ELSE expression %prec OP_OR
          | expression OP_XOR expression
          | expression OP_AND expression
          | expression OP_AND KW_THEN expression %prec OP_AND
          | expression "|" expression
          | expression "&" expression
          | KW_NOT expression
          | "!" expression
          | "+" expression %prec UPLUS
          | "-" expression %prec UMINUS
          | expression "=" expression
          | expression "/=" expression
          | expression "<" expression
          | expression ">" expression
          | expression "<=" expression
          | expression ">=" expression
          | expression "+" expression
          | expression "-" expression
          | expression "*" expression
          | expression "/" expression
          | expression "^" expression
          | TYPE_INT
          | TYPE_REAL
          | TYPE_CHAR
          | TYPE_STRING
          | TYPE_BOOLEAN
          | feature_reference
          | feature_reference_with_parameters
          | array_element_reference
          ;

          
/* FEATURE KINDS SECTION */

parameters_list: %empty
               | expression
               | parameters_list "," expression;

feature_reference: TYPE_ID
                 | feature_reference "." TYPE_ID
                 | feature_reference_with_parameters "." TYPE_ID
                 | array_element_reference "." TYPE_ID;

array_element_reference: feature_reference "[" expression "]";

feature_reference_with_parameters: feature_reference "(" parameters_list ")";


create_instruction: "create" TYPE_ID "." TYPE_ID "(" parameters_list ")"
                  | "create" TYPE_ID "." TYPE_ID;

/* Инструкция = команда = стейтмент = одна строчка кода.*/
instruction: feature_reference ":=" expression
           | array_element_reference ":=" expression
           | KW_RESULT ":=" expression
           | create_instruction
           | loop_instruction
           | if_instruction
           | inspect_instruction
           | feature_reference_with_parameters 
           | feature_reference; 



/* реализация структуры: "следование". Последовательность инструкций к выполнению. */
instruction_list: %empty
                | instruction_list instruction
                | instruction_list ";" {/* Буквально ничего не делать */}; 

/* цикл. вроде похоже на правду? не знаю пока что че сюда дописать... */
loop_instruction: KW_FROM instruction_list
    KW_UNTIL expression
    KW_LOOP
    instruction_list
    "end";


/* условная конструкция. elseif и else необязательны, end обязательно */
if_instruction: KW_IF expression 
    KW_THEN instruction_list
    elseif_list else_section
    "end";

elseif_list: %empty
           | elseif_list KW_ELSEIF expression KW_THEN instruction_list;

else_section: %empty
            | KW_ELSE instruction_list;

/* switch-case (inspect) */
inspect_instruction: KW_INSPECT expression when_list else_section "end";

when_list: %empty
         | when_list KW_WHEN inspect_choices KW_THEN instruction_list;

inspect_choices: inspect_choice
               | inspect_choices "," inspect_choice;

inspect_choice: inspect_constant
              | inspect_constant ".." inspect_constant;

/* это чтобы в семантике можно было проверить на уникальность */
inspect_constant: constant_value
                | TYPE_ID;

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

/* Константный атрибут класса (значение задаётся литералом) */
constant_definition: TYPE_ID ":" TYPE_ID "=" constant_value;

constant_value: TYPE_INT
              | TYPE_REAL
              | "+" TYPE_INT
              | "-" TYPE_INT
              | "+" TYPE_REAL
              | "-" TYPE_REAL
              | TYPE_CHAR
              | TYPE_STRING
              | TYPE_BOOLEAN;

/* Последовательное перечисление фич класса, будь то рутина или атрибут. */
feature_list: feature_method_definition
            | field_definition
            | constant_definition
            | feature_list feature_method_definition
            | feature_list field_definition
            | feature_list constant_definition;

/* Список идентификаторов произвольной длинны. Через запятую, т.к. используется в указании доступов. */
identifier_list: TYPE_ID
               | identifier_list "," TYPE_ID;

/* Заголовок объявления класса */
class_definition_header: "class" TYPE_ID;

/* Описание секции о наследовании в классе */
class_inheritance_section:  %empty | "inherit" parent_list;

parent_list: parent
               | parent_list parent
               | parent_list ";" parent
               ;

parent: TYPE_ID
            | TYPE_ID inherit_feature_adaptation
            ;

/* Адаптация уналедованных features */
inherit_feature_adaptation:
      "undefine" identifier_list redefine_section rename_section export_section select_section "end"
    | "redefine" identifier_list rename_section export_section select_section "end"
    | "rename" rename_list export_section select_section "end"
    | "export" export_list select_section "end"
    | "select" identifier_list "end"
    ;

redefine_section: %empty
            | "redefine" identifier_list
            ;

rename_section: %empty
            | "rename" rename_list
            ;

rename_list: rename_pair
            | rename_list "," rename_pair
            ;

rename_pair: TYPE_ID "as" TYPE_ID
            ;

export_section: %empty
            | "export" export_list 
            ;

export_list: export_item
            | export_list export_item
            ;

export_item: "{" identifier_list "}" identifier_list
            ;
            

select_section: %empty
            | "select" identifier_list
            ;


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
