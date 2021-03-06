import sqlalchemy
from . import settings

from sqlalchemy import Column, Integer, String , ForeignKey, DateTime, Boolean, Date, Numeric
from sqlalchemy.ext.declarative import declarative_base 
from sqlalchemy.orm import relationship

Base = declarative_base()

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
	__tablename__ = 'pecota_bat_park_neutral_deciles'
	__table_args__ = {'schema': 'jjudge'}

	batter 	 = Column(Integer, primary_key = True)
	proj_year  = Column(Integer, primary_key = True)
	vintage = Column(DateTime, primary_key = True)
	decile  = Column(Integer, primary_key = True)
	DRC = Column(Numeric)
	dRAA_PA = Column(Numeric)
	HR_proj_pneu = Column(Numeric)
	B3_proj_pneu = Column(Numeric)
	B2_proj_pneu = Column(Numeric)
	B1_proj_pneu = Column(Numeric)
	ROE_proj_pneu = Column(Numeric)
	HBP_proj_pneu = Column(Numeric)
	BB_proj_pneu = Column(Numeric)
	SO_proj_pneu = Column(Numeric)
	GB_proj_pneu = Column(Numeric)
	OUT_proj_pneu = Column(Numeric)


	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)




class Pecota_padj_batters(Base):
	__tablename__ = 'pecota_bat_park_adjusted_deciles'
	__table_args__ = {'schema': 'jjudge'}

	batter 	 = Column(Integer, primary_key = True)
	proj_year  = Column(Integer, primary_key = True)
	vintage = Column(DateTime, primary_key = True)
	decile  = Column(Integer, primary_key = True)
	DRC = Column(Numeric)
	dRAA_PA = Column(Numeric)
	HR_proj_padj = Column(Numeric)
	B3_proj_padj = Column(Numeric)
	B2_proj_padj = Column(Numeric)
	B1_proj_padj = Column(Numeric)
	ROE_proj_padj = Column(Numeric)
	HBP_proj_padj = Column(Numeric)
	BB_proj_padj = Column(Numeric)
	SO_proj_padj = Column(Numeric)
	GB_proj_padj = Column(Numeric)
	OUT_proj_padj = Column(Numeric)


	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Pecota_raw_pitchers(Base):
	__tablename__ = 'pecota_pit_park_neutral_deciles'
	__table_args__ = {'schema': 'jjudge'}
	pitcher = Column(Integer, primary_key = True)
	proj_year  = Column(Integer, primary_key = True)
	decile  = Column(Integer, primary_key = True)
	vintage = Column(DateTime, primary_key = True)
	proj_DRA = Column(Numeric)
	HR_proj_pneu = Column(Numeric)
	B3_proj_pneu = Column(Numeric)
	B2_proj_pneu = Column(Numeric)
	B1_proj_pneu = Column(Numeric)
	ROE_proj_pneu = Column(Numeric)
	HBP_proj_pneu = Column(Numeric)
	BB_proj_pneu = Column(Numeric)
	SO_proj_pneu = Column(Numeric)
	OUT_proj_pneu = Column(Numeric)
	GB_proj_pneu = Column(Numeric)
	proj_DRA_minus= Column(Numeric)
	proj_cFIP = Column(Numeric)
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)



class Pecota_padj_pitchers(Base):
	__tablename__ = 'pecota_pit_park_adjusted_deciles'
	__table_args__ = {'schema': 'jjudge'}
	pitcher = Column(Integer, primary_key = True)
	proj_year  = Column(Integer, primary_key = True)
	vintage = Column(DateTime, primary_key = True)
	decile  = Column(Integer, primary_key = True)
	proj_DRA = Column(Numeric)
	HR_proj_padj = Column(Numeric)
	B3_proj_padj = Column(Numeric)
	B2_proj_padj = Column(Numeric)
	B1_proj_padj = Column(Numeric)
	ROE_proj_padj = Column(Numeric)
	HBP_proj_padj = Column(Numeric)
	BB_proj_padj = Column(Numeric)
	SO_proj_padj = Column(Numeric)
	OUT_proj_padj = Column(Numeric)
	GB_proj_padj = Column(Numeric)
	proj_DRA_minus= Column(Numeric)
	proj_cFIP = Column(Numeric)
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


class Pecota_runner_binomials(Base):
	__tablename__ = 'runner_binomials'
	__table_args__ = {'schema': 'pecota'}
	year_proj = Column(Integer, primary_key = True)
	bat_id = Column(Integer, primary_key = True)
	sba_var = Column('$SBA_VAR',Numeric)
	sba = Column('$SBA',Numeric)
	sb_var = Column('$SB_VAR',Numeric)
	sb = Column('$SB',Numeric)


	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)




class Pecota_fraa_cda(Base):
	__tablename__ = 'pecota_catcher_fraa_deciles'
	__table_args__ = {'schema': 'jjudge'}
	proj_year = Column(Integer, primary_key = True)
	playerid = Column(Integer, primary_key = True)
	decile = Column(Integer, primary_key = True)
	lvl = Column(String)
	csaa_proj = Column(Numeric) 
	epaa_proj = Column(Numeric) 
	sraa_proj = Column(Numeric) 
	traa_proj = Column(Numeric) 
	vintage = Column(DateTime) 
	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Pecota_fielder_binomials(Base):
	__tablename__ = 'pecota_fielder_binomials'
	__table_args__ = {'schema': 'pecota'}

	year_proj = Column(Integer, primary_key = True)
	fld_id = Column(Integer, primary_key = True)
	years = Column(Integer)
	pos = Column(Integer, primary_key = True)
	ch = Column(Numeric) 
	ch_weighted = Column(Numeric) 
	pm_rt_var = Column(Numeric) 
	pm_rt = Column(Numeric) 
	pm_rt_lg = Column(Numeric) 
	pm_rt_raw = Column(Numeric) 
	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)

class Pecota_of_assists(Base):
	__tablename__ = 'pecota_of_assists'
	__table_args__ = {'schema': 'pecota'}
	year_proj = Column(Integer, primary_key = True)
	fld_id = Column(Integer, primary_key = True)
	years = Column(Integer)
	pos = Column(Integer, primary_key = True)
	z = Column(Numeric) 
	z_reg = Column(Numeric) 
	ast_rt_mlb = Column(Numeric) 
	ast150 = Column(Numeric) 
	mlb_ast_rt = Column(Numeric) 
	mlb_sd_rt = Column(Numeric) 
	runs_per_ast = Column(Numeric) 
	runs_per_g = Column(Numeric) 
	of_ass = Column(Numeric) 
	g_of = Column(Numeric) 
	ast_rt = Column(Numeric) 
	ast_rt_lg = Column(Numeric) 
	ast_sd_lg = Column(Numeric) 
	g_of_adj = Column(Numeric) 
	g_of_lg_adj = Column(Numeric) 
	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


#### legacy stats

class Legacy_batting_daily(Base):
	__tablename__ = 'bat_master'
	__table_args__ = {'schema': 'legacy_stats'}
	batter= Column(Integer, primary_key = True)
	year= Column(Integer, primary_key = True)
	lvl    = Column(String, primary_key = True)
	team   = Column(String, primary_key = True)
	version_date = Column(DateTime, primary_key = True)
	pa   = Column(Numeric) 
	drc_plus = Column(Numeric) 
	drc_raa = Column(Numeric)  
	fraa = Column(Numeric) 
	brr = Column(Numeric) 
	pos_adj = Column(Numeric) 
	rep_level = Column(Numeric) 
	drc_warp = Column(Numeric) 
	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Legacy_pitching_daily(Base):
	__tablename__ = 'pit_master'
	__table_args__ = {'schema': 'legacy_stats'}
	pitcher= Column(Integer, primary_key = True)
	year= Column(Integer, primary_key = True)
	lvl    = Column(String, primary_key = True)
	team    = Column(String, primary_key = True)
	version_date = Column(DateTime, primary_key = True)
	pa   = Column(Numeric) 
	dra   = Column(Numeric) 
	dra_minus = Column(Numeric) 
	cfip = Column(Numeric) 
	dra_pwarp = Column(Numeric) 
	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)

### Reference Tables

class Pecota_ref_bat_events_by_lineup(Base):
	__tablename__ = 'bat_events_by_lineup'
	__table_args__ = {'schema': 'pecota'}
	year_id = Column(Integer, primary_key = True)
	lg = Column(String, primary_key = True)
	bat_lineup_id = Column(Integer, primary_key = True)
	pa  = Column(Numeric) 
	outs  = Column(Numeric) 
	ab  = Column(Numeric) 
	h  = Column(Numeric) 
	b1  = Column(Numeric) 
	b2  = Column(Numeric) 
	b3  = Column(Numeric) 
	hr  = Column(Numeric) 
	tb  = Column(Numeric) 
	bb  = Column(Numeric) 
	ubb  = Column(Numeric) 
	ibb  = Column(Numeric) 
	hbp  = Column(Numeric) 
	sf  = Column(Numeric) 
	sh  = Column(Numeric) 
	roe  = Column(Numeric) 
	rbi  = Column(Numeric) 
	dp  = Column(Numeric) 
	tp  = Column(Numeric) 
	wp  = Column(Numeric) 
	pb  = Column(Numeric) 
	so  = Column(Numeric) 
	bk  = Column(Numeric) 
	interference  = Column(Numeric) 
	fc  = Column(Numeric) 
	tob  = Column(Numeric) 
	sit_dp  = Column(Numeric) 
	gidp  = Column(Numeric) 
	pitches  = Column(Numeric) 
	strikes  = Column(Numeric) 
	balls  = Column(Numeric) 
	fb  = Column(Numeric) 
	gb  = Column(Numeric) 
	linedr  = Column(Numeric) 
	popup  = Column(Numeric) 
	batted_ball_type_known  = Column(Numeric) 
	sf_op  = Column(Numeric) 
	sh_op  = Column(Numeric) 
	dp_op  = Column(Numeric) 
	tp_op  = Column(Numeric)  


	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)

		

class Pecota_ref_dyna_lg_pos_batting_stats(Base):
	__tablename__ = 'dyna_lg_pos_batting_stats'
	__table_args__ = {'schema': 'pecota'}
	year = Column(Integer, primary_key = True)
	lvl = Column(String, primary_key = True)
	lg = Column(String, primary_key = True)
	pos = Column(String, primary_key = True)
	g  = Column(Numeric) 
	pa  = Column(Numeric) 
	ab  = Column(Numeric) 
	h  = Column(Numeric) 
	b1  = Column(Numeric) 
	b2  = Column(Numeric) 
	b3  = Column(Numeric) 
	hr  = Column(Numeric) 
	tb  = Column(Numeric) 
	bb  = Column(Numeric) 
	ubb  = Column(Numeric) 
	ibb  = Column(Numeric) 
	hbp  = Column(Numeric) 
	sf  = Column(Numeric) 
	sh  = Column(Numeric) 
	roe  = Column(Numeric) 
	rbi  = Column(Numeric) 
	leadoff_pa  = Column(Numeric) 
	dp  = Column(Numeric) 
	tp  = Column(Numeric) 
	wp  = Column(Numeric) 
	pb  = Column(Numeric) 
	end_game  = Column(Numeric) 
	no_event  = Column(Numeric) 
	gen_out  = Column(Numeric) 
	so  = Column(Numeric) 
	bk  = Column(Numeric) 
	interference  = Column(Numeric) 
	fc  = Column(Numeric) 
	tob  = Column(Numeric) 
	obppa  = Column(Numeric) 
	missing_play  = Column(Numeric) 
	outs  = Column(Numeric) 
	sit_dp  = Column(Numeric) 
	gidp  = Column(Numeric) 
	pitches  = Column(Numeric) 
	strikes  = Column(Numeric) 
	balls  = Column(Numeric) 
	fb  = Column(Numeric) 
	gb  = Column(Numeric) 
	linedr  = Column(Numeric) 
	popup  = Column(Numeric) 
	batted_ball_type_known  = Column(Numeric) 
	pa_p  = Column(Numeric) 
	pa_c  = Column(Numeric) 
	pa_1b  = Column(Numeric) 
	pa_2b  = Column(Numeric) 
	pa_3b  = Column(Numeric) 
	pa_ss  = Column(Numeric) 
	pa_lf  = Column(Numeric) 
	pa_cf  = Column(Numeric) 
	pa_rf  = Column(Numeric) 
	pa_dh  = Column(Numeric) 
	pa_ph  = Column(Numeric) 
	pa_pr  = Column(Numeric) 
	g_p  = Column(Numeric) 
	g_c  = Column(Numeric) 
	g_1b  = Column(Numeric) 
	g_2b  = Column(Numeric) 
	g_3b  = Column(Numeric) 
	g_ss  = Column(Numeric) 
	g_lf  = Column(Numeric) 
	g_cf  = Column(Numeric) 
	g_rf  = Column(Numeric) 
	g_of  = Column(Numeric) 
	g_dh  = Column(Numeric) 
	g_ph  = Column(Numeric) 
	g_pr  = Column(Numeric) 
	sb  = Column(Numeric) 
	cs  = Column(Numeric) 
	pickoff  = Column(Numeric) 
	r  = Column(Numeric) 
	grp_id  = Column(Numeric) 
	grp_year  = Column(Numeric) 
	grp_lg  = Column(Numeric) 
	grp_team  = Column(Numeric) 
	grp_batter  = Column(Numeric) 
	grp_gameid  = Column(Numeric) 
	grp_pos  = Column(Numeric) 
	avg  = Column(Numeric) 
	obp  = Column(Numeric) 
	slg  = Column(Numeric) 
	ops  = Column(Numeric) 
	iso  = Column(Numeric) 
	tbp  = Column(Numeric) 
	bbr  = Column(Numeric) 
	ubbr  = Column(Numeric) 
	ibbr  = Column(Numeric) 
	so_bb  = Column(Numeric) 
	abr  = Column(Numeric) 
	hitr  = Column(Numeric) 
	b1r  = Column(Numeric) 
	b2r  = Column(Numeric) 
	b3r  = Column(Numeric) 
	hrr  = Column(Numeric) 
	hbpr  = Column(Numeric) 
	sfr  = Column(Numeric) 
	shr  = Column(Numeric) 
	roer  = Column(Numeric) 
	gen_outr  = Column(Numeric) 
	sor  = Column(Numeric) 
	outr  = Column(Numeric) 
	nsor  = Column(Numeric) 
	rbir  = Column(Numeric) 
	leadoffr  = Column(Numeric) 
	end_gamer  = Column(Numeric) 
	dp_percent  = Column(Numeric) 
	fb_percent  = Column(Numeric) 
	gb_percent  = Column(Numeric) 
	linedr_percent  = Column(Numeric) 
	popup_percent  = Column(Numeric) 
	sb_percent  = Column(Numeric) 
	runr  = Column(Numeric) 
	tav  = Column(Numeric)  
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)

		

class Pecota_ref_pitcher_league_pos(Base):
	__tablename__ = 'pitcher_league_pos'
	__table_args__ = {'schema': 'pecota'}
	year = Column(Integer, primary_key = True)
	pit_start_fl = Column(String, primary_key=True)
	lg = Column(String, primary_key = True)
 
	ip_start  = Column(Numeric) 
	ip_relief  = Column(Numeric) 
	outs  = Column(Numeric) 
	r  = Column(Numeric) 
	er  = Column(Numeric) 
	pa  = Column(Numeric) 
	ab  = Column(Numeric) 
	h  = Column(Numeric) 
	b1  = Column(Numeric) 
	b2  = Column(Numeric) 
	b3  = Column(Numeric) 
	hr  = Column(Numeric) 
	tb  = Column(Numeric) 
	bb  = Column(Numeric) 
	ubb  = Column(Numeric) 
	ibb  = Column(Numeric) 
	hbp  = Column(Numeric) 
	sf  = Column(Numeric) 
	sh  = Column(Numeric) 
	roe  = Column(Numeric) 
	rbi  = Column(Numeric) 
	dp  = Column(Numeric) 
	tp  = Column(Numeric) 
	wp  = Column(Numeric) 
	pb  = Column(Numeric) 
	so  = Column(Numeric) 
	bk  = Column(Numeric) 
	interference  = Column(Numeric) 
	fc  = Column(Numeric) 
	tob  = Column(Numeric) 
	sit_dp  = Column(Numeric) 
	gidp  = Column(Numeric) 
	pitches  = Column(Numeric) 
	strikes  = Column(Numeric) 
	balls  = Column(Numeric) 
	fb  = Column(Numeric) 
	gb  = Column(Numeric) 
	linedr  = Column(Numeric) 
	popup  = Column(Numeric) 
	batted_ball_type_known  = Column(Numeric) 
	inh_runners  = Column(Numeric) 
	runs_charged_during_app  = Column(Numeric) 
	inh_runners_scored  = Column(Numeric) 
	inh_score  = Column(Numeric) 
	beq_resp_runners  = Column(Numeric) 
	beq_runners  = Column(Numeric) 
	beq_scored  = Column(Numeric) 
	winp  = Column(Numeric) 
	relp  = Column(Numeric) 
	babip  = Column(Numeric) 
	def_eff  = Column(Numeric) 
	era  = Column(Numeric) 
	ra  = Column(Numeric) 
	ura  = Column(Numeric) 
	h_ip  = Column(Numeric) 
	bb_ip  = Column(Numeric) 
	so_ip  = Column(Numeric) 
	hr_ip  = Column(Numeric) 
	whip  = Column(Numeric) 
	h9  = Column(Numeric) 
	bb9  = Column(Numeric) 
	so9  = Column(Numeric) 
	hr9  = Column(Numeric) 
	br9  = Column(Numeric) 
	avg  = Column(Numeric) 
	obp  = Column(Numeric) 
	slg  = Column(Numeric) 
	iso  = Column(Numeric) 
	tbp  = Column(Numeric) 
	bbr  = Column(Numeric) 
	ubbr  = Column(Numeric) 
	ibbr  = Column(Numeric) 
	so_bb  = Column(Numeric) 
	hitr  = Column(Numeric) 
	b1r  = Column(Numeric) 
	b2r  = Column(Numeric) 
	b3r  = Column(Numeric) 
	hrr  = Column(Numeric) 
	hbpr  = Column(Numeric) 
	sfr  = Column(Numeric) 
	shr  = Column(Numeric) 
	roer  = Column(Numeric) 
	sor  = Column(Numeric) 
	outr  = Column(Numeric) 
	nsor  = Column(Numeric) 
	rbir  = Column(Numeric) 
	runr  = Column(Numeric) 
	dp_percent  = Column(Numeric) 
	fb_percent  = Column(Numeric) 
	gb_percent  = Column(Numeric) 
	linedr_percent  = Column(Numeric) 
	popup_percent  = Column(Numeric)  

	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)

