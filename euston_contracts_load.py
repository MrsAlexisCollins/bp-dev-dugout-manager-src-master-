from dugout_manager.connectors.cage import session_cage  
from dugout_manager.connectors.dugout import session_dugout
from dugout_manager.cage_models import Euston_contracts
from dugout_manager.dugout_models import Bp_organizations, Xref_org, People_contracts
from sqlalchemy import func
from datetime import datetime

euston_contracts = session_cage.query(Euston_contracts)
bp_organizations = session_dugout.query(Bp_organizations).join(Xref_org, Bp_organizations.org_id == Xref_org.org_id)

for row in euston_contracts: 
    new_contract_entry = {}
    new_contract_entry['contract_id'] = row.contract_id
    new_contract_entry['bpid'] = row.bpid
    new_contract_entry['signed_date'] = row.signed_date
    new_contract_entry['terminated_date'] = row.terminated_date
    new_contract_entry['duration_years_max'] = row.duration_years_max
    new_contract_entry['duration_years_base'] = row.duration_years_base
    new_contract_entry['duration_years_actual'] = row.duration_years_actual
    new_contract_entry_org = bp_organizations.filter(Xref_org.xref_id == row.signing_org).first()
    if new_contract_entry_org :
        new_contract_entry['signing_org_id'] =  new_contract_entry_org.org_id
    else:
        continue
    new_contract_entry['first_season'] = row.first_season
    new_contract_entry['updated_timestamp'] = datetime.now()
    new_row = People_contracts(**new_contract_entry)
    session_dugout.add(new_row) 
    session_dugout.commit()