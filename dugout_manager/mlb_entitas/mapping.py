# defines and maps the database objects in CAGE and DUGOUT

import sqlalchemy
from .. import settings

from sqlalchemy import Column, Integer, String , ForeignKey, DateTime, Boolean, Date, Numeric
from sqlalchemy.ext.declarative import declarative_base 
from sqlalchemy.orm import relationship

Base = declarative_base()


## inbound


class Mlb_levels(Base):
    __tablename__ = 'levels'
    __table_args__ = {'schema': 'mlbapi'}
    id = Column(Integer, primary_key = True) 
    code = Column(String) 
    name = Column(String) 
    abbreviation = Column(String) 
    sort_order = Column(Integer) 
    leagues = relationship("Mlb_leagues", back_populates="levels")
    divisions = relationship("Mlb_divisions", back_populates="levels")	
    teams = relationship("Mlb_teams", back_populates="levels")	
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Mlb_people(Base):
    __tablename__ = 'people'
    __table_args__ = {'schema': 'mlbapi'}
    id = Column(Integer, primary_key = True) 
    full_name = Column(String)  
    bpxref = relationship( "Bp_xref" , back_populates="people")
    people_names = relationship("Mlb_people_names", back_populates="people")
    people_death = relationship("Mlb_people_death", back_populates="people")
    people_birth = relationship("Mlb_people_birth", back_populates="people")
    people_mutables = relationship("Mlb_people_mutables", back_populates="people")	
    people_roster_entries = relationship("Mlb_people_roster_entries", back_populates="people")	
    people_roster_status = relationship("Mlb_people_roster_status", back_populates="people")	
    people_transactions = relationship("Mlb_people_transactions", back_populates="people")
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Mlb_player_status_codes(Base):
    __tablename__ = 'player_status_codes'
    __table_args__ = {'schema': 'mlbapi'}
    code = Column(String, primary_key = True) 
    description = Column(String)  
    people_roster_entries = relationship("Mlb_people_roster_entries", back_populates="player_status_codes")	
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Mlb_leagues(Base):
    __tablename__ = 'leagues'
    __table_args__ = {'schema': 'mlbapi'}
    id = Column(Integer, primary_key = True) 
    name = Column(String) 
    abbreviation = Column(String) 
    name_short = Column(String) 
    org_code = Column(String) 
    level_id = Column(Integer, ForeignKey('mlbapi.levels.id')) 
    sort_order = Column(Integer)  
    levels = relationship("Mlb_levels", back_populates="leagues")
    divisions = relationship("Mlb_divisions", back_populates="leagues")	
    teams = relationship("Mlb_teams", back_populates="leagues")	
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)
		


class Mlb_people_birth(Base):
    __tablename__ = 'people_birth'
    __table_args__ = {'schema': 'mlbapi'}
    id = Column(Integer, ForeignKey('mlbapi.people.id'), primary_key = True) 
    birth_date = Column(Date)
    birth_city = Column(String) 
    birth_state_province = Column(String) 
    birth_country = Column(String)  
    people = relationship( "Mlb_people" , back_populates="people_birth")
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__) 


class Mlb_people_death(Base):
    __tablename__ = 'people_death'
    __table_args__ = {'schema': 'mlbapi'}
    id = Column(Integer, ForeignKey('mlbapi.people.id'), primary_key = True) 
    death_date = Column(Date)
    death_city = Column(String) 
    death_state_province = Column(String) 
    death_country = Column(String)  
    people = relationship( "Mlb_people" , back_populates="people_death")
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__) 


class Mlb_people_names(Base):
    __tablename__ = 'people_names'
    __table_args__ = {'schema': 'mlbapi'}
    id = Column(Integer, ForeignKey('mlbapi.people.id'), primary_key = True) 
    first_name = Column(String) 
    middle_name = Column(String) 
    last_name = Column(String) 
    use_name = Column(String) 
    name_matrilineal = Column(String) 
    boxscore_name = Column(String) 
    nick_name = Column(String) 
    name_title = Column(String) 
    name_slug = Column(String) 
    first_last_name = Column(String) 
    last_first_name = Column(String)  
    people = relationship( "Mlb_people" , back_populates="people_names")
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Mlb_divisions(Base):
    __tablename__ = 'divisions'
    __table_args__ = {'schema': 'mlbapi'}
    id = Column(Integer, primary_key = True) 
    name = Column(String) 
    name_short = Column(String) 
    abbreviation = Column(String) 
    level = Column(Integer, ForeignKey('mlbapi.levels.id')) 
    league = Column(Integer, ForeignKey('mlbapi.leagues.id'))   
    levels = relationship("Mlb_levels", back_populates="divisions")
    leagues = relationship("Mlb_leagues", back_populates="divisions")
    teams = relationship("Mlb_teams", back_populates="divisions")	
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Mlb_people_mutables(Base):
    __tablename__ = 'people_mutables'
    __table_args__ = {'schema': 'mlbapi'}
    id = Column(Integer, ForeignKey('mlbapi.people.id'), primary_key = True) 
    timestamp  = Column(DateTime, primary_key = True) 
    is_player = Column(Boolean) 
    is_verified = Column(Boolean) 
    gender = Column(String) 
    height = Column(String) 
    weight = Column(Integer) 
    primary_position = Column(String) 
    primary_number = Column(Integer) 
    bats = Column(String) 
    throws = Column(String) 
    strike_zone_top  = Column(Numeric)  
    strike_zone_bottom  = Column(Numeric)  
    people = relationship("Mlb_people", back_populates="people_mutables")
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Mlb_people_roster_entries(Base):
    __tablename__ = 'people_roster_entries'
    __table_args__ = {'schema': 'mlbapi'}
    id = Column(Integer, ForeignKey('mlbapi.people.id'), primary_key = True) 
    jersey_number = Column(String) 
    position = Column(String) 
    status = Column(String, ForeignKey('mlbapi.player_status_codes.code')) 
    team = Column(Integer, ForeignKey('mlbapi.teams.id')) 
    is_active = Column(Boolean) 
    start_date = Column(Date)
    end_date = Column(Date)
    status_date = Column(Date)
    is_active_forty_man = Column(Boolean) 
    people = relationship("Mlb_people", back_populates="people_roster_entries")
    teams = relationship("Mlb_teams", back_populates="people_roster_entries")
    player_status_codes = relationship("Mlb_player_status_codes", back_populates="people_roster_entries")
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Mlb_people_roster_status(Base):
    __tablename__ = 'people_roster_status'
    __table_args__ = {'schema': 'mlbapi'}
    id = Column(Integer, ForeignKey('mlbapi.people.id'), primary_key = True) 
    active = Column(Boolean) 
    current_team = Column(Integer, ForeignKey('mlbapi.teams.id')) 
    last_played_date = Column(Date)
    mlb_debut_date = Column(Date) 
    people = relationship("Mlb_people", back_populates="people_roster_status")
    teams = relationship("Mlb_teams", back_populates="people_roster_status")
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)

class Mlb_people_transactions(Base):
    __tablename__ = 'people_transactions'
    __table_args__ = {'schema': 'mlbapi'}
    id = Column(Integer, ForeignKey('mlbapi.people.id'), primary_key = True) 
    from_team_id = Column(Integer , primary_key = True) 
    to_team_id = Column(Integer , primary_key = True) 
    date = Column(Date, primary_key = True)
    effective_date = Column(Date)
    resolution_date = Column(Date)
    is_conditional = Column(Boolean) 
    description = Column(String) 
    people = relationship("Mlb_people", back_populates="people_transactions") 
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Mlb_teams(Base):
    __tablename__ = 'teams'
    __table_args__ = {'schema': 'mlbapi'}
    id = Column(Integer, primary_key = True) 
    name = Column(String) 
    short_name = Column(String) 
    venue = Column(Integer) 
    team_code = Column(String) 
    file_code = Column(String) 
    abbreviation = Column(String) 
    team_name = Column(String) 
    location_name = Column(String) 
    first_year_of_play = Column(Integer) 
    parent_org = Column(Integer) 
    all_star_status = Column(String) 
    active = Column(Boolean) 
    level = Column(Integer, ForeignKey('mlbapi.levels.id')) 
    league = Column(Integer, ForeignKey('mlbapi.leagues.id')) 
    division = Column(Integer, ForeignKey('mlbapi.divisions.id')) 
    levels = relationship("Mlb_levels", back_populates="teams")
    leagues = relationship("Mlb_leagues", back_populates="teams")
    divisions = relationship("Mlb_divisions", back_populates="teams")
    people_roster_entries = relationship("Mlb_people_roster_entries", back_populates="teams")	
    people_roster_status = relationship("Mlb_people_roster_status", back_populates="teams")	 
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)



class Bp_xref(Base): 
    __tablename__ = 'people_xrefids'

    bpid = Column(Integer, primary_key = True)
    mlb = Column(Integer, ForeignKey('mlbapi.people.id')) 
    people = relationship("Mlb_people", back_populates="bpxref")

    __table_args__ = {'schema': 'ingest'}

    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)



## outbound


