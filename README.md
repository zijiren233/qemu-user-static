# qemu-user-static

Multi-arch static QEMU user-mode emulation binaries for binfmt_misc registration.

## Usage

```bash
docker run --rm --privileged ghcr.io/zijiren233/qemu-user-static --reset -p yes
```

### Options

- `--reset`: Remove existing qemu-* binfmt registrations before registering
- `-p yes` / `--persistent yes`: Keep interpreter loaded in memory (recommended)
- `-c yes` / `--credential yes`: Enable credential passing

### Available Tags

| Tag | Description |
|-----|-------------|
| `latest` | Default, musl multi-arch |
| `<version>` | Specific version (e.g., `10.2.0-rc1`) |
| `musl` | musl libc, multi-arch |
| `gnu` | glibc, multi-arch (x86_64 + arm64) |
| `linux-<arch>-<libc>` | Specific arch/libc (e.g., `linux-x86_64-musl`) |
