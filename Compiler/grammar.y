%{
#include <stdio.h>
#include <stdlib.h>
#include "lexer.h"
#include <stddef.h>
#include <stdint.h>
#include "grammar.tab.h"

void yyerror(const char* s);
%}

%code requires {
#define MAX_TEXT_TOKEN 4096
}

/* просто перетащила из tokens.h, хз */
%union {
    long integer; // TYPE_INT, TYPE_INT2, TYPE_INT8, TYPE_INT16
    double real; // TYPE_REAL
    int boolean; // TYPE_TRUE, TYPE_FALSE
    struct {
        char data[MAX_TEXT_TOKEN];
        size_t length;
    } identifier; // TYPE_ID
    uint32_t character; // TYPE_CHAR
    struct {
        uint32_t data[MAX_TEXT_TOKEN];
        size_t length;
    } string; // TYPE_STRING
}

// ---------------- TOKENS ----------------

%token KW_ACROSS KW_AGENT KW_ALIAS KW_ALL KW_AS
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

%token OP_GREATER OP_LESS OP_ASSIGN OP_EQUAL OP_NE
%token OP_LE OP_GE OP_PLUS OP_MINUS OP_MULT
%token OP_DIV OP_LPARENTHESIS OP_RPARENTHESIS OP_LSQBRACKET OP_RSQBRACKET
%token OP_LBRACE OP_RBRACE OP_COMMA OP_COLON OP_SEMICOLON
%token OP_POINT OP_ATSIGN OP_QUESTION OP_TILDE OP_EXCLAMATION
%token OP_HASH OP_DOLLAR OP_PERCENT OP_AMPERSAND OP_VBAR
%token OP_CARET OP_AND OP_OR OP_XOR

%token <integer> TYPE_INT TYPE_INT2 TYPE_INT8 TYPE_INT16
%token <real> TYPE_REAL
%token <character> TYPE_CHAR
%token <string> TYPE_STRING
%token <boolean> TYPE_BOOLEAN TYPE_TRUE TYPE_FALSE
%token <identifier> TYPE_ID
%token ENDL

%start eiffel_code

%%

eiffel_code:
        %empty
	   | eiffel_code class_decl
;

class_decl:
        note_opt
        class_header
        formal_generics_opt
        obsolete_opt
        inherit_opt
        create_list_opt /*тут фигня с рут классом и входной функцией*/
        convert_opt
        feature_list_opt
        invariant_opt
        note_opt
        KW_END
        ;

class_header:
        class_mod_opt KW_CLASS TYPE_ID
        ;

class_mod_opt:
        %empty
        | KW_DEFERRED
        | KW_EXPANDED
        | KW_FROZEN
        ;

formal_generics_opt:
        %empty
        | formal_generics
        ;

formal_generics:
        OP_LSQBRACKET formal_generic_list OP_RSQBRACKET
        ;

formal_generic_list:
        TYPE_ID
        | formal_generic_list OP_COMMA TYPE_ID
        ;

obsolete_opt:
        %empty
        | KW_OBSOLETE TYPE_STRING /*требует уточения*/
        ;

inherit_opt:
        %empty
        | KW_INHERIT inherit_list
        ;

inherit_list:
        TYPE_ID inherit_body_opt
        | inherit_list TYPE_ID inherit_body_opt
        | inherit_list ',' TYPE_ID inherit_body_opt
        ;

inherit_body_opt: 
        %empty
        | KW_REDEFINE combined_id_list KW_END
        ;

/* сделать креате и фичи листами - посмотреть что еще может быть листами */

create_list_opt:
        %empty
        | create_list
        ;

create_list:
        create
        | create_list create
        ;

create:
        | KW_CREATE
        | KW_CREATE combined_id_list
        ;

/* convert не сделан */
convert_opt:
        %empty
        | KW_CONVERT convert_list 
        ;

convert_list:
        TYPE_ID OP_COLON OP_LPARENTHESIS OP_LBRACE combined_id_list OP_RBRACE OP_RPARENTHESIS
        | TYPE_ID OP_COLON OP_LBRACE combined_id_list OP_RBRACE
        | 
        ;

feature_list_opt:
        %empty
        | feature_list
        ;

feature_list:
        feature
        | feature feature_list
        ;

feature:
        note_opt KW_FEATURE feature_acces_mod_opt feature_decl 
        ;

feature_acces_mod_opt:
        %empty
        | OP_LBRACE combined_id_list OP_RBRACE;
        ;

feature_decl:
        assigner_opt
        TYPE_ID arg_opt OP_COLON TYPE_ID
        require_opt
        local_opt
        runtime_mod
        routine_body
        ensure_opt
        rescue_opt
        KW_END
        ;

assigner_opt:
        %empty 
        | param KW_ASSIGN TYPE_ID
        ;

arg_opt:
        %empty
        | OP_LPARENTHESIS param_list OP_RPARENTHESIS
        ;

invariant_opt:
        %empty
        | KW_INVARIANT
        ;

note_opt:
        %empty
        | note
        ;





combined_id_list: 
        TYPE_ID
        | combined_id_list ',' TYPE_ID
        ;

ss_id_list: 
        TYPE_ID
        | ss_id_list OP_SEMICOLON TYPE_ID
        | ss_id_list TYPE_ID
        ;



param_list:
        param
        | param_list OP_SEMICOLON param
        | param_list param /* не уверена про разделители при списке аргументов */ 
        ;

param:
        TYPE_ID OP_COLON TYPE_ID
        | combined_id_list OP_COLON TYPE_ID
        ;

runtime_mod:
        KW_DO
        | KW_ONCE
        ;

require_opt:
        %empty
        | KW_REQUIRE
        ;

local_opt:
        %empty
        | KW_LOCAL param_list
        ;

ensure_opt:
        %empty
        | KW_ENSURE
        ;

rescue_opt:
        %empty
        | KW_RESCUE routine_body
        ;

routine_body:
        %empty
        ;

note:
        KW_NOTE
        | KW_NOTE note_body
        ;

note_body: 
        ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}