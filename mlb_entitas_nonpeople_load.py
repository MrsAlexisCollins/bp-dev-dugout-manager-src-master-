
from dugout_manager.mlb_entitas.read import session_read  
from dugout_manager.mlb_entitas.write import session_write
from dugout_manager.mlb_entitas.mapping import Mlb_leagues, Mlb_levels, Mlb_divisions, Mlb_teams, Bp_leagues, Bp_levels, Bp_organizations, Bp_teams, Bp_governing_bodies
from sqlalchemy import func
from datetime import datetime

######### get the pre-built data ALREADY IN DUGOUT 
organizations = session_write.query(Bp_organizations).join(Bp_governing_bodies).all()

######### fetch data FROM CAGE
mlb_teams = session_read.query(Mlb_teams).join(Mlb_leagues,  Mlb_levels).filter(
    Mlb_teams.active == 'True',Mlb_levels.code.in_(['win','aaa', 'aax','afa','afx','asx','rok','roa', 'mlb'])
    ).order_by(Mlb_levels.code).all()

mlb_teams_selfref  = session_read.query(Mlb_teams).order_by(Mlb_teams.id).all()

mlb_levels = session_read.query(Mlb_levels).all()
mlb_leagues = session_read.query(Mlb_leagues).all()
mlb_divisions = session_read.query(Mlb_divisions).all() 

# for row in organizations:
#     print(row.org_name, row.governing_bodies.gov_bod_name)

# for row in mlb_teams:
#     print(row.id, row.name, row.levels.code, row.parent_org )

level_count = session_write.query(func.count(Bp_levels.level_id)).scalar()
level_entries = []
for row in mlb_levels:
    new_entry = {}
    level_count += 1
    new_entry['level_id'] = level_count
    new_entry['level_name'] = row.code
    new_entry['gov_bod_id'] = 1
    new_entry['updated_timestamp'] = datetime.now()  
    level_entries.append(new_entry)
    
for new_entry in level_entries:
    new_row = Bp_levels(**new_entry)
    session_write.add(new_row)


#session_write.commit()