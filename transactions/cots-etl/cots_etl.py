""" 
Program that runs ETL on Cots Contracts
""" 

from cots_etl_functions import CotsETL
import time
import json 

cots = CotsETL()

# Load connection data 
print("Enter text file to use: ")
file = input()
with open(file) as json_file: # Use own connection file 
    conn_args = json.load(json_file)

startTime = time.time()
df = cots.cotsExtract(conn_args)
df_clean = cots.cotsTransformContracts(df)

cots.cotsLoad(conn_args, df_clean, "euston", "contracts")

print("Total time: {:.2f} secs".format(time.time() - startTime))
