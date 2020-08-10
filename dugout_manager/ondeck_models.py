import sqlalchemy
from . import settings

from sqlalchemy import Column, Integer, String , ForeignKey, DateTime, Boolean, Date, Numeric
from sqlalchemy.ext.declarative import declarative_base 
from sqlalchemy.orm import relationship

Base = declarative_base()


 
class Od_depth_charts_batters(Base):
	__tablename__ = 'depth_charts_batters'
	__table_args__ = {'schema': 'public'}
	bpid = Column(Integer, primary_key = True)
	fullname  = Column(String)
	shortname  = Column(String)
	primary_pos = Column(Integer)
	org_id = Column(Integer)
	year = Column(Integer)
	pt_c = Column(Integer)
	pt_1b = Column(Integer)
	pt_2b = Column(Integer)
	pt_3b = Column(Integer)
	pt_ss = Column(Integer)
	pt_lf = Column(Integer)
	pt_cf = Column(Integer)
	pt_rf = Column(Integer)
	pt_dh = Column(Integer)
	updated_timestamp  = Column(DateTime)  
	user_id = Column(Integer)
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


 
class Od_depth_charts_pitchers(Base):
	__tablename__ = 'depth_charts_pitchers'
	__table_args__ = {'schema': 'public'}
	bpid = Column(Integer, primary_key = True)
	fullname  = Column(String)
	shortname  = Column(String)
	primary_pos = Column(Integer)
	org_id = Column(Integer)
	year = Column(Integer)
	gs_pct = Column(Numeric)
	sp_role  = Column(String)
	ip_gs = Column(Numeric)
	rp_ip_pct = Column(Numeric)
	rp_role  = Column(String)
	saves_pct = Column(Numeric)
	updated_timestamp  = Column(DateTime)  
	user_id = Column(Integer)
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)