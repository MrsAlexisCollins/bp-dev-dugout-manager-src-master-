# defines and maps the database objects in CAGE and DUGOUT

import sqlalchemy
from . import settings

from sqlalchemy import Column, Integer, String , ForeignKey, DateTime, Boolean, Date, Numeric
from sqlalchemy.ext.declarative import declarative_base 
from sqlalchemy.orm import relationship

Base = declarative_base()

## inbound
class Mlb_people_search(Base): # materialzed view, one row per player, don't bother with other FKs, all data is here
	__tablename__ = 'people_search'
	__table_args__ = {'schema': 'mlbapi'}
	bpid = Column(Integer  , primary_key = True)  
	active = Column(Boolean)
	on_40 = Column(Boolean)
	team_id = Column(Integer)  
	org_id = Column(Integer) 
	birth_date = Column(Date)
	death_date = Column(Date)
	throws = Column(String)
	bats = Column(String)
	height = Column(Integer)  
	weight = Column(Integer)
	boxscore_name = Column(String)
	first_name_proper = Column(String)
	first_name = Column(String)
	middle_name = Column(String)
	last_name = Column(String)
	matrilineal_name = Column(String)
	full_name = Column(String)
	sortable_name = Column(String)
	birth_city = Column(String)
	birth_state_province = Column(String)
	birth_country = Column(String) 
	status = Column(String)
	position = Column(String)
	jersey_number = Column(Integer)
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Mlb_stats_catching(Base):
	__tablename__ = 'stats_catching'
	__table_args__ = {'schema': 'mlbapi'}
	id = Column(Integer, ForeignKey('mlbapi.people.id'),  primary_key = True)
	season = Column(Integer, primary_key = True)
	team = Column(Integer, ForeignKey('mlbapi.teams.id'), primary_key = True)
	timestamp = Column(DateTime, primary_key = True)
	games_played = Column(Integer)
	runs = Column(Integer)
	home_runs = Column(Integer)
	strike_outs = Column(Integer)
	base_on_balls = Column(Integer)
	intentional_walks = Column(Integer)
	hits = Column(Integer)
	avg = Column(Numeric)
	at_bats = Column(Integer)
	obp = Column(Numeric)
	slg = Column(Numeric)
	ops = Column(Numeric)
	caught_stealing = Column(Integer)
	stolen_bases = Column(Integer)
	stolen_base_percentage = Column(Numeric)
	era = Column(Numeric)
	earned_runs = Column(Integer)
	whip = Column(Numeric)
	batters_faced = Column(Integer)
	games_pitched = Column(Integer)
	hit_batsmen = Column(Integer)
	wild_pitches = Column(Integer)
	pickoffs = Column(Integer)
	total_bases = Column(Integer)
	strikeout_walk_ratio = Column(Numeric)
	strikeouts_per_9_inn = Column(Numeric)
	walks_per_9_inn = Column(Numeric)
	hits_per_9_inn = Column(Numeric)
	catchers_interference = Column(Integer)
	sac_bunts = Column(Integer)
	sac_flies = Column(Integer)
	people = relationship("Mlb_people", back_populates="stats_catching")	
	teams = relationship("Mlb_teams", back_populates="stats_catching")	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Mlb_stats_fielding(Base):
	__tablename__ = 'stats_fielding'
	__table_args__ = {'schema': 'mlbapi'}
	id = Column(Integer, ForeignKey('mlbapi.people.id'),  primary_key = True)
	season = Column(Integer, primary_key = True)
	team = Column(Integer, ForeignKey('mlbapi.teams.id'), primary_key = True)
	position = Column(String, primary_key = True)
	timestamp = Column(DateTime, primary_key = True)
	assists = Column(Integer)
	put_outs = Column(Integer)
	errors = Column(Integer)
	chances = Column(Integer)
	fielding = Column(Numeric)
	range_factor_per_game = Column(Numeric)
	range_factor_per_9_inn = Column(Numeric)
	innings = Column(Numeric)
	games = Column(Integer)
	games_started = Column(Integer)
	double_plays = Column(Integer)
	triple_plays = Column(Integer)
	throwing_errors = Column(Integer)
	people = relationship("Mlb_people", back_populates="stats_fielding")	
	teams = relationship("Mlb_teams", back_populates="stats_fielding")	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Mlb_stats_hitting(Base):
	__tablename__ = 'stats_hitting'
	__table_args__ = {'schema': 'mlbapi'}
	id = Column(Integer, ForeignKey('mlbapi.people.id'),  primary_key = True)
	season = Column(Integer, primary_key = True)
	team = Column(Integer, ForeignKey('mlbapi.teams.id'), primary_key = True)
	timestamp = Column(DateTime, primary_key = True)
	games_played = Column(Integer)
	ground_outs = Column(Integer)
	air_outs = Column(Integer)
	runs = Column(Integer)
	doubles = Column(Integer)
	triples = Column(Integer)
	home_runs = Column(Integer)
	strike_outs = Column(Integer)
	base_on_balls = Column(Integer)
	intentional_walks = Column(Integer)
	hits = Column(Integer)
	hit_by_pitch = Column(Integer)
	avg = Column(Numeric)
	at_bats = Column(Integer)
	obp = Column(Numeric)
	slg = Column(Numeric)
	ops = Column(Numeric)
	caught_stealing = Column(Integer)
	stolen_bases = Column(Integer)
	stolen_base_percentage = Column(Numeric)
	ground_into_double_play = Column(Integer)
	number_of_pitches = Column(Integer)
	plate_appearances = Column(Integer)
	total_bases = Column(Integer)
	rbi = Column(Integer)
	left_on_base = Column(Integer)
	sac_bunts = Column(Integer)
	sac_flies = Column(Integer)
	babip = Column(Numeric)
	ground_outs_to_airouts = Column(Numeric)
	at_bats_per_home_run = Column(Numeric)
	people = relationship("Mlb_people", back_populates="stats_hitting")	
	teams = relationship("Mlb_teams", back_populates="stats_hitting")	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Mlb_stats_pitching(Base):
	__tablename__ = 'stats_pitching'
	__table_args__ = {'schema': 'mlbapi'}
	id = Column(Integer, ForeignKey('mlbapi.people.id'),  primary_key = True)
	season = Column(Integer, primary_key = True)
	team = Column(Integer, ForeignKey('mlbapi.teams.id'), primary_key = True)
	timestamp = Column(DateTime, primary_key = True)
	games_played = Column(Integer)
	games_started = Column(Integer)
	ground_outs = Column(Integer)
	air_outs = Column(Integer)
	runs = Column(Integer)
	doubles = Column(Integer)
	triples = Column(Integer)
	home_runs = Column(Integer)
	strike_outs = Column(Integer)
	base_on_balls = Column(Integer)
	intentional_walks = Column(Integer)
	hits = Column(Integer)
	avg = Column(Numeric)
	at_bats = Column(Integer)
	obp = Column(Numeric)
	slg = Column(Numeric)
	ops = Column(Numeric)
	caught_stealing = Column(Integer)
	stolen_bases = Column(Integer)
	stolen_base_percentage = Column(Numeric)
	ground_into_double_play = Column(Integer)
	number_of_pitches = Column(Integer)
	era = Column(Numeric)
	innings_pitched = Column(Numeric)
	wins = Column(Integer)
	losses = Column(Integer)
	saves = Column(Integer)
	save_opportunities = Column(Integer)
	holds = Column(Integer)
	blown_saves = Column(Integer)
	earned_runs = Column(Integer)
	whip = Column(Numeric)
	batters_faced = Column(Integer)
	games_pitched = Column(Integer)
	complete_games = Column(Integer)
	shutouts = Column(Integer)
	strikes = Column(Integer)
	strike_percentage = Column(Numeric)
	hit_batsmen = Column(Integer)
	balks = Column(Integer)
	wild_pitches = Column(Integer)
	pickoffs = Column(Integer)
	total_bases = Column(Integer)
	ground_outs_to_airouts = Column(Numeric)
	win_percentage = Column(Numeric)
	pitches_per_inning = Column(Numeric)
	games_finished = Column(Integer)
	strikeout_walk_ratio = Column(Numeric)
	strikeouts_per_9_inn = Column(Numeric)
	walks_per_9_inn = Column(Numeric)
	hits_per_9_inn = Column(Numeric)
	runs_scored_per_9 = Column(Numeric)
	home_runs_per_9 = Column(Numeric)
	inherited_runners = Column(Integer)
	inherited_runners_scored = Column(Integer)
	people = relationship("Mlb_people", back_populates="stats_pitching")	
	teams = relationship("Mlb_teams", back_populates="stats_pitching")	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)



