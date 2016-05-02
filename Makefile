.PHONY: all build publish watch

all: reset build commit publish

watch:
	@rm -fr ./public/* --force --interactive=never
	@hugo server -w -D -t v1

watch2:
	@rm -fr ./public/* --force --interactive=never
	@hugo server -w -D -t v2

reset:
	cd ./public && git reset --hard origin/master

build:
	@echo "build start"
	@rm -fr ./public/* --force --interactive=never
	@hugo -b http://gastaud.io -t v1
	@rm -fr ./public/sass --force --interactive=never
	@echo "build succes"

build2:
	@echo "build start"
	@rm -fr ./public/* --force --interactive=never
	@hugo -b http://gastaud.io -t v2
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
