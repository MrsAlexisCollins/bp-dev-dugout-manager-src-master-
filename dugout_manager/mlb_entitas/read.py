# This script pulls in data from the CAGE.  

import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.orm  import Session

from .. import settings

engine_read = create_engine(settings.BP_CAGE_URL) 
session_read = Session(engine_read)

## manage the acquistion of data here