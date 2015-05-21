.PHONY: all build publish

all: build commit publish

watch:
	@hugo server -w

build:
	@echo "build start"
	@rm -fr ./public/* --force --interactive=never
	@hugo
	@echo "build succes"

commit:
	@echo "commit start"
	cd ./public && git add --all && git commit -m "publish new version"
	@echo "build success"

publish:
	@echo "push start"
	cd ./public && git push origin master
	@echo "push success"
