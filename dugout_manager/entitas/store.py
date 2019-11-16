# saves data to the DUGOUT

import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.orm  import Session

from .. import settings

from .mapping import People


engine = create_engine(settings.BP_DUGOUT_URL) 
session = Session(engine)


