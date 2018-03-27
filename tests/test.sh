#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

CWD="$(dirname $0)/"

. ${CWD}functions.sh

echo "=> Test vacuum command"
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:latest > /dev/null
docker run -t -i --name $TEST_NAME --link postgres $TEST_CONTAINER vacuum
cleanup postgres $TEST_NAME

echo "=> Test create-user-db command"
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:latest > /dev/null
docker run -t -i --name $TEST_NAME --link postgres $TEST_CONTAINER create-user-db foo foopass
cleanup postgres $TEST_NAME
