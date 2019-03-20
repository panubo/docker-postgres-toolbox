NAME       := postgres-toolbox
TAG        := latest
IMAGE_NAME := panubo/$(NAME)

.PHONY: build test push clean
build:
	docker build --pull -t $(IMAGE_NAME):$(TAG) .

test:
	./tests/dind-runner.sh

push:
	docker push $(IMAGE_NAME):$(TAG)

clean:
	docker rmi $(IMAGE_NAME):$(TAG)
