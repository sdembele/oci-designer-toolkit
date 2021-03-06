#!/bin/bash

# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Run Command Options
export BASH_SHELL='/bin/bash'
export FLASK_SERVER='python3 -m flask run --host=0.0.0.0 --port=80 --no-debugger'
export GUNICORN_SERVER='gunicorn --bind=0.0.0.0:80 --workers=2 --limit-request-line 0 '\''okitweb:create_app()'\'''
export NGINX_SERVER='nginx;gunicorn --workers=2 --limit-request-line 0 --bind=0.0.0.0:5000 okitweb.wsgi:app'

RUN_COMMAND=${GUNICORN_SERVER}
RUNTIME='gunicorn'
export EXPOSE_PORTS="\
       -p 80:80 \
       -p 443:443 \
"


while getopts bfgn option
do
  case "${option}"
  in
    b)
      RUN_COMMAND=${BASH_SHELL}
      RUNTIME='bash    '
      break
      ;;
    f)
      RUN_COMMAND=${FLASK_SERVER}
      RUNTIME='flask   '
      export EXPOSE_PORTS="-p 80:80 "
      break
      ;;
    g)
      RUN_COMMAND=${GUNICORN_SERVER}
      RUNTIME='gunicorn'
      break
      ;;
    n)
      RUN_COMMAND=${NGINX_SERVER}
      RUNTIME='nginx   '
      break
      ;;
    *)
      break
      ;;
  esac
done

export BASENAME=$(basename $0)
export DIRNAME=$(dirname $0)
export FILENAME="${BASENAME%.*}"

source $(dirname $0)/docker-env.sh

echo ""
echo ""
echo ""
echo "=========================================================================="
echo "=====  Runtime : ${RUNTIME}                                            ====="
echo "=====  Version : ${VERSION}                                               ====="
echo "=====  Image   : ${DOCKERIMAGE}                                ====="
echo "=========================================================================="
echo ""
echo ""
echo ""

# Test Docker Image exists
PCMAIMAGE=$(docker images | grep ${DOCKERIMAGE})
if [[ "$PCMAIMAGE" == "" ]]
then
    ${DOCKERDIR}/${BUILDSCRIPT}
fi

# Run command
docker run \
       --name ${FILENAME}-${VERSION} \
       --hostname ${FILENAME}-${VERSION} \
       ${VOLUMES} \
       ${ENVIRONMENT} \
       -w /okit \
       ${EXPOSE_PORTS} \
       --rm \
       -it \
       ${DOCKERIMAGE} \
       /bin/bash -c "${RUN_COMMAND}"

docker ps -l
