load test_functions.bash

# Generate a sql dump for testing load function
generate_testing_dump() {
	postgres_container="$(docker run -d -e POSTGRES_PASSWORD=password postgres:${POSTGRES_TARGET_VERSION})"
	postgres_container_ip="$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${postgres_container})"
	docker run --rm -e DATABASE_HOST=${postgres_container_ip} \
		-e DATABASE_USERNAME=postgres \
		-e DATABASE_PASSWORD=password \
		${TOOLBOX_IMAGE} bash -c '. /panubo-functions.sh; wait_postgres ${DATABASE_HOST}'

	docker run --rm \
		-e DATABASE_HOST=${postgres_container_ip} \
		-e DATABASE_USERNAME=postgres \
		-e DATABASE_PASSWORD=password \
		"${TOOLBOX_IMAGE}" create-user-db mydb

	docker exec "${postgres_container}" pgbench -U postgres -i -s 5 mydb

	# The dump will be saved to this volume and used later
	export working_volume="$(docker volume create)"

	docker run --rm \
			-e DATABASE_HOST=${postgres_container_ip} \
			-e DATABASE_USERNAME=postgres \
			-e DATABASE_PASSWORD=password \
			-v "${working_volume}:/db-dumps" \
			"${TOOLBOX_IMAGE}" save --format custom /db-dumps

	docker rm -f "${postgres_container}"
}

setup_file() {
	generate_testing_dump

	export postgres_container="$(docker run -d -e POSTGRES_PASSWORD=password postgres:${POSTGRES_TARGET_VERSION})"
	export postgres_container_ip="$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${postgres_container})"
	docker run --rm -e DATABASE_HOST=${postgres_container_ip} \
		-e DATABASE_USERNAME=postgres \
		-e DATABASE_PASSWORD=password \
		${TOOLBOX_IMAGE} bash -c '. /panubo-functions.sh; wait_postgres ${DATABASE_HOST}'

	docker run --rm \
		-e DATABASE_HOST=${postgres_container_ip} \
		-e DATABASE_USERNAME=postgres \
		-e DATABASE_PASSWORD=password \
		"${TOOLBOX_IMAGE}" create-user-db mydb
}

teardown_file() {
	# teardown runs after each test
	docker rm -f "${postgres_container}"
	docker volume rm "${working_volume}"
}

@test "load from disk" {
	run docker run --rm \
		-e DATABASE_HOST=${postgres_container_ip} \
		-e DATABASE_USERNAME=postgres \
		-e DATABASE_PASSWORD=password \
		-v "${working_volume}:/db-dumps" \
		"${TOOLBOX_IMAGE}" bash -c 'echo "*:5432:*:${DATABASE_USERNAME}:${DATABASE_PASSWORD}" > ${HOME}/.pgpass; \
            chmod 600 ${HOME}/.pgpass; \
			gunzip < /db-dumps/*/mydb.dump.gz | pg_restore --host "${DATABASE_HOST}" --username "${DATABASE_USERNAME}" --role mydb --dbname=mydb --no-acl --no-owner'
	diag "${output}"
	[[ "${status}" -eq 0 ]]

	run docker run --rm \
		-e DATABASE_HOST=${postgres_container_ip} \
		-e DATABASE_USERNAME=postgres \
		-e DATABASE_PASSWORD=password \
		"${TOOLBOX_IMAGE}" psql -- -c 'SELECT pg_database_size('"'mydb'"');'
	diag "${output}"
	[[ "${status}" -eq 0 ]]

	# we expect the dump to be larger than 80MiB
	[[ "${lines[-2]}" -gt "83886080" ]]
}
