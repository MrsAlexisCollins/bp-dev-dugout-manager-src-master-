from dugout_manager.read import session_read  
from dugout_manager.write import session_write
from dugout_manager.mapping import *
from sqlalchemy import func
from datetime import datetime
######### TO DO dupe management


pecota_raw = session_read.query(Pecota_raw_pitchers).all()

for row in pecota_raw:
    new_entry = {}
    new_entry['bpid'] =  int(row.pitcher)
    new_entry['season']  = int(row.proj_year)
    new_entry['created_datetime'] = datetime.strptime(row.vintage, '%Y-%m-%d %H:%M:%S')
    new_entry['dra'] = row.DRA_final
    new_entry['dra_minus'] = row.DRA_minus
    new_entry['hr'] = row.HR_proj
    new_entry['hr_sd'] = row.HR_proj_sd
    new_entry['b3'] = row.B3_proj
    new_entry['b3_sd'] = row.B3_proj_sd
    new_entry['b2'] = row.B2_proj
    new_entry['b2_sd'] = row.B2_proj_sd
    new_entry['b1'] = row.B1_proj
    new_entry['b1_sd'] = row.B1_proj_sd
    new_entry['roe'] = row.ROE_proj
    new_entry['roe_sd'] = row.ROE_proj_sd
    new_entry['hbp'] = row.HBP_proj
    new_entry['hbp_sd'] = row.HBP_proj_sd
    new_entry['bb'] = row.BB_proj
    new_entry['bb_sd'] = row.BB_proj_sd
    new_entry['so'] = row.SO_proj
    new_entry['so_sd'] = row.SO_proj_sd
    new_entry['out'] = row.OUT_proj

    new_row = Bp_pecota_pitching_raw(**new_entry)
    session_write.add(new_row) 

    session_write.commit()