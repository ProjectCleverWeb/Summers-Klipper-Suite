export MSYS_NO_PATHCONV=1 # Fix file paths when on Windows and using Git Bash/Cygwin/Ming

# Makefile vars
MAKEFLAGS     += --no-print-directory
.DEFAULT_GOAL := help

# SKS Vars
FUNC               := @. ./bin/makeFunctions && MAKE_GOALS="$(MAKECMDGOALS)" && 
SKS_DIR            := $(shell pwd)
SOURCE_DIR         := ./src
BUILD_DIR          := ./dist
KLIPPER_DIR        := ../klipper
KLIPPER_CONFIG_DIR := $(KLIPPER_DIR)/config
SKS_INSTALL_DIR    := $(KLIPPER_DIR)/Summers-Klipper-Suite

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
	$(FUNC) cliHeader "Help: Frequently Used Targets" "$@"
	$(FUNC) generateTargetHelpDocs "###" "$(MAKEFILE_LIST)"
	$(FUNC) logInfo "Run \`make help.all\` to see all available targets."

help.all: ### Display all targets
	$(FUNC) cliHeader "Help: All Available Targets" "$@"
	$(FUNC) generateTargetHelpDocs "##" "$(MAKEFILE_LIST)"

.npm.check-if-installed: ## Check if npm is installed
	@command -v npm >/dev/null 2>&1 || { $(FUNC) logError "npm is not installed. Please install it first."; exit 1; }

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

.require-klipper-directory: ## Check if klipper directory exists
ifeq ($(wildcard $(KLIPPER_DIR)),)
	$(FUNC) logError "Klipper directory not found. Should be located at: $(KLIPPER_DIR)."
	$(FUNC) logInfo "SKS and Klipper should be in the same parent directory."
	@exit 1;
else
	$(FUNC) logDebug "Klipper directory found at: $(KLIPPER_DIR)"
endif


build: ### Build the project
	$(FUNC) cliHeader "Building the project" "$@"
	@# remove old build files
	@rm -rf $(BUILD_DIR)
	$(FUNC) logSuccess "Removed old build files"
	@# Copy macros to "macro/" in the build directory
	@mkdir -p $(BUILD_DIR)/macro
	@cp -r $(SOURCE_DIR)/macro/* $(BUILD_DIR)/macro
	$(FUNC) logSuccess "Copied macro files to ${BUILD_DIR}/macro"
	@# Copy and concatenate all macros into "all-macros.cfg" in the build directory
	$(FUNC) generateConcatenatedMacroFile "${BUILD_DIR}" "${BUILD_DIR}"
	$(FUNC) logSuccess "Concatenated all macros into ${BUILD_DIR}/all-macros.cfg"


install: ### Install the project
	$(FUNC) cliHeader "Installing the project" "$@"
	@# remove existing installation
ifeq ($(wildcard $(SKS_INSTALL_DIR)),)
	$(FUNC) logSuccess "No existing installation found at $(SKS_INSTALL_DIR)"
else
	$(FUNC) remove $(SKS_INSTALL_DIR)
	$(FUNC) logSuccess "Removed existing installation at $(SKS_INSTALL_DIR)"
endif
	@# Move the build directory to the installation directory
	@mkdir -p $(SKS_INSTALL_DIR)
	$(FUNC) copy $(BUILD_DIR)/* $(SKS_INSTALL_DIR)
	$(FUNC) logSuccess "Moved build files to $(SKS_INSTALL_DIR)"

install.auto:: ### Install the project automatically
	$(FUNC) cliHeader "Running automatic installation" "$@"
install.auto:: build install
