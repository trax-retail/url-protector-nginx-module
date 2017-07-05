#!/usr/bin/env bash

#
# Create build folder if not exists.
#

if [ ! -f "build" ]; then
    mkdir build
fi

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
# Copy default configure script if not exists.
#

if [ ! -f "nginx_configure.sh" ]; then
    cp nginx_configure.sh.default nginx_configure.sh
fi

#
# Build and install (or run tests).
#

cd "build/nginx-$NGINX_VERSION"

./../../nginx_configure.sh

make
if [ $TEST = "true" ]; then
    cd ../../
    TEST_NGINX_BINARY="./build/nginx-$NGINX_VERSION/objs/nginx" prove ./t
else
    make install
fi
