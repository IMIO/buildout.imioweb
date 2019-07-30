#!/usr/bin/make

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

docker-image:
	docker build --pull -t imioweb/mutual:latest .

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
