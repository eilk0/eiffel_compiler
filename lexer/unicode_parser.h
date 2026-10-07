#include <stddef.h>

struct ParsedChar {
    char success;
    uint32_t character;
};

struct ParsedChar parseUnicode(const char* unicodeEncoded, size_t charactersCount, int base);