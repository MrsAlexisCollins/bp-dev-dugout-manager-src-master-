### set season ###

season <- 2020

### load packages ###

if (!require("pacman")) install.packages("pacman")
pacman::p_load(RPostgres,
               tidyverse)

### acquire data ###

## Open DB Connection (requires my.con1.maker.R) ####
source("my.conpg.maker.R") #your con1 <- mysql with your credentials
con1 <- dbConnect(RPostgreSQL::PostgreSQL(),user=con_pg.user,password=con_pg.password,dbname=con_pg.dbname,host=con_pg.host)
rm(con_pg.password)
## 0 - Variables for use later
BRR_qualifying_event_codes <- c(2,4,6,9,10,18,19,20,21,22) # This is a powerful set of variables 

## 1 - Getting data for use, maybe using a new paradigm -- NOPE
re_diff_run.query <- paste("select t.*, 
	re1.base, 
	(re1.runs::numeric /re1.total) as start_re,
	(re2.runs::numeric /re2.total) as end_re
from (SELECT season, level_id, outs_ct, event_outs_ct 
		, outs_ct + event_outs_ct AS end_outs_ct
		, COUNT(*) AS Num
	FROM mlbapi.warehouse_events we 
	WHERE season = ", season,
	"and game_type = 'R' and level_id = 1
	GROUP BY season, level_id, outs_ct, event_outs_ct, end_outs_ct ) t
inner join legacy_models.runner_runs re1 
on (re1.season = t.season 
and t.level_id = re1.level_id 
and t.outs_ct = re1.outs) 
inner join legacy_models.runner_runs re2
on ( re2.season = t.season
and t.level_id = re2.level_id
and t.end_outs_ct = re2.outs
and re1.base = re2.base)", sep = "")


re_diff_run.data <- dbGetQuery(con1, re_diff_run.query)
re_diff_run.data.wide <- re_diff_run.data%>%   
  pivot_wider(
    names_from = base,
    names_glue = "{.value}_{base}",
    values_from = c(start_re, end_re)
  )

# Getting events data for the rest of the script 
events.query <- paste(
  "with baseout_mod as (
	SELECT DISTINCT baseout.game_pk,
    	        baseout.at_bat_index,
            	last_value(baseout.event_index) OVER w AS event_index_end,
            	last_value(baseout.outs_pre) OVER w AS outs_pre,
            	last_value(baseout.away_score_pre) over w AS away_score_pre,
            	last_value(baseout.home_score_pre) OVER w AS home_score_pre,
            	last_value(baseout.firstbase_pre) OVER w AS firstbase_pre,
            	last_value(baseout.secondbase_pre) OVER w AS secondbase_pre,
            	last_value(baseout.thirdbase_pre) OVER w AS thirdbase_pre,
            	last_value(baseout.outs_end) OVER w AS outs_end,
            	last_value(baseout.away_score_end) OVER w AS away_score_end,
            	last_value(baseout.home_score_end) OVER w AS home_score_end,
            	last_value(baseout.firstbase_end) OVER w AS firstbase_end,
            	last_value(baseout.secondbase_end) OVER w AS secondbase_end,
            	last_value(baseout.thirdbase_end) OVER w AS thirdbase_end
	FROM mlbapi.baseout baseout
	join mlbapi.games_schedule_deduped gs ON baseout.game_pk = gs.game_pk AND left(gs.status_code, 1) = 'F'::text
	where gs.season = ", season, "and gs.game_type = 'R' and gs.level_id = 1 
	window w as (PARTITION BY baseout.game_pk, baseout.at_bat_index ORDER BY baseout.event_index RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
),
start_base_tbl as (
	select game_pk, at_bat_index, 
		   unnest(array[1, 2, 3]) AS start_base,
       	   unnest(array[firstbase_pre, secondbase_pre, thirdbase_pre]) AS id
    from baseout_mod),
end_base_tbl as (
	select game_pk, at_bat_index, 
		unnest(array[1, 2, 3]) AS end_base,
       	unnest(array[firstbase_end, secondbase_end, thirdbase_end]) AS id
    from baseout_mod), 
on_base_stayers as (
	select sb.game_pk, sb.at_bat_index, sb.id as runner_id, sb.start_base, eb.end_base
	from start_base_tbl sb 
	inner join end_base_tbl eb using (game_pk, at_bat_index, id)
),
wide_dest as (
	select 
  		p.game_pk,
 		p.inning,  
  		case when p.half_inning = 'top' then 0 else 1 end as bat_home_id, 
  		at_bat_index,
  		event_index as ab_ev, 
  		runner_id, 
  		min( (case when start_base is null then 0 
  			  else left(start_base,1)::int end) ) as start_base, 
  		case when bool_or(is_out) then 0
  	   		 else max( (case when end_base = 'score' then 4 
  	   				    else left(end_base,1)::int end) ) end as end_base, 
  		bool_or(is_out) as is_out_any 
	from mlbapi.runners r 
	left join mlbapi.plays p using (game_pk, at_bat_index) 
	join mlbapi.games_schedule_deduped gs ON p.game_pk = gs.game_pk AND left(gs.status_code, 1) = 'F'::text
	where gs.season = ", season, "and gs.game_type = 'R' and gs.level_id = 1 
	group by p.game_pk, p.inning, p.half_inning, event_index, at_bat_index, runner_id
	order by p.game_pk, at_bat_index, runner_id, start_base),
wide_dest_final as (
	select game_pk, at_bat_index, runner_id, min(start_base) as start_base, case when bool_or(end_base = 0) then 0 else max(end_base) end as end_base
	from (
		select wd.game_pk, wd.at_bat_index, wd.runner_id, wd.start_base, wd.end_base 	
		from wide_dest wd
		union all
		select obs.game_pk, obs.at_bat_index, obs.runner_id, obs.start_base, obs.end_base
		from on_base_stayers obs 
		order by game_pk, at_bat_index, start_base
	) combined_runner_transition
	group by game_pk, at_bat_index, runner_id
	order by game_pk, at_bat_index, start_base),
runner_dests as (
	select 
    	game_pk, at_bat_index as event_id,
    	unnest(array_agg(runner_id) filter(where start_base = 0)) as batter_id,
    	unnest(array_agg(end_base) filter(where start_base = 0)) as batter_dest_id,
		unnest(array_agg(runner_id) filter(where start_base = 1)) as run1_id, 
		unnest(array_agg(end_base) filter(where start_base = 1))::int as run1_dest_id,
		unnest(array_agg(runner_id) filter(where start_base = 2)) as run2_id, 
		unnest(array_agg(end_base) filter(where start_base = 2))::int as run2_dest_id,
		unnest(array_agg(runner_id) filter(where start_base = 3)) as run3_id, 
		unnest(array_agg(end_base) filter(where start_base = 3))::int as run3_dest_id
	from wide_dest_final 
	group by game_pk, at_bat_index)
select 
	we.season,
	we.level_id, 
	we.game_pk,
	we.inn_ct,
	we.event_id, 
	we.outs_ct,
	we.event_cd, 
	we.battedball_cd,
	we.fld_team,
	we.fld_cd,
	we.pitcher_id,
	we.pos2_fld_id,
	we.pos3_fld_id,
	we.pos4_fld_id,
	we.pos5_fld_id,
  we.pos6_fld_id,
	we.pos7_fld_id,
	we.pos8_fld_id,
	we.pos9_fld_id,
	we.run1_origin_event_id,
	we.run2_origin_event_id, 
	we.run3_origin_event_id, 
	coalesce(rd.batter_dest_id, 0) as batter_dest_id, 
	rd.run1_id, coalesce(rd.run1_dest_id, 0) as run1_dest_id, 
	rd.run2_id, coalesce(rd.run2_dest_id, 0) as run2_dest_id, 
	rd.run3_id, coalesce(rd.run3_dest_id, 0) as run3_dest_id,
	we.ass1_fld_cd, 
	we.ass2_fld_cd,
	we.ass3_fld_cd
from mlbapi.warehouse_events we 
left join runner_dests rd 
on (we.game_pk = rd.game_pk 
and we.event_id = rd.event_id)
where we.season = ", season, "and we.game_type = 'R' and we.level_id = 1", sep = "")

events.data <- dbGetQuery(con1, events.query) %>% 
  filter(event_cd %in% BRR_qualifying_event_codes)

## Augmenting and cleaning the event data for all of the necessary processes.

# Batter Event Flag Setting
bat_event_codes <- c(2,3,14,15,16,17,18,19,20,21,22,23)

batter_event_flag <- quos(
  .data$event_cd %in% bat_event_codes ~ 1,
  TRUE ~ 0
)
# BRR Event Code Translation 
stolen_base_codes <- c(4,6)
wild_passed_codes <- c(9,10)
out_codes <- c(2,19)
normal_codes <- c(18, 20, 21, 22)

event_code_cases <- quos(
  .data$event_cd %in% stolen_base_codes ~ "SBA",
  .data$event_cd %in% wild_passed_codes ~ "WPPB",
  .data$event_cd %in% out_codes 
  & .data$battedball_cd == "G" ~ "G",
  .data$event_cd %in% out_codes 
  & (.data$battedball_cd != "G" |
       is.na(.data$battedball_cd))~ "A",
  .data$event_cd %in% normal_codes ~ as.character(.data$event_cd),
  TRUE ~ NA_character_)

# Fielder ID case analysis 
fielder_id_cases <- quos(
  .data$fld_cd == 1 ~ .data$pitcher_id,
  .data$fld_cd == 2 ~ .data$pos2_fld_id,
  .data$fld_cd == 3 ~ .data$pos3_fld_id,
  .data$fld_cd == 4 ~ .data$pos4_fld_id,
  .data$fld_cd == 5 ~ .data$pos5_fld_id,
  .data$fld_cd == 6 ~ .data$pos6_fld_id,
  .data$fld_cd == 7 ~ .data$pos7_fld_id,
  .data$fld_cd == 8 ~ .data$pos2_fld_id,
  .data$fld_cd == 9 ~ .data$pos3_fld_id
)

# Adding columns for joining & processing later down the line
# In particular, the "outs_batter_join" and "event_outs" columns are meant 
# to replace join conditions in the original SQL code that were functions of parameters.
events.data <- events.data %>% 
  mutate(
    bat_event_fl = case_when(!!!batter_event_flag),
    event = case_when(!!!event_code_cases), 
    fld_id = case_when(!!!fielder_id_cases),
    outs_batter_join = outs_ct + 
      if_else(batter_dest_id == 0 & bat_event_fl == 1, 1 ,0),
    run1_event_outs = if_else(run1_dest_id == 0, 1, 0),
    run2_event_outs = if_else(run2_dest_id == 0, 1, 0),
    run3_event_outs = if_else(run3_dest_id == 0, 1, 0)) %>%
  dplyr::select(-c(pitcher_id, pos2_fld_id, pos3_fld_id, pos4_fld_id,
            pos5_fld_id, pos6_fld_id, pos7_fld_id, pos8_fld_id, pos9_fld_id))


test <- events.data %>% 
  filter((run1_origin_event_id > 0 & is.na(run1_id)) |
         (run2_origin_event_id > 0 & is.na(run2_id)) |
         (run3_origin_event_id > 0 & is.na(run3_id)) )
## 2 - Average run expectancy per base(?)

## Filter for each starting base, have separate DFs, then bind based on base. 
## While this is suboptimal (and could be done with smart pivoting), we just don't have time.
# In fact, we can just get tables of events relevant to each type of baserunner, I think.

run1.events <- events.data %>% 
  filter(run1_origin_event_id > 0, 
         run2_origin_event_id == 0, 
         (run3_origin_event_id == 0 | event == "SBA"))

# Now, we can join the expectancy table.
baserunning_runs.run1 <- run1.events %>% 
  inner_join(re_diff_run.data.wide, 
            by = c("season", "level_id", "outs_batter_join" = "outs_ct",
                   "run1_event_outs" = "event_outs_ct"))

# And then compute the per-event run values 
baserunning_runs.run1 <- baserunning_runs.run1 %>% 
  transmute(season, 
            level_id,
            game_pk,
            inn_ct, 
            event_id,
            outs_ct, 
            run_id = run1_id,
            fld_team, 
            fld_id,
            fld_cd,
            event, 
            base_end = run1_dest_id,
            start_re = start_re_1, 
            end_re = 
              case_when(
                run1_dest_id == 0 ~ 0,
                run1_dest_id == 1 ~ end_re_1,
                run1_dest_id == 2 ~ end_re_2,
                run1_dest_id == 3 ~ end_re_3,
                run1_dest_id > 3 ~ 1,
                TRUE ~ NA_real_),
            trail_reb_play = 
              case_when(
                batter_dest_id == 1 
                 & run1_dest_id == 0 ~ end_re_1 - start_re_0,
                batter_dest_id == 2 
                 & run1_dest_id == 0 ~ end_re_2 - start_re_0, 
                batter_dest_id == 3
                 & run1_dest_id == 0 ~ end_re_3 - start_re_0,
                TRUE ~ 0),
            trail_re1_play = 0,
            trail_re2_play = 0,
            trail_re_play = trail_reb_play + trail_re1_play + trail_re2_play,
            re_diff_notrail_play = end_re - start_re, 
            re_diff_play = re_diff_notrail_play + trail_re_play,
            ass1_fld_cd, 
            ass2_fld_cd,
            ass3_fld_cd)

# Standalone version of the run average table
run1_avg_re <- baserunning_runs.run1 %>% 
  group_by(season, level_id, outs_ct, event, fld_cd) %>% 
  summarize(event_count = n(),
            across(ends_with("_play"), mean)) %>% 
  rename_with(~ gsub("_play", "_lg", .x, fixed = TRUE), ends_with("_play")) %>% 
  ungroup()
            
# Now to place the run averages in the table itself (sans join!)
baserunning_runs.run1 <- baserunning_runs.run1 %>% 
  group_by(season, level_id, outs_ct, event, fld_cd) %>% 
  mutate(re_diff_lg = mean(re_diff_play)) %>% 
  ungroup() %>% 
  mutate(re_diff = re_diff_play - re_diff_lg)

         
# Repeat the process for the runner starting at 2nd. 
run2.events <- events.data %>% 
  filter(run2_origin_event_id > 0, 
         run3_origin_event_id == 0)

# Now, we can join the expectancy table.
baserunning_runs.run2 <- run2.events %>% 
  inner_join(re_diff_run.data.wide, 
             by = c("season", "level_id", "outs_batter_join" = "outs_ct",
                    "run1_event_outs" = "event_outs_ct"))

# And then compute the per-event run values for runner 2
baserunning_runs.run2 <- baserunning_runs.run2 %>% 
  transmute(season, 
            level_id,
            game_pk,
            inn_ct, 
            event_id,
            outs_ct, 
            run_id = run1_id,
            fld_team, 
            fld_id,
            fld_cd,
            event, 
            base_end = run1_dest_id,
            start_re = start_re_2, 
            end_re = 
              case_when(
                run2_dest_id == 0 ~ 0,
                run2_dest_id == 1 ~ end_re_1,
                run2_dest_id == 2 ~ end_re_2,
                run2_dest_id == 3 ~ end_re_3,
                run2_dest_id > 3 ~ 1,
                TRUE ~ NA_real_),
            trail_reb_play = 
              case_when(
                batter_dest_id == 1 
                & run2_dest_id == 0 ~ end_re_1 - start_re_0,
                batter_dest_id == 2 
                & run2_dest_id == 0 ~ end_re_2 - start_re_0, 
                batter_dest_id == 3
                & run2_dest_id == 0 ~ end_re_3 - start_re_0,
                TRUE ~ 0),
            trail_re1_play = 
              case_when(
                run1_dest_id == 1 
                & run2_dest_id == 0 ~ end_re_1 - start_re_1,
                run1_dest_id == 2 
                & run2_dest_id == 0 ~ end_re_2 - start_re_1, 
                run1_dest_id == 3
                & run2_dest_id == 0 ~ end_re_3 - start_re_1,
                TRUE ~ 0),
            trail_re2_play = 0,
            trail_re_play = trail_reb_play + trail_re1_play + trail_re2_play,
            re_diff_notrail_play = end_re - start_re, 
            re_diff_play = re_diff_notrail_play + trail_re_play,
            ass1_fld_cd, 
            ass2_fld_cd,
            ass3_fld_cd)

# Standalone version of the run average table for runner 2
run2_avg_re <- baserunning_runs.run2 %>% 
  group_by(season, level_id, outs_ct, event, fld_cd) %>% 
  summarize(event_count = n(),
            across(ends_with("_play"), mean)) %>% 
  rename_with(~ gsub("_play", "_lg", .x, fixed = TRUE), ends_with("_play")) %>% 
  ungroup()

# Now to place the run averages in the table itself (sans join!)
baserunning_runs.run2 <- baserunning_runs.run2 %>% 
  group_by(season, level_id, outs_ct, event, fld_cd) %>% 
  mutate(re_diff_lg = mean(re_diff_play)) %>% 
  ungroup() %>% 
  mutate(re_diff = re_diff_play - re_diff_lg)

# And one more time for the runner starting at 3rd 
run3.events <- events.data %>% 
  filter(run3_origin_event_id > 0)

# Now, we can join the expectancy table.
baserunning_runs.run3 <- run3.events %>% 
  inner_join(re_diff_run.data.wide, 
             by = c("season", "level_id", "outs_batter_join" = "outs_ct",
                    "run1_event_outs" = "event_outs_ct"))

# And then compute the per-event run values for runner 3
baserunning_runs.run3 <- baserunning_runs.run3 %>% 
  transmute(season, 
            level_id,
            game_pk,
            inn_ct, 
            event_id,
            outs_ct, 
            run_id = run1_id,
            fld_team, 
            fld_id,
            fld_cd,
            event, 
            base_end = run1_dest_id,
            start_re = start_re_3, 
            end_re = 
              case_when(
                run3_dest_id == 0 ~ 0,
                run3_dest_id == 1 ~ end_re_1,
                run3_dest_id == 2 ~ end_re_2,
                run3_dest_id == 3 ~ end_re_3,
                run3_dest_id > 3 ~ 1,
                TRUE ~ NA_real_),
            trail_reb_play = 
              case_when(
                batter_dest_id == 1 
                & run3_dest_id == 0 ~ end_re_1 - start_re_0,
                batter_dest_id == 2 
                & run3_dest_id == 0 ~ end_re_2 - start_re_0, 
                batter_dest_id == 3
                & run3_dest_id == 0 ~ end_re_3 - start_re_0,
                TRUE ~ 0),
            trail_re1_play = 
              case_when(
                run1_dest_id == 1 
                & run3_dest_id == 0 ~ end_re_1 - start_re_1,
                run1_dest_id == 2 
                & run3_dest_id == 0 ~ end_re_2 - start_re_1, 
                run1_dest_id == 3
                & run3_dest_id == 0 ~ end_re_3 - start_re_1,
                TRUE ~ 0),
            trail_re2_play = 
              case_when(
                run2_dest_id == 1 
                & run3_dest_id == 0 ~ end_re_1 - start_re_2,
                run2_dest_id == 2 
                & run3_dest_id == 0 ~ end_re_2 - start_re_2, 
                run2_dest_id == 3
                & run3_dest_id == 0 ~ end_re_3 - start_re_2,
                TRUE ~ 0),
            trail_re_play = trail_reb_play + trail_re1_play + trail_re2_play,
            re_diff_notrail_play = end_re - start_re, 
            re_diff_play = re_diff_notrail_play + trail_re_play,
            ass1_fld_cd, 
            ass2_fld_cd,
            ass3_fld_cd)

# Standalone version of the run average table for runner 3
run3_avg_re <- baserunning_runs.run3 %>% 
  group_by(season, level_id, outs_ct, event, fld_cd) %>% 
  summarize(event_count = n(),
            across(ends_with("_play"), mean)) %>% 
  rename_with(~ gsub("_play", "_lg", .x, fixed = TRUE), ends_with("_play")) %>% 
  ungroup()

# Now to place the run averages in the table itself (sans join!)
baserunning_runs.run3 <- baserunning_runs.run3 %>% 
  group_by(season, level_id, outs_ct, event, fld_cd) %>% 
  mutate(re_diff_lg = mean(re_diff_play)) %>% 
  ungroup() %>% 
  mutate(re_diff = re_diff_play - re_diff_lg)


## With all of the br_raw tables done, let's mash them together with bind_rows
baserunning_runs_raw <- bind_rows(
  list(`1` = baserunning_runs.run1, 
       `2` = baserunning_runs.run2, 
       `3` = baserunning_runs.run3), 
  .id = "base_start")

# The final process: excluding outfield and catcher-focused events,
# then summing for each fielder/position/team stint

outfielder_codes <- c(7,8,9)
catcher_plays <- c("SBA", "WPPB")
brr_season_arm <- baserunning_runs_raw %>% 
  filter(fld_cd > 0,
         !event %in% catcher_plays,
         !ass1_fld_cd %in% outfielder_codes,
         !ass2_fld_cd %in% outfielder_codes,
         !ass3_fld_cd %in% outfielder_codes) %>% 
  group_by(season, level_id, fld_id, fld_cd, fld_team) %>% 
  summarize(BRR_arm = -sum(re_diff), 
            count = n()) %>%
  ungroup()


# Now we obtain league average runs saved per chance, and then de-mean again 
# to get our final values 
brr_season_arm <- brr_season_arm %>% 
  group_by(season, level_id, fld_cd) %>%
  mutate(BRR_arm_per_cnt = sum(coalesce(BRR_arm,0))/sum(coalesce(count,0))) %>% 
  ungroup() %>% 
  mutate(BRR_arm = coalesce(BRR_arm,0) - coalesce(count,0)*BRR_arm_per_cnt)

# Adding brr_run_season (successor to brr_season) at Harry's request
brr_run_season <- baserunning_runs_raw %>% 
  group_by(season, level_id, run_id) %>% 
  summarize(
    BRR_opps = n(),
    BRR = sum(re_diff),
    SBR_opps = sum(if_else(event == "SBA", 1, 0)),
    SBR = sum(if_else(event == "SBA", re_diff, 0)),
    HBR_opps = sum(if_else(event %in% normal_codes, 1, 0)),
    HBR = sum(if_else(event %in% normal_codes, re_diff, 0)),  
    GBR_opps = sum(if_else(event == "G", 1, 0)),
    GBR = sum(if_else(event == "G", re_diff, 0)),
    ABR_opps = sum(if_else(event == "A", 1, 0)),
    ABR = sum(if_else(event == "A", re_diff, 0)),
    OBR_opps = sum(if_else(event == "WPPB", 1, 0)),
    OBR = sum(if_else(event == "WPPB", re_diff, 0))
  )
