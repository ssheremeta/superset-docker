#---------------------------------------------------------
# Superset specific config
#---------------------------------------------------------
ROW_LIMIT = 5000
SUPERSET_WORKERS = 4
WEBSERVER_THREADS = 8
SUPERSET_WEBSERVER_PORT = 8888
SUPERSET_WEBSERVER_TIMEOUT = 60
#---------------------------------------------------------

#---------------------------------------------------------
# Flask App Builder configuration
#---------------------------------------------------------
# Your App secret key
SECRET_KEY = 'thisismyscretkey'

# The SQLAlchemy connection string to your database backend
# This connection defines the path to the database that stores your
# superset metadata (slices, connections, tables, dashboards, ...).
# Note that the connection information to connect to the datasources
# you want to explore are managed directly in the web UI
SQLALCHEMY_DATABASE_URI = 'postgresql+psycopg2://superset:superset@localhost/superset'

CSRF_ENABLED = True

# Flask-WTF flag for CSRF
WTF_CSRF_ENABLED = True

# Logging
ENABLE_TIME_ROTATE = True
TIME_ROTATE_LOG_LEVEL = 'DEBUG'
FILENAME = '/home/superset/logs/superset.log'
ROLLOVER = 'midnight'
INTERVAL = 1
BACKUP_COUNT = 10

# Translation
BABEL_DEFAULT_LOCALE = 'ru'
BABEL_DEFAULT_FOLDER = '/superset/src/superset/translations'
LANGUAGES = {
    'ru': {'flag': 'ru', 'name': 'Russian'},
    'en': {'flag': 'us', 'name': 'English'}
}