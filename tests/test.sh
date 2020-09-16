#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

CWD="$(dirname $0)/"

. ${CWD}functions.sh

echo "===> Test create-readonly-user command"
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:$POSTGRES_VERSION > /dev/null
sleep 5
docker run -t -i --name ${TEST_NAME}a --link postgres $TEST_CONTAINER create-user-db foo foopass_rw
docker run -t -i --name ${TEST_NAME}b --link postgres $TEST_CONTAINER create-readonly-user foo foo_ro foopass_ro
cleanup postgres ${TEST_NAME}a ${TEST_NAME}b

echo "===> Test create-user-db command"
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:$POSTGRES_VERSION > /dev/null
sleep 5
docker run -t -i --name $TEST_NAME --link postgres $TEST_CONTAINER create-user-db foo foopass
cleanup postgres $TEST_NAME

echo "===> Test delete-user-db command"
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:$POSTGRES_VERSION > /dev/null
sleep 5
docker run -t -i --name ${TEST_NAME}-create --link postgres $TEST_CONTAINER create-user-db foo
docker run -t -i --name ${TEST_NAME}-delete --link postgres $TEST_CONTAINER delete-user-db foo
cleanup postgres ${TEST_NAME}-create ${TEST_NAME}-delete

echo "===> Test fix-owner command"
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:$POSTGRES_VERSION > /dev/null
sleep 5
docker run -t -i --name ${TEST_NAME}-create --link postgres $TEST_CONTAINER create-user-db foo
docker run -t -i --name ${TEST_NAME}-fix --link postgres $TEST_CONTAINER fix-owner foo
cleanup postgres ${TEST_NAME}-create ${TEST_NAME}-fix

echo "===> Test load command"
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:$POSTGRES_VERSION > /dev/null
sleep 5
docker run -t -i --name ${TEST_NAME}-create1 --link postgres $TEST_CONTAINER create-user-db foo
docker run -t -i --name ${TEST_NAME}-save --link postgres -e DUMP_DIR="/srv" -v /srv:/srv $TEST_CONTAINER save
docker run -t -i --name ${TEST_NAME}-delete --link postgres $TEST_CONTAINER delete-user-db foo
docker run -t -i --name ${TEST_NAME}-create2 --link postgres $TEST_CONTAINER create-user-db foo
docker run -t -i --name ${TEST_NAME}-load --link postgres -e DUMP_DIR="/srv" -v /srv:/srv $TEST_CONTAINER load foo
cleanup postgres ${TEST_NAME}-create1 ${TEST_NAME}-save ${TEST_NAME}-delete ${TEST_NAME}-load ${TEST_NAME}-create2

echo "===> Test psql command"
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:$POSTGRES_VERSION > /dev/null
sleep 5
echo "\l" | docker run -i --name ${TEST_NAME}-psql --link postgres $TEST_CONTAINER psql
cleanup postgres ${TEST_NAME}-psql

echo "===> Test save command"
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:$POSTGRES_VERSION > /dev/null
sleep 5
docker run -t -i --name ${TEST_NAME}-create --link postgres $TEST_CONTAINER create-user-db foo
docker run -t -i --name ${TEST_NAME}-save --link postgres -e DUMP_DIR="/srv" $TEST_CONTAINER save
cleanup postgres ${TEST_NAME}-create ${TEST_NAME}-save

echo "===> Test vacuum command"
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:$POSTGRES_VERSION > /dev/null
sleep 5
docker run -t -i --name $TEST_NAME --link postgres $TEST_CONTAINER vacuum
cleanup postgres $TEST_NAME
