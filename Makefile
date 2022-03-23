.PHONY: *

HELP_TAB_WIDTH = 25

.DEFAULT_GOAL := help

CLUSTER_NAME ?= kong-a-thon
CLUSTER_NODE_COUNT ?= 1
NAMESPACE ?= kong

SHELL=/bin/bash -o pipefail

echo_fail = printf "\e[31m✘ \033\e[0m$(1)\n"
echo_pass = printf "\e[32m✔ \033\e[0m$(1)\n"

check-dependency = $(if $(shell command -v $(1)),$(call echo_pass,found $(1)),$(call echo_fail,$(1) not installed);exit 1)

check-gcp-dependencies:
	@$(call check-dependency,gcloud)

check-dependencies:
	@$(call check-dependency,kubectl)
	@$(call check-dependency,helm)

GCP_CLUSTER_REGION ?= us-central1

guard-%:
	@ if [ "${${*}}" = "" ]; then \
	    echo "Environment variable $* not set"; \
	    exit 1; \
	fi

gke-cluster: check-gcp-dependencies guard-GCP_PROJECT_ID guard-GCP_CLUSTER_NAME ## Create a GCP GKE K8s cluster
	@gcloud container --project $(GCP_PROJECT_ID) clusters create-auto $(GCP_CLUSTER_NAME) --region $(GCP_CLUSTER_REGION)  --release-channel "regular" --network "projects/$(GCP_PROJECT_ID)/global/networks/default" --subnetwork "projects/$(GCP_PROJECT_ID)/regions/$(GCP_CLUSTER_REGION)/subnetworks/default"

destroy-cluster: check-gcp-dependencies ## Destroy the GCP K8s cluster
	@gcloud container cluster delete $(GCP_CLUSTER_NAME) --region $(GCP_CLUSTER_REGION)

attach-shell: check-dependencies
	@kubectl -n $(NAMESPACE) exec --stdin --tty shell -- /bin/bash
	
shell: check-dependencies ## Run a shell on the current k8s cluster
	@kubectl -n $(NAMESPACE) apply -f shell.yaml

echo: check-dependencies ## Install an http echo service to work with
	@kubectl -n $(NAMESPACE) apply -f echo-deployment.yaml
	@kubectl -n $(NAMESPACE) apply -f echo-service.yaml

kong: check-dependencies ## Install Kong into the current K8s cluster 
	@kubectl apply -f kong-namespace.yaml
	@helm upgrade --install my-kong kong/kong -n $(NAMESPACE) --values ./values.yaml

###########################################
# To add help to a command, postfix it with 
# 		## help text
###########################################
help:
	@$(foreach m,$(MAKEFILE_LIST),grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(m) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-$(HELP_TAB_WIDTH)s\033[0m %s\n", $$1, $$2}';)

