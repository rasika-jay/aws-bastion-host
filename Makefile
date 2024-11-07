.PHONY: init build deploy terraform%

## Base Config
LOCAL_WORKDIR ?= $(PWD)
DOCKER_WORKDIR?= /workspace
ENV ?= dev


## TERRAFORM Config

TERRAFORM_VER ?= 1.9.8
TERRAFORM_DIR ?= $(LOCAL_WORKDIR)/terraform
TERRAFORM_BIN ?= docker run -it -v $(HOME)/.aws:/root/.aws:ro -v $(TERRAFORM_DIR):$(DOCKER_WORKDIR) -w /workspace hashicorp/terraform:$(TERRAFORM_VER) -chdir=$(DOCKER_WORKDIR)

## PACKER Config

PACKER_VER ?= 1.11.2
PACKER_DIR ?= $(LOCAL_WORKDIR)/packer
# PACKER_BIN ?= docker run -it -e PACKER_PLUGIN_PATH=$(DOCKER_WORKDIR)/.plugins -v $(HOME)/.aws:/root/.aws:ro -v $(PACKER_DIR):$(DOCKER_WORKDIR) -w /workspace hashicorp/packer:full-$(PACKER_VER)
PACKER_BIN ?= docker run -it -e PACKER_PLUGIN_PATH=$(DOCKER_WORKDIR)/.plugins -v $(HOME)/.aws:/root/.aws:ro -v $(PACKER_DIR):$(DOCKER_WORKDIR) -w /workspace packer-ansible

## ANSIBLE Config

# Ansible 2.17.0
ANSIBLE_VER ?= 9.5.1-r0
ANSIBLE_DIR ?= $(PACKER_DIR)/provisioners/ansible
ANSIBLE_BIN ?= docker run --entrypoint /usr/bin/ansible-playbook -it -v $(HOME)/.aws:/root/.aws:ro -v $(ANSIBLE_DIR):$(DOCKER_WORKDIR) -w /workspace packer-ansible


.EXPORT_ALL_VARIABLES:

#### PACKER ####

# build docker image required for running ansible and packer within docker
packer-image:
	docker build --build-arg PACKER_VER --build-arg ANSIBLE_VER -t packer-ansible $(LOCAL_WORKDIR)/docker/packer-ansible

# packer initiation
packer-init: packer-image
	$(PACKER_BIN) init $(DOCKER_WORKDIR)

# packer formatting
packer-fmt:
	$(PACKER_BIN) fmt $(DOCKER_WORKDIR)

# packer validation
packer-validate:
	$(PACKER_BIN) validate $(DOCKER_WORKDIR)

# packer build
packer-build: packer-init packer-validate ansible-check
	$(PACKER_BIN) build $(DOCKER_WORKDIR)


#### ANSIBLE ####

# Ansible dry-run
ansible-check:
	$(ANSIBLE_BIN) $(DOCKER_WORKDIR)/playbook.yml --check --syntax-check


#### TERRAFORM ####

# terraform initiation
terraform-init:
	$(TERRAFORM_BIN) init

# terraform formatting
terraform-fmt:
	$(TERRAFORM_BIN) fmt

# terraform validation and linting
terraform-lint: terraform-init
	$(TERRAFORM_BIN) validate
	$(TERRAFORM_BIN) fmt -list=true -check -write=false -diff -recursive

# terraform plan - this will create a terraform plan file
terraform-plan: terraform-lint
	$(TERRAFORM_BIN) plan -out=$(ENV).tfplan

# terraform apply - this will use a terraform plan created by terraform plan
terraform-apply: terraform-plan
	$(TERRAFORM_BIN) apply $(ENV).tfplan

# terraform destroy - to destroy all created infrastructure
terraform-destroy: terraform-init
	$(TERRAFORM_BIN) destroy