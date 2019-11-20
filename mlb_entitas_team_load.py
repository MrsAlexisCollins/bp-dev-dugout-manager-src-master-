
from dugout_manager.mlb_entitas.read import session_read  
from dugout_manager.mlb_entitas.write import session_write
from dugout_manager.mlb_entitas.mapping import Mlb_leagues, Mlb_levels, Mlb_divisions, Mlb_teams, Bp_leagues, Bp_divisions, Bp_levels, Bp_organizations, Bp_teams, Bp_governing_bodies
from sqlalchemy import func, exists, or_, and_
from datetime import datetime

bp_governing_bodies = session_write.query(Bp_governing_bodies)
bp_organizations = session_write.query(Bp_organizations)
bp_leagues = session_write.query(Bp_leagues)
bp_levels = session_write.query(Bp_levels)
bp_divisions = session_write.query(Bp_divisions)
mlb_leagues = session_read.query(Mlb_leagues)
mlb_levels = session_read.query(Mlb_levels)
mlb_divisions = session_read.query(Mlb_divisions)
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


    parent_abbrev = all_mlb_teams.filter(Mlb_teams.id==team_row.parent_org).first()
    # no parent means orphan or MLB
    if not parent_abbrev:  
        new_team_entry['org_id']  = bp_organizations.filter(or_(Bp_organizations.org_name=="orphan", 
            and_(team_row.level==1,Bp_organizations.org_name==team_row.abbreviation)
        )).order_by(Bp_organizations.org_id).first().org_id
    else: 
        new_team_entry['org_id']  = bp_organizations.filter(Bp_organizations.org_name==parent_abbrev.abbreviation).first().org_id
    
    new_team_entry['league_id']  =  bp_leagues.filter(
        Bp_leagues.league_name == mlb_leagues.filter(Mlb_leagues.id==team_row.league).first().abbreviation 
        ).first().league_id
    
    team_level_lookup = mlb_levels.filter(Mlb_levels.id==team_row.level).first()
    if not team_level_lookup:   
        new_team_entry['level_id']  =  None
    else:
        new_team_entry['level_id']  =   bp_levels.filter(
            Bp_levels.level_name == team_level_lookup.code 
        ).first().level_id  
    
    team_division_lookup = mlb_divisions.filter(Mlb_divisions.id==team_row.division).first()
    if not team_division_lookup:   
        new_team_entry['division_id']  =  None 
    else:
        new_team_entry['division_id']  =   bp_divisions.filter(
            Bp_divisions.division_name == team_division_lookup.abbreviation 
        ).first().division_id  

    new_team_entry['updated_timestamp']  = datetime.now()

    team_entries.append(new_team_entry)

for team_entry in team_entries:
    new_team_row = Bp_teams(**team_entry)
    session_write.add(new_team_row)

#session_write.commit()