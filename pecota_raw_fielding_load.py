from dugout_manager.read import session_read  
from dugout_manager.write import session_write
from dugout_manager.mapping import *
from sqlalchemy import func
from datetime import datetime

DEFAULT_PA = 500

vintage_last = session_write.query(func.max(Bp_pecota_fielders_raw_raw.created_datetime)).scalar() 
vintage_last_judge = session_read.query(func.max(Pecota_raw_fielders.vintage)).scalar() 
print(vintage_last_judge ,vintage_last)
if vintage_last_judge > vintage_last:
    pecota_raw = session_read.query(Pecota_raw_fielders).filter(Pecota_raw_fielders.vintage == vintage_last_judge).all()
    session_write.query(Bp_pecota_fielders_raw).delete()  

    for row in pecota_raw:
        new_entry = {}
        new_entry['bpid'] =  int(row.fielder)
        new_entry['season']  = int(row.proj_year)
        new_entry['created_datetime'] =  row.vintage
        new_entry['position'] =  row.pos
        new_entry['fraa_100'] =  row.fraa_100_proj
        new_entry['fraa_100_sd'] =  row.fraa_100_proj_sd


        new_row = Bp_pecota_fielders_raw(**new_entry)
        session_write.add(new_row) 

    session_write.commit()