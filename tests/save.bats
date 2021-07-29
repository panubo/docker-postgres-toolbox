load test_functions.bash
load minio_setup.bash

setup_file() {
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

	docker exec "${postgres_container}" pgbench -U postgres -i -s 5 mydb

	export working_volume="$(docker volume create)"
}

teardown_file() {
	# teardown runs after each test
	docker rm -f "${postgres_container}"
	docker volume rm "${working_volume}"
}

@test "save to disk" {
	run docker run --rm \
		-e DATABASE_HOST=${postgres_container_ip} \
		-e DATABASE_USERNAME=postgres \
		-e DATABASE_PASSWORD=password \
		-v "${working_volume}:/db-dumps" \
		"${TOOLBOX_IMAGE}" save --umask 022 --pgdump-args "--compress 0" --format custom /db-dumps
	diag "${output}"
	[[ "${status}" -eq 0 ]]
}

@test "save to minio/s3" {
	run docker run --rm \
		-e DATABASE_HOST=${postgres_container_ip} \
		-e DATABASE_USERNAME=postgres \
		-e DATABASE_PASSWORD=password \
		-e AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE \
		-e AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
		"${TOOLBOX_IMAGE}" save --aws-args "--endpoint-url http://${minio_container_ip}:9000" --format custom --compression lz4 s3://db-dumps
	diag "${output}"
	[[ "${status}" -eq 0 ]]
}
