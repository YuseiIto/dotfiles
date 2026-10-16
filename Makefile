DOCKER:=docker
IMAGE_NAME:=yuseiito-dev
BUNDLER:=bundle

.PHONY: build-pine build-bamboo build-plum build-devcontainer

build-pine:
	$(DOCKER) build -t $(IMAGE_NAME):pine -f docker/Dockerfile.pine .

build-bamboo:
	$(DOCKER) build -t $(IMAGE_NAME):bamboo -f docker/Dockerfile.bamboo .

build-plum:
	$(DOCKER) build -t $(IMAGE_NAME):plum -f docker/Dockerfile.plum .

build-devcontainer:
	$(DOCKER) build -t $(IMAGE_NAME):devcontainer -f docker/Dockerfile.devcontainer .

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

.PHONY: shellcheck

# Lint shell scripts. *.sh files are discovered with git; extensionless shell
# commands and dotfiles the '*.sh' glob misses are listed explicitly. zsh files
# are outside the glob except docker/entrypoint.sh, which opts out via an
# inline `# shellcheck disable=SC1071` directive. CI runs this same target.
SHELLCHECK_EXTRA_FILES = \
	mitamae/bin/setup \
	mitamae/cookbooks/bash/files/.bash_profile \
	mitamae/cookbooks/bash/files/.bashrc \
	mitamae/cookbooks/claude-code/files/claude-tmux-notify \
	mitamae/cookbooks/claude-code/files/claude-dotfiles-link \
	mitamae/cookbooks/git-commit-claude/files/git-commit-claude

shellcheck:
	shellcheck $$(git ls-files '*.sh') $(SHELLCHECK_EXTRA_FILES)

.PHONY: check check-role-variants check-version-pins actionlint zizmor

# Everything the Lint workflow checks. CI runs each target as its own job.
check: lint shellcheck check-role-variants check-version-pins actionlint zizmor

check-role-variants:
	scripts/check-role-variants.sh

check-version-pins:
	scripts/check-version-pins.sh

actionlint:
	actionlint

zizmor:
	zizmor --offline .

.PHONY: dry-run

# Evaluate every recipe of a role without changing the host. Set DOTFILES_ROLE
# to pick a role other than the current hostname.
dry-run:
	./setup.sh --dry-run

.PHONY: audit audit-baseline

# Report packages installed on this host that mitamae does not declare.
# Set DOTFILES_ROLE to audit a role other than the current hostname.
audit:
	scripts/audit-packages.sh

# Accept the host's current package state as the baseline for its role.
# Run once on a known-good host, then commit mitamae/audit/baseline.<role>.txt.
audit-baseline:
	scripts/audit-packages.sh --update-baseline
