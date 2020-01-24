from Pecotadugout_manager.connectors.cage import session_cage  
from Pecotadugout_manager.connectors.dugout import session_dugout
from dugout_manager.cage_models import Judge_pecota_bpf
from dugout_manager.dugout_models import Pecota_bpf, Bp_organizations, Xref_org
from sqlalchemy import func
from datetime import datetime

bp_organizations = session_dugout.query(Bp_organizations).join(Xref_org, Bp_organizations.org_id == Xref_org.org_id)

## pick org_id, cast year to season integer

judge_bpf = session_cage.query(Judge_pecota_bpf).all()

pecota_bpf = session_dugout.query(Pecota_bpf) 
pecota_bpf.delete()  

new_entries = []
for row in judge_bpf:
    new_entry = {}
    new_entry_org = bp_organizations.filter(Xref_org.xref_id == row.bat_team).first()
    if new_entry_org :
        new_entry['org_id'] =  new_entry_org.org_id
    else:
        continue
    new_entry['season'] = row.year
    new_entry['bats'] = row.bats
    new_entry['hr_bpf'] = row.hr_bpf
    new_entry['hr_bpf_sd'] = row.hr_bpf_sd
    new_entry['b3_bpf'] = row.b3_bpf
    new_entry['b3_bpf_sd'] = row.b3_bpf_sd
    new_entry['b2_bpf'] = row.b2_bpf
    new_entry['b2_bpf_sd'] = row.b2_bpf_sd
    new_entry['b1_bpf'] = row.b1_bpf
    new_entry['b1_bpf_sd'] = row.b1_bpf_sd
    new_entry['roe_bpf'] = row.roe_bpf
    new_entry['roe_bpf_sd'] = row.roe_bpf_sd
    new_entry['hbp_bpf'] = row.hbp_bpf
    new_entry['hbp_bpf_sd'] = row.hbp_bpf_sd
    new_entry['bb_bpf'] = row.bb_bpf
    new_entry['bb_bpf_sd'] = row.bb_bpf_sd
    new_entry['so_bpf'] = row.so_bpf
    new_entry['so_bpf_sd'] = row.so_bpf_sd

    new_entries.append(new_entry)

for new_entry in new_entries:
    new_row = Pecota_bpf(**new_entry)
    session_dugout.add(new_row)

session_dugout.commit()