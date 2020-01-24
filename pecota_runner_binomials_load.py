from Pecotadugout_manager.connectors.cage import session_cage  
from Pecotadugout_manager.connectors.dugout import session_dugout
from dugout_manager.cage_models import Pecota_runner_binomials
from dugout_manager.dugout_models import Bp_pecota_runner_binomials
from sqlalchemy import func
from datetime import datetime


pecota_raw = session_cage.query(Pecota_runner_binomials).all()
session_dugout.query(Bp_pecota_runner_binomials).delete()  

for row in pecota_raw:
    new_entry = {}
    new_entry['bpid'] =  int(row.bat_id)
    new_entry['season']  = int(row.year_proj)
    new_entry['sba_var'] =  row.sba_var
    new_entry['sba'] =  row.sba
    new_entry['sb_var'] =  row.sb_var
    new_entry['sb'] =  row.sb


    new_row = Bp_pecota_runner_binomials(**new_entry)
    session_dugout.add(new_row) 

session_dugout.commit()