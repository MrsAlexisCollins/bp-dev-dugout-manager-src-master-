drop materialized view if exists legacy_models.start_warp_rolling;
create materialized view if not exists legacy_models.start_warp_rolling as 
select
	w1.season, w1.level_id, avg(w2.start_warp_rt) as start_warp_rt
from legacy_models.start_warp_raw w1, legacy_models.start_warp_raw w2
where w1.level_id = w2.level_id
and abs(w1.season-w2.season) < 3
group by w1.season, w1.level_id
order by 1;

grant select on legacy_models.start_warp_rolling to PUBLIC;
grant all privileges on legacy_models.start_warp_rolling to models;
