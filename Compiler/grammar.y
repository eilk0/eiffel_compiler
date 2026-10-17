%{

#include <stdlib.h>
#include "lexer.h"
void yyerror(const char* s);
// Пример грамматики: https://github.com/meyerd/flex-bison-example/blob/master/calc.y
%}

%start eiffel_code

%%

eiffel_code:
	   | eiffel_code
;
%%

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}