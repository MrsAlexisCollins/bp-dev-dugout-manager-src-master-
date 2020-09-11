drop materialized view if exists legacy_models.ip_split_lg2;
create materialized view if not exists legacy_models.ip_split_lg2 as
select 
	season, level_id, league
	, avg(ip_g) as ip_g
	, avg(ip_start) as ip_gs
	, avg(ip_per_app) as ip_per_app 
	, sum(floor(innings_pitched) + (innings_pitched - floor(innings_pitched)) * 3.333333333333) as ip
	, sum(p.games_started * ip_start) / sum(p.games_started * ip_start + (p.games_pitched - p.games_started) * ip_per_app) as ip_split
	, sum(floor(innings_pitched) + (innings_pitched - floor(innings_pitched)) * 3.333333333333) * sum(p.games_started * ip_start) / sum(p.games_started * ip_start + (p.games_pitched - p.games_started) * ip_per_app) as ip_start
	, sum(floor(innings_pitched) + (innings_pitched - floor(innings_pitched)) * 3.333333333333) * (1 - sum(p.games_started * ip_start) / sum(p.games_started * ip_start + (p.games_pitched - p.games_started) * ip_per_app)) as ip_relief
	, sum(p.runs) / sum(floor(innings_pitched) + (innings_pitched - floor(innings_pitched)) * 3.333333333333) * 9 as RA 
	, (sum(p.runs * (p.games_started * ip_start) / nullif(p.games_started * ip_start + (p.games_pitched - p.games_started) * ip_per_app, 0))
		/ sum((floor(innings_pitched) + (innings_pitched - floor(innings_pitched)) * 3.333333333333) * 3 * (p.games_started * ip_start) / nullif(p.games_started * ip_start + (p.games_pitched - p.games_started) * ip_per_app, 0))) * 27 as ra_start
	, (sum(p.runs * ((p.games_pitched - p.games_started) * ip_start) / nullif(p.games_started * ip_start + (p.games_pitched - p.games_started) * ip_per_app, 0))
		/ sum((floor(innings_pitched) + (innings_pitched - floor(innings_pitched)) * 3.333333333333) * 3 * ((p.games_pitched - p.games_started) * ip_start) / nullif(p.games_started * ip_start + (p.games_pitched - p.games_started) * ip_per_app, 0))) * 27 as ra_relief
from mlbapi.stats_pitching p
join mlbapi.games_schedule_deduped gs using (game_pk)
join mlbapi.teams t on gs.home_team = t.id
join legacy_models.ip_split_lg isl using (season, level_id, league)  
where gs.game_type = 'R' 
and left(gs.status_code, 1) = 'F'
and gs.level_id = 1 
group by season, level_id, league;

grant select on legacy_models.ip_split_lg2 to PUBLIC;
grant all privileges on legacy_models.ip_split_lg2 to models;