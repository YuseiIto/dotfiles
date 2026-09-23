DOCKER:=docker
IMAGE_NAME:=yuseiito-dev
BUNDLER:=bundle

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_%-]+:.*##/ {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# The docker/lxc build targets are pattern rules, not .PHONY: GNU Make skips
# implicit/pattern rules for phony targets, so declaring these phony would break
# them (`make build-palm` -> "Nothing to be done"). A single build-% rule also
# means adding a docker/Dockerfile.<variant> is enough to build it -- no target
# to forget. build-% and build-lxc-% coexist via shortest-stem matching.
build-%: ## Build the <variant> docker image (pine|bamboo|plum|palm)
	$(DOCKER) build -t $(IMAGE_NAME):$* -f docker/Dockerfile.$* .

build-lxc-%: ## Build the <variant> LXC image
	sudo scripts/build-lxc.sh $*


# Generate a binstub so this file target is actually created; otherwise the
# target is never satisfied and `bundle install` re-runs on every lint/format.
mitamae/bin/rubocop:
	cd mitamae && $(BUNDLER) install && $(BUNDLER) binstubs rubocop

.PHONY: lint format
lint: mitamae/bin/rubocop ## Run RuboCop
	cd mitamae && bin/rubocop

format: mitamae/bin/rubocop ## Auto-correct RuboCop offenses
	cd mitamae && bin/rubocop -a

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

shellcheck: ## Lint shell scripts
	shellcheck $$(git ls-files '*.sh') $(SHELLCHECK_EXTRA_FILES)

.PHONY: audit audit-baseline

# Report packages installed on this host that mitamae does not declare.
# Set DOTFILES_ROLE to audit a role other than the current hostname.
audit: ## Report packages installed but not declared by mitamae
	scripts/audit-packages.sh

# Accept the host's current package state as the baseline for its role.
# Run once on a known-good host, then commit mitamae/audit/baseline.<role>.txt.
audit-baseline: ## Accept the host's current package state as its role baseline
	scripts/audit-packages.sh --update-baseline
