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

push:
	@date -u +"%Y%m%d%H%M" > version
	git commit -am "$$(cat version)"
	ssh -oStrictHostKeyChecking=no git@github.com &>/dev/null || true
	git tag -f "$$(cat version)"
	git push --tags origin master
	targit -a .github -c -f akerl/google-authenticator $$(cat version) build/

local: build push


