FROM harbor.imio.be/common/base:py3-ubuntu-20.04 as builder
ENV PIP=19.3.1 \
  ZC_BUILDOUT=2.13.2 \
  SETUPTOOLS=45.0.0 \
  WHEEL=0.33.6 \
  PLONE_MAJOR=5.2 \
  PLONE_VERSION=5.2.1

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  gcc \
  git \
  libbz2-dev \
  libc6-dev \
  libffi-dev \
  libjpeg62-dev \
  libopenjp2-7-dev \
  libmemcached-dev \
  libpcre3-dev \
  libpq-dev \
  libreadline-dev \
  libssl-dev \
  libxml2-dev \
  libxslt1-dev \
  python3-dev \
  python3-pip \
  wget \
  zlib1g-dev \
  && pip3 install --no-cache-dir pip==$PIP setuptools==$SETUPTOOLS zc.buildout==$ZC_BUILDOUT py-spy
WORKDIR /plone
RUN chown imio:imio -R /plone && mkdir /data && chown imio:imio -R /data
#COPY --chown=imio eggs /plone/eggs/
COPY --chown=imio *.cfg /plone/
COPY --chown=imio scripts /plone/scripts
RUN su -c "buildout -c prod.cfg -t 30" -s /bin/sh imio


FROM harbor.imio.be/common/base:py3-ubuntu-20.04

ENV PIP=19.3.1 \
  ZC_BUILDOUT=2.13.2 \
  SETUPTOOLS=45.0.0 \
  WHEEL=0.33.6 \
  PLONE_VERSION=5.2.1 \
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

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  libjpeg62 \
  libmemcached11 \
  libopenjp2-7 \
  libpq5 \
  libtiff5 \
  libxml2 \
  libxslt1.1 \
  lynx \
  netcat \
  poppler-utils \
  python3-distutils \
  rsync \
  wget \
  wv \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
RUN curl -L https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_amd64.deb > /tmp/dumb-init.deb && dpkg -i /tmp/dumb-init.deb && rm /tmp/dumb-init.deb

LABEL plone=$PLONE_VERSION \
  os="Ubuntu" \
  os.version="22.04" \
  name="Plone 5.2.5" \
  description="Plone image for imioweb app on iA.Smartweb project" \
  maintainer="iMio"

COPY --from=builder /usr/local/lib/python3.8/dist-packages /usr/local/lib/python3.8/dist-packages
COPY --chown=imio --from=builder /plone .
RUN chown imio:imio /plone
# DEBUG tools
# RUN echo 'manylinux1_compatible = True' > /usr/local/lib/python3.8/site-packages/_manylinux.py && pip install py-spy

COPY --chown=imio docker-initialize.py docker-entrypoint.sh /
USER imio
EXPOSE 8080
HEALTHCHECK --interval=1m --timeout=5s --start-period=30s \
  CMD nc -z -w5 127.0.0.1 8080 || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["console"]

