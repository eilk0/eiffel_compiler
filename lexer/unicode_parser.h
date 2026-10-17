#ifndef UNICODE_PARSER_H
#define UNICODE_PARSER_H

#include <stddef.h>
#include <stdint.h>

struct ParsedChar {
    char success;
    uint32_t character;
};

struct ParsedChar parseUnicode(const char* unicodeEncoded, size_t charactersCount, int base);

#endif