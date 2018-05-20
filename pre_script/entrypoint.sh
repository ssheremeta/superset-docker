#!/bin/bash

set -eo pipefail

if [ "$SUPERSET_HOME" != "/home/superset" ]; then
    sed -i "s#FILENAME = '/home/superset/logs/superset.log'#FILENAME = '$SUPERSET_HOME/logs/superset.log'#" "$SUPERSET_HOME"/superset_config.py
fi

if [ -n "$SUPERSET_ROW_LIMIT" ]; then
    sed -i "s#ROW_LIMIT = 5000#ROW_LIMIT = $SUPERSET_ROW_LIMIT#" "$SUPERSET_HOME"/superset_config.py
fi

if [ -n "$SUPERSET_WORKERS" ]; then
    sed -i "s#SUPERSET_WORKERS = 4#SUPERSET_WORKERS = $SUPERSET_WORKERS#" "$SUPERSET_HOME"/superset_config.py
fi

if [ -n "$SUPERSET_WEB_THREADS" ]; then
    sed -i "s#WEBSERVER_THREADS = 8#WEBSERVER_THREADS = $SUPERSET_WEB_THREADS#" "$SUPERSET_HOME"/superset_config.py
fi

if [ -n "$SUPERSET_WEB_PORT" ]; then
    sed -i "s#SUPERSET_WEBSERVER_PORT = 8888#SUPERSET_WEBSERVER_PORT = $SUPERSET_WEB_PORT#" "$SUPERSET_HOME"/superset_config.py
fi

sed -i "s#SQLALCHEMY_DATABASE_URI = 'postgresql+psycopg2://superset:superset@localhost/superset'#SQLALCHEMY_DATABASE_URI = 'postgresql+psycopg2://$SUPERSET_POSTGRES_USER:$SUPERSET_POSTGRES_PASSWORD@$SUPERSET_POSTGRES_HOST:$SUPERSET_POSTGRES_PORT/$SUPERSET_POSTGRES_DB'#" "$SUPERSET_HOME"/superset_config.py



# Wait for Postresql
TRY_LOOP="10"
i=0
while ! nc -z $SUPERSET_POSTGRES_HOST $SUPERSET_POSTGRES_PORT >/dev/null 2>&1 < /dev/null; do
  i=$((i+1))
  echo "$(date) - waiting for ${SUPERSET_POSTGRES_HOST}:${SUPERSET_POSTGRES_PORT}... $i/$TRY_LOOP"
  if [ $i -ge $TRY_LOOP ]; then
    echo "$(date) - ${SUPERSET_POSTGRES_HOST}:${SUPERSET_POSTGRES_PORT} still not reachable, giving up"
    exit 1
  fi
  sleep 10
done



# check for existence of /docker-entrypoint.sh & run it if it does
echo "Checking for docker-entrypoint"
if [ -f /docker-entrypoint.sh ]; then
  echo "docker-entrypoint found, running"
  chmod +x /docker-entrypoint.sh
  . docker-entrypoint.sh
fi

# set up Caravel if we haven't already
if [ ! -f $SUPERSET_HOME/.setup-complete ]; then
  echo "Running first time setup for Caravel"

  echo "Creating admin user ${SUPERSET_ADMIN_USERNAME}"
  cat > $SUPERSET_HOME/admin.config <<EOF
${SUPERSET_ADMIN_USERNAME}
${SUPERSET_ADMIN_USERNAME}
${SUPERSET_ADMIN_USERNAME}
${SUPERSET_ADMIN_EMAIL}
${SUPERSET_ADMIN_PASSWORD}
${SUPERSET_ADMIN_PASSWORD}

EOF
  
  /bin/sh -c '/usr/local/bin/fabmanager create-admin --app superset < $SUPERSET_HOME/admin.config'

  rm $SUPERSET_HOME/admin.config

  echo "Initializing database"
  superset db upgrade

  superset load_examples

  echo "Creating default roles and permissions"
  superset init

  touch $SUPERSET_HOME/.setup-complete
else
  # always upgrade the database, running any pending migrations
  superset db upgrade
fi

echo "Starting up Caravel"
superset runserver