
from dugout_manager.mlb_entitas.read import session_read  
from dugout_manager.mlb_entitas.write import session_write
from dugout_manager.mlb_entitas.mapping import Mlb_leagues, Mlb_levels, Mlb_divisions, Mlb_teams, Bp_leagues, Bp_divisions, Bp_levels, Bp_organizations, Bp_teams, Bp_governing_bodies
from sqlalchemy import func
from datetime import datetime

######### TO DO dupe management

######### get the pre-built data ALREADY IN DUGOUT 
organizations = session_write.query(Bp_organizations).join(Bp_governing_bodies).all()

######### fetch data FROM CAGE
mlb_teams = session_read.query(Mlb_teams).join(Mlb_leagues,  Mlb_levels).filter(
    Mlb_teams.active == 'True',
    Mlb_levels.code.in_(['win','aaa', 'aax','afa','afx','asx','rok','roa', 'mlb'])
).order_by(Mlb_levels.code).all()

mlb_levels = session_read.query(Mlb_levels).filter(
    Mlb_levels.code.in_(['win','aaa', 'aax','afa','afx','asx','rok','roa', 'mlb'])
).all()
mlb_leagues = session_read.query(Mlb_leagues).join(Mlb_levels).filter(
    Mlb_levels.code.in_(['win','aaa', 'aax','afa','afx','asx','rok','roa', 'mlb'])
).all()
mlb_divisions = session_read.query(Mlb_divisions).join(Mlb_leagues,  Mlb_levels).filter(
    Mlb_levels.code.in_(['win','aaa', 'aax','afa','afx','asx','rok','roa', 'mlb'])
).all() 

level_count = session_write.query(func.count(Bp_levels.level_id)).scalar()
level_entries = []
for level_row in mlb_levels:
    new_level_entry = {}
    level_count += 1
    new_level_entry['level_id'] = level_count
    new_level_entry['level_name'] = level_row.code
    new_level_entry['gov_bod_id'] = session_write.query(Bp_governing_bodies).filter(Bp_governing_bodies.gov_bod_name=='Major League Baseball').first().gov_bod_id
    new_level_entry['updated_timestamp'] = datetime.now()  
    level_entries.append(new_level_entry)

for level_entry in level_entries:
    new_level_row = Bp_levels(**level_entry)
    session_write.add(new_level_row)



league_count = session_write.query(func.count(Bp_leagues.league_id)).scalar()
league_entries = []
for league_row in mlb_leagues:
    new_league_entry = {}
    league_count += 1
    new_league_entry['league_id'] = league_count
    new_league_entry['league_name'] = league_row.abbreviation
    new_league_entry['gov_bod_id'] = session_write.query(Bp_governing_bodies).filter(Bp_governing_bodies.gov_bod_name=='Major League Baseball').first().gov_bod_id
    new_league_entry['updated_timestamp'] = datetime.now()  
    league_entries.append(new_league_entry)

for league_entry in league_entries:
    new_league_row = Bp_leagues(**league_entry)
    session_write.add(new_league_row)


division_count = session_write.query(func.count(Bp_divisions.division_id)).scalar()
division_entries = []
for division_row in mlb_divisions:
    new_division_entry = {}
    division_count += 1
    new_division_entry['division_id'] = division_count
    new_division_entry['division_name'] = division_row.abbreviation
    new_division_entry['league_id'] = session_write.query(Bp_leagues).filter(Bp_leagues.league_name==division_row.leagues.abbreviation).first().league_id
    new_division_entry['gov_bod_id'] = session_write.query(Bp_leagues).filter(Bp_leagues.league_name==division_row.leagues.abbreviation).first().gov_bod_id
    new_division_entry['updated_timestamp'] = datetime.now()  
    division_entries.append(new_division_entry)

for division_entry in division_entries:
    new_division_row = Bp_divisions(**division_entry)
    session_write.add(new_division_row)

session_write.commit()