load test_functions.bash

@test "create-user-db" {
	run docker run --rm \
		-e DATABASE_HOST=${postgres_container_ip} \
		-e DATABASE_USERNAME=postgres \
		-e DATABASE_PASSWORD=password \
		panubo/postgres-toolbox create-user-db myuser myuserpassword
	diag "${output}"
	[[ "${status}" -eq 0 ]]

	run docker run --rm \
		-e DATABASE_HOST=${postgres_container_ip} \
		-e DATABASE_USERNAME=myuser \
		-e DATABASE_PASSWORD=myuserpassword \
		panubo/postgres-toolbox psql -- -c 'SELECT current_database();'
	diag "${output}"
	[[ "${status}" -eq 0 ]]
}

# echo "===> Test create-user-db command"
# docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:$POSTGRES_VERSION > /dev/null
# sleep 5
# docker run -t -i --name $TEST_NAME --link postgres $TEST_CONTAINER create-user-db foo foopass
# cleanup postgres $TEST_NAME
