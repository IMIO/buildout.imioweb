#!/usr/bin/make

IMAGE_NAME="docker-staging.imio.be/imioweb/mutual:alpine"

build-dev: bin/pip
	ln -fs dev.cfg buildout.cfg
	bin/pip install -I -r requirements.txt
	bin/buildout

build-prod: bin/pip
	ln -fs prod.cfg buildout.cfg
	bin/pip install -I -r requirements.txt
	bin/buildout

build: build-dev

bin/pip:
	if [ -f /usr/bin/virtualenv-2.7 ] ; then virtualenv-2.7 .;else virtualenv -p python2.7 .;fi

run: bin/instance
	bin/instance fg

docker-image: eggs
	docker build --pull -t imioweb/mutual:alpinepy3 .

cleanall:
	rm -fr develop-eggs downloads eggs parts .installed.cfg lib include bin .mr.developer.cfg local/

bash:
	docker-compose run --rm -p 8080:8080 -u imio instance bash

rsync:
	rsync -rP imio@pre-prod3.imio.be:/srv/instances/imioweb/filestorage/Data.fs var/filestorage/Data.fs
	rsync -r --info=progress2 imio@pre-prod3.imio.be:/srv/instances/imioweb/blobstorage/ var/blobstorage/

dev:
	ln -fs dev.cfg buildout.cfg
	if [ -f /usr/bin/virtualenv-2.7 ] ; then virtualenv-2.7 .;else virtualenv -p python2.7 .;fi
	./bin/pip install -r requirements.txt
	./bin/buildout -t 30

buildout.cfg:
	ln -fs dev.cfg buildout.cfg

dev-py3: buildout.cfg
	python3 -m venv .
	./bin/pip install -r requirements.txt
	./bin/buildout -t 30


eggs:  ## Copy eggs from docker image to speed up docker build
	-docker run --entrypoint='' $(IMAGE_NAME) tar -c -C /plone eggs | tar x
	mkdir -p eggs
