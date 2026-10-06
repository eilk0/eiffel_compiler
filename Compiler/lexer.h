
/*
Этот заголовочный файл используется нашим кодом для того, чтобы получить доступ к ключевым функциям.
Сюда можно добавлять предобъявления всего, что содержится в файле lex.yy.c и должно быть доступно в main.c.
Таким образом, мы регулируем то, к чему доступ должен быть, а к чему нет. 

ТЕПЕРЬ ЭТОТ ФАЙЛ СКАНЕРА ЧИСТО ИНТЕРФЕЙСНЫЙ, ОН МОЖЕТ РЕДАКТИРОВАТЬСЯ!
Сам сканер переехал в lex.yy.c
*/

#define MAX_LEXER_ERRORS 100

// Библиотека для работы с FILE
#include <stdio.h>

// Интерфейс сканера (флекс)
extern int yylex(); // Функция вызова сканера (лексера)
extern FILE* yyin; // Переменная-параметр - файл, который нужно просканировать.


// Интерфейс грамматики (бизон)
extern int yyparse(); // Функция вызова грамматики (бизона)


// Кастомные струкртуры данных
typedef enum {
    LEX_SYNTAX_IN_LINE_ERROR,
    LEX_INVALID_INT_DECLARATION_ERROR,
    LEX_INVATID_CHAR_ERROR,
    LEX_INCOMPLITE_STRNG_MISS_FINAL_QUOTE_ERROR,
    LEX_UNKNOWN_SYMB_ERROR,
    LEX_OTHER_ERROR
} LexerErrorType;

typedef struct {
    const char* file_name;
    int line;
    int position;
    char* prev_line;
    char* line_text;
    char* next_line;
    char* lexeme;
    LexerErrorType type;
} LexerError;


// Кастомные глобальные переменные
extern int lexerErrorCount; // Счетчик ошибок
extern LexerError lexerErrors[MAX_LEXER_ERRORS];

