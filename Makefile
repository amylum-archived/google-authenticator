DIR=$(shell pwd)

.PHONY : default build_container manual container build push local

default: container

build_container:
	docker build -t google-authenticator meta

manual: build_container
	./meta/launch /bin/bash || true

container: build_container
	./meta/launch

build:
	make -C google-authenticator/libpam
	mkdir -p build/usr/{lib/security,local/bin}
	cp google-authenticator/libpam/google-authenticator build/usr/local/bin/
	cp google-authenticator/libpam/pam_google_authenticator.so build/usr/lib/security
	make -C google-authenticator/libpam clean
	tar -czv -C build/ -f google-authenticator.tar.gz .

push:
	@date -u +"%Y%m%d%H%M" > version
	git commit -am "$$(cat version)"
	ssh -oStrictHostKeyChecking=no git@github.com &>/dev/null || true
	git tag -f "$$(cat version)"
	git push --tags origin master
	targit -a .github -c -f akerl/google-authenticator $$(cat version) google-authenticator.tar.gz

local: build push

