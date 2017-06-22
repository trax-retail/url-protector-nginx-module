#!/usr/bin/env bash

#
# Set and check version.
#

NGINX_VERSION=$1

if [ -z "${NGINX_VERSION// }" ]; then
    NGINX_VERSION="1.12.0"
fi

function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

if version_gt "1.11.5" $NGINX_VERSION; then
     echo "Error: min nginx version is 1.11.5." >&2
     exit 1
fi

#
# Download sources.
#

if [ ! -f "build/nginx-$NGINX_VERSION.tar.gz" ]; then
    wget "https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz" -O "build/nginx-$NGINX_VERSION.tar.gz"
fi

#
# Extract sources.
#

cd build

if [ ! -d "nginx-$NGINX_VERSION" ]; then
    tar -xvzf "nginx-$NGINX_VERSION.tar.gz"
fi

cd ..

#
# Build and install.
#

cd "build/nginx-$NGINX_VERSION"

# This is copy of prebuild configuration of nginx-1.12.0 for debian, but without additional dynamic modules.
./configure \
    --prefix=/usr/share/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --lock-path=/var/lock/nginx.lock \
    --pid-path=/run/nginx.pid \
    --modules-path=/usr/lib/nginx/modules \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --http-scgi-temp-path=/var/lib/nginx/scgi \
    --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
    --with-debug \
    --with-pcre-jit \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_realip_module \
    --with-http_auth_request_module \
    --with-http_v2_module \
    --with-http_dav_module \
    --with-http_slice_module \
    --with-threads \
    --with-http_addition_module \
    --with-http_geoip_module=dynamic \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module=dynamic \
    --with-http_sub_module \
    --with-http_xslt_module=dynamic \
    --with-stream=dynamic \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-mail=dynamic \
    --with-mail_ssl_module \
    --add-dynamic-module=../../module/dependencies/ngx_devel_kit \
    --add-dynamic-module=../../module

make
make install
