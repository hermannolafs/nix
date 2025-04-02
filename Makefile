.DEFAULT_GOAL := help
.PHONY: help

help: ## This help message
	@awk -F '[, ]+' '/^[a-zA-Z0-9_-]+:.*##/ { \
		target = $$0; \
		sub(/^[ \t]*/, "", target); \
		sub(/:.*##/, "##", target); \
		split(target, parts, "##"); \
		gsub(/^[ \t]*|[ \t]*$$/, "", parts[1]); \
		gsub(/^[ \t]*|[ \t]*$$/, "", parts[2]); \
		printf "%-30s %s\n", parts[1], parts[2]; \
	}' $(MAKEFILE_LIST)

commit-nix-configuration: ## commit /etc/nixos/configuration.nix
	cp /etc/nixos/configuration.nix configuration.nix
	git add configuration.nix
	git commit

push: ## git push
	git push

nix-update: ## Update channels and packages
	nixos-rebuild switch --upgrade --use-remote-sudo

cleanup: ## Cleanup old/unused objects in store
	nixos-rebuild switch --upgrade