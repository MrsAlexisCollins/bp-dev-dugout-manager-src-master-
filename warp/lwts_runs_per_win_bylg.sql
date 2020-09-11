drop materialized view if exists legacy_models.lwts_runs_per_win_bylg;

create materialized view if not exists legacy_models.lwts_runs_per_win_bylg as
select gs.season, gs.level_id, ht.league
	, avg(gs.away_score + gs.home_score) as rpg
	, power(avg(gs.away_score+gs.home_score),(1-.28))*2 as rpw 
from mlbapi.games_schedule_deduped gs 
left join mlbapi.teams ht on gs.home_team=ht.id 
where gs.game_type='R' 
and left(gs.status_code, 1)='F' 
group by gs.season, gs.level_id, ht.league;

grant select on legacy_models.lwts_runs_per_win_bylg to PUBLIC;
grant all privileges on legacy_models.lwts_runs_per_win_bylg to models;
