.PHONY: clean

.EXPORT_ALL_VARIABLES:

DEFAULT_IMG=kubuszok/jekyll:4.2.2-v2

JEKYLL_IMG?=$(DEFAULT_IMG)
AWS_IMG=mesosphere/aws-cli:1.14.5
EXTRA_ARGS?=-it --privileged --userns=host

WITH_JEKYLL=docker run --rm --volume="${PWD}/src:/srv/jekyll:Z" --volume="${PWD}/bundle:/usr/gem:Z" -e JEKYLL_ENV="${JEKYLL_ENV}" -p 4000:4000 $(EXTRA_ARGS) "${JEKYLL_IMG}"
WITH_AWSCLI=docker run --rm --volume="${PWD}/src/_site:/project" -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" -e AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}" "${AWS_IMG}"

serve:
	@JEKYLL_ENV=development $(WITH_JEKYLL) jekyll serve --incremental --profile true --draft --future --verbose --config _config.yaml,_config.dev.yaml

build:
	@if find src/_posts -type f -name "* *" | egrep '.*'; then \
		@echo Found published post with a space in its name, aborting!; \
		@exit 1; \
	fi
	@JEKYLL_ENV=production $(WITH_JEKYLL) jekyll build

install:
	@$(WITH_JEKYLL) bundle install

update:
	@$(WITH_JEKYLL) bundle update

publish:
	@if grep "http://localhost:4000" "src/_site/feed.xml" > /dev/null; then \
		@echo Publish should be run after "make build" not "make serve"; \
		@echo   -- preventing publishing developer version --; \
		@exit 1; \
	fi
	@$(WITH_AWSCLI) s3 sync --delete --size-only --no-progress --sse AES256 ./ s3://${S3_BUCKET}/ \
		| sed 's/^(dryrun) //' \
		| awk '{print "/"$$2;}' \
		| sed 's/\/.\//\//' \
		| sed 's/index.html$$//' \
		| xargs --no-run-if-empty $(WITH_AWSCLI) cloudfront create-invalidation --distribution-id "${CF_DISTRIBUTION_ID}" --paths \
		|| $(WITH_AWSCLI) cloudfront create-invalidation --distribution-id "${CF_DISTRIBUTION_ID}" --paths '/*'

rebuild_docker:
	@docker buildx create --use
	@docker buildx build --platform linux/amd64,linux/arm64/v8 --tag "${JEKYLL_IMG}" --push .
	@docker buildx stop

rebuild_docker_local:
	@if [ "$(JEKYLL_IMG)" = "$(DEFAULT_IMG)" ]; then \
		echo Local docker image should not be names the same as CI one:; \
		echo  - set up JEKYLL_IMG to something other than $(DEFAULT_IMG)!; \
		exit 1; \
	fi
	@docker build --tag "${JEKYLL_IMG}" --push .

clean:
	@rm -rf bundle src/{.jekyll-cache,.jekyll-metadata,_site}
