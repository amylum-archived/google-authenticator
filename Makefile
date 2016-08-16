PACKAGE = google-authenticator
ORG = amylum

BUILD_DIR = /tmp/$(PACKAGE)-build
RELEASE_DIR = /tmp/$(PACKAGE)-release
RELEASE_FILE = /tmp/$(PACKAGE).tar.gz

PAM_VERSION = 1.3.0-11
PAM_URL = https://github.com/amylum/pam/releases/download/$(PAM_VERSION)/pam.tar.gz
PAM_TAR = /tmp/pam.tar.gz
PAM_DIR = /tmp/pam
PAM_PATH = -I$(PAM_DIR)/usr/include -L$(PAM_DIR)/usr/lib

.PHONY : default submodule deps manual container build push version local

default: submodule container

submodule:
	git submodule update --init

manual: submodule
	./meta/launch /bin/bash || true

container:
	./meta/launch

deps:
	rm -rf $(PAM_DIR) $(PAM_TAR)
	mkdir $(PAM_DIR)
	curl -sLo $(PAM_TAR) $(PAM_URL)
	tar -x -C $(PAM_DIR) -f $(PAM_TAR)

build: submodule deps
	rm -rf $(BUILD_DIR)
	cp -R upstream/libpam $(BUILD_DIR)
	cd $(BUILD_DIR) && ./bootstrap.sh
	cd $(BUILD_DIR) && CC=musl-gcc CFLAGS='$(PAM_PATH)' ./configure
	make -C $(BUILD_DIR)
	mkdir -p $(RELEASE_DIR)/usr/{lib/security,bin,share/licenses/$(PACKAGE)}
	cp $(BUILD_DIR)/google-authenticator $(RELEASE_DIR)/usr/bin/
	cp $(BUILD_DIR)/.libs/pam_google_authenticator.so $(RELEASE_DIR)/usr/lib/security
	cp $(BUILD_DIR)/LICENSE $(RELEASE_DIR)/usr/share/licenses/$(PACKAGE)/LICENSE
	cd $(RELEASE_DIR) && tar -czvf $(RELEASE_FILE) *

version:
	date -u +"%Y%m%d%H%M" | tr -d '\n' > version
	printf - >> version
	git -C upstream rev-parse --short HEAD >> version

push: version
	git commit -am "v$$(cat version)"
	ssh -oStrictHostKeyChecking=no git@github.com &>/dev/null || true
	git tag -f "$$(cat version)"
	git push --tags origin master
	@sleep 2
	targit -a .github -c -f $(ORG)/$(PACKAGE) $$(cat version) $(RELEASE_FILE)
	@sha512sum $(RELEASE_FILE) | cut -d' ' -f1

local: build push

