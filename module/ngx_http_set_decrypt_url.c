#include <ndk.h>
#include "ngx_http_set_decrypt_url.h"
#include "dependencies/xxtea/xxtea.h"
#include "ngx_http_url_protector_module.h"

ngx_int_t
ngx_http_url_protector_set_decrypt_url(ngx_http_request_t *r, ngx_str_t *res, ngx_http_variable_value_t *v) {
    ngx_str_t src;

    src.len = v->len;
    src.data = v->data;

    ngx_str_t res_b64;

    res_b64.len = ngx_base64_decoded_length(v->len);
    ndk_palloc_re(res_b64.data, r->pool, res_b64.len);

    if (ngx_decode_base64(&res_b64, &src) != NGX_OK) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0, "set_decode_base64: invalid value"); // TODO
        return NGX_ERROR;
    }

    ngx_http_url_protector_loc_conf_t *conf;
    conf = ngx_http_get_module_loc_conf(r, ngx_http_url_protector_module);

    size_t out_len;
    char *decrypt_data = xxtea_decrypt(res_b64.data, res_b64.len, conf->decryption_key.data, &out_len);

    // TODO: check errors somehow

    res->len = out_len;
    ndk_palloc_re(res->data, r->pool, res->len);
    ngx_memcpy(res->data, decrypt_data, res->len);

    free(decrypt_data);

    return NGX_OK;
}
