from dugout_manager.connectors.cage import session_cage  
from dugout_manager.connectors.dugout import session_dugout
from dugout_manager.cage_models import *
from dugout_manager.dugout_models import *
from sqlalchemy import func
from datetime import datetime

DEFAULT_PA = 500

vintage_last = session_dugout.query(func.max(Bp_pecota_fielders_raw.created_datetime)).scalar() or datetime.strptime('01/01/01 01:01:01', '%m/%d/%y %H:%M:%S')
vintage_last_judge = session_cage.query(func.max(Pecota_raw_fielders.vintage)).scalar() 
print(vintage_last_judge ,vintage_last)
if vintage_last_judge > vintage_last:
    pecota_raw = session_cage.query(Pecota_raw_fielders).filter(Pecota_raw_fielders.vintage == vintage_last_judge).all()
    session_dugout.query(Bp_pecota_fielders_raw).delete()  

    for row in pecota_raw:
        new_entry = {}
        new_entry['bpid'] =  int(row.fielder)
        new_entry['season']  = int(row.proj_year)
        new_entry['created_datetime'] =  row.vintage
        new_entry['position'] =  row.pos
        new_entry['fraa_100'] =  row.fraa_100_proj
        new_entry['fraa_100_sd'] =  row.fraa_100_proj_sd


        new_row = Bp_pecota_fielders_raw(**new_entry)
        session_dugout.add(new_row) 

    session_dugout.commit()