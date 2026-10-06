
#include "unicode_parser.h"
#include <string.h>
#include <stdio.h>
#include <limits.h>

struct ParsedChar parseUnicode(const char* unicodeEncoded, size_t charactersCount, int base) {
    char strbuf[64];
    struct ParsedChar result;
    strcpy(strbuf, unicodeEncoded + 4);
    strbuf[charactersCount - 5] = 0;
    long decoded = strtol(strbuf, NULL, base);
    if (LONG_MAX == decoded || LONG_MIN == decoded) {
        result.success = 0;
    }
    else {
        result.success = 1;
        result.character = decoded;
    }
    return result;
}