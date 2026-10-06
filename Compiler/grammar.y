%{

#include <stdlib.h>
#include "lexer.h"
// Пример грамматики: https://github.com/meyerd/flex-bison-example/blob/master/calc.y
%}

%start eiffel_code

%%

eiffel_code:
	   | eiffel_code
;
%%
