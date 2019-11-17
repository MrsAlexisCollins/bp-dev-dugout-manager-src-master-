# saves data to the DUGOUT

import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.orm  import Session

from .. import settings
from .mapping import Bp_people 


engine = create_engine(settings.BP_DUGOUT_URL) 
session = Session(engine)


## manage data writing here
for upload in uploads:
    row = Uploads(**upload)
    session.add(row)

session.commit()