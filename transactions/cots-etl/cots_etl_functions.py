"""
Creates class CotsETL for Cots extract, transform, and load process. Contains three functions within the class: 
1. cotsExtract: function that calls BP postgresql server and obtains data from Cots Contracts. 
2. cotsTransform: function that transfroms Cots Contract data into BP format. 
3. cotsLoad: function that loads data back into BP postgresql server

Author: Martin Alonso 
Date: 2019-10-16
Update: 2020-05-26 - Cleaned cotsTransform
Update: 2020-05-28 - Added safeguards in cotsTransform to prevent date duplication; cleaner first_season calculation and transaction_type
"""

# Import libraries 
from dateutil.relativedelta import relativedelta
from sqlalchemy import create_engine 
from datetime import datetime 
import sqlalchemy as sql 
import pandas as pd 
import numpy as np
import itertools
import datetime
import psycopg2 
import sys 
import re 

class CotsETL(): 
    def __init__(self): 
        pass 

    def cotsExtract(self): 
        """
        Function that connects to BP PostgreSQL database and extracts Cots Contracts data. 
        Takes no arguments and requires a txt file with the database connection parameters
        """
        
        # Load txt file with connection strings, create the connection string 
        f = open("con1_con.txt", "r")
        ls = [x.strip() for x in f]

        # Connection string requires that the list be in the following order: 
        # ls[3]: user 
        # ls[2]: password
        # ls[1]: hostname 
        # ls[0]: database 
        conn_string = "postgresql+psycopg2://{}:{}@{}/{}".format(ls[3], ls[2], ls[1], ls[0])

        # Connect to the engine using conn_string 
        engine = create_engine(conn_string)
        conn = engine.connect()

        # Obtain contract data
        cots_df = pd.read_sql("select * from euston.player", con=conn)

        # Close connection 
        conn.close()

        # Return cots_df 
        return cots_df 

    def replace_dict(self, dictionary, txt):
        """ 
        Function that replaces team name with team abbreviation using key, value pairs in teams dictionary. 
        """
        dt = dictionary

        # Search for every team name in the list 
        rep = dict((re.escape(k), v) for k, v in dt.items())
        
        # Compile the pattern 
        pattern = re.compile("|".join(rep.keys()))

        # Replace the text and return it 
        text = pattern.sub(lambda x: rep[re.escape(x.group(0))], txt)
        
        return text

    def date_cleaning(self, date): 
        '''
        Function to clean and standardize date values 
        '''
        # If date value is missing, insert 1900-01-01
        dt = '01/01/1900' if date == None or date == "None" else date
        dt_split = dt.split("/")

        # If date value has day, month, and year, do yyyy-mm-dd...
        if len(dt_split) > 2: 
            day = dt_split[1][:2]
            month = dt_split[0][:2]
            year = dt_split[2] if len(dt_split[2]) == 4 else dt_split[2][-2:]
            date_new = year + '-' + month + '-' + day
            date_clean = datetime.datetime.strptime(date_new, '%Y-%m-%d').strftime('%Y-%m-%d') if\
                len(year) == 4 else datetime.datetime.strptime(date_new, '%y-%m-%d').strftime('%Y-%m-%d')
        # ...else, if only month and year are availabel, do yyyy-mm-01
        else: 
            month = dt_split[0][:2]
            year = dt_split[1] if len(dt_split[1]) == 4 else dt_split[1][-2:]
            date_new = year + '-' + month
            date_clean = datetime.datetime.strptime(date_new, '%Y-%m').strftime('%Y-%m-01') if\
                len(year) == 4 else datetime.datetime.strptime(date_new, '%y-%m').strftime('%Y-%m-01')
        
        return date_clean

    def first_season_cleaning(self, date, season):
        '''
        Function to fill first season value if missing 
        '''
        if date != '1900-01-01' and season == None: 
            fs = datetime.datetime.strptime(date, "%Y-%m-%d").year
        elif date == '1900-01-01' and season == None: 
            fs = None 
        else: 
            fs = float(season)

        # If contract is signed after september, first season takes place the following year. 
        m = datetime.datetime.strptime(date, '%Y-%m-%d').month
        y = float(datetime.datetime.strptime(date, '%Y-%m-%d').year)
        # Makes sure to only add a season if month is after September, fs is not null, and fs and signing year match. 
        if m >= 10 and fs != None and y == fs:
            fs += 1

        return fs

    def date_check(self, date, season): 
        dt = date 
        if dt == '1900-01-01': 
            new_date = str(int(season)) + dt[4:]
        else: 
            new_date = dt

        return new_date

    def cotsTransform(self, df): 
        """ 
        Function that transforms Cots Contracts data into a more readable data frame. 
        Takes a single argument: 
        * df: input Cots dataframe as extracted from BP PostgreSQL database. 
        """
        df = df

        # Split transaction details 
        transaction_details = df['cots_details'].str.split(";", expand=True)

        # Merge details back into the main df using indices 
        df_details = df.merge(transaction_details, left_index=True, right_index=True)

        # Drop ml_srv, agent, cots_lengthval, and cots_details columns 
        df_details.drop(['ml_srv', 'agent', 'cots_lengthval', 'cots_details'], axis=1, inplace=True)

        # Re-index df_details and melt dataframe 
        df_details['id'] = df_details.index
        cols_list = df_details.columns.values
        df_details_melt = pd.melt(df_details, 
                                value_vars=cols_list[1:-1], 
                                id_vars="bpid")

        # Rename columns and drop missing data 
        df_details_melt.rename(columns={"variable":"second_id", "value":"detail"}, inplace=True)
        df_details_melt.dropna(axis="rows", inplace=True)
        df_details_melt.sort_values(["bpid", "second_id"], inplace=True)

        """
        This next section deals with cleaning and restructuring the data. 
        First, three new columns are added: 
        1. team_id: this column will search for the team within each player detail and insert it into a new column. 
            However, we have to keep an eye out in case there are multiple team_ids within a comment.
        2. first_year: this will be the lowest year mentioned within detail.
        3. transaction_type: this will help us classify each transaction (i.e. Draft, Trade, Signed, etc...)
        
        Once these three items are created, we can move on to cleaning the details column to further populate the 
        table similar to how it looks in euston.contracts
        """

        # Acronyms dictionary; used to homogenize all team names within each contract detail. 
        acronyms = {'Anaheim':'LAA', 'ANA':'LAA', 
                'Arizona':'ARI', 'ARZ':'ARI', 
                'Atlanta':'ATL', 
                'Baltimore':'BAL', 
                'Boston':'BOS', 
                'Chicago Cubs':'CHN', 'CHC':'CHN',
                'Chicago White Sox':'CHA', 'CHW':'CHA', 'CWS':'CHA', 
                'Cincinnati':'CIN', 
                'Cleveland':'CLE', 
                'Colorado':'COL', 
                'Detroit':'DET', 'DT':'DET', 
                'Florida':'MIA', 'FLA':'MIA', 
                'Houston':'HOU', 
                'Kansas City':'KCA', 'KC':'KCA', 
                'LA Angels':'LAA', 
                'LA Dodgers':'LAN', 'LAD':'LAN', 
                'Miami':'MIA', 
                'Milwaukee':'MIL', 
                'Minnesota':'MIN', 
                'Montreal':'MON', 
                'NY Mets':'NYN', 'NYM':'NYN', 
                'NY Yankees':'NYA', 'NYY':'NYA', 
                'Oakland':'OAK', 
                'Philadelphia':'PHI', 
                'Pittsburgh':'PIT', 
                'St. Louis':'SLN', 'STL':'SLN', 
                'San Diego':'SDN', 'SD':'SDN', 
                'SF':'SFN', 'San Francisco':'SFN', 
                'Seattle':'SEA', 
                'Tampa Bay':'TBA', 'TB':'TBA',
                'Texas':'TEX', 'TX':'TEX', 
                'Toronto':'TOR', 
                'Washington':'WAS', 
                # Other acronyms
                'DFA': 'Designated for assignment', 
                'MVP': 'Most Valuable Player', 
                'LDS': 'League Division Series', 
                'LCS': 'League Championship Series', 
                'WS': 'World Series', 
                'UNC': 'University of North Carolina', 
                'USC': 'University of South Carolina', 
                'LSU': 'Louisiana State University',
                'UNL': 'University Nebraska-Lincoln', 
                'PED': 'Performance-Enhancing Drug', 
                'MLS': 'Major League Soccer', 
                'MLB': 'Major League Baseball', 
                'NPB': 'Nippon Professional Baseball', 
                'KBO': 'Korean Baseball Organization', 
                'MRI': 'Magnetic Resonance Image', 
                'USA': 'United States of America', 
                'AND': 'and'}

        # Replaces the team name in the detail column for homogenization. 
        df_details_melt.loc[:, "detail"] = df_details_melt.detail.apply(lambda x: CotsETL().replace_dict(acronyms, x))

        # Within details contracts, there are some subdetails that need to be further broken down.
        sub_details = df_details_melt.detail.str.split(r"\.\s", expand=True)
        sub_details_cols = sub_details.columns.values
        df_details_melt2 = df_details_melt.merge(sub_details, left_index=True, right_index=True)
        df_details_melt2['id2'] = df_details_melt2.index
        
        # Melt new df once again to obtain all contract details in one column
        df_details_melt3 = pd.melt(df_details_melt2, 
                            value_vars=sub_details_cols, 
                            id_vars=['bpid','second_id'])

        # Reset the index and sort values. 
        df_details_melt3.reset_index(inplace=True)
        df_sort = df_details_melt3.sort_values(["bpid"]).sort_values(["second_id", "variable"], ascending=True)

        # Drop missing data from value column
        df_no_na = df_sort.dropna(subset=["value"])

        # Keep all transaction types
        trns = r'([Dd]rafted.+|[Ss]igned.+|[Rr]e-signed.+|[Aa]cquired.+|[Rr]eleased.+|[Cc]ontract purchased.+|[Cc]ontract selected.+|[Dd]esignated for assignment.+|[Rr]etired.+|\d{1,}.+[Yy]ear.+|\$.+[Ss]igning bonus|[Oo]ptioned.+|[Rr]ecalled.+|[Nn]on-tendered.+)'

        df_no_na.loc[:, 'transaction'] = df_no_na.loc[:, 'value'].astype(str).\
            apply(lambda x: re.findall(trns, x))

        # Make sure that we keep only text in the column and insert None if no data is available
        df_no_na.loc[:, "transaction"] = df_no_na.loc[:, "transaction"].astype(str).apply(lambda x: str(x)[2:-2] if len(x)>0 else None)
        df_no_na.loc[:, "transaction"].replace("", np.nan, inplace=True)
        df_no_na.dropna(subset=["transaction"], inplace=True)

        # Obtain team_id, first season, transaction type, and date for each contract detail 
        df_no_na.loc[:, "team_id"] = df_no_na.loc[:, 'transaction'].astype(str).\
            apply(lambda x: re.findall(r'[A-Z]{3}', x))
        df_no_na.loc[:, 'first_season'] = df_no_na.loc[:, 'transaction'].astype(str).\
            apply(lambda x: re.findall(r'\((\d{4})\.?', x))

        # Further isolate transactions
        trns_only = r'([Dd]rafted|[Ss]igning bonus|[Ss]igned|[Rr]e-signed|[Aa]cquired|[Rr]eleased|[Cc]ontract purchased|[Cc]ontract selected|[Dd]esignated for assignment|[Rr]etired|[Oo]ptioned|[Rr]ecalled|[Nn]on-tendered)'

        df_no_na.loc[:, 'transaction_type'] = df_no_na.loc[:, 'transaction'].astype(str).\
            apply(lambda x: re.findall(trns_only, x.lower()))
        df_no_na.loc[:, 'date'] = df_no_na.loc[:, 'transaction'].astype(str).\
            apply(lambda x: re.findall(r'(\d{1,}\/\d{1,}\/?\d{1,}\d?)', x))

        # Clean each variable, inserting None if there is no data 
        df_no_na.loc[:, 'team_id'] = df_no_na.loc[:, 'team_id'].\
            apply(lambda x: x[0] if len(x) >= 1 else None)
        df_no_na.loc[:, 'first_season'] = df_no_na.loc[:, 'first_season'].\
            apply(lambda x: x[0] if len(x) >= 1 else None)
        df_no_na.loc[:, 'transaction_type'] = df_no_na.loc[:, 'transaction_type'].\
            apply(lambda x: x[0] if len(x) >= 1 else None)
        df_no_na.loc[:, 'date'] = df_no_na.loc[:, 'date'].\
            apply(lambda x: x[0] if len(x) > 0 else None)

        df_no_na.reset_index(inplace=True)

        # Transaction type dictionary to standardize names 
        trns_type = {
            "drafted": "Draft", 
            "acquired": "Trade",
            "released": "Release", 
            "retired": "Retire", 
            "contract purchased": "Call-up", 
            "contract selected": "Call-up", 
            "designated for assignment": "Designated For Assignment", 
            "signed": "Sign", 
            "re-signed": "Sign", 
            "signing bonus": "Sign", 
            "None": "None", 
            "optioned": "Sent down", 
            "recalled": "Call-up", 
            "non-tendered": "Release"
        }

        # Replaces the team name in the detail column for homogenization. 
        df_no_na.loc[:, "transaction_type2"] = df_no_na.loc[:, "transaction_type"].astype(str).\
            apply(lambda x: CotsETL().replace_dict(trns_type, x))
        df_reset = df_no_na.iloc[:, 2:].reset_index()

        # Clean some outstanding variables 
        ## Dates 
        df_reset.loc[df_reset[(df_reset['bpid']=='67154') & \
            (df_reset['date']=='3/38/17')].index, 'date'] = '3/28/17'
        df_reset.loc[df_reset[(df_reset['bpid']=='107932') & \
            (df_reset['date']=='11/20/1')].index, 'date'] = '1/11/20'
        df_reset.loc[df_reset[(df_reset['bpid']=='47495') & \
            (df_reset['date']=='11/23')].index, 'date'] = '11/23/11'
        df_reset.loc[df_reset[(df_reset['bpid']=='33335') & \
            (df_reset['date']=='12/9/11') & \
                (df_reset['team_id']=='TOR')].index, 'date'] = '12/20/12'
        df_reset.loc[df_reset[(df_reset['bpid']=='40947') & \
            (df_reset['date']=='5/50')].index, 'date'] = '5/05'
        df_reset.loc[df_reset[(df_reset['bpid']=='1333') & \
            (df_reset['date']=='2/93') & \
                (df_reset['team_id']=='MON')].index, 'date'] = '2/94'
        df_reset.loc[df_reset[(df_reset['bpid']=='419') & \
            (df_reset['first_season']==204)].index, 'date'] = 2004
        df_reset.loc[df_reset[(df_reset['bpid']=='70783') & \
            (df_reset['team_id']=='NYN') & \
                (df_reset['date']=='11/17')].index, 'date'] = '11/18'
        df_reset.loc[df_reset[(df_reset['bpid']=='34765') & \
            (df_reset['team_id']=='KCA') & \
                (df_reset['date']=='12/05')].index, 'date'] = '6/05'
        df_reset.loc[df_reset[(df_reset['bpid']=='58568') & \
            (df_reset['date']=='12/2119')].index, 'date'] = '12/2019'
        df_reset.loc[df_reset[(df_reset['bpid']=='58643') & \
            (df_reset['date']=='12/19/20')].index, 'date'] = '12/19/12'
        
        ## First season 
        df_reset.loc[df_reset[(df_reset['bpid']=='1211') & \
            (df_reset['date']=='12/04') & \
                (df_reset['transaction_type']=='Re-signed')].index, 'first_season'] = 2005
        df_reset.loc[df_reset[(df_reset['bpid']=='419') & \
            (df_reset['first_season']=='0204')].index, 'first_season'] = 2004
        
        ## Team
        df_reset.loc[df_reset[(df_reset['bpid']=='1274') & \
            (df_reset['date']=='1/03')].index, 'team_id'] = 'TEX'
        df_reset.loc[df_reset[(df_reset['bpid']=='1608') & \
            (df_reset['date']=='3/98') & \
                (df_reset['transaction_type']=='Retired')].index, 'team_id'] = 'NPB'
        df_reset.loc[df_reset[(df_reset['bpid']=='50158') & \
            (df_reset['team_id']=='TOR') & \
                (df_reset['date']=='2/21/09')].index, 'team_id'] = 'CIN'
        df_reset.loc[df_reset[(df_reset['bpid']=='1115') & \
            (df_reset['transaction_type2']=='Sign') & \
                (df_reset['date']=='1/06')].index, 'team_id'] = 'CLE'
        df_reset.loc[df_reset[(df_reset['bpid']=='31549') & \
            (df_reset['second_id'].isin([4, 5, 6]))].index, 'team_id'] = 'ATL'

        # Standardize dates to yyyy-mm-dd
        df_reset.loc[:, 'date'] = df_reset.loc[:, 'date'].astype(str).apply(lambda x: CotsETL().date_cleaning(x))
        
        # Fill in missing first season values 
        df_reset['first_season'] = df_reset.apply(lambda x: \
            CotsETL().first_season_cleaning(x['date'], x['first_season']), axis=1)

        df_reset['first_season'] = df_reset['first_season'].astype(float)

        # Sort dataframe and use ffill to fill team_id values
        df_ffill = df_reset.sort_values(['bpid', 'first_season', 'date'], ascending=False)
        df_ffill['team_id'] = df_ffill.groupby('bpid')['team_id'].transform(lambda x: x.ffill())

        # Clean draft data 
        draft = df_ffill[df_ffill['transaction_type2']=='Draft']
        non_draft = df_ffill[df_ffill['transaction_type2']!='Draft']

        # Make sure that draft season is correct  
        draft.reset_index(inplace=True)
        draft.loc[:, 'first_season'] = draft.loc[:, 'transaction'].apply(lambda x: re.findall(r'\d{4}', x))
        draft.loc[:, 'first_season'] = draft.loc[:, 'first_season'].apply(lambda x: x[0] if len(x) >= 1 else None)
        draft = draft.iloc[:, 1:]

        # Merge back corrected draft season with remaining data set 
        df_merge = pd.concat([draft, non_draft], axis=0)
        df_merge['first_season'] = df_merge.first_season.astype(float)
        df_merge = df_merge.sort_values(['bpid', 'first_season', 'date'], ascending=False)

        df_merge.reset_index(inplace=True)

        """
        Now that the data has been transformed, this section will start trimming the data and columns, 
        making sure that only the required columns for the Load section remain. 
        """
        # Keep only five columns 
        all_transactions = df_merge[['bpid', 'date', 'team_id', 'first_season', 'transaction_type2']]\
            .sort_values(['bpid', 'first_season', 'date'], ascending=False)
        
        # Filter out NaN
        all_transactions = all_transactions[~all_transactions['first_season'].isna()]

        # Keep all contracts that were either signed or where the player retired 
        signed_contracts = all_transactions[all_transactions['transaction_type2'].isin(['Sign'])]
        signed_contracts['cumcount'] = signed_contracts.groupby(['bpid', 'team_id', 'first_season'])['date'].cumcount()

        # Keep contracts where the player retired or the first cumulative count equals 0.
        clean_contracts = signed_contracts[(signed_contracts['transaction_type2']=='Retire') | (signed_contracts['cumcount']==0)]
        clean_contracts.reset_index(inplace=True)
        clean_contracts.rename(columns={'index':'contract_id', 'date':'signed_date', 'team_id':'signing_org'}, inplace=True)

        # Calculate number of years the contract will last 
        clean_contracts.loc[:, 'duration_years_actual'] = clean_contracts.groupby(['bpid'])['first_season'].diff()
        clean_contracts.loc[:, 'duration_years_actual'] = clean_contracts.loc[:, 'duration_years_actual'] * -1 
        clean_contracts.loc[:, 'duration_years_actual'] = clean_contracts.loc[:, 'duration_years_actual'].fillna(0)
        clean_contracts.loc[:, 'duration_years_actual'] = clean_contracts.loc[:, 'duration_years_actual'].replace(-0, 0)

        # Calculates the maximum and minimum number of years the contract may last 
        clean_contracts.loc[:, 'terminated_date'] = None
        clean_contracts.loc[:, 'duration_years_base'] = clean_contracts.loc[:, 'duration_years_actual']
        clean_contracts.loc[:, 'duration_years_max'] = clean_contracts.loc[:, 'duration_years_actual']
        clean_contracts.loc[:, 'duration_years_base'] = clean_contracts.loc[:, 'duration_years_base'].replace(0, 1)

        # Make sure the signed date is aligned with the first_season. 
        clean_contracts['signed_date'] = clean_contracts.apply(\
            lambda x: CotsETL().date_check(x['signed_date'], x['first_season']), axis=1)

        # Keep only necessary columns 
        contracts = clean_contracts[['contract_id', 'bpid', 'signed_date', \
            'terminated_date', 'duration_years_max', 'duration_years_base', \
                'duration_years_actual', 'signing_org', 'first_season']] 

        # Add update column 
        contracts.loc[:, 'last_update'] = datetime.datetime.today()       

        return contracts

    def batch_load(self, df, schema, table, con):
        """
        Function to load data frame into PostgreSQL in batches. 
        """ 
        # List columns of data frame 
        df_columns = list(df)
        columns = ",".join(df_columns)

        # Delete all items from the current table
        delete_stmt = "DELETE FROM public.temp_contracts"

        # Set values and insert statement 
        values = "VALUES({})".format(",".join(["%s" for _ in df_columns]))
        insert_stmt = "INSERT INTO public.temp_contracts({}) {}".format(columns, values)

        # Create a cursor and execute the delete and insert statements 
        cur = con.cursor()
        cur.execute(delete_stmt)
        psycopg2.extras.execute_batch(cur, insert_stmt, df.values)
        con.commit()

        """
        Update euston.contracts with data from temp_contracts. 
        """
        # Update statement 
        update_stmt = """UPDATE {}.{} 
                        SET 
                            contract_id = tc.contract_id 
                            , bpid = tc.bpid 
                            , signed_date = tc.signed_date 
                            , terminated_date = tc.terminated_date 
                            , duration_years_max = tc.duration_years_max 
                            , duration_years_base  = tc.duration_years_base
                            , duration_years_actual = tc.duration_years_actual 
                            , signing_org = tc.signing_org 
                            , first_season = tc.first_season 
                            , last_update = tc.last_update 
                        FROM 
                            public.temp_contracts tc
                        WHERE 
                            {}.{}.contract_id = tc.contract_id 
                            and {}.{}.bpid = tc.bpid; 
                    """.format(schema, table, schema, table, schema, table)

        # Execute the update statement
        cur.execute(update_stmt)

        # Commit and lose connection
        con.commit()
        cur.close()

    def cotsLoad(self, df, schema, table):
        """
        Function that takes a single argument, a data frame, and connects to BP PostgreSQL database
        to load the transformed Cots Contracts data. 
        Requires the same txt file with the database connection parameters used in cotsExtract(), with the difference
        that the database is different. 
        """

        # Load txt file with connection strings, create the connection string 
        f = open("con1_con.txt", "r")
        ls = [x.strip() for x in f]

        # Connection string requires that the list be in the following order: 
        # ls[3]: user 
        # ls[2]: password
        # ls[1]: hostname 
        # ls[0]: database 
        host, port = ls[1].split(':')
        conn = psycopg2.connect(dbname="cage", user=ls[3], password=ls[2], host=host, port=port, \
                options = f'-c search_path={schema}',)

        CotsETL().batch_load(df, schema, table, conn)

        print("Database upload succesful.")
