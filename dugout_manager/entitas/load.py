# This script pulls in data from the CAGE.  

import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.orm  import Session

from .. import settings

from .mapping import People


engine = create_engine(settings.BP_CAGE_URL) 
session = Session(engine)

persons = session.query(People).filter_by(fullname="Keith Hernandez").all()

