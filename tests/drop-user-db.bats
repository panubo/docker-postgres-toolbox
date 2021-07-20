load test_functions.bash
load standard_setup.bash

@test "drop-user-db" {
	# create the user
	run docker run --rm \
		-e DATABASE_HOST=${postgres_container_ip} \
		-e DATABASE_USERNAME=postgres \
		-e DATABASE_PASSWORD=password \
		panubo/postgres-toolbox create-user-db myuser myuserpassword
	diag "${output}"
	[[ "${status}" -eq 0 ]]

	# drop the user
	run docker run --rm \
		-e DATABASE_HOST=${postgres_container_ip} \
		-e DATABASE_USERNAME=postgres \
		-e DATABASE_PASSWORD=password \
		panubo/postgres-toolbox drop-user-db --drop-database myuser
	diag "${output}"
	[[ "${status}" -eq 0 ]]

	# check the user and db do not exist
	run docker run --rm \
		-e DATABASE_HOST=${postgres_container_ip} \
		-e DATABASE_USERNAME=postgres \
		-e DATABASE_PASSWORD=password \
		panubo/postgres-toolbox psql -- -c 'SELECT count(*) FROM pg_database WHERE datname='"'myuser'"';'
	diag "${output}"
	[[ "${lines[-2]}" -eq "0" ]]
}
