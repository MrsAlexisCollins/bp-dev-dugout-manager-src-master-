
from dugout_manager.mlb_entitas.read import session_read  
from dugout_manager.mlb_entitas.write import session_write
from dugout_manager.mlb_entitas.mapping import Mlb_leagues, Mlb_levels, Mlb_divisions, Mlb_teams, Bp_leagues, Bp_levels, Bp_organizations, Bp_teams, Bp_governing_bodies

from datetime import datetime

######### get the pre-built data ALREADY IN DUGOUT 
organizations = session_write.query(Bp_organizations).join(Bp_governing_bodies).all()

######### fetch data FROM CAGE
mlb_teams = session_read.query(Mlb_teams).join(Mlb_leagues,  Mlb_levels).all()
 

for row in organizations:
    print(row.org_name, row.governing_bodies.gov_bod_name)

for row in mlb_teams:
    print(row.name, row.levels.name, row.leagues.name, row.parent_org)


