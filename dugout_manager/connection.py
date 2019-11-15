"""
Manages database connections for use with SQLAlchemy models
copied from Matt Dennewitz's skunkworks 
"""

import sqlalchemy
from sqlalchemy.orm import scoped_session, sessionmaker

__all__ = (
    'DEFAULT_DB_ALIAS',
    'connections',
)

DEFAULT_DB_ALIAS = 'default'


class ConnectionHandler(object):
    """Manages database connections, gives easy access to existing engines
    and metadata
    """

    def __init__(self):
        self._connections = {}
        self._sessions = {}

    def __getitem__(self, key):
        if key in self._connections:
            return self._connections[key]
        raise KeyError('Connection {} not configured'.format(key))

    def add_connection(self, alias, dsn, isolation_level='AUTOCOMMIT'):
        """Creates new engine and metadata handles for a given alias/DSN pair

        Args:
            alias: Name for this database connection
            dsn: Connection DSN (e.g., `postgresql://localhost/dbname`)
            isolation_level: PostgreSQL isolation level. Default: autocommit
        """

        engine = sqlalchemy.create_engine(dsn, isolation_level=isolation_level)

        self._connections[alias] = Connection(
            alias=alias,
            engine=engine,
            metadata=sqlalchemy.MetaData(bind=engine),
        )

        return self._connections[alias]

    def get_connection(self, using=DEFAULT_DB_ALIAS):
        """Returns an engine/metadata hash for given alias.

        Args:
            alias: Desired database connection's alias

        Raises:
            `KeyError` if specified `alias` has not been added to this handler.

        Returns:
            A `dict` with `engine` and `metadata` handles for given alias
        """

        if using not in self._connections:
            raise KeyError('Database {} is not defined'.format(using))

        return self._connections[using]


class Connection(object):
    """A wrapped connection spun off from ``ConnectionHandler``
    """

    def __init__(self, alias, engine, metadata):
        """Creates a new connection

        Args:
            alias: name given to this connection
            engine: SQLAlchemy engine powering this connection
            metadata: SQLAlchemy metadata bound to given engine
        """
        self.alias = alias
        self.engine = engine
        self.metadata = metadata

    def connect(self):
        return self.engine.connect()

    def get_session(self, scoped=False):
        """Creates a session for this connection

        Args:
            scope: True if session should be scoped, False if not.
                   Default: False.

        Returns:
            SQLAlchemy session, possibly scoped
        """

        session_factory = sessionmaker(bind=self.engine)

        if scoped:
            return scoped_session(session_factory)

        return session_factory()


connections = ConnectionHandler()  # pylint: disable=invalid-name
