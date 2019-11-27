from dugout_manager.read import session_read  
from dugout_manager.write import session_write
from dugout_manager.mapping import *
from sqlalchemy import func
from datetime import datetime

all_mlb_teams = session_read.query(Mlb_teams)
bp_teams = session_write.query(Bp_teams)
######### TO DO dupe management


pecota_raw = session_read.query(Pecota_raw_pitchers).limit(1)

for row in pecota_raw:
    new_entry = {}
    new_entry['bpid'] =  int(row.pitcher)
    new_entry['season']  = int(row.proj_year)
    new_entry['created_datetime'] = datetime.strptime(row.vintage, '%Y-%m-%d %H:%M:%S')
    new_entry['DRA'] = row.DRA_final
    new_entry['DRA_minus'] = row.DRA_minus
    new_entry['HR'] = row.HR_proj
    new_entry['HR_sd'] = row.HR_proj_sd
    new_entry['B3'] = row.B3_proj
    new_entry['B3_sd'] = row.B3_proj_sd
    new_entry['B2'] = row.B2_proj
    new_entry['B2_sd'] = row.B2_proj_sd
    new_entry['B1'] = row.B1_proj
    new_entry['B1_sd'] = row.B1_proj_sd
    new_entry['ROE'] = row.ROE_proj
    new_entry['ROE_sd'] = row.ROE_proj_sd
    new_entry['HBP'] = row.HBP_proj
    new_entry['HBP_sd'] = row.HBP_proj_sd
    new_entry['BB'] = row.BB_proj
    new_entry['BB_sd'] = row.BB_proj_sd
    new_entry['SO'] = row.SO_proj
    new_entry['SO_sd'] = row.SO_proj_sd
    new_entry['OUT'] = row.OUT_proj
    print(new_entry)