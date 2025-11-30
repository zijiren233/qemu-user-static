#!/bin/sh

set -e

apk add --no-cache \
    alsa-lib-dev \
    ninja \
    meson \
    py3-pip \
    libslirp-dev \
    libslirp \
    g++ \
    pkgconf \
    xz \
    attr-dev \
    libcap-ng-dev \
    libcap-ng-static \
    libffi-dev \
    glib-dev \
    glib-static \
    pixman-dev \
    pixman-static \
    zlib-dev \
    zlib-static \
    zstd-dev \
    autoconf \
    automake \
    bison \
    bzip2 \
    curl \
    flex \
    libtool \
    make \
    patch \
    python3 \
    wget \
    linux-headers \
    musl-dev \
    perl \
    tar \
    pcre2-static
