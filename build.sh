#!/usr/bin/env bash

# TODO: version, 1.12.0

if [ ! -d build/nginx ]; then
    wget https://nginx.org/download/nginx-1.11.13.tar.gz -O build/nginx.tar.gz
    cd build
    tar -xvzf nginx.tar.gz
    rm nginx.tar.gz
    mv nginx-1.11.13 nginx
    cd ..
fi

cd build/nginx

./configure \
    --add-dynamic-module=../../module/dependencies/ngx_devel_kit \
    --add-dynamic-module=../../module

make -f objs/Makefile modules

cd ../..

rm -f ndk_http_module.so
rm -f ngx_http_url_protector_module.so

cp build/nginx/objs/ndk_http_module.so build/ndk_http_module.so
cp build/nginx/objs/ngx_http_url_protector_module.so build/ngx_http_url_protector_module.so
