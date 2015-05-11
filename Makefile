.PHONY: all build publish

all: build publish

watch:
	@hugo server -w

build:
	@echo "coucou"
	@rm -fr ./public/* --force --interactive=never
	hugo

publish:
	@echo "publish"
	cd public
	git add --all
	git commit -m "publish new version"
	@echo "success"
