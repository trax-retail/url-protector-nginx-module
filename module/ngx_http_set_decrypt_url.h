#include <ngx_core.h>
#include <ngx_config.h>
#include <ngx_http.h>

ngx_int_t ngx_http_url_protector_set_decrypt_url(ngx_http_request_t *r, ngx_str_t *res, ngx_http_variable_value_t *v);
