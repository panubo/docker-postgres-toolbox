TOOLBOX_IMAGE="panubo/postgres-toolbox:latest"
POSTGRES_TARGET_VERSION="12.7"

diag() {
	echo "$@" | sed -e 's/^/# /' >&3 ;
}

setup() {
	# setup runs before each test
	# Important: we aren't exposing port etc so running tests in parallel works
	postgres_container="$(docker run -d -e POSTGRES_PASSWORD=password postgres:${POSTGRES_TARGET_VERSION})"
	postgres_container_ip="$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${postgres_container})"
	docker run --rm -e DATABASE_HOST=${postgres_container_ip} \
		-e DATABASE_USERNAME=postgres \
		-e DATABASE_PASSWORD=password \
		${TOOLBOX_IMAGE} bash -c '. /panubo-functions.sh; wait_postgres ${DATABASE_HOST}'
}

teardown() {
	# teardown runs after each test
	docker rm -f "${postgres_container}"
}
