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

# Lint shell scripts. *.sh files are discovered with git; extensionless shell
# commands and dotfiles the '*.sh' glob misses are listed explicitly. zsh files
# are outside the glob except docker/entrypoint.sh, which opts out via an
# inline `# shellcheck disable=SC1071` directive. CI runs this same target.
SHELLCHECK_EXTRA_FILES = \
	mitamae/bin/setup \
	mitamae/cookbooks/bash/files/.bash_profile \
	mitamae/cookbooks/bash/files/.bashrc \
	mitamae/cookbooks/claude-code/files/claude-tmux-notify \
	mitamae/cookbooks/git-commit-claude/files/git-commit-claude

shellcheck:
	shellcheck $$(git ls-files '*.sh') $(SHELLCHECK_EXTRA_FILES)
