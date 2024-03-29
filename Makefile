NAME       := postgres-toolbox
TAG        := latest
IMAGE_NAME := panubo/$(NAME)

.PHONY: build test push clean
build:
	docker build --pull -t $(IMAGE_NAME):$(TAG) .

build-quick:
	docker build -t $(IMAGE_NAME):$(TAG) .

build-with-cache:
	# Used by CI to speed up build and test process
	docker pull $(IMAGE_NAME):$(TAG)
	docker build -t $(IMAGE_NAME):$(TAG) --cache-from $(IMAGE_NAME):$(TAG) .

test:
	bats -r tests/

_ci_test:
	true

push:
	docker push $(IMAGE_NAME):$(TAG)

clean:
	docker rmi $(IMAGE_NAME):$(TAG)

bash: .env
	docker run --rm -it --env-file .env $(IMAGE_NAME):$(TAG) bash

.env:
	touch .env

shellcheck:
	shellcheck commands/common.sh commands/create-user-db commands/drop-user-db commands/psql commands/report commands/save commands/pg-ping commands/vacuumdb commands/pganalyze
