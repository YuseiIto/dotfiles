DOCKER:=docker
IMAGE_NAME:=yuseiito-dev
BUNDLER:=bundle

.PHONY: build-pine build-bamboo build-plum

build-pine:
	$(DOCKER) build -t $(IMAGE_NAME):pine -f docker/Dockerfile.pine .

build-bamboo:
	$(DOCKER) build -t $(IMAGE_NAME):bamboo -f docker/Dockerfile.bamboo .

build-plum:
	$(DOCKER) build -t $(IMAGE_NAME):plum -f docker/Dockerfile.plum .

.PHONY: build-lxc-pine build-lxc-bamboo build-lxc-plum

build-lxc-%:
	sudo scripts/build-lxc.sh $*


mitamae/bin/rubocop:
	cd mitamae && $(BUNDLER) install

.PHONY: lint format
lint: mitamae/bin/rubocop
	cd mitamae && $(BUNDLER) exec rubocop

format: mitamae/bin/rubocop
	cd mitamae && $(BUNDLER) exec rubocop -a

.PHONY: shellcheck dry-run dry-run-linux dry-run-macos

shellcheck:
	shellcheck setup.sh mitamae/bin/setup

dry-run-linux: dry-run-plum dry-run-bamboo dry-run-pine

dry-run-macos: dry-run-belle

dry-run-%:
	cd mitamae && DOTFILES_ROLE=$* bin/mitamae dry-run lib/custom_resources.rb roles/$*/default.rb


.PHONY: clean
clean:
	@sudo rm  -f yuseiito-dev-live_*.raw\
			 yuseiito-dev-live_*.vmlinuz\
			 yuseiito-dev-live_*.efi\
			 yuseiito-dev-live_*.initrd\
			 initrd\
			 initrd.cpio.zst
	@sudo rm -rf debian-tools mkosi.cache
