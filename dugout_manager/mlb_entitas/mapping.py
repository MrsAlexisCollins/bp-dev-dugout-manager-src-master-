# defines and maps the database objects in CAGE and DUGOUT

import sqlalchemy
from .. import settings

from sqlalchemy import Column, Integer, String , ForeignKey, DateTime
from sqlalchemy.ext.declarative import declarative_base 
from sqlalchemy.orm import relationship

Base = declarative_base()


## inbound

class Mlb_people(Base): 
    __tablename__ = 'people'

    id = Column(Integer, primary_key = True)
    full_name = Column(String)
    bpxref = relationship( "Bp_xref" , back_populates="mlbpeople")
    mlbpeople_names = relationship("Mlb_people_names", back_populates="mlbpeople")
     
    __table_args__ = {'schema': 'mlbapi'}

    def __repr__(self):
        return "\n%s %i %i " % (
          self.full_name ,   self.id  , self.bpxref[0].bpid)



class Mlb_people_names(Base): 
    __tablename__ = 'people_names'

    id = Column(Integer, ForeignKey('mlbapi.people.id'), primary_key = True)
    use_name = Column(String)
    mlbpeople = relationship( "Mlb_people" , back_populates="mlbpeople_names")
     
    __table_args__ = {'schema': 'mlbapi'}

    def __repr__(self):
        return "\n%s %i %i " % (
          self.use_name ,   self.id  , self.bpxref[0].bpid)


class Bp_xref(Base): 
    __tablename__ = 'people_xrefids'

    bpid = Column(Integer, primary_key = True)
    mlb = Column(Integer, ForeignKey('mlbapi.people.id')) 
    mlbpeople = relationship("Mlb_people", back_populates="bpxref")

    __table_args__ = {'schema': 'ingest'}

    def __repr__(self):
        return "<Bpxref(bpid=%i)>" % (
            self.bpid )



## outbound
 
class Bp_people(Base): 
    __tablename__ = 'people'

    bpid = Column(Integer, primary_key = True)
    use_full_name = Column(String) 
    use_sortable_name = Column(String) 
    updated_timestamp = Column(DateTime)

    __table_args__ = {'schema': 'entitas'}

    def __repr__(self):
        return "a dugout person %s %i   " % (
          self.use_full_name ,  self.use_sortable_name ,   self.bpid)