# echo "===> Test delete-user-db command"
# docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:$POSTGRES_VERSION > /dev/null
# sleep 5
# docker run -t -i --name ${TEST_NAME}-create --link postgres $TEST_CONTAINER create-user-db foo
# docker run -t -i --name ${TEST_NAME}-delete --link postgres $TEST_CONTAINER delete-user-db foo
# cleanup postgres ${TEST_NAME}-create ${TEST_NAME}-delete
