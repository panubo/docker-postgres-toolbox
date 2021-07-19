# echo "===> Test load command"
# docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:$POSTGRES_VERSION > /dev/null
# sleep 5
# docker run -t -i --name ${TEST_NAME}-create1 --link postgres $TEST_CONTAINER create-user-db foo
# docker run -t -i --name ${TEST_NAME}-save --link postgres -e DUMP_DIR="/srv" -v /srv:/srv $TEST_CONTAINER save
# docker run -t -i --name ${TEST_NAME}-delete --link postgres $TEST_CONTAINER delete-user-db foo
# docker run -t -i --name ${TEST_NAME}-create2 --link postgres $TEST_CONTAINER create-user-db foo
# docker run -t -i --name ${TEST_NAME}-load --link postgres -e DUMP_DIR="/srv" -v /srv:/srv $TEST_CONTAINER load foo
# cleanup postgres ${TEST_NAME}-create1 ${TEST_NAME}-save ${TEST_NAME}-delete ${TEST_NAME}-load ${TEST_NAME}-create2
