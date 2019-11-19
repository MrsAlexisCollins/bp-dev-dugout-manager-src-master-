
from dugout_manager.mlb_entitas.read import session_read  
from dugout_manager.mlb_entitas.write import session_write
from dugout_manager.mlb_entitas.mapping import Mlb_leagues, Mlb_levels, Mlb_divisions, Mlb_teams, Bp_leagues, Bp_divisions, Bp_levels, Bp_organizations, Bp_teams, Bp_governing_bodies
from sqlalchemy import func, exists
from datetime import datetime

bp_governing_bodies = session_write.query(Bp_governing_bodies)
bp_organizations = session_write.query(Bp_organizations)
bp_leagues = session_write.query(Bp_leagues)
bp_levels = session_write.query(Bp_levels)
bp_divisions = session_write.query(Bp_divisions)
######### TO DO dupe management

######### fetch data FROM CAGE
all_mlb_teams = session_read.query(Mlb_teams)
mlb_teams = all_mlb_teams.join(Mlb_leagues,  Mlb_levels,  Mlb_divisions).filter(
    Mlb_teams.active == 'True',
    Mlb_levels.code.in_(['win','aaa', 'aax','afa','afx','asx','rok','roa', 'mlb'])
).order_by(Mlb_levels.code).all()


team_count = session_write.query(func.count(Bp_teams.team_id)).scalar() #this should change to be max() not count()
team_entries = []
for team_row in mlb_teams:
    new_team_entry = {}
    team_count += 1
    new_team_entry['team_id']  = team_count
    new_team_entry['team_name']  = team_row.name

    # todo: handle none case with 31:orphan
    parent_abbrev = all_mlb_teams.filter(Mlb_teams.id==team_row.parent_org).first()
    if not parent_abbrev: 
        new_team_entry['org_id']  = bp_organizations.filter(Bp_organizations.org_name=="orphan").first().org_id
    else: 
        print (team_row.parent_org,parent_abbrev)
        new_team_entry['org_id']  = bp_organizations.filter(Bp_organizations.org_name==parent_abbrev.abbreviation).first().org_id
    


    new_team_entry['league_id']  =  team_row.league # team_row.league -> Mlb_leagues.id -> Mlb_leagues.abbreviation -> Bp_leagues.league_name -> Bp_leagues.league_id
    
    
    new_team_entry['level_id']  =   team_row.level  # team_row.level -> Mlb_levels.id -> Mlb_levels.abbreviation -> Bp_levels.level_name -> Bp_levels.level_id

    
    new_team_entry['division_id']  =   team_row.division #  team_row.division -> Mlb_divisions.id -> Mlb_divisions.abbreviation -> Bp_divisions.division_name -> Bp_divisions.division_id


    new_team_entry['updated_timestamp']  = datetime.now()
    print (new_team_entry)