#!/bin/bash

set -e

QEMU_VERSION="${1:-}"

if [ -z "$QEMU_VERSION" ]; then
    echo "Error: QEMU_VERSION is required" >&2
    echo "Usage: $0 <version>" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Auto-detect OS and install dependencies
install_deps() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
        alpine)
            echo "Detected Alpine Linux, installing dependencies..."
            sh "$SCRIPT_DIR/init-alpine.sh"
            ;;
        ubuntu | debian)
            echo "Detected $ID, installing dependencies..."
            sh "$SCRIPT_DIR/init-ubuntu.sh"
            ;;
        *)
            echo "Warning: Unknown distribution '$ID', skipping dependency installation" >&2
            ;;
        esac
    elif command -v apk >/dev/null 2>&1; then
        echo "Detected apk, assuming Alpine Linux..."
        sh "$SCRIPT_DIR/init-alpine.sh"
    elif command -v apt >/dev/null 2>&1; then
        echo "Detected apt, assuming Debian/Ubuntu..."
        sh "$SCRIPT_DIR/init-ubuntu.sh"
    else
        echo "Warning: Could not detect package manager, skipping dependency installation" >&2
    fi
}

install_deps

rm -f "qemu-${QEMU_VERSION}.tar.xz"
rm -rf "qemu-${QEMU_VERSION}"
wget "https://download.qemu.org/qemu-${QEMU_VERSION}.tar.xz"
tar xJf "qemu-${QEMU_VERSION}.tar.xz"
cd "qemu-${QEMU_VERSION}"

# Apply musl patches from Alpine Linux
PATCH_DIR="$SCRIPT_DIR/patchs"
echo "Applying musl patches..."
for patch in "$PATCH_DIR"/*.patch; do
    if [ -f "$patch" ]; then
        echo "  Applying: $(basename "$patch")"
        patch -p1 <"$patch"
    fi
done
# Setup ccache if available
if command -v ccache >/dev/null 2>&1; then
    echo "Enabling ccache..."
    export CC="ccache gcc"
    export CXX="ccache g++"
    ccache --show-stats || true
fi
export CFLAGS="$CFLAGS -O2"
export CXXFLAGS="$CXXFLAGS -O2"
export CPPFLAGS="$CPPFLAGS -O2"

./configure \
    --prefix="$PWD/qemu-user-static" \
    --bindir="$PWD/qemu-user-static" \
    --enable-linux-user \
    --disable-system \
    --static \
    --disable-vnc \
    --disable-kvm \
    --disable-brlapi \
    --disable-bpf \
    --disable-cap-ng \
    --disable-capstone \
    --disable-curl \
    --disable-curses \
    --disable-docs \
    --disable-gcrypt \
    --disable-gnutls \
    --disable-gtk \
    --disable-guest-agent \
    --disable-guest-agent-msi \
    --disable-libnfs \
    --disable-mpath \
    --disable-nettle \
    --disable-numa \
    --disable-sdl \
    --disable-spice \
    --disable-tools \
    --enable-strip \
    --disable-install-blobs \
    --disable-glusterfs \
    --disable-debug-info \
    --disable-bsd-user \
    --disable-werror

make -j$(nproc)
make install
rm -rf "$PWD/qemu-user-static/share"
rm -f "$PWD/qemu-user-static.tgz"
tar -zcf "$PWD/qemu-user-static.tgz" -C "$PWD/qemu-user-static" .
