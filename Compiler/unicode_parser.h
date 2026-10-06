#include <stddef.h>

struct ParsedChar {
    char success;
    char character;
};

struct ParsedChar parseUnicode(const char* unicodeEncoded, size_t charactersCount, int base);