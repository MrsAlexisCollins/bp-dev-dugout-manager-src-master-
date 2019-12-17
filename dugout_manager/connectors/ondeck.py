# saves data to   ONDECK

import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.orm  import Session

from . import settings

engine_ondeck = create_engine(settings.BP_ONDECK_URL) 
session_ondeck = Session(engine_ondeck)