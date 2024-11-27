.PHONY: apply-system
apply-system:
	darwin-rebuild switch --flake .#belle

.PHONY: install-nix-darwin
install-nix-darwin:
	nix run nix-darwin -- switch --flake .#belle

.PHONY: gc
gc:
	nix-collect-garbage -d
