#!/bin/sh

set -e

apt update

apt install -y \
    ninja-build \
    meson \
    python3-pip \
    libslirp-dev \
    g++ \
    pkg-config \
    xz-utils \
    libattr1-dev \
    libcap-ng-dev \
    libffi-dev \
    libglib2.0-dev \
    libpixman-1-dev \
    libselinux1-dev \
    zlib1g-dev \
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
    bash \
    ccache
