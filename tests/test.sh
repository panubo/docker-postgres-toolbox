#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

CWD="$(dirname $0)/"

. ${CWD}functions.sh

echo "=> Test vacuum command"
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:latest > /dev/null
sleep 5
docker run -t -i --name $TEST_NAME --link postgres $TEST_CONTAINER vacuum
cleanup postgres $TEST_NAME

echo "=> Test create-user-db command"
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:latest > /dev/null
sleep 5
docker run -t -i --name $TEST_NAME --link postgres $TEST_CONTAINER create-user-db foo foopass
cleanup postgres $TEST_NAME

echo "=> Test delete-user-db command"
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:latest > /dev/null
sleep 5
docker run -t -i --name ${TEST_NAME}-create --link postgres $TEST_CONTAINER create-user-db foo
docker run -t -i --name ${TEST_NAME}-delete --link postgres $TEST_CONTAINER delete-user-db foo
cleanup postgres ${TEST_NAME}-create ${TEST_NAME}-delete

echo "=> Test dump command"
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:latest > /dev/null
sleep 5
docker run -t -i --name ${TEST_NAME}-create --link postgres $TEST_CONTAINER create-user-db foo
docker run -t -i --name ${TEST_NAME}-dump --link postgres -e DUMP_DIR="/srv" $TEST_CONTAINER dump
cleanup postgres ${TEST_NAME}-create ${TEST_NAME}-dump

echo "=> Test restore command"
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:latest > /dev/null
sleep 5
docker run -t -i --name ${TEST_NAME}-create1 --link postgres $TEST_CONTAINER create-user-db foo
docker run -t -i --name ${TEST_NAME}-dump --link postgres -e DUMP_DIR="/srv" -v /srv:/srv $TEST_CONTAINER dump
docker run -t -i --name ${TEST_NAME}-delete --link postgres $TEST_CONTAINER delete-user-db foo
docker run -t -i --name ${TEST_NAME}-create2 --link postgres $TEST_CONTAINER create-user-db foo
docker run -t -i --name ${TEST_NAME}-restore --link postgres -e DUMP_DIR="/srv" -v /srv:/srv $TEST_CONTAINER restore foo
cleanup postgres ${TEST_NAME}-create1 ${TEST_NAME}-dump ${TEST_NAME}-delete ${TEST_NAME}-restore ${TEST_NAME}-create2
