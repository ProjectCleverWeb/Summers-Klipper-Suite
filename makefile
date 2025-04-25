export MSYS_NO_PATHCONV=1 # Fix file paths when on Windows and using Git Bash/Cygwin/Ming

MAKEFLAGS     += --no-print-directory
.DEFAULT_GOAL := help
FUNC          := @. ./bin/makeFunctions && 

# Platform detection
ifeq ($(OS),Windows_NT)
	PLATFORM = WINDOWS
else
	UNAME := $(shell uname -s)
	ifeq ($(UNAME),Darwin)
		PLATFORM = MAC
	else
		PLATFORM = LINUX
	endif
endif

help: ### Display frequently used targets
	$(FUNC) cliHeader "Frequently Used Targets"
	$(FUNC) generateTargetHelpDocs "###" "$(MAKEFILE_LIST)"
	$(FUNC) logInfo "Run \`make allTargets\` to see all available targets."

allTargets: ### Display all targets
	$(FUNC) cliHeader "All Targets"
	$(FUNC) generateTargetHelpDocs "##" "$(MAKEFILE_LIST)"

.checkIfNpmInstalled: ## Check if npm is installed
	@command -v npm >/dev/null 2>&1 || { $(FUNC) logError "npm is not installed. Please install it first."; exit 1; }

install\:npmPackages: .checkIfNpmInstalled ## Install npm packages
	$(FUNC) logInfo "Installing npm packages..."
	@npm install -g gomplate
	$(FUNC) logInfo "npm packages installed."

run: ## Run gomplate
	$(FUNC) logInfo "Running gomplate..."
	@gomplate -V
	$(FUNC) logInfo "gomplate run completed."

test\:logs: ### Run tests
	$(FUNC) logInfo "Hello World!!!"
	$(FUNC) logWarning "Hello World!!!"
	$(FUNC) logError "Hello World!!!"
	$(FUNC) logSuccess "Hello World!!!"
	$(FUNC) logDebug "Hello World!!!"
	$(FUNC) logSkipped "Hello World!!!"
