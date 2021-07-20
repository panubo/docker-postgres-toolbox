load test_functions.bash
load standard_setup.bash

@test "vacuum" {
	run docker run --rm \
		-e DATABASE_HOST=${postgres_container_ip} \
		-e DATABASE_USERNAME=postgres \
		-e DATABASE_PASSWORD=password \
		panubo/postgres-toolbox vacuumdb -- --maintenance-db=postgres --all
	diag "${output}"
	[[ "${status}" -eq 0 ]]
}
