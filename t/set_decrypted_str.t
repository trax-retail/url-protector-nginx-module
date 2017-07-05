use Test::Nginx::Socket;

repeat_each(3);

plan tests => repeat_each() * 2 * blocks();

run_tests();

__DATA__

=== TEST 1: hello world
--- main_config
    load_module ../../build/nginx-1.12.0/objs/ndk_http_module.so;
    load_module ../../build/nginx-1.12.0/objs/ngx_http_url_protector_module.so;
    load_module ../../build/nginx-1.12.0/objs/ngx_http_set_misc_module.so;
    load_module ../../build/nginx-1.12.0/objs/ngx_http_echo_module.so;
--- config
    location = /test {
        set_unescape_uri $arg_url_unescaped $arg_url;

        set_decryption_key 1234567890;
        set_decrypted_str $arg_decrypted_url $arg_url_unescaped;

        echo $arg_decrypted_url;
    }
--- request
    GET /test?url=T3pE83TTT%2BWtGMj77T%2F98Q%3D%3D
--- response_body
hello world

=== TEST 2: bad key
--- main_config
    load_module ../../build/nginx-1.12.0/objs/ndk_http_module.so;
    load_module ../../build/nginx-1.12.0/objs/ngx_http_url_protector_module.so;
    load_module ../../build/nginx-1.12.0/objs/ngx_http_set_misc_module.so;
    load_module ../../build/nginx-1.12.0/objs/ngx_http_echo_module.so;
--- config
    location = /test {
        set_unescape_uri $arg_url_unescaped $arg_url;

        set_decryption_key abc;
        set_decrypted_str $arg_decrypted_url $arg_url_unescaped;

        echo $arg_decrypted_url;
    }
--- request
    GET /test?url=T3pE83TTT%2BWtGMj77T%2F98Q%3D%3D
--- error_code: 500
--- error_log eval
qr/\[error\] .*? set_decrypted_str: invalid xxtea key or value/

=== TEST 3: bad base64
--- main_config
    load_module ../../build/nginx-1.12.0/objs/ndk_http_module.so;
    load_module ../../build/nginx-1.12.0/objs/ngx_http_url_protector_module.so;
    load_module ../../build/nginx-1.12.0/objs/ngx_http_set_misc_module.so;
    load_module ../../build/nginx-1.12.0/objs/ngx_http_echo_module.so;
--- config
    location = /test {
        set_unescape_uri $arg_url_unescaped $arg_url;

        set_decryption_key 1234567890;
        set_decrypted_str $arg_decrypted_url $arg_url_unescaped;

        echo $arg_decrypted_url;
    }
--- request
    GET /test?url=T3pE83TTT+WtGMj77T/98Q==
--- error_code: 500
--- error_log eval
qr/\[error\] .*? set_decrypted_str: invalid base64 value/
