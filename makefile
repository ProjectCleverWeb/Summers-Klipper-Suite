export MSYS_NO_PATHCONV=1 # Fix file paths when on Windows and using Git Bash/Cygwin/Ming

MAKEFLAGS     += --no-print-directory
.DEFAULT_GOAL := help
FUNC          := @. ./bin/makeFunctions && 

# Platform detection - will likely need this later
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
	$(FUNC) cliHeader "Help: Frequently Used Targets"
	$(FUNC) generateTargetHelpDocs "###" "$(MAKEFILE_LIST)"
	$(FUNC) logInfo "Run \`make help.all\` to see all available targets."

help.all: ### Display all targets
	$(FUNC) cliHeader "Help: All Available Targets"
	$(FUNC) generateTargetHelpDocs "##" "$(MAKEFILE_LIST)"

.npm.check-if-installed: ## Check if npm is installed
	@command -v npm >/dev/null 2>&1 || { $(FUNC) logError "npm is not installed. Please install it first."; exit 1; }

install: .npm.check-if-installed ## Install npm packages
	$(FUNC) logInfo "Installing npm packages..."
	@npm install
	$(FUNC) logInfo "npm packages installed."

klipper.restart: ### Restart Klipper service
	echo RESTART > /tmp/printer

firmware.restart: ### Restart 3D printer firmware
	echo FIRMWARE_RESTART > /tmp/printer

sks.reset-files: ## Reset all files to the last commit
	git reset --hard

sks.clear-files: ## Clear all files and reset to the last commit
	git add --all && make sks.reset-files

sks.update: sks.clear-files ### Update all files and reset to the last commit
	git pull --all && make klipper.restart
