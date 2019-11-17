
from dugout_manager.mlb_entitas.read import mlb_persons  
from datetime import datetime

uploads = []

for result in mlb_persons.all():
    row = {} 
    row['bpid'] = result.bpxref[0].bpid
    row['use_full_name'] = result.full_name
    row['updated_timestamp'] = datetime.now() 

    uploads.append(row)

print(uploads) 