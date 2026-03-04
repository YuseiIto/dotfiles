DOCKER:=docker
IMAGE_NAME:=yuseiito-dev

.PHONY: build-pine build-bamboo build-plum

build-pine:
	$(DOCKER) build -t $(IMAGE_NAME):pine -f docker/Dockerfile.pine .

build-bamboo:
	$(DOCKER) build -t $(IMAGE_NAME):bamboo -f docker/Dockerfile.bamboo .

build-plum:
	$(DOCKER) build -t $(IMAGE_NAME):plum -f docker/Dockerfile.plum .
