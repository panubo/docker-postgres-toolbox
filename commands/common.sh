#!/usr/bin/env bash

HOST=${DATABASE_HOST-${POSTGRES_PORT_5432_TCP_ADDR-localhost}}
PORT=${DATABASE_PORT-${POSTGRES_PORT_5432_TCP_PORT-5432}}
USER=${DATABASE_USER-${POSTGRES_ENV_POSTGRES_USER-postgres}}
PASS="${DATABASE_PASS-${POSTGRES_ENV_POSTGRES_PASSWORD}}"
export PGPASSWORD="${PASS}"
PGCONN="--username=${USER} --host=${HOST} --port=${PORT}"
PSQL="psql ${PGCONN}"
PGDUMP="pg_dump ${PGCONN}"
GZIP="gzip --fast"


function wait_postgres {
    # Wait for PostgreSQL to be available
    TIMEOUT=${3:-30}
    echo -n "Waiting to connect to PostgreSQL at ${1-$HOST}:${2-$PORT}"
    for (( i=0;; i++ )); do
        if [ ${i} -eq ${TIMEOUT} ]; then
            echo " timeout!"
            exit 99
        fi
        sleep 1
        (exec 3<>/dev/tcp/${1-$HOST}/${2-$PORT}) &>/dev/null && break
        echo -n "."
    done
    echo " connected."
    exec 3>&-
    exec 3<&-
}


function genpasswd() {
    export LC_CTYPE=C  # Quiet tr warnings
    local l=$1
    [ "$l" == "" ] && l=16
    set +o pipefail
    strings < /dev/urandom | tr -dc A-Za-z0-9_ | head -c ${l}
    set -o pipefail
}
