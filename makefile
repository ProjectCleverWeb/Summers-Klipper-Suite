export MSYS_NO_PATHCONV=1 #this is needed for windows when using Git bash

MAKEFLAGS     += --no-print-directory
.DEFAULT_GOAL := help

INDENT = "  "

# Platform detection
ifeq ($(OS),Windows_NT)
	PLATFORM = WINDOWS
else
	UNAME := $(shell uname -s)
	ifeq ($(UNAME),Linux)
		PLATFORM = LINUX
	else ifeq ($(UNAME),Darwin)
		PLATFORM = MAC
	else
		PLATFORM = LINUX
	endif
endif

# Function for showing show log messages (INFO, WARNING, ERROR)
define log
	@echo "$(INDENT)[$(1)] $(2)"
endef

# Function for generating CLI headers
define cliHeader
	# get the length of the first argument
	$(eval len := $(shell echo -n $(1) | wc -c))
	# Repeat the character "-" for the length of the first argument
	$(eval line := $(shell printf "%${len}s" | tr " " "-"))
	@echo
	@echo "$(INDENT)>>>-$(line)-<<<"
	@echo "$(INDENT)>   $(1)   <"
	@echo "$(INDENT)>>>-$(line)-<<<"
	@echo
endef

# Function for generating target help docs
define generateTargetHelpDocs
	awk 'BEGIN {FS = ":.*?$(1) "} /^[a-zA-Z0-9_-]+:.*?$(1) / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
	@echo
	@$(call log,INFO,"Usage: make [target1] [target2] ...")
endef


help: ### Display frequently used targets
	@$(call cliHeader,"Frequently Used Targets")
	@$(call generateTargetHelpDocs,###)
	@$(call log,INFO,"Run \`make allTargets\` to see all available targets.")

allTargets: ### Display all available targets
	@$(call cliHeader,"ALL Targets")
	@$(call generateTargetHelpDocs,##)

.checkIfNpmInstalled: ## Check if npm is installed
	@command -v npm >/dev/null 2>&1 || { $(call log,ERROR,"npm is not installed. Please install it first."); exit 1; }

installNpmPackages: .checkIfNpmInstalled ## Install npm packages
	@$(call log,INFO,"Installing npm packages...")
	@npm install -g gomplate
	@$(call log,INFO,"npm packages installed.")

run: ## Run gomplate
	@$(call log,INFO,"Running gomplate...")
	@export SKS_MODULES=$(cat ../config/sks-library.gcode.j2)
	@gomplate
	@$(call log,INFO,"gomplate run completed.")
	
