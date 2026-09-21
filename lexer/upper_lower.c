#include "upper_lower.h"
#include <ctype.h>

char* upper(char* string) {
	for (char* c = string; *c != 0; c++) {
		*c = toupper(*c);
	}
	return string;
}

char* lower(char* string) {
	for (char* c = string; *c != 0; c++) {
		*c = tolower(*c);
	}
	return string;
}