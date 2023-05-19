FROM --platform=$BUILDPLATFORM ruby:3.2.2-alpine3.18

LABEL maintainer="Mateusz Kubuszok <mateusz.kubuszok@gmail.com>"

COPY jekyll-docker-utils /

ENV BUNDLE_HOME=/usr/local/bundle
ENV BUNDLE_APP_CONFIG=/usr/local/bundle
ENV BUNDLE_DISABLE_PLATFORM_WARNINGS=true
ENV BUNDLE_BIN=/usr/local/bundle/bin
ENV GEM_BIN=/usr/gem/bin
ENV GEM_HOME=/usr/gem
ENV RUBYOPT=-W0
ENV JEKYLL_VAR_DIR=/var/jekyll
ENV JEKYLL_DOCKER_TAG=4.2.2
ENV JEKYLL_VERSION=4.2.2
ENV JEKYLL_DOCKER_NAME=jekyll
ENV JEKYLL_DATA_DIR=/srv/jekyll
ENV JEKYLL_BIN=/usr/jekyll/bin
ENV JEKYLL_ENV=development
ENV LANG=en_US.UTF-8

RUN \
  apk --no-cache add zlib-dev libffi-dev build-base libxml2-dev imagemagick-dev readline-dev libxslt-dev libffi-dev yaml-dev zlib-dev vips-dev vips-tools sqlite-dev cmake && \
  apk --no-cache add linux-headers openjdk8-jre less zlib libxml2 readline libxslt libffi git nodejs tzdata shadow bash su-exec npm libressl yarn && \
  apk --no-cache add graphviz gcompat && \
  echo "gem: --no-ri --no-rdoc" > ~/.gemrc && \
  unset GEM_HOME && unset GEM_BIN && yes | gem update --system && \
  unset GEM_HOME && unset GEM_BIN && yes | gem install --force bundler && \
  gem install jekyll -v$JEKYLL_VERSION -- --use-system-libraries && \
  gem install jekyll liquid-c jekyll-diagrams jekyll-minifier jekyll-sitemap jekyll-toc execjs katex kramdown-math-katex -- --use-system-libraries && \
  addgroup -Sg 1000 jekyll && \
  adduser -Su 1000 -G jekyll jekyll && \
  mkdir -p $JEKYLL_VAR_DIR && \
  mkdir -p $JEKYLL_DATA_DIR && \
  chown -R jekyll:jekyll $JEKYLL_DATA_DIR && \
  chown -R jekyll:jekyll $JEKYLL_VAR_DIR && \
  chown -R jekyll:jekyll $BUNDLE_HOME && \
  rm -rf /home/jekyll/.gem && \
  rm -rf $BUNDLE_HOME/cache && \
  rm -rf $GEM_HOME/cache && \
  rm -rf /root/.gem && \
  mkdir -p /usr/gem/cache/bundle && \
  chown -R jekyll:jekyll /usr/gem/cache/bundle

CMD ["jekyll" "--help"]
ENTRYPOINT ["/usr/jekyll/bin/entrypoint"]
WORKDIR /srv/jekyll
VOLUME /srv/jekyll
EXPOSE 35729
EXPOSE 4000
