#include "coolstr.h"
#include <stdio.h>

int main(int argc, char ** argv) {
    coolstr a, b;
    char buffer[64];
    cstr_init(&a, "Hello ");
    cstr_init(&b, "World!");
    cstr_append(&a, &b);
    cstr_get(&a, buffer, sizeof(buffer));
    puts(buffer);
    cstr_free(&a);
    cstr_free(&b);
    return 0;
}
