#include "ngx_http_url_protector_module.h"
#include <ndk.h>
#include "ngx_http_set_decrypted_str.h"

static void *ngx_http_url_protector_create_loc_conf(ngx_conf_t *cf);

static char *ngx_http_url_protector_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child);

static ndk_set_var_t ngx_http_url_protector_set_decrypted_str_filter = {
    NDK_SET_VAR_VALUE,
    (void *) ngx_http_url_protector_set_decrypted_str,
    1,
    NULL
};

static ngx_command_t ngx_http_url_protector_commands[] = {
    {
        ngx_string("set_decrypted_str"),
        NGX_HTTP_MAIN_CONF | NGX_HTTP_SRV_CONF | NGX_HTTP_SIF_CONF | NGX_HTTP_LOC_CONF | NGX_HTTP_LIF_CONF |
        NGX_CONF_TAKE12,
        ndk_set_var_value,
        0,
        0,
        &ngx_http_url_protector_set_decrypted_str_filter
    },
    {
        ngx_string("set_decryption_key"),
        NGX_HTTP_MAIN_CONF | NGX_HTTP_SRV_CONF | NGX_HTTP_SIF_CONF | NGX_HTTP_LOC_CONF | NGX_HTTP_LIF_CONF |
        NGX_CONF_TAKE1,
        ngx_conf_set_str_slot,
        NGX_HTTP_LOC_CONF_OFFSET,
        offsetof(ngx_http_url_protector_loc_conf_t, decryption_key),
        NULL
    },
    ngx_null_command
};

static ngx_http_module_t ngx_http_url_protector_module_ctx = {
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    ngx_http_url_protector_create_loc_conf,
    ngx_http_url_protector_merge_loc_conf
};

ngx_module_t ngx_http_url_protector_module = {
    NGX_MODULE_V1,
    &ngx_http_url_protector_module_ctx,
    ngx_http_url_protector_commands,
    NGX_HTTP_MODULE,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NGX_MODULE_V1_PADDING
};

void *
ngx_http_url_protector_create_loc_conf(ngx_conf_t *cf) {
    ngx_http_url_protector_loc_conf_t *conf;

    conf = ngx_palloc(cf->pool, sizeof(ngx_http_url_protector_loc_conf_t));
    if (conf == NULL) {
        return NULL;
    }

    conf->decryption_key.data = NULL;
    conf->decryption_key.len = 0;

    return conf;
}

char *
ngx_http_url_protector_merge_loc_conf(ngx_conf_t *cf, void *parent, void *child) {
    ngx_http_url_protector_loc_conf_t *prev = parent;
    ngx_http_url_protector_loc_conf_t *conf = child;


    ngx_conf_merge_str_value(conf->decryption_key, prev->decryption_key, NULL);

    return NGX_CONF_OK;
}
