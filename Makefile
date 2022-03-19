.PHONY: *

HELP_TAB_WIDTH = 25

.DEFAULT_GOAL := help

CLUSTER_NAME ?= kong-a-thon

SHELL=/bin/bash -o pipefail

echo_fail = printf "\e[31m✘ \033\e[0m$(1)\n"
echo_pass = printf "\e[32m✔ \033\e[0m$(1)\n"

check-dependency = $(if $(shell command -v $(1)),$(call echo_pass,found $(1)),$(call echo_fail,$(1) not installed);exit 1)

check-dependencies:
	@$(call check-dependency,jq)
	@$(call check-dependency,k3d)

cluster: check-dependencies ## Create a local K8s cluster
	@echo "creating new k3d cluster named $(CLUSTER_NAME)"
	@k3d cluster create $(CLUSTER_NAME) --servers 3 --wait

destroy-cluster: check-dependencies ## Destroy the local K8s cluster
	@echo "destroying $(CLUSTER_NAME) k3d cluster"
	@k3d cluster delete $(CLUSTER_NAME)

kong: ## Install Kong into the current K8s cluster 
	@echo kong FTW

###########################################
# To add help to a command, postfix it with 
# 		## help text
###########################################
help:
	@$(foreach m,$(MAKEFILE_LIST),grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(m) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-$(HELP_TAB_WIDTH)s\033[0m %s\n", $$1, $$2}';)

