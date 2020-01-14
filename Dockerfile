FROM docker-staging.imio.be/base:alpinepy3 as builder
ENV PIP=9.0.3 \
  ZC_BUILDOUT=2.13.2 \
  SETUPTOOLS=41.0.1 \
  WHEEL=0.31.1 \
  PLONE_MAJOR=5.2 \
  PLONE_VERSION=5.2.0

RUN apk add --update --no-cache --virtual .build-deps \
  build-base \
  gcc \
  git \
  libc-dev \
  libffi-dev \
  libjpeg-turbo-dev \
  libpng-dev \
  libwebp-dev \
  libxml2-dev \
  libxslt-dev \
  openssl-dev \
  pcre-dev \
  wget \
  zlib-dev \
  && pip install pip==$PIP setuptools==$SETUPTOOLS zc.buildout==$ZC_BUILDOUT wheel==$WHEEL
WORKDIR /plone
RUN chown imio:imio -R /plone && mkdir /data && chown imio:imio -R /data
# COPY --chown=imio eggs /plone/eggs/
COPY --chown=imio *.cfg /plone/
COPY --chown=imio scripts /plone/scripts
RUN su -c "buildout -c prod.cfg" -s /bin/sh imio


FROM docker-staging.imio.be/base:alpinepy3

ENV PIP=9.0.3 \
  ZC_BUILDOUT=2.13.2 \
  SETUPTOOLS=41.0.1 \
  WHEEL=0.31.1 \
  PLONE_VERSION=5.2.0 \
  TZ=Europe/Brussel \
  ZEO_HOST=zeo \
  ZEO_PORT=8100 \
  HOSTNAME_HOST=local \
  POLICY_PROFILE=imioweb.policy:default \
  PROJECT_ID=imio

RUN mkdir /data && chown imio:imio -R /data
VOLUME /data/blobstorage
VOLUME /data/filestorage
WORKDIR /plone

RUN apk add --no-cache --virtual .run-deps \
  bash \
  rsync \
  libxml2 \
  libxslt \
  libpng \
  libjpeg-turbo

LABEL plone=$PLONE_VERSION \
  os="alpine" \
  os.version="3.10" \
  name="Plone 5.2.0" \
  description="Plone image for iA.Smartweb" \
  maintainer="Imio"

COPY --from=builder /usr/local/lib/python3.7/site-packages /usr/local/lib/python3.7/site-packages
COPY --chown=imio --from=builder /plone .
RUN chown imio:imio /plone

COPY --chown=imio docker-initialize.py docker-entrypoint.sh /
USER imio
EXPOSE 8080
HEALTHCHECK --interval=1m --timeout=5s --start-period=30s \
  CMD nc -z -w5 127.0.0.1 8080 || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["console"]

