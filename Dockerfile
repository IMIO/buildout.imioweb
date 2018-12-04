FROM docker-staging.imio.be/imioweb/cache:latest
ENV PATH="/home/imio/.local/bin:${PATH}" \
    ZEO_HOST=db \
    ZEO_PORT=8100 \
    HOSTNAME_HOST=local \
    PROJECT_ID=imioweb \
    HOME=/home/imio
RUN mkdir /home/imio/plone
COPY docker-entrypoint.sh /
COPY Makefile *.cfg *.txt /home/imio/plone/
RUN buildDeps="libpq-dev wget git python-virtualenv gcc libc6-dev libpcre3-dev libssl-dev libxml2-dev libxslt1-dev libbz2-dev libffi-dev libjpeg62-dev libopenjp2-7-dev zlib1g-dev python-dev" \
  && runDeps="poppler-utils wv rsync lynx netcat libxml2 libxslt1.1 libjpeg62 libtiff5 libopenjp2-7 gosu" \
  && apt-get update \
  && apt-get install -y --no-install-recommends $buildDeps \
  && cd /home/imio/plone \
  && pip install -I -r requirements.txt \
  && ln -fs prod.cfg buildout.cfg \
  && buildout \
  && chown imio:imio -R /home/imio/plone/ && chown imio:imio /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh \
  && apt-get remove -y $buildDeps \
  && apt-get install -y $runDeps \
  && apt-get autoremove -y \
  && apt-get clean
WORKDIR /home/imio/plone
EXPOSE 8080
HEALTHCHECK --start-period=15s --timeout=5s --interval=1m \
  CMD curl --fail http://127.0.0.1:8080/ || exit 1
ENTRYPOINT ["/docker-entrypoint.sh"]
