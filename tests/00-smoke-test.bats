load test_functions.bash
load standard_setup.bash

@test "smoke test - select 1" {
	run docker run --rm \
		-e DATABASE_HOST=${postgres_container_ip} \
		-e DATABASE_USERNAME=postgres \
		-e DATABASE_PASSWORD=password \
		panubo/postgres-toolbox psql -- -c 'SELECT 1;'
	diag "${output}"
	[[ "${status}" -eq 0 ]]
}
