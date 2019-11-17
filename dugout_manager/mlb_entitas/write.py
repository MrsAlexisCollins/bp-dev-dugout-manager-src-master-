# saves data to the DUGOUT

import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.orm  import Session

from .. import settings

engine = create_engine(settings.BP_DUGOUT_URL) 
session_write = Session(engine)