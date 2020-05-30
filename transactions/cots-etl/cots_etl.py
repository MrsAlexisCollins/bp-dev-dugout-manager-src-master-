""" 
Program that runs ETL on Cots Contracts
""" 

from cots_etl_functions import CotsETL
from datetime import datetime 

cots = CotsETL()

startTime = datetime.now()
df = cots.cotsExtract()
df_clean = cots.cotsTransform(df)
cots.cotsLoad(df_clean, "euston", "contracts")

print(datetime.now() - startTime)
