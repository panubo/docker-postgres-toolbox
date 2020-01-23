NAME       := postgres-toolbox
TAG        := latest
IMAGE_NAME := panubo/$(NAME)

.PHONY: build test push clean
build:
	docker build --pull -t $(IMAGE_NAME):$(TAG) .

build-quick:
	docker build -t $(IMAGE_NAME):$(TAG) .

test:
	./tests/dind-runner.sh

push:
	docker push $(IMAGE_NAME):$(TAG)

clean:
	docker rmi $(IMAGE_NAME):$(TAG)

bash: .env
	docker run --rm -it --env-file .env $(IMAGE_NAME):$(TAG) bash

.env:
	touch .env

shellcheck:
	shellcheck commands/common.sh commands/create-user-db commands/drop-user-db commands/psql commands/report commands/save

beta:
	docker tag panubo/postgres-toolbox:latest panubo/postgres-toolbox:2.0.0-beta.1
	docker push panubo/postgres-toolbox:2.0.0-beta.1