class Mlb_team_rosters(Base):
	__tablename__ = 'team_rosters'
	__table_args__ = {'schema': 'mlbapi'}

	team = Column(Integer, ForeignKey('mlbapi.teams.id'), primary_key = True) 
	timestamp = Column(DateTime, primary_key = True)  
	player = Column(Integer, ForeignKey('mlbapi.people.id'), primary_key = True)
	jersey_number  = Column(Integer) 
	position  = Column(String) 
	status  = Column(String)  
	people = relationship("Mlb_people", back_populates="team_rosters")	
	teams = relationship("Mlb_teams", back_populates="team_rosters")	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


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
	team_rosters = relationship("Mlb_team_rosters", back_populates="people")
	
	stats_catching = relationship("Mlb_stats_catching", back_populates="people")
	stats_hitting = relationship("Mlb_stats_hitting", back_populates="people")
	stats_fielding = relationship("Mlb_stats_fielding", back_populates="people")
	stats_pitching = relationship("Mlb_stats_pitching", back_populates="people")
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
	team_rosters = relationship("Mlb_team_rosters", back_populates="teams")
	stats_catching = relationship("Mlb_stats_catching", back_populates="teams")
	stats_hitting = relationship("Mlb_stats_hitting", back_populates="teams")
	stats_fielding = relationship("Mlb_stats_fielding", back_populates="teams")
	stats_pitching = relationship("Mlb_stats_pitching", back_populates="teams")
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)



