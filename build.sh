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

export CFLAGS="$CFLAGS -static --static -O2"
export CXXFLAGS="$CXXFLAGS -static --static -O2"
export CPPFLAGS="$CPPFLAGS -static --static -O2"

./configure \
    --prefix="$PWD/qemu-user-static" \
    --bindir="$PWD/qemu-user-static" \
    --static \
    --disable-kvm \
    --disable-vnc \
    --disable-system \
    --disable-brlapi \
    --disable-bpf \
    --disable-cap-ng \
    --disable-capstone \
    --disable-curl \
    --disable-curses \
    --disable-guest-agent \
    --disable-guest-agent-msi \
    --disable-libnfs \
    --disable-mpath \
    --disable-nettle \
    --disable-numa \
    --disable-sdl \
    --disable-spice \
    --disable-tools \
    --disable-docs \
    --disable-gcrypt \
    --disable-gnutls \
    --disable-gtk \
    --enable-linux-user \
    --disable-libvduse \
    --disable-vhost-kernel \
    --disable-vhost-net \
    --disable-vhost-user \
    --disable-vhost-vdpa \
    --disable-qom-cast-debug \
    --disable-debug-info \
    --enable-strip \
    --disable-debug-tcg \
    --disable-tpm \
    --disable-selinux \
    --disable-attr \
    --disable-membarrier \
    --disable-install-blobs \
    --disable-relocatable

make -j$(nproc)
make install
rm -rf "$PWD/qemu-user-static/share"
rm -f "$PWD/qemu-user-static.tgz"
tar -zcf "$PWD/qemu-user-static.tgz" "$PWD/qemu-user-static"
