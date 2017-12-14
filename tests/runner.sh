#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

CWD="$(dirname $0)/"

. ${CWD}functions.sh

echo "=> Starting $0"
start_docker
check_docker
check_environment
cleanup
build_image

for T in ${CWD}test*.sh; do
    echo "==> Executing Test $T"
    ${T}
done

cleanup
echo "=> Done!"
