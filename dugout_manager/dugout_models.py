import sqlalchemy
from . import settings

from sqlalchemy import Column, Integer, String , ForeignKey, DateTime, Boolean, Date, Numeric
from sqlalchemy.ext.declarative import declarative_base 
from sqlalchemy.orm import relationship

Base = declarative_base()


 
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
	decile = Column(Numeric) 
	hr_pa = Column(Numeric) 
	hr_sd = Column(Numeric) 
	b3_pa = Column(Numeric) 
	b3_sd = Column(Numeric) 
	b2_pa = Column(Numeric) 
	b2_sd = Column(Numeric) 
	b1_pa = Column(Numeric) 
	b1_sd = Column(Numeric) 
	roe_pa = Column(Numeric) 
	roe_sd = Column(Numeric) 
	hbp_pa = Column(Numeric) 
	hbp_sd = Column(Numeric) 
	bb_pa = Column(Numeric) 
	bb_sd = Column(Numeric) 
	so_pa = Column(Numeric) 
	so_sd = Column(Numeric) 
	gb_pa = Column(Numeric) 
	gb_sd = Column(Numeric) 
	out_pa = Column(Numeric) 
	hits_pa = Column(Numeric) 
	total_base_pa = Column(Numeric) 
	on_base_pa  = Column(Numeric) 
	ab_pa  = Column(Numeric) 

	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)



class Bp_pecota_hitting_park_adj(Base):
	__tablename__ = 'pecota_hitting_park_adj'
	__table_args__ = {'schema': 'stats'}
	id = Column(Integer,primary_key = True)
	bpid   = Column(Integer, ForeignKey('entitas.people.bpid'))
	season  = Column(Integer)
	created_datetime = Column(DateTime)  
	drc_plus = Column(Numeric) 
	draa_pa = Column(Numeric) 
	decile = Column(Numeric) 
	hr_pa = Column(Numeric) 
	hr_sd = Column(Numeric) 
	b3_pa = Column(Numeric) 
	b3_sd = Column(Numeric) 
	b2_pa = Column(Numeric) 
	b2_sd = Column(Numeric) 
	b1_pa = Column(Numeric) 
	b1_sd = Column(Numeric) 
	roe_pa = Column(Numeric) 
	roe_sd = Column(Numeric) 
	hbp_pa = Column(Numeric) 
	hbp_sd = Column(Numeric) 
	bb_pa = Column(Numeric) 
	bb_sd = Column(Numeric) 
	so_pa = Column(Numeric) 
	so_sd = Column(Numeric) 
	gb_pa = Column(Numeric) 
	gb_sd = Column(Numeric) 
	out_pa = Column(Numeric) 
	hits_pa = Column(Numeric) 
	total_base_pa = Column(Numeric) 
	on_base_pa  = Column(Numeric) 
	ab_pa  = Column(Numeric) 

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
	decile = Column(Numeric) 
	cfip = Column(Numeric) 
	hr_pa = Column(Numeric) 
	hr_sd = Column(Numeric) 
	b3_pa = Column(Numeric) 
	b3_sd = Column(Numeric) 
	b2_pa = Column(Numeric) 
	b2_sd = Column(Numeric) 
	b1_pa = Column(Numeric) 
	b1_sd = Column(Numeric) 
	roe_pa = Column(Numeric) 
	roe_sd = Column(Numeric) 
	hbp_pa = Column(Numeric) 
	hbp_sd = Column(Numeric) 
	bb_pa = Column(Numeric) 
	bb_sd = Column(Numeric) 
	so_pa = Column(Numeric) 
	so_sd = Column(Numeric) 
	out_pa = Column(Numeric) 
	gb_pa = Column(Numeric) 
	gb_sd = Column(Numeric) 
	hits_pa = Column(Numeric) 
	total_base_pa = Column(Numeric) 
	on_base_pa  = Column(Numeric) 
	ab_pa  = Column(Numeric) 
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)

class Bp_pecota_pitching_park_adj(Base):
	__tablename__ = 'pecota_pitching_park_adj'
	__table_args__ = {'schema': 'stats'}
	id = Column(Integer,primary_key = True)
	bpid = Column(Integer, ForeignKey('entitas.people.bpid'))
	season = Column(Integer)
	created_datetime = Column(DateTime)  
	dra = Column(Numeric) 
	dra_minus = Column(Numeric) 
	decile = Column(Numeric) 
	cfip = Column(Numeric) 
	hr_pa = Column(Numeric) 
	hr_sd = Column(Numeric) 
	b3_pa = Column(Numeric) 
	b3_sd = Column(Numeric) 
	b2_pa = Column(Numeric) 
	b2_sd = Column(Numeric) 
	b1_pa = Column(Numeric) 
	b1_sd = Column(Numeric) 
	roe_pa = Column(Numeric) 
	roe_sd = Column(Numeric) 
	hbp_pa = Column(Numeric) 
	hbp_sd = Column(Numeric) 
	bb_pa = Column(Numeric) 
	bb_sd = Column(Numeric) 
	so_pa = Column(Numeric) 
	so_sd = Column(Numeric) 
	out_pa = Column(Numeric) 
	gb_pa = Column(Numeric) 
	gb_sd = Column(Numeric) 
	hits_pa = Column(Numeric) 
	total_base_pa = Column(Numeric) 
	on_base_pa  = Column(Numeric) 
	ab_pa  = Column(Numeric) 
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
	oneline = Column(Boolean)
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



class Bp_pecota_runner_binomials (Base):
	__tablename__ = 'pecota_runner_binomials'
	__table_args__ = {'schema': 'stats'}

	id = Column(Integer,primary_key = True)
	bpid = Column(Integer, ForeignKey('entitas.people.bpid'))
	season = Column(Integer)
	sba_var = Column(Numeric)
	sba = Column(Numeric)
	sb_var = Column(Numeric)
	sb = Column(Numeric)
	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)



class Bp_pecota_depthcharts_batters(Base):
	__tablename__ = 'depth_chart_batters'
	__table_args__ = {'schema':'entitas'}

	id = Column(Integer,primary_key = True)
	bpid = Column(Integer, ForeignKey('entitas.people.bpid'))
	org_id = Column(Integer, ForeignKey('entitas.organizations.org_id'))
	season = Column(Integer)
	pt_c = Column(Integer)
	pt_1b = Column(Integer)
	pt_2b = Column(Integer)
	pt_3b = Column(Integer)
	pt_ss = Column(Integer)
	pt_lf = Column(Integer)
	pt_cf = Column(Integer)
	pt_rf = Column(Integer)
	pt_dh = Column(Integer)
	pt_ph = Column(Integer)

	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)





class Bp_pecota_depthcharts_pitchers(Base):
	__tablename__ = 'depth_chart_pitchers'
	__table_args__ = {'schema':'entitas'}

	id = Column(Integer,primary_key = True)
	bpid = Column(Integer, ForeignKey('entitas.people.bpid'))
	org_id = Column(Integer, ForeignKey('entitas.organizations.org_id'))
	season = Column(Integer)
	gs_pct = Column(Numeric)
	sp_role  = Column(String)
	ip_gs = Column(Numeric)
	rp_ip_pct = Column(Numeric)
	rp_role  = Column(String)
	saves_pct = Column(Numeric)
	

	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)



class Bp_pecota_fraa_cda(Base):
	__tablename__ = 'pecota_catcher_fraa'
	__table_args__ = {'schema': 'stats'}
	season = Column(Integer, primary_key = True)
	bpid = Column(Integer, primary_key = True)
	csaa_proj = Column(Numeric) 
	csaa_proj_sd = Column(Numeric) 
	epaa_proj = Column(Numeric) 
	epaa_proj_sd = Column(Numeric) 
	sraa_proj = Column(Numeric) 
	sraa_proj_sd = Column(Numeric) 
	traa_proj = Column(Numeric) 
	traa_proj_sd = Column(Numeric) 
	created_datetime = Column(DateTime) 
	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Bp_pecota_fielder_binomials(Base):
	__tablename__ = 'pecota_fielder_binomials'
	__table_args__ = {'schema': 'stats'}

	season = Column(Integer, primary_key = True)
	bpid = Column(Integer, primary_key = True)
	years = Column(Integer)
	position = Column(Integer, primary_key = True)
	ch = Column(Numeric) 
	ch_weighted = Column(Numeric) 
	pm_rt_var = Column(Numeric) 
	pm_rt = Column(Numeric) 
	pm_rt_lg = Column(Numeric) 
	pm_rt_raw = Column(Numeric) 
	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)

class Bp_pecota_of_assists(Base):
	__tablename__ = 'pecota_of_assists'
	__table_args__ = {'schema': 'stats'}
	season = Column(Integer, primary_key = True)
	bpid = Column(Integer, primary_key = True)
	years = Column(Integer)
	position = Column(Integer, primary_key = True)
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


### Reference Tables



class Ref_batter_events_league_lineup(Base):
	__tablename__ = 'ref_bat_events_by_lineup'
	__table_args__ = {'schema': 'stats'}
	id = Column(Integer,primary_key = True)
	season  = Column(Integer) 
	league_id  = Column(Integer) 
	lineup_slot  = Column(Integer) 
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

		

class Ref_batting_stats_league_position(Base):
	__tablename__ = 'ref_dyna_lg_pos_batting_stats'
	__table_args__ = {'schema': 'stats'}
	id = Column(Integer,primary_key = True)	 
	season  = Column(Integer) 
	level_id  = Column(Integer) 
	league_id  = Column(Integer) 
	pos  = Column(Integer) 
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

		

class Ref_pitching_stats_league_position(Base):
	__tablename__ = 'ref_pitcher_league_pos'
	__table_args__ = {'schema': 'stats'}
	id = Column(Integer,primary_key = True)
	season  = Column(Integer) 
	starters  = Column(Boolean) 
	league_id  = Column(Integer) 
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




class Pecota_bpf(Base):
	__tablename__ = 'pecota_bpf'
	__table_args__ = {'schema': 'stats'}
	id = Column(Integer,primary_key = True)
	season = Column(Integer)
	org_id = Column(Integer)
	bats = Column(String)
	hr_bpf = Column(Numeric) 
	hr_bpf_sd = Column(Numeric) 
	b3_bpf = Column(Numeric) 
	b3_bpf_sd = Column(Numeric) 
	b2_bpf = Column(Numeric) 
	b2_bpf_sd = Column(Numeric) 
	b1_bpf = Column(Numeric) 
	b1_bpf_sd = Column(Numeric) 
	roe_bpf = Column(Numeric) 
	roe_bpf_sd = Column(Numeric) 
	hbp_bpf = Column(Numeric) 
	hbp_bpf_sd = Column(Numeric) 
	bb_bpf = Column(Numeric) 
	bb_bpf_sd = Column(Numeric) 
	so_bpf = Column(Numeric) 
	so_bpf_sd = Column(Numeric) 
	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


#### legacy stats

class Stats_legacy_batting_daily(Base):
	__tablename__ = 'bat_master'
	__table_args__ = {'schema': 'stats'}
	id = Column(Integer,primary_key = True)
	bpid= Column(Integer )
	season = Column(Integer )
	team_name    = Column(String )
	level_name    = Column(String )
	version  = Column(DateTime )
	pa  = Column(Numeric) 
	drc_plus = Column(Numeric) 
	drc_raa = Column(Numeric)  
	fraa = Column(Numeric) 
	brr = Column(Numeric) 
	pos_adj = Column(Numeric) 
	rep_level = Column(Numeric) 
	drc_warp = Column(Numeric) 
	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)


class Stats_legacy_pitching_daily(Base):
	__tablename__ = 'pit_master'
	__table_args__ = {'schema': 'stats'}
	id = Column(Integer,primary_key = True)
	bpid= Column(Integer )
	season = Column(Integer )
	team_name    = Column(String )
	level_name    = Column(String )
	version  = Column(DateTime )
	pa   = Column(Numeric) 
	dra   = Column(Numeric) 
	dra_minus = Column(Numeric) 
	cfip = Column(Numeric) 
	dra_pwarp = Column(Numeric) 
	
	def __repr__(self):
		return "{}({!r})".format(self.__class__.__name__, self.__dict__)