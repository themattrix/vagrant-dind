#!/bin/sh

### Run development environment

docker run -i -t --rm --privileged=true \
    -v "/vagrant:/vagrant" \
    -v "${PERSIST_DIR}/var/lib/docker:/var/lib/docker" \
    -v "${PERSIST_DIR}/repos:/repos" \
    -v "${PERSIST_DIR}/home/.bash_history:/home/.bash_history" \
    -v "${PERSIST_DIR}/home/.ssh:/home/.ssh" \
    -p 8888:8888 \
    develop

### Archive persistent data

set -e

echo
echo -n "Archiving '${PERSIST_DIR}' to '${RESTORE_TAR}'..."

sudo tar \
    -C "$(dirname "${PERSIST_DIR}")" \
    -cf ~/"$(basename "${RESTORE_TAR}")" \
    --exclude=persist/var/lib/docker \
    "$(basename "${PERSIST_DIR}")"

sudo mv -f ~/"$(basename "${RESTORE_TAR}")" "${RESTORE_TAR}"

echo 'success!'
echo
