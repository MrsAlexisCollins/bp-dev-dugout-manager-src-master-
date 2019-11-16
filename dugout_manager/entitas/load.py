import sqlalchemy
from . import settings
from . import mapping
from mapping import People
from sqlalchemy import create_engine
from sqlalchemy.orm  import Session

engine = create_engine(settings.BP_CAGE_URL) 
session = Session(engine)

persons = session.query(People).filter_by(fullname="Keith Hernandez").all()

print(
  persons
)