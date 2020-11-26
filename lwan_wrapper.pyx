from libc.string cimport strlen
from libc.stdlib cimport atol
from libc.stdlib cimport malloc, free
from libc.stdio cimport printf, sprintf

cdef extern from "gmp.h":
    ctypedef struct mpz_t:
        pass

    cdef void mpz_init(mpz_t) nogil
    cdef void mpz_init_set_ui(mpz_t, unsigned int)  nogil

    cdef void mpz_add(mpz_t, mpz_t, mpz_t) nogil
    cdef void mpz_sub(mpz_t, mpz_t, mpz_t) nogil
    cdef void mpz_add_ui(mpz_t, const mpz_t, unsigned long int) nogil

    cdef void mpz_set(mpz_t, mpz_t) nogil

    cdef void mpz_clear(mpz_t) nogil
    cdef unsigned long int mpz_get_ui(mpz_t) nogil

    cdef void mpz_set_ui(mpz_t, unsigned long int) nogil

    cdef char *mpz_get_str(char *str, int base, const mpz_t op) nogil
    # cdef int mpz_set_str(mpz_t op, const char *str, int base) nogil
    cdef size_t mpz_sizeinbase (mpz_t op, int base) nogil

    cdef int gmp_printf(const char*, ...) nogil
    cdef int gmp_asprintf(char**, const char*, ...) nogil
    cdef size_t mpz_out_str(FILE, int, const mpz_t) nogil
    void mpz_set_si(mpz_t, long) nogil


cdef char* get_fibonacci(unsigned long long n) nogil:
    cdef mpz_t a, b
    cdef int i
    mpz_init(a)
    mpz_init(b)
    mpz_init_set_ui(a, 0)
    mpz_init_set_ui(b, 1)
    for i in range(n):
        mpz_add(a, a, b)
        mpz_sub(b, a, b)
    cdef size_t len_buf = mpz_sizeinbase(a, 10)
    cdef char *buf = <char *> malloc((len_buf + 2) * sizeof(char))
    mpz_get_str(buf, 10, a)
    mpz_clear(a)
    mpz_clear(b)
    return buf

cdef extern from "ctype.h" nogil:
    bint isdigit(int)

cdef extern from "lwan/lwan.h" nogil:
    struct lwan:
        pass

    struct lwan_request:
        pass

    struct lwan_response:
        char *mime_type
        lwan_strbuf *buffer

    const char *lwan_request_get_query_param(lwan_request *request, const char *key) nogil

    enum lwan_http_status:
        HTTP_OK

    struct lwan_url_map:
        lwan_http_status (*handler)(lwan_request *request, lwan_response *response, void *data)
        char *prefix

    void lwan_init(lwan *l)
    void lwan_set_url_map(lwan *l, lwan_url_map *map)
    void lwan_main_loop(lwan *l)
    void lwan_shutdown(lwan *l)

    struct lwan_strbuf:
        pass

    bint lwan_strbuf_set_static(lwan_strbuf *s1, const char *s2, size_t sz)
    bint lwan_strbuf_set(lwan_strbuf *s1, const char *s2, size_t sz)
    bint lwan_strbuf_printf(lwan_strbuf *s, const char *fmt, ...)
    bint lwan_strbuf_append_char(lwan_strbuf *s, const char c)

cdef lwan_http_status handle_root(lwan_request *request, lwan_response *response, void *data) nogil:
    cdef char *message = "Hello!"
    response.mime_type = "text/plain"

    lwan_strbuf_set_static(response.buffer, message, strlen(message))

    return HTTP_OK

cdef lwan_http_status handle_fibonacci(lwan_request *request, lwan_response *response, void *data) nogil:
    cdef const char *qparam = lwan_request_get_query_param(request, b"n")
    cdef unsigned long input = 0
    cdef bint valid = True
    if qparam:
        if qparam[0] == b'0':
            valid = False
        else:
            for i in range(strlen(qparam)):
                if not isdigit(qparam[i]):
                    valid = False
        if valid:
            input = atol(qparam)
    response.mime_type = "text/plain"
    if input > 0 and input <= 50000:
        ret = get_fibonacci(input)
        lwan_strbuf_printf(response.buffer, "%s", ret)
    else:
        lwan_strbuf_printf(response.buffer, "%s", b"Error: invalid input.")
    return HTTP_OK

def run():
    cdef:
        lwan l
        lwan_url_map *default_map = [
            {"prefix": "/", "handler": handle_root},
            {"prefix": "/fib", "handler": handle_fibonacci},
            {"prefix": NULL}
        ]

    with nogil:
        lwan_init(&l)

        lwan_set_url_map(&l, default_map)
        lwan_main_loop(&l)

        lwan_shutdown(&l)
