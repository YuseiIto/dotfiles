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

# Lint every tracked shell script: all *.sh files plus shebang scripts, while
# skipping zsh files (shellcheck cannot parse zsh). This is the single source of
# truth for shell linting, shared by the CI ShellCheck job, so the two never
# drift apart.
shellcheck:
	@files="$$(git ls-files | while IFS= read -r f; do \
		[ -f "$$f" ] || continue; \
		first="$$(head -n1 "$$f")"; \
		case "$$first" in *zsh*) continue ;; esac; \
		case "$$f" in \
			*.sh) printf '%s\n' "$$f" ;; \
			*) printf '%s\n' "$$first" | grep -Eq '^#!.*(/| )(bash|sh|dash|ksh)([[:space:]]|$$)' && printf '%s\n' "$$f" ;; \
		esac; \
	done)"; \
	echo "Linting shell scripts:"; printf '%s\n' "$$files" | sed 's/^/  /'; \
	printf '%s\n' "$$files" | xargs shellcheck
