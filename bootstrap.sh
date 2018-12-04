#!/bin/sh
# Usage:
#     ./bootstrap.sh  # use buildout.cfg
#     ./bootstrap.sh -c dev.cfg  # use dev.cfg
ln -s dev.cfg buildout.cfg
if [ -f /usr/bin/virtualenv-2.7 ] ; then virtualenv-2.7 .;else virtualenv -p python2.7 .;fi
bin/pip install -I -r requirements.txt
bin/buildout "$@"
