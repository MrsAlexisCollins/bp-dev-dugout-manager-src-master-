import requests
from bs4 import BeautifulSoup


leagues_url =  'http://www.scoresheet.com/BB_LeagueList.php'
leagues_page = requests.get(leagues_url)
leagues_soup = BeautifulSoup(leagues_page.content,'html.parser')
 
# <p><a href="../CWWW/AL_Al_Kaline.htm" target="_blank">AL Al Kaline</a></p>
# <p><a href="../CWWW/AL_Babe_Ruth.htm" target="_blank">AL Babe Ruth</a></p>