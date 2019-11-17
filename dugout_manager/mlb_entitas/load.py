# This script pulls in data from the CAGE.  

import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.orm  import Session

from .. import settings

from .mapping import Mlb_people
from .mapping import Bp_xref


engine = create_engine(settings.BP_CAGE_URL) 
session = Session(engine)

mlb_persons = session.query(Mlb_people).limit(100) 

