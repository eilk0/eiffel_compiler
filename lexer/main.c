#include "yylex.h"


int main(int argc, char** argv) {
    if (argc > 1) {
        FILE* file = fopen(argv[1], "r");
        if (!file) {
            perror(argv[1]);
            return 1;
        }
        yyin = file;
    }
    else {
        printf("File is not specified!");
        return -1;
    }
    int token;
    while ((token = yylex())) {}
    return 0;
}