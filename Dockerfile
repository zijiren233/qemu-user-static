FROM busybox

ENV QEMU_BIN_DIR=/usr/bin

WORKDIR /

COPY register.sh /register
COPY qemu-binfmt-conf.sh /qemu-binfmt-conf.sh

RUN chmod +x /register /qemu-binfmt-conf.sh

COPY qemu-* /usr/bin/

ENTRYPOINT ["/register"]
