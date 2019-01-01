.PHONY: clean

.EXPORT_ALL_VARIABLES:

JEKYLL_IMG=kubuszok/jekyll:3.8.5
AWS_IMG=mesosphere/aws-cli:1.14.5
EXTRA_ARGS?=-it --privileged --userns=host

WITH_JEKYLL=docker run --rm --volume="${PWD}/src:/srv/jekyll" --volume="${PWD}/bundle:/usr/local/bundle" -e JEKYLL_ENV=${JEKYLL_ENV} -p 4000:4000 $(EXTRA_ARGS) ${JEKYLL_IMG}
WITH_AWSCLI=docker run --rm --volume="${PWD}/src/_site:/project" -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} -t $(tty &>/dev/null && echo "-i") ${AWS_IMG}

serve:
	@JEKYLL_ENV=development $(WITH_JEKYLL) jekyll serve --incremental --profile true --draft --future --verbose --config _config.yaml,_config.dev.yaml

build:
	@if find src/_posts -type f -name "* *" | egrep '.*'; then \
		@echo Found published post with a space in its name, aborting!; \
		@exit 1; \
	fi
	@JEKYLL_ENV=production $(WITH_JEKYLL) jekyll build

update:
	@$(WITH_JEKYLL) bundle update

publish:
	@if grep "http://localhost:4000" "src/_site/feed.xml" > /dev/null; then \
		@echo Publish should be run after "make publish" not "make serve"; \
		@echo   -- preventing publishing developer version --; \
		@exit 1; \
	fi
	@$(WITH_AWSCLI) s3 sync --delete --size-only --no-progress --sse AES256 ./ s3://${S3_BUCKET}/ \
		| sed 's/^(dryrun) //' \
		| awk '{print "/"$$2;}' \
		| sed 's/\/.\//\//' \
		| sed 's/index.html$$//' \
		| xargs --no-run-if-empty $(WITH_AWSCLI) cloudfront create-invalidation --distribution-id ${CF_DISTRIBUTION_ID} --paths \
		|| $(WITH_AWSCLI) cloudfront create-invalidation --distribution-id ${CF_DISTRIBUTION_ID} --paths '/*'

pull_docker:
	@docker pull ${JEKYLL_IMG}
	@docker pull ${AWS_IMG}

push_docker:
	@docker build . -t ${JEKYLL_IMG}
	@docker push ${JEKYLL_IMG}

clean:
	@rm bundle src/{.jekyll_metadata,.sass-cache,_site} -rf
