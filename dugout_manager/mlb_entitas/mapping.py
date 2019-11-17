# defines and maps the database objects in CAGE and DUGOUT

import sqlalchemy
from .. import settings

from sqlalchemy import Column, Integer, String , ForeignKey
from sqlalchemy.ext.declarative import declarative_base 
from sqlalchemy.orm import relationship


Base = declarative_base()

class Mlb_people(Base): 
    __tablename__ = 'people'

    id = Column(Integer, primary_key = True)
    full_name = Column(String)
    bpxref = relationship( "Bp_xref" , back_populates="mlbpeople")
     
    __table_args__ = {'schema': 'mlbapi'}

    def __repr__(self):
        return "<Person(mlbid=%i, full_name='%s' %s)>" % (
            self.id  , self.full_name , self.bpxref)


class Bp_xref(Base): 
    __tablename__ = 'people_xrefids'

    bpid = Column(Integer, primary_key = True)
    mlb = Column(Integer, ForeignKey('mlbapi.people.id')) 
    mlbpeople = relationship("Mlb_people", back_populates="bpxref")

    __table_args__ = {'schema': 'ingest'}

    def __repr__(self):
        return "<Bpxref(bpid=%i)>" % (
            self.bpid )

