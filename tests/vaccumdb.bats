load test_functions.bash

@test "vacuum" {
	run docker run --rm \
		-e DATABASE_HOST=${postgres_container_ip} \
		-e DATABASE_USERNAME=postgres \
		-e DATABASE_PASSWORD=password \
		panubo/postgres-toolbox vacuumdb -- --maintenance-db=postgres --all
	diag "${output}"
	[[ "${status}" -eq 0 ]]
}

# echo "===> Test vacuum command"
# docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=password postgres:$POSTGRES_VERSION > /dev/null
# sleep 5
# docker run -t -i --name $TEST_NAME --link postgres $TEST_CONTAINER vacuum
# cleanup postgres $TEST_NAME
