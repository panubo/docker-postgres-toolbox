#!/usr/bin/env bash

#
# Functions
#

CWD="$(dirname $0)/"

. ${CWD}config.sh

function rm_container {
    set +e
    docker rm -fv "$@" > /dev/null 2>&1
    set -e
}

function cleanup {
    echo "=> Clean up ${@-$TEST_CONTAINER}"
    rm_container ${@-$TEST_CONTAINER}
}

function wait_on_http {
    TIMEOUT=$1
    shift
    for (( i=0;; i++ )); do
        if [ ${i} -eq ${TIMEOUT} ]; then
            break
        fi
        sleep 1
        curl --insecure --location "$@" > /dev/null 2>&1 && break
    done
}

function wait_on_port {
    TIMEOUT=${1:-30}
    echo "Waiting to connect to service at $HOST:$PORT"
    for (( i=0;; i++ )); do
        if [ ${i} -eq ${TIMEOUT} ]; then
            echo " timeout!"
            exit 99
        fi
        sleep 1
        (exec 3<>/dev/tcp/${2}/${3}) &>/dev/null && break
        echo -n "."
    done
    echo " connected."
    exec 3>&-
    exec 3<&-
}

function start_docker {
    echo "=> Starting docker"
    if ! docker version > /dev/null 2>&1; then
        wrapdocker > /dev/null 2>&1 &
        sleep 5
    fi
}

function check_docker {
    echo "=> Checking docker daemon"
    docker version > /dev/null 2>&1 || (echo "Failed to start docker (did you use --privileged when running this container?)" && exit 1)
}

function check_environment {
    echo "=> Testing environment"
    docker version > /dev/null 
    which curl > /dev/null
}

function build_image {
    echo "=> Building ${1-$TEST_CONTAINER}"
    docker build -t ${1-$TEST_CONTAINER} ${2-'.'}
}
