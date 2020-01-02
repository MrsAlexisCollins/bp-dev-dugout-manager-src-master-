from dugout_manager.connectors.read import session_read  
from dugout_manager.connectors.write import session_write
from dugout_manager.cage_models import Pecota_fielder_binomials, Pecota_of_assists
from dugout_manager.dugout_models import Bp_pecota_fielder_binomials, Bp_pecota_of_assists
from sqlalchemy import func 


pecota_raw = session_read.query(Pecota_fielder_binomials).all()
session_write.query(Bp_pecota_fielder_binomials).delete()  

for row in pecota_raw:
    new_entry = {}
    new_entry['bpid'] =  int(row.fld_id)
    new_entry['season']  = int(row.year_proj)

    new_row = Bp_pecota_fielder_binomials(**new_entry)
    session_write.add(new_row) 

#session_write.commit()