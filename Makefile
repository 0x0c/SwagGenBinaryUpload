# Variables

PRODUCT_NAME := SwagGenBinaryUpload
PROJECT_NAME := ${PRODUCT_NAME}.xcodeproj
WORKSPACE_NAME := ${PRODUCT_NAME}.xcworkspace
SCHEME_NAME := ${PRODUCT_NAME}
UI_TESTS_TARGET_NAME := ${PRODUCT_NAME}UITests

TEST_SDK := iphonesimulator
TEST_CONFIGURATION := Debug
TEST_PLATFORM := iOS Simulator
TEST_DEVICE ?= iPhone 12 Pro Max
TEST_OS ?= 14.3
TEST_DESTINATION := 'platform=${TEST_PLATFORM},name=${TEST_DEVICE},OS=${TEST_OS}'
COVERAGE_OUTPUT := html_report

XCODEBUILD_BUILD_LOG_NAME := xcodebuild_build.log
XCODEBUILD_TEST_LOG_NAME := xcodebuild_test.log

MODULE_TEMPLATE_NAME ?= 0x0c_viper

.DEFAULT_GOAL := help

# Targets

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?# .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":[^#]*? #| #"}; {printf "%-42s%s\n", $$1 $$3, $$2}'

.PHONY: setup
setup: # Install dependencies and prepared development configuration
	$(MAKE) install-ruby
	$(MAKE) install-bundler
	# $(MAKE) install-templates
	$(MAKE) install-mint
	$(MAKE) swagger-codegen
	$(MAKE) generate-xcodeproj

.PHONY: install-ruby
install-ruby: # Install Ruby
	rbenv install -s
	gem install bundler

.PHONY: install-bundler
install-bundler: # Install Bundler dependencies
	bundle config path vendor/bundle
	bundle install --jobs 4 --retry 3

.PHONY: update-bundler
update-bundler: # Update Bundler dependencies
	bundle config path vendor/bundle
	bundle update --jobs 4 --retry 3

.PHONY: update-pods
update-pods: # Update Podfile.lock
	bundle exec pod update
	$(MAKE) generate-xcodeproj

.PHONY: update-dependencies
update-dependencies: # Update Podfile.lock
	$(MAKE) update-bundler
	$(MAKE) update-pods

.PHONY: install-mint
install-mint: # Install Mint dependencies
	mint bootstrap --overwrite y

.PHONY: install-templates
install-templates: # Install Generamba templates
	bundle exec generamba template install

.PHONY: generate-module
generate-module: # Generate module with Generamba and regenerate project # MODULE_NAME=[module name]
	bundle exec generamba gen ${MODULE_NAME} ${MODULE_TEMPLATE_NAME}
	$(MAKE) format
	$(MAKE) generate-xcodeproj

.PHONY: generate-xcodeproj
generate-xcodeproj: # Generate project with XcodeGen
	mint run xcodegen
	bundle exec pod install

.PHONY: swagger-codegen
swagger-codegen:
	rm -rf ./swagger_generated
	mint run swaggen generate API/test.yaml --destination swagger_generated --option name:TestAPI --option typeAliases.File:UploadFile --clean all --verbose

.PHONY: beta
beta:
	bundle exec fastlane beta

.PHONY: open
open: # Open project in Xcode
	open ./${WORKSPACE_NAME}

.PHONY: format
format: # Format code
	./Pods/SwiftFormat/CommandLineTool/swiftformat .

.PHONY: clean
clean: # Delete cache
	rm -rf ./vendor/bundle
	rm -rf ./Templates
	rm -rf ./Pods
	xcodebuild clean -alltargets
	rm -rf ./${PROJECT_NAME}
	rm -rf ./${WORKSPACE_NAME}