class Bp_xref(Base): 
	__tablename__ = 'people_xrefids'
	__table_args__ = {'schema': 'ingest'}

	bpid = Column(Integer, primary_key = True)
	mlb = Column(Integer, ForeignKey('mlbapi.people.id')) 
	people = relationship("Mlb_people", back_populates="bpxref") 


	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)

class Pecota_book_list(Base):
	__tablename__ = 'book_list_cms'
	__table_args__ = {'schema': 'pecota'}
	playerid = Column(Integer )
	position = Column(String)
	team = Column(String)
	listid = Column(Integer , primary_key= True)
	lastname = Column(String)
	firstname = Column(String)
	fullname  = Column(String)
	oneline	  = Column(Boolean)
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)

class Pecota_raw_batters(Base):
	__tablename__ = 'batters_raw'
	__table_args__ = {'schema': 'pecota'}

	batter 	 = Column(Integer, primary_key = True)
	proj_year  = Column(Integer, primary_key = True)
	vintage = Column(DateTime, primary_key = True)
	proj_dRC_plus = Column(Numeric)
	proj_dRAA_PA = Column(Numeric)
	HR_proj_pneu = Column(Numeric)
	HR_proj_pneu_sd = Column(Numeric)
	B3_proj_pneu = Column(Numeric)
	B3_proj_pneu_sd = Column(Numeric)
	B2_proj_pneu = Column(Numeric)
	B2_proj_pneu_sd = Column(Numeric)
	B1_proj_pneu = Column(Numeric)
	B1_proj_pneu_sd = Column(Numeric)
	ROE_proj_pneu = Column(Numeric)
	ROE_proj_pneu_sd = Column(Numeric)
	HBP_proj_pneu = Column(Numeric)
	HBP_proj_pneu_sd = Column(Numeric)
	BB_proj_pneu = Column(Numeric)
	BB_proj_pneu_sd = Column(Numeric)
	SO_proj_pneu = Column(Numeric)
	SO_proj_pneu_sd = Column(Numeric)
	GB_proj_pneu = Column(Numeric)
	GB_proj_pneu_sd = Column(Numeric)
	OUT_proj_pneu = Column(Numeric)


	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Pecota_raw_pitchers(Base):
	__tablename__ = 'pitchers_raw'
	__table_args__ = {'schema': 'pecota'}
	pitcher = Column(Integer, primary_key = True)
	proj_year  = Column(Integer, primary_key = True)
	vintage = Column(DateTime, primary_key = True)
	DRA_final= Column(Numeric)
	HR_proj_pneu = Column(Numeric)
	HR_proj_pneu_sd = Column(Numeric)
	B3_proj_pneu = Column(Numeric)
	B3_proj_pneu_sd = Column(Numeric)
	B2_proj_pneu = Column(Numeric)
	B2_proj_pneu_sd = Column(Numeric)
	B1_proj_pneu = Column(Numeric)
	B1_proj_pneu_sd = Column(Numeric)
	ROE_proj_pneu = Column(Numeric)
	ROE_proj_pneu_sd = Column(Numeric)
	HBP_proj_pneu = Column(Numeric)
	HBP_proj_pneu_sd = Column(Numeric)
	BB_proj_pneu = Column(Numeric)
	BB_proj_pneu_sd = Column(Numeric)
	SO_proj_pneu = Column(Numeric)
	SO_proj_pneu_sd = Column(Numeric)
	OUT_proj_pneu = Column(Numeric)
	DRA_minus= Column(Numeric)
	cFIP= Column(Numeric)
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)

