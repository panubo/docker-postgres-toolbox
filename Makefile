NAME = panubo/postgres-toolbox
VERSION = `git describe --long --tags --dirty --always`

.PHONY: all build tag_latest test clean

all:    clean build

build:
	docker build --no-cache -t $(NAME):$(VERSION) .

tag_latest:
	docker tag -f $(NAME):$(VERSION) $(NAME):latest

test:
	./tests/dind-runner.sh

clean:
	docker images | grep $(NAME) | awk '{ print $$3 }' | xargs -r docker rmi
