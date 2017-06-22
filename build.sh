#!/usr/bin/env bash

#
# Get nginx version.
#

NGINX_VERSION=$1

if [ -z "${NGINX_VERSION// }" ]; then
    if ! [ -x "$(command -v nginx)" ]; then
        echo "Error: you should specify version to nginx should be installed." >&2
        exit 1
    fi

    VERSION_STR="$(nginx -v 2>&1)"
    IFS='/' read -ra VERSION_STR_PARTS <<< "$VERSION_STR"
    NGINX_VERSION="${VERSION_STR_PARTS[1]}"

    # Like "1.4.6 (Ubuntu)".
    if [[ "$NGINX_VERSION" == *" "* ]]; then
      IFS=' ' read -ra VERSION_STR_PARTS <<< "$NGINX_VERSION"
      NGINX_VERSION="${VERSION_STR_PARTS[0]}"
    fi
fi

function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

if version_gt "1.11.5" $NGINX_VERSION; then
     echo "Error: min nginx version is 1.11.5. Please update from PPA: https://launchpad.net/~nginx/+archive/ubuntu/stable" >&2
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
# Build.
#

cd "build/nginx-$NGINX_VERSION"

./configure \
    --add-dynamic-module=../../module/dependencies/ngx_devel_kit \
    --add-dynamic-module=../../module

make -f objs/Makefile modules

cd ../..

#
# Copy modules.
#

rm -f ndk_http_module.so
rm -f ngx_http_url_protector_module.so

cp "build/nginx-$NGINX_VERSION/objs/ndk_http_module.so" build/ndk_http_module.so
cp "build/nginx-$NGINX_VERSION/objs/ngx_http_url_protector_module.so" build/ngx_http_url_protector_module.so

#
# Finish.
#

echo "--------------------------------"
echo "Done. Add modules to nginx.conf:"
echo "load_module $(pwd)/build/ndk_http_module.so;"
echo "load_module $(pwd)/build/ngx_http_url_protector_module.so;"