class Pecota_raw_fielders(Base):
	__tablename__ = 'fielders_raw'
	__table_args__ = {'schema': 'pecota'}
	fielder = Column(Numeric, primary_key = True)
	pos = Column(String, primary_key = True)
	proj_year = Column(Numeric, primary_key = True)
	vintage = Column(DateTime, primary_key = True)
	fraa_100_proj = Column(Numeric)
	fraa_100_proj_sd  = Column(Numeric)

	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)

class Pecota_raw_runners(Base):
	__tablename__ = 'runners_raw'
	__table_args__ = {'schema': 'pecota'}
	run_id = Column(Numeric, primary_key = True)
	proj_year = Column(Numeric, primary_key = True)
	vintage = Column(DateTime, primary_key = True)
	brr_50_proj = Column(Numeric)
	brr_50_proj_sd  = Column(Numeric)

	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Euston_contracts(Base): 
	__tablename__ = 'contracts'
	__table_args__ = {'schema': 'euston'}
	contract_id = Column(Integer, primary_key = True)
	bpid = Column(Integer)
	signed_date = Column(Date)
	terminated_date = Column(Date)
	duration_years_max = Column(Integer)
	duration_years_base = Column(Integer)
	duration_years_actual = Column(Integer)
	signing_org = Column(String)
	first_season = Column(Integer)
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)

## outbound



 
class Bp_stats_catching(Base):
	__tablename__ = 'stats_catching'
	__table_args__ = {'schema': 'stats'}
	bpid = Column(Integer, ForeignKey('entitas.people.bpid'), primary_key = True)
	season = Column(Integer, primary_key = True)
	team_id = Column(Integer, ForeignKey('entitas.teams.team_id'),  primary_key = True)
	timestamp = Column(DateTime, primary_key = True)
	games_played = Column(Integer)
	runs = Column(Integer)
	home_runs = Column(Integer)
	strike_outs = Column(Integer)
	base_on_balls = Column(Integer)
	intentional_walks = Column(Integer)
	hits = Column(Integer)
	avg = Column(Numeric)
	at_bats = Column(Integer)
	obp = Column(Numeric)
	slg = Column(Numeric)
	ops = Column(Numeric)
	caught_stealing = Column(Integer)
	stolen_bases = Column(Integer)
	stolen_base_percentage = Column(Numeric)
	era = Column(Numeric)
	earned_runs = Column(Integer)
	whip = Column(Numeric)
	batters_faced = Column(Integer)
	games_pitched = Column(Integer)
	hit_batsmen = Column(Integer)
	wild_pitches = Column(Integer)
	pickoffs = Column(Integer)
	total_bases = Column(Integer)
	strikeout_walk_ratio = Column(Numeric)
	strikeouts_per_9_inn = Column(Numeric)
	walks_per_9_inn = Column(Numeric)
	hits_per_9_inn = Column(Numeric)
	catchers_interference = Column(Integer)
	sac_bunts = Column(Integer)
	sac_flies = Column(Integer)
	people = relationship("Bp_people", back_populates="stats_catching")
	teams = relationship("Bp_teams", back_populates="stats_catching")
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Bp_stats_fielding(Base):
	__tablename__ = 'stats_fielding'
	__table_args__ = {'schema': 'stats'}
	bpid = Column(Integer, ForeignKey('entitas.people.bpid'), primary_key = True)
	season = Column(Integer, primary_key = True)
	team_id = Column(Integer, ForeignKey('entitas.teams.team_id'),  primary_key = True)
	position = Column(String, primary_key = True)
	timestamp = Column(DateTime, primary_key = True)
	assists = Column(Integer)
	put_outs = Column(Integer)
	errors = Column(Integer)
	chances = Column(Integer)
	fielding = Column(Numeric)
	range_factor_per_game = Column(Numeric)
	range_factor_per_9_inn = Column(Numeric)
	innings = Column(Numeric)
	games = Column(Integer)
	games_started = Column(Integer)
	double_plays = Column(Integer)
	triple_plays = Column(Integer)
	throwing_errors = Column(Integer)
	people = relationship("Bp_people", back_populates="stats_fielding")
	teams = relationship("Bp_teams", back_populates="stats_fielding")
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Bp_stats_hitting(Base):
	__tablename__ = 'stats_hitting'
	__table_args__ = {'schema': 'stats'}
	bpid = Column(Integer, ForeignKey('entitas.people.bpid'), primary_key = True)
	season = Column(Integer, primary_key = True)
	team_id = Column(Integer, ForeignKey('entitas.teams.team_id'),  primary_key = True)
	timestamp = Column(DateTime, primary_key = True)
	games_played = Column(Integer)
	ground_outs = Column(Integer)
	air_outs = Column(Integer)
	runs = Column(Integer)
	doubles = Column(Integer)
	triples = Column(Integer)
	home_runs = Column(Integer)
	strike_outs = Column(Integer)
	base_on_balls = Column(Integer)
	intentional_walks = Column(Integer)
	hits = Column(Integer)
	hit_by_pitch = Column(Integer)
	avg = Column(Numeric)
	at_bats = Column(Integer)
	obp = Column(Numeric)
	slg = Column(Numeric)
	ops = Column(Numeric)
	caught_stealing = Column(Integer)
	stolen_bases = Column(Integer)
	stolen_base_percentage = Column(Numeric)
	ground_into_double_play = Column(Integer)
	number_of_pitches = Column(Integer)
	plate_appearances = Column(Integer)
	total_bases = Column(Integer)
	rbi = Column(Integer)
	left_on_base = Column(Integer)
	sac_bunts = Column(Integer)
	sac_flies = Column(Integer)
	babip = Column(Numeric)
	ground_outs_to_airouts = Column(Numeric)
	at_bats_per_home_run = Column(Numeric)
	people = relationship("Bp_people", back_populates="stats_hitting")
	teams = relationship("Bp_teams", back_populates="stats_hitting")
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Bp_stats_pitching(Base):
	__tablename__ = 'stats_pitching'
	__table_args__ = {'schema': 'stats'}
	bpid = Column(Integer, ForeignKey('entitas.people.bpid'), primary_key = True)
	season = Column(Integer, primary_key = True)
	team_id = Column(Integer, ForeignKey('entitas.teams.team_id'),  primary_key = True)
	timestamp = Column(DateTime, primary_key = True)
	games_played = Column(Integer)
	games_started = Column(Integer)
	ground_outs = Column(Integer)
	air_outs = Column(Integer)
	runs = Column(Integer)
	doubles = Column(Integer)
	triples = Column(Integer)
	home_runs = Column(Integer)
	strike_outs = Column(Integer)
	base_on_balls = Column(Integer)
	intentional_walks = Column(Integer)
	hits = Column(Integer)
	avg = Column(Numeric)
	at_bats = Column(Integer)
	obp = Column(Numeric)
	slg = Column(Numeric)
	ops = Column(Numeric)
	caught_stealing = Column(Integer)
	stolen_bases = Column(Integer)
	stolen_base_percentage = Column(Numeric)
	ground_into_double_play = Column(Integer)
	number_of_pitches = Column(Integer)
	era = Column(Numeric)
	innings_pitched = Column(Numeric)
	wins = Column(Integer)
	losses = Column(Integer)
	saves = Column(Integer)
	save_opportunities = Column(Integer)
	holds = Column(Integer)
	blown_saves = Column(Integer)
	earned_runs = Column(Integer)
	whip = Column(Numeric)
	batters_faced = Column(Integer)
	games_pitched = Column(Integer)
	complete_games = Column(Integer)
	shutouts = Column(Integer)
	strikes = Column(Integer)
	strike_percentage = Column(Numeric)
	hit_batsmen = Column(Integer)
	balks = Column(Integer)
	wild_pitches = Column(Integer)
	pickoffs = Column(Integer)
	total_bases = Column(Integer)
	ground_outs_to_airouts = Column(Numeric)
	win_percentage = Column(Numeric)
	pitches_per_inning = Column(Numeric)
	games_finished = Column(Integer)
	strikeout_walk_ratio = Column(Numeric)
	strikeouts_per_9_inn = Column(Numeric)
	walks_per_9_inn = Column(Numeric)
	hits_per_9_inn = Column(Numeric)
	runs_scored_per_9 = Column(Numeric)
	home_runs_per_9 = Column(Numeric)
	inherited_runners = Column(Integer)
	inherited_runners_scored = Column(Integer)
	people = relationship("Bp_people", back_populates="stats_pitching")
	teams = relationship("Bp_teams", back_populates="stats_pitching")
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)



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
	team_rosters = relationship("Bp_team_rosters", back_populates="people")
	stats_catching = relationship("Bp_stats_catching", back_populates="people")
	stats_hitting = relationship("Bp_stats_hitting", back_populates="people")
	stats_fielding = relationship("Bp_stats_fielding", back_populates="people")
	stats_pitching = relationship("Bp_stats_pitching", back_populates="people")
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
	team_rosters = relationship("Bp_team_rosters", back_populates="teams")
	stats_catching = relationship("Bp_stats_catching", back_populates="teams")
	stats_hitting = relationship("Bp_stats_hitting", back_populates="teams")
	stats_fielding = relationship("Bp_stats_fielding", back_populates="teams")
	stats_pitching = relationship("Bp_stats_pitching", back_populates="teams")
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



class Bp_team_rosters(Base):
	__tablename__ = 'team_rosters'
	__table_args__ = {'schema': 'entitas'}

	team = Column(Integer, ForeignKey('entitas.teams.team_id'), primary_key = True) 
	timestamp = Column(DateTime, primary_key = True)  
	player = Column(Integer, ForeignKey('entitas.people.bpid'), primary_key = True)
	jersey_number  = Column(Integer) 
	position  = Column(String) 
	status  = Column(String)  
	updated_timestamp  = Column(DateTime)  
	people = relationship("Bp_people", back_populates="team_rosters")	
	teams = relationship("Bp_teams", back_populates="team_rosters")	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)



class Bp_pecota_hitting_raw(Base):
	__tablename__ = 'pecota_hitting_raw'
	__table_args__ = {'schema': 'stats'}
	id = Column(Integer,primary_key = True)
	bpid   = Column(Integer, ForeignKey('entitas.people.bpid'))
	season  = Column(Integer)
	created_datetime = Column(DateTime)  
	drc_plus = Column(Numeric) 
	draa_pa = Column(Numeric) 
	hr = Column(Numeric) 
	hr_sd = Column(Numeric) 
	b3 = Column(Numeric) 
	b3_sd = Column(Numeric) 
	b2 = Column(Numeric) 
	b2_sd = Column(Numeric) 
	b1 = Column(Numeric) 
	b1_sd = Column(Numeric) 
	roe = Column(Numeric) 
	roe_sd = Column(Numeric) 
	hbp = Column(Numeric) 
	hbp_sd = Column(Numeric) 
	bb = Column(Numeric) 
	bb_sd = Column(Numeric) 
	so = Column(Numeric) 
	so_sd = Column(Numeric) 
	gb = Column(Numeric) 
	gb_sd = Column(Numeric) 
	out = Column(Numeric) 
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)

class Bp_pecota_pitching_raw(Base):
	__tablename__ = 'pecota_pitching_raw'
	__table_args__ = {'schema': 'stats'}
	id = Column(Integer,primary_key = True)
	bpid = Column(Integer, ForeignKey('entitas.people.bpid'))
	season = Column(Integer)
	created_datetime = Column(DateTime)  
	dra = Column(Numeric) 
	dra_minus = Column(Numeric) 
	cfip = Column(Numeric) 
	hr = Column(Numeric) 
	hr_sd = Column(Numeric) 
	b3 = Column(Numeric) 
	b3_sd = Column(Numeric) 
	b2 = Column(Numeric) 
	b2_sd = Column(Numeric) 
	b1 = Column(Numeric) 
	b1_sd = Column(Numeric) 
	roe = Column(Numeric) 
	roe_sd = Column(Numeric) 
	hbp = Column(Numeric) 
	hbp_sd = Column(Numeric) 
	bb = Column(Numeric) 
	bb_sd = Column(Numeric) 
	so = Column(Numeric) 
	so_sd = Column(Numeric) 
	out = Column(Numeric) 
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)

class People_contracts(Base): 
	__tablename__ = 'people_contracts'
	__table_args__ = {'schema': 'entitas'}
	contract_id = Column(Integer, primary_key = True)
	bpid = Column(Integer)
	signed_date = Column(Date)
	terminated_date = Column(Date)
	duration_years_max = Column(Integer)
	duration_years_base = Column(Integer)
	duration_years_actual = Column(Integer)
	signing_org_id = Column(Integer, ForeignKey('entitas.organizations.org_id'))
	first_season = Column(Integer)
	updated_timestamp = Column(DateTime)
	def __repr__(self): 
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)

class Xref_org(Base): 
	__tablename__ = 'org_refs'
	__table_args__ = {'schema': 'xrefs'}
	org_ref_id = Column(Integer, primary_key = True)
	org_id = Column(Integer)
	xref_type = Column(String)
	xref_id = Column(String)
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Bp_people_search(Base):  
	__tablename__ = 'people_search'
	__table_args__ = {'schema': 'entitas'}
	bpid = Column(Integer  , primary_key = True)  
	active = Column(Boolean)
	on_40 = Column(Boolean)
	team_id = Column(Integer)  
	org_id = Column(Integer)  
	birth_date = Column(Date)
	death_date = Column(Date)
	throws = Column(String)
	bats = Column(String)
	height = Column(Integer)  
	weight = Column(Integer)
	boxscore_name = Column(String)
	first_name_proper = Column(String)
	first_name = Column(String)
	middle_name = Column(String)
	last_name = Column(String)
	matrilineal_name = Column(String)
	full_name = Column(String)
	sortable_name = Column(String)
	birth_city = Column(String)
	birth_state_province = Column(String)
	birth_country = Column(String) 
	status = Column(String)
	position = Column(String)
	jersey_number = Column(Integer)
	updated_timestamp = Column(DateTime)
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Bp_book_list(Base):
	__tablename__ = 'book_list'
	__table_args__ = {'schema': 'entitas'}
	bpid = Column(Integer, primary_key = True)
	position = Column(String)
	org_id = Column(Integer)
	online = Column(Boolean)
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)



class Bp_pecota_fielders_raw (Base):
	__tablename__ = 'pecota_fielding_raw'
	__table_args__ = {'schema': 'stats'}

	id = Column(Integer,primary_key = True)
	bpid = Column(Integer, ForeignKey('entitas.people.bpid'))
	season = Column(Integer)
	position = Column(Integer )
	created_datetime = Column(DateTime)  
	fraa_100 = Column(Numeric)
	fraa_100_sd  = Column(Numeric)

	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)

class Bp_pecota_runners_raw (Base):
	__tablename__ = 'pecota_running_raw'
	__table_args__ = {'schema': 'stats'}

	id = Column(Integer,primary_key = True)
	bpid = Column(Integer, ForeignKey('entitas.people.bpid'))
	season = Column(Integer)
	created_datetime = Column(DateTime)  
	brr_50  = Column(Numeric)
	brr_50_sd  = Column(Numeric)
	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)

