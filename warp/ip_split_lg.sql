drop materialized view if exists legacy_models.ip_split_lg;
create materialized view if not exists legacy_models.ip_split_lg as (
--
select *
	, ip_g - ip_start as ip_relief
	, (ip_g - ip_start) / relief_app_per_game as ip_per_app
from (
	select
		season
		, level_id
		, league
		, sum(games_started) as gs
		, sum(games_pitched-games_started) / cast(sum(games_started) as decimal) as relief_app_per_game
		, ((sum(floor(innings_pitched) + (innings_pitched - floor(innings_pitched)) * 3.333333333333)) * 3)::int as ip_outs
		, (sum(floor(innings_pitched) + (innings_pitched - floor(innings_pitched)) * 3.333333333333)) / sum(games_started) as ip_g
		, ((sum(((floor(innings_pitched) + ((innings_pitched - floor(innings_pitched)) * 3.333333333333)) * 3) / nullif(games_started, 0) * greatest(games_started - (games_pitched - games_started), 0))) 
			/ sum(greatest(games_started - (games_pitched - games_started), 0))) / 3 as ip_start		--why did MySQL not need the nullif
	from mlbapi.stats_pitching p
	join mlbapi.games_schedule_deduped gs using (game_pk)
	join mlbapi.teams t  on gs.home_team = t.id
	where gs.game_type = 'R' 
	and left(gs.status_code, 1) = 'F'
	and games_pitched >= games_started
	and gs.level_id = 1
	group by season
		, level_id
		, league
	) s
);

grant select on legacy_models.ip_split_lg to PUBLIC;
grant all privileges on legacy_models.ip_split_lg to models;
