from dugout_manager.connectors.read import session_read  
from dugout_manager.connectors.write import session_write
from dugout_manager.cage_models import *
from dugout_manager.dugout_models import *
from sqlalchemy import func
from datetime import datetime


vintage_last = session_write.query(func.max(Bp_pecota_hitting_raw.created_datetime)).scalar()  or datetime.strptime('01/01/01 01:01:01', '%m/%d/%y %H:%M:%S')
vintage_last_judge = session_read.query(func.max(Pecota_raw_batters.vintage)).scalar() 
print(vintage_last_judge ,vintage_last)
if vintage_last_judge >  vintage_last:
    pecota_raw = session_read.query(Pecota_raw_batters).filter(Pecota_raw_batters.vintage == vintage_last_judge ).all()
    session_write.query(Bp_pecota_hitting_raw).delete()   

    for row in pecota_raw:
        new_entry = {}
        new_entry['bpid'] =  int(row.batter)
        new_entry['season']  = int(row.proj_year)
        new_entry['created_datetime'] =  row.vintage 
        new_entry['drc_plus'] = row.DRC
        new_entry['draa_pa'] = row.dRAA_PA
        new_entry['decile'] = int(row.decile)
        new_entry['hr_pa'] = row.HR_proj_pneu
        new_entry['b3_pa'] = row.B3_proj_pneu
        new_entry['b2_pa'] = row.B2_proj_pneu
        new_entry['b1_pa'] = row.B1_proj_pneu
        new_entry['roe_pa'] = row.ROE_proj_pneu
        new_entry['hbp_pa'] = row.HBP_proj_pneu
        new_entry['bb_pa'] = row.BB_proj_pneu
        new_entry['so_pa'] = row.SO_proj_pneu
        new_entry['gb_pa'] = row.GB_proj_pneu
        new_entry['out_pa'] = row.OUT_proj_pneu
        new_entry['hits_pa'] = sum([new_entry['hr_pa'],new_entry['b3_pa'],new_entry['b2_pa'],new_entry['b1_pa']])
        new_entry['total_base_pa'] = sum([new_entry['hr_pa']*4,new_entry['b3_pa']*3,new_entry['b2_pa']*2,new_entry['b1_pa']])
        new_entry['on_base_pa'] = sum([new_entry['hits_pa'],new_entry['hbp_pa'],new_entry['bb_pa']])
        new_entry['ab_pa'] = sum([new_entry['out_pa'], new_entry['hits_pa'], new_entry['roe_pa'], new_entry['so_pa']])
        new_row = Bp_pecota_hitting_raw(**new_entry)
        session_write.add(new_row) 


    session_write.commit()