import sqlalchemy
import settings

from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base


Base = declarative_base()

class People(Base): 
    __tablename__ = 'people'

    bpid = Column(Integer, primary_key = True)
    fullname = Column(String)

    __table_args__ = {'schema': 'ingest'}

    def __repr__(self):
        return "<Person(id=%i, full_name='%s')>" % (
            self.bpid, self.fullname)

 
