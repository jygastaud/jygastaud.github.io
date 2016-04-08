.PHONY: all build publish watch

all: build commit publish

watch:
	@rm -fr ./public/* --force --interactive=never
	@hugo server -w -D

build:
	@echo "build start"
	@rm -fr ./public/* --force --interactive=never
	@hugo -b http://gastaud.io
	@rm -fr ./public/sass --force --interactive=never
	@echo "build succes"

commit:
	@echo "commit start"
	cd ./public && git add --all && git commit -m "publish new version"
	@echo "build success"

publish:
	@echo "push start"
	cd ./public && git push origin master
	@echo "push success"
