from dugout_manager.connectors.read import session_read  
from dugout_manager.connectors.write import session_write
from dugout_manager.cage_models import Pecota_fraa_cda
from dugout_manager.dugout_models import Bp_pecota_fraa_cda
from sqlalchemy import func
from datetime import datetime


vintage_last = session_write.query(func.max(Bp_pecota_fraa_cda.created_datetime)).scalar() or datetime.strptime('01/01/01 01:01:01', '%m/%d/%y %H:%M:%S')
vintage_last_judge = session_read.query(func.max(Pecota_fraa_cda.vintage)).scalar() 
print(vintage_last_judge ,vintage_last)
if vintage_last_judge > vintage_last:
    pecota_raw = session_read.query(Pecota_fraa_cda).filter(Pecota_fraa_cda.vintage == vintage_last_judge , Pecota_fraa_cda.decile==5).all()
    session_write.query(Bp_pecota_fraa_cda).delete()  

    for row in pecota_raw:
        new_entry = {}
        new_entry['bpid'] =  int(row.playerid)
        new_entry['season']  = int(row.proj_year)
        new_entry['created_datetime'] =  row.vintage
        new_entry['csaa_proj'] =  row.csaa_proj
        new_entry['epaa_proj'] =  row.epaa_proj
        new_entry['sraa_proj'] =  row.sraa_proj
        new_entry['traa_proj'] =  row.traa_proj


        new_row = Bp_pecota_fraa_cda(**new_entry)
        session_write.add(new_row) 

    session_write.commit()