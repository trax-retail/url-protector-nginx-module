#ifndef NGX_HTTP_URL_PROTECTOR_MODULE_H
#define NGX_HTTP_URL_PROTECTOR_MODULE_H


#include <ngx_core.h>
#include <ngx_config.h>
#include <ngx_http.h>
#include <nginx.h>

typedef struct {
    ngx_str_t decryption_key;
} ngx_http_url_protector_loc_conf_t;

extern ngx_module_t ngx_http_url_protector_module;


#endif /* NGX_HTTP_URL_PROTECTOR_MODULE_H */
