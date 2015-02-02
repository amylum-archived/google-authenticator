DIR=$(shell pwd)

.PHONY : default manual container build push version local

default: upstream/Makefile container

upstream/Makefile:
	git submodule update --init

manual:
	./meta/launch /bin/bash || true

container:
	./meta/launch

build:
	rm -rf build
	make -C upstream/libpam clean
	cd upstream/libpam && ./bootstrap.sh && ./configure
	make -C upstream/libpam
	mkdir -p build/usr/{lib/security,local/bin}
	cp upstream/libpam/google-authenticator build/usr/local/bin/
	cp upstream/libpam/.libs/pam_google_authenticator.so build/usr/lib/security
	make -C upstream/libpam clean
	mkdir -p $(RELEASE_DIR)/usr/share/licenses/$(PACKAGE)
	cp package-license $(RELEASE_DIR)/usr/share/licenses/$(PACKAGE)/LICENSE
	cd build && tar -czvf ../google-authenticator.tar.gz *

push:
	@date -u +"%Y%m%d%H%M" > version
	git commit -am "v$$(cat version)"
	ssh -oStrictHostKeyChecking=no git@github.com &>/dev/null || true
	git tag -f "v$$(cat version)"
	git push --tags origin master
	targit -a .github -c -f akerl/google-authenticator v$$(cat version) google-authenticator.tar.gz

local: build push

