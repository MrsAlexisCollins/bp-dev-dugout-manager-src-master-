from dugout_manager.read import session_read  
from dugout_manager.write import session_write
from dugout_manager.mapping import *
from sqlalchemy import func
from datetime import datetime

all_mlb_teams = session_read.query(Mlb_teams)
bp_teams = session_write.query(Bp_teams)
######### TO DO dupe management


pecota_raw = session_read.query(Pecota_raw_batters).limit(1)

for row in pecota_raw:
    new_entry = {}
    new_entry['bpid'] =  int(row.batter)
    new_entry['season']  = int(row.proj_year)
    new_entry['created_datetime'] = datetime.strptime(row.vintage, '%Y-%m-%d %H:%M:%S')
    new_entry['dRC_plus'] = row.proj_dRC_plus
    new_entry['dRAA_PA'] = row.proj_dRAA_PA
    new_entry['HR'] = row.HR_proj_pneu
    new_entry['HR_sd'] = row.HR_proj_pneu_sd
    new_entry['B3'] = row.B3_proj_pneu
    new_entry['B3_sd'] = row.B3_proj_pneu_sd
    new_entry['B2'] = row.B2_proj_pneu
    new_entry['B2_sd'] = row.B2_proj_pneu_sd
    new_entry['B1'] = row.B1_proj_pneu
    new_entry['B1_sd'] = row.B1_proj_pneu_sd
    new_entry['ROE'] = row.ROE_proj_pneu
    new_entry['ROE_sd'] = row.ROE_proj_pneu_sd
    new_entry['HBP'] = row.HBP_proj_pneu
    new_entry['HBP_sd'] = row.HBP_proj_pneu_sd
    new_entry['BB'] = row.BB_proj_pneu
    new_entry['BB_sd'] = row.BB_proj_pneu_sd
    new_entry['SO'] = row.SO_proj_pneu
    new_entry['SO_sd'] = row.SO_proj_pneu_sd
    new_entry['GB'] = row.GB_proj_pneu
    new_entry['GB_sd'] = row.GB_proj_pneu_sd
    new_entry['OUT'] = row.OUT_proj_pneu
    print(new_entry)