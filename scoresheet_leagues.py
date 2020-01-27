from dugout_manager.cage_models import Scoresheet_leagues
from dugout_manager.connectors.cage import session_cage   #cage bound
import requests
from bs4 import BeautifulSoup


leagues_url =  'http://www.scoresheet.com/BB_LeagueList.php'
leagues_page = requests.get(leagues_url)
leagues_soup = BeautifulSoup(leagues_page.content,'html.parser')



leagues = leagues_soup.findAll('table')[1].findAll('a')
session_cage.query(Scoresheet_leagues).delete()  

for league in leagues:
    new_leauge = {}
    new_leauge['league_name'] = league.contents[0]
    new_leauge['league_path'] = league.get('href')
    new_leauge_row = Scoresheet_leagues(**new_leauge)
    session_cage.add(new_leauge_row) 

# session_cage.commit()
 
 

