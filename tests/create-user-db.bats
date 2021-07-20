load test_functions.bash
load standard_setup.bash

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
	# check the output of the second last line
	[[ "${lines[-2]}" = " myuser" ]]
}
