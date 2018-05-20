FROM python:3.6

# Caravel setup options
ENV SUPERSET_VERSION=0.18.5 \
    SUPERSET_HOME=/home/superset

ENV PYTHONPATH=$SUPERSET_HOME:$PYTHONPATH


RUN apt-get update \
&& apt-get install -y \
  		build-essential \
  		libssl-dev \
  		libffi-dev \
  		libsasl2-dev \ 
  		libldap2-dev \
  		libpq5 \
  		libpq-dev \
  		apt-utils \
  		curl \
  		netcat \
&& pip install --no-cache-dir \
        psycopg2 \
        numpy \
        boto3==1.4.4 \
        celery==3.1.25 \
        colorama==0.3.9 \
        cryptography==1.7.2 \
        flask-appbuilder==1.9.1 \
        flask-cache==0.13.1 \
        flask-migrate==2.0.3 \
        flask-script==2.0.5 \
        flask-sqlalchemy==2.1 \
        flask-testing==0.6.2 \
        flask-wtf==0.14.2 \
        flower==0.9.1 \
        future==0.16.0 \
        humanize==0.5.1 \
        gunicorn==19.7.1 \
        markdown==2.6.8 \
        pandas==0.20.2 \
        parsedatetime==2.0.0 \
        pydruid==0.3.1 \
        PyHive>=0.3.0 \
        python-dateutil==2.6.0 \
        requests==2.17.3 \
        simplejson==3.10.0 \
        six==1.10.0 \
        sqlalchemy==1.1.9 \
        sqlalchemy-utils==0.32.14 \
        sqlparse==0.2.3 \
        thrift>=0.9.3 \
        thrift-sasl>=0.2.1 \
        idna==2.5 \
        superset==0.25.0 \
&& apt-get remove -y \
  build-essential libssl-dev libffi-dev libsasl2-dev libldap2-dev \
&& apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*

# Cleanup
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*


COPY pre_script/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY pre_config/superset_config.py $SUPERSET_HOME/

VOLUME $SUPERSET_HOME
EXPOSE 8888

# since this can be used as a base image adding the file /docker-entrypoint.sh
# is all you need to do and it will be run *before* Caravel is set up
ENTRYPOINT [ "/entrypoint.sh" ]