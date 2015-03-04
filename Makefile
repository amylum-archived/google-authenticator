PACKAGE = google-authenticator
ORG = amylum
BUILD_DIR = /tmp/$(PACKAGE)-build
RELEASE_DIR = /tmp/$(PACKAGE)-release
RELEASE_FILE = /tmp/$(PACKAGE).tar.gz

.PHONY : default submodule manual container build push version local

default: submodule container

submodule:
	git submodule update --init

manual: submodule
	./meta/launch /bin/bash || true

container:
	./meta/launch

build: submodule
	rm -rf $(BUILD_DIR)
	cp -R upstream/libpam $(BUILD_DIR)
	cd $(BUILD_DIR) && ./bootstrap.sh && CC="musl-gcc" ./configure
	make -C $(BUILD_DIR)
	mkdir -p $(RELEASE_DIR)/usr/{lib/security,bin,share/licenses/$(PACKAGE)}
	cp $(BUILD_DIR)/google-authenticator $(RELEASE_DIR)/usr/bin/
	cp $(BUILD_DIR)/.libs/pam_google_authenticator.so $(RELEASE_DIR)/usr/lib/security
	cp package-license $(RELEASE_DIR)/usr/share/licenses/$(PACKAGE)/LICENSE
	cd $(RELEASE_DIR) && tar -czvf $(RELEASE_FILE) *

version:
	@date -u +"%Y%m%d%H%M" > version

push: version
	git commit -am "v$$(cat version)"
	ssh -oStrictHostKeyChecking=no git@github.com &>/dev/null || true
	git tag -f "v$$(cat version)"
	git push --tags origin master
	targit -a .github -c -f $(ORG)/$(PACKAGE) v$$(cat version) $(RELEASE_FILE)

local: build push

