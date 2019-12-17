from dugout_manager.connectors.read import session_read  
from dugout_manager.connectors.write import session_write
from dugout_manager.cage_models import Pecota_runner_binomials
from dugout_manager.dugout_models import Bp_pecota_runner_binomials
from sqlalchemy import func
from datetime import datetime


pecota_raw = session_read.query(Pecota_runner_binomials).all()
session_write.query(Bp_pecota_runner_binomials).delete()  

for row in pecota_raw:
    new_entry = {}
    new_entry['bpid'] =  int(row.bat_id)
    new_entry['season']  = int(row.year_proj)
    new_entry['sba_var'] =  row.sba_var
    new_entry['sba'] =  row.sba
    new_entry['sb_var'] =  row.sb_var
    new_entry['sb'] =  row.sb


    new_row = Bp_pecota_runner_binomials(**new_entry)
    session_write.add(new_row) 

session_write.commit()