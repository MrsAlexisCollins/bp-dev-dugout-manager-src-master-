
from dugout_manager.mlb_entitas.read import session_read  
from dugout_manager.mlb_entitas.write import session_write
from dugout_manager.mlb_entitas.mapping import Mlb_leagues, Mlb_levels, Mlb_divisions, Mlb_teams, Bp_leagues, Bp_divisions, Bp_levels, Bp_organizations, Bp_teams, Bp_governing_bodies
from sqlalchemy import func
from datetime import datetime

######### TO DO dupe management

######### get the pre-built data ALREADY IN DUGOUT 
organizations = session_write.query(Bp_organizations).join(Bp_governing_bodies).all()

######### fetch data FROM CAGE
mlb_teams = session_read.query(Mlb_teams).join(Mlb_leagues,  Mlb_levels,  Mlb_divisions).filter(
    Mlb_teams.active == 'True',
    Mlb_levels.code.in_(['win','aaa', 'aax','afa','afx','asx','rok','roa', 'mlb'])
).order_by(Mlb_levels.code).all()