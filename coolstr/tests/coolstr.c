#include "coolstr.h"

#include <string.h>
#include <stdlib.h>

typedef struct strbuf {
    char *data;
    size_t len;
    unsigned int refcount;
} strbuf;

static strbuf * sbuf_create(const char *str, size_t len) {
    strbuf *buf = malloc(sizeof(strbuf));
    buf->data = malloc(len);
    memcpy(buf->data, str, len);
    buf->len = len;
    buf->refcount = 1;
    return buf;
}

static void sbuf_free(strbuf *buf) {
    if (--buf->refcount == 0) {
        free(buf->data);
        free(buf);
    }
}

coolstr *cstr_init(coolstr *cstr, const char *str) {
    cstr->buf = sbuf_create(str, strlen(str));
    cstr->next = 0;
    return cstr;
}

coolstr *cstr_create(const char *str) {
    coolstr *cstr = calloc(1, sizeof(coolstr));
    return cstr_init(cstr, str);
}

coolstr * cstr_dup(const coolstr *rhs) {
    coolstr *result = 0, *lhs;
    for (; rhs; rhs = rhs->next) {
        lhs = calloc(1, sizeof(coolstr));
        lhs->buf = rhs->buf;
        ++lhs->buf->refcount;
        if (!result) result = lhs;
        lhs = lhs->next;
    }
    return result;
}

coolstr *cstr_append(coolstr *lhs, const coolstr *rhs) {
    coolstr **end = &lhs;
    while (*end) {
        end = &(*end)->next;
    }
    // FIXME: nope! must make copies
    *end = cstr_dup(rhs);
    return lhs;
}

void cstr_free(coolstr *cstr) {
    if (cstr->next) {
        cstr_free(cstr->next);
    }
    sbuf_free(cstr->buf);
}

const char *cstr_get(const coolstr *cstr, char *buf, size_t siz) {
    char *p = buf;
    while (cstr) {
        size_t len = siz;
        if (len > cstr->buf->len) len = cstr->buf->len;
        memcpy(p, cstr->buf->data, len);
        p += len;
        cstr = cstr->next;
    }
    *p = 0;
    return p;
}
