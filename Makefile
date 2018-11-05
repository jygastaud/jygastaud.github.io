.PHONY: all build publish watch

all: reset build commit publish

watch:
	@rm -fr ./public/* --force --interactive=never
	@hugo server -w -D -t jane --navigateToChanged 

reset:
	cd ./public && git reset --hard origin/master

build:
	@echo "build start"
	@rm -fr ./public/* --force --interactive=never
	@hugo -t jane
	@echo "build success"

build-netlify:
	@echo "build start"
	@rm -fr ./public/* --force --interactive=never
	@hugo -t jane
	@echo "build success"

commit:
	@echo "commit start"
	cd ./public && git add --all && git commit -m "publish new version"
	@echo "build success"

publish:
	@echo "push start"
	cd ./public && git push origin master
	@echo "push success"