class Bp_governing_bodies(Base): 
    __tablename__ = 'governing_bodies'
    __table_args__ = {'schema': 'entitas'}
    gov_bod_id  = Column(Integer, primary_key = True)
    gov_bod_name  = Column(String)
    updated_timestamp  = Column(DateTime)  
    levels = relationship("Bp_levels", back_populates="governing_bodies")
    leagues = relationship("Bp_leagues", back_populates="governing_bodies")
    organizations = relationship("Bp_organizations", back_populates="governing_bodies")
    divisions = relationship("Bp_divisions", back_populates="governing_bodies")    
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Bp_people(Base): 
    __tablename__ = 'people'
    __table_args__ = {'schema': 'entitas'}
    bpid  = Column(Integer, primary_key = True)
    use_full_name  = Column(String)
    use_sortable_name  = Column(String)
    use_short_name  = Column(String)
    last_name  = Column(String)
    middle_name  = Column(String)
    middle_initial  = Column(String)
    matrilineal_name  = Column(String)
    first_name  = Column(String)
    updated_timestamp  = Column(DateTime)  
    people_roster_entries = relationship("Bp_people_roster_entries", back_populates="people")
    people_roster_status = relationship("Bp_people_roster_status", back_populates="people")
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Bp_leagues(Base): 
    __tablename__ = 'leagues'
    __table_args__ = {'schema': 'entitas'}
    league_id  = Column(Integer, primary_key = True)
    league_name  = Column(String)
    gov_bod_id  = Column(Integer, ForeignKey('entitas.governing_bodies.gov_bod_id'))
    updated_timestamp  = Column(DateTime)   
    governing_bodies = relationship("Bp_governing_bodies", back_populates="leagues")
    divisions = relationship("Bp_divisions", back_populates="leagues")
    teams = relationship("Bp_teams", back_populates="leagues")
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Bp_levels(Base): 
    __tablename__ = 'levels'
    __table_args__ = {'schema': 'entitas'}
    level_id  = Column(Integer, primary_key = True)
    level_name  = Column(String)
    gov_bod_id  = Column(Integer, ForeignKey('entitas.governing_bodies.gov_bod_id'))
    updated_timestamp  = Column(DateTime)   
    governing_bodies = relationship("Bp_governing_bodies", back_populates="levels")
    teams = relationship("Bp_teams", back_populates="levels")
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Bp_organizations(Base): 
    __tablename__ = 'organizations'
    __table_args__ = {'schema': 'entitas'}
    org_id  = Column(Integer, primary_key = True)
    org_name  = Column(String)
    gov_bod_id  = Column(Integer, ForeignKey('entitas.governing_bodies.gov_bod_id'))
    updated_timestamp  = Column(DateTime)   
    governing_bodies = relationship("Bp_governing_bodies", back_populates="organizations")
    teams = relationship("Bp_teams", back_populates="organizations")
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Bp_divisions(Base): 
    __tablename__ = 'divisions'
    __table_args__ = {'schema': 'entitas'}
    division_id  = Column(Integer, primary_key = True)
    division_name  = Column(String)
    league_id  = Column(Integer, ForeignKey('entitas.leagues.league_id')) 
    gov_bod_id  = Column(Integer, ForeignKey('entitas.governing_bodies.gov_bod_id'))
    updated_timestamp  = Column(DateTime)  
    leagues = relationship("Bp_leagues", back_populates="divisions")
    governing_bodies = relationship("Bp_governing_bodies", back_populates="divisions")
    teams = relationship("Bp_teams", back_populates="divisions")
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)
 
 

class Bp_teams(Base): 
    __tablename__ = 'teams'
    __table_args__ = {'schema': 'entitas'}
    team_id  = Column(Integer, primary_key = True)
    team_name  = Column(String)
    org_id  = Column(Integer, ForeignKey('entitas.organizations.org_id'))
    league_id  = Column(Integer, ForeignKey('entitas.leagues.league_id'))
    level_id  = Column(Integer, ForeignKey('entitas.levels.level_id')) 
    division_id  = Column(Integer, ForeignKey('entitas.divisions.division_id'))
    updated_timestamp  = Column(DateTime)  
    organizations = relationship("Bp_organizations", back_populates="teams")
    leagues = relationship("Bp_leagues", back_populates="teams")
    levels = relationship("Bp_levels", back_populates="teams")
    divisions = relationship("Bp_divisions", back_populates="teams")
    people_roster_entries = relationship("Bp_people_roster_entries", back_populates="teams")
    people_roster_status = relationship("Bp_people_roster_status", back_populates="teams")
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Bp_people_roster_entries(Base): 
    __tablename__ = 'people_roster_entries'
    __table_args__ = {'schema': 'entitas'}
    bpid  = Column(Integer, ForeignKey('entitas.people.bpid'), primary_key = True)
    jersey_number  = Column(String)
    position  = Column(String)
    status  = Column(String)
    team  = Column(Integer, ForeignKey('entitas.teams.team_id'))
    is_active = Column(Boolean)
    start_date = Column(Date)
    end_date = Column(Date)
    status_date = Column(Date)
    is_active_forty_man = Column(Boolean)
    updated_timestamp  = Column(DateTime)  
    people = relationship("Bp_people", back_populates="people_roster_entries")
    teams = relationship("Bp_teams", back_populates="people_roster_entries")
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Bp_people_roster_status(Base): 
    __tablename__ = 'people_roster_status'
    __table_args__ = {'schema': 'entitas'}
    bpid  = Column(Integer, ForeignKey('entitas.people.bpid'), primary_key = True)
    active = Column(Boolean)
    current_team  = Column(Integer, ForeignKey('entitas.teams.team_id'))
    last_played_date = Column(Date)
    mlb_debut_date = Column(Date)
    updated_timestamp  = Column(DateTime)  
    people = relationship("Bp_people", back_populates="people_roster_status")
    teams = relationship("Bp_teams", back_populates="people_roster_status")
    def __repr__(self):
        return "{}({!r})".format(self.__class__.__name__, self.__dict__)




