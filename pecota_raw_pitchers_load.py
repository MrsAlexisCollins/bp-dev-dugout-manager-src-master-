from dugout_manager.read import session_read  
from dugout_manager.write import session_write
from dugout_manager.mapping import *
from sqlalchemy import func
from datetime import datetime



vintage_last = session_write.query(func.max(Bp_pecota_pitching_raw.created_datetime)).scalar() 
vintage_last_judge = session_read.query(func.max(Pecota_raw_pitchers.vintage)).scalar() 

if vintage_last_judge > vintage_last:
    pecota_raw = session_read.query(Pecota_raw_pitchers).filter(Pecota_raw_pitchers.vintage == vintage_last_judge).all()
    session_write.query(Bp_pecota_pitching_raw).delete()   

#     for row in pecota_raw:
#         new_entry = {}
#         new_entry['bpid'] =  int(row.pitcher)
#         new_entry['season']  = int(row.proj_year)
#         new_entry['created_datetime'] = datetime.strptime(row.vintage, '%Y-%m-%d %H:%M:%S')
#         new_entry['dra'] = row.DRA_final
#         new_entry['dra_minus'] = row.DRA_minus
#         new_entry['hr'] = row.HR_proj * 500
#         new_entry['hr_sd'] = row.HR_proj_sd * 500
#         new_entry['b3'] = row.B3_proj * 500
#         new_entry['b3_sd'] = row.B3_proj_sd * 500
#         new_entry['b2'] = row.B2_proj * 500
#         new_entry['b2_sd'] = row.B2_proj_sd * 500
#         new_entry['b1'] = row.B1_proj * 500
#         new_entry['b1_sd'] = row.B1_proj_sd * 500
#         new_entry['roe'] = row.ROE_proj * 500
#         new_entry['roe_sd'] = row.ROE_proj_sd * 500
#         new_entry['hbp'] = row.HBP_proj * 500
#         new_entry['hbp_sd'] = row.HBP_proj_sd * 500
#         new_entry['bb'] = row.BB_proj * 500
#         new_entry['bb_sd'] = row.BB_proj_sd * 500
#         new_entry['so'] = row.SO_proj * 500
#         new_entry['so_sd'] = row.SO_proj_sd * 500
#         new_entry['out'] = row.OUT_proj * 500

#         new_row = Bp_pecota_pitching_raw(**new_entry)
#         session_write.add(new_row) 

#     session_write.commit()