setup() {

	minio_container="$(docker run -d \
		-e MINIO_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE \
		-e MINIO_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
		-p "9000:9000" \
		-v $(mktemp -d)/minio:/export \
		--entrypoint /bin/sh minio/minio:latest -c "mkdir -p /export/db-dumps && minio server /export")"
	minio_container_ip="$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${minio_container})"
}

teardown() {
	# teardown runs after each test
	docker rm -f "${minio_container}"
}
