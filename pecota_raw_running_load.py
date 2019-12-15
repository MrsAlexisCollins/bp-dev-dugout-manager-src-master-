from dugout_manager.read import session_read  
from dugout_manager.write import session_write
from dugout_manager.cage_models import *
from dugout_manager.dugout_models import *
from sqlalchemy import func
from datetime import datetime

DEFAULT_PA = 500

vintage_last = session_write.query(func.max(Bp_pecota_runners_raw.created_datetime)).scalar()  or datetime.strptime('01/01/01 01:01:01', '%m/%d/%y %H:%M:%S')
vintage_last_judge = session_read.query(func.max(Pecota_raw_runners.vintage)).scalar() 
print(vintage_last_judge ,vintage_last)
if vintage_last_judge > vintage_last:
    pecota_raw = session_read.query(Pecota_raw_runners).filter(Pecota_raw_runners.vintage == vintage_last_judge).all()
    session_write.query(Bp_pecota_runners_raw).delete()  

    for row in pecota_raw:
        new_entry = {}
        new_entry['bpid'] =  int(row.run_id)
        new_entry['season']  = int(row.proj_year)
        new_entry['created_datetime'] =  row.vintage
        new_entry['brr_50'] =  row.brr_50_proj
        new_entry['brr_50_sd'] =  row.brr_50_proj_sd


        new_row = Bp_pecota_runners_raw(**new_entry)
        session_write.add(new_row) 

    session_write.commit()