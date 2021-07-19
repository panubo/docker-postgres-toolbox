# echo "===> Test save command"
# docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:$POSTGRES_VERSION > /dev/null
# sleep 5
# docker run -t -i --name ${TEST_NAME}-create --link postgres $TEST_CONTAINER create-user-db foo
# docker run -t -i --name ${TEST_NAME}-save --link postgres -e DUMP_DIR="/srv" $TEST_CONTAINER save
# cleanup postgres ${TEST_NAME}-create ${TEST_NAME}-save
