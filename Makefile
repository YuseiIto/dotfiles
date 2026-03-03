DOCKER:=docker
IMAGE_NAME:=yuseiito-dev

.PHONY: build-pine

build-pine:
	$(DOCKER) build -t $(IMAGE_NAME):pine -f docker/Dockerfile.pine .
