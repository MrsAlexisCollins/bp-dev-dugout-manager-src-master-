
from dugout_manager.read import session_read  
from dugout_manager.write import session_write
from dugout_manager.mapping import Euston_contracts, People_contracts, Bp_organizations
from sqlalchemy import func
from datetime import datetime

euston_contracts = session_read.query(Euston_contracts).limit(10)
bp_organizations = session_write.query(Bp_organizations)

for row in euston_contracts: 
    new_contract_entry = {}
    new_contract_entry['contract_id'] = row.contract_id
    new_contract_entry['bpid'] = row.bpid
    new_contract_entry['signed_date'] = row.signed_date
    new_contract_entry['terminated_date'] = row.terminated_date
    new_contract_entry['duration_years_max'] = row.duration_years_max
    new_contract_entry['duration_years_base'] = row.duration_years_base
    new_contract_entry['duration_years_actual'] = row.duration_years_actual
    new_contract_entry_org = bp_organizations.filter(Bp_organizations.org_name == row.signing_org).first()
    if new_contract_entry_org :
        new_contract_entry['signing_org_id'] =  new_contract_entry_org .org_id
    else:
        continue
    new_contract_entry['first_season'] = row.first_season
    new_contract_entry['updated_timestamp'] = datetime.now()
    new_row = People_contracts(**new_contract_entry)
    session_write.add(new_row) 
    #session_write.commit()
    print(new_row)


    # new_contract_entry_org = bp_organizations.filter(Bp_organizations.org_name == row.signing_org).first()
    #if new_contract_entry_org :
    #    new_contract_entry['signing_org_id'] =  new_contract_entry_org .org_id
    #else:
    #    continue