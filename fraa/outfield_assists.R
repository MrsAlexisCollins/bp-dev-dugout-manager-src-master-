### set season ###

season <- 2020

### load packages ###

if (!require("pacman")) install.packages("pacman")
pacman::p_load(RPostgreSQL,
               tidyverse)

### acquire data ###
load("FRAA.RData")

## Open DB Connection (requires my.cage.maker.R) ####
source("creds.R") #your cage <- mysql with your credentials
cage <- dbConnect(RPostgreSQL::PostgreSQL(),user=cage.user,password=cage.password,dbname=cage.dbname,host=cage.host,options="-c search_path=models")
rm(cage.password)
## 0 - Variables for use later
FRAA_qualifying_event_codes <- c(2,18,19,20,21,22) # This is a powerful set of variables 

# Player position codes
leftfield_code <- 7
centerfield_code <- 8
rightfield_code <- 9

# Step 1: Set up queries and supporting elements

# Add batter_lwts_official_24
batter_lwts_official.query <- paste(
  "SELECT me.season, me.level_id, me.startbases_cd, me.outs_ct
    , (CASE WHEN me.event_cd BETWEEN 18 AND 19 THEN 2 
        ELSE me.event_cd END) AS EVENT
    , COUNT(1) AS Num
    , AVG(CASE WHEN me.event_cd = 3 THEN 1
        WHEN me.event_cd BETWEEN 14 AND 16 THEN 0
        ELSE me.event_outs_ct END) AS Outs
    , AVG(CASE WHEN me.event_cd = 3 THEN r.re_diff
        ELSE me.event_runs_lwts+r.re_diff END) AS LWTS 
FROM 
( SELECT e.season, e.level_id, e.game_type, e.game_pk, e.inn_ct, e.bat_home_id, e.event_cd
	, e.startbases_cd, e.outs_ct
	, e.event_outs_ct
	, (case when e.event_cd between 14 and 16 then
			CASE WHEN e.startbases_cd = 7 AND e.endbases_cd = 7 THEN 1 ELSE 0 end
	  	else e.event_runs_ct end) as event_runs_lwts
	, (CASE WHEN e.event_cd = 3 THEN 1 WHEN e.event_cd BETWEEN 14 AND 16 THEN 0 ELSE e.event_outs_ct END) as event_outs_lwts
	, (CASE WHEN e.EVENT_CD = 3 THEN e.startbases_cd 
			WHEN e.EVENT_CD BETWEEN 14 AND 16 THEN 
				case when e.startbases_cd = 0 then 1 
					 when e.startbases_cd in (1,2) then 3
					 when e.startbases_cd = 4 then 5
					 when e.startbases_cd in (3,5,6,7) then 7 
					 else null end 
			ELSE e.endbases_cd END) as endbases_lwts 
  FROM mlbapi.warehouse_events e)  me
INNER JOIN 
	(select sum(num_events) as num_events,
			season,
			level_id,
			coalesce(outs_pre, 0) as outs_ct,
			(CASE WHEN onfirst_pre = 't' THEN 1 ELSE 0 end 
			+ 
			CASE WHEN onsecond_pre = 't' THEN 2 ELSE 0 end
			+ 
			CASE WHEN onthird_pre = 't' THEN 4 ELSE 0 end) as startbases_cd,
			coalesce(outs_post - outs_pre, 0) as event_outs_ct,
			(CASE WHEN onfirst_post = 't' THEN 1 ELSE 0 end 
			+ 
			CASE WHEN onsecond_post = 't' THEN 2 ELSE 0 end
			+ 
			CASE WHEN onthird_post = 't' THEN 4 ELSE 0 end) as endbases_cd,
			coalesce(sum(re_diff * num_events::numeric) / sum(num_events), 0) AS re_diff
	from cage.models.lwts_event_baseout_retrosheet lebr
	GROUP BY season, level_id, outs_pre, onfirst_pre, onsecond_pre, onthird_pre, outs_post, onfirst_post, onsecond_post, onthird_post
	) r ON me.season = r.season 
				and me.level_id = r.level_id 
				and me.startbases_cd = r.startbases_cd 
				and me.outs_ct = r.outs_ct 
				and me.endbases_lwts = r.endbases_cd 
				and me.event_outs_lwts = r.event_outs_ct
 INNER JOIN 
		( select distinct gs.season, gs.level_id, 
		                 p.game_pk, p.inning, p.half_inning 
              from cage.mlbapi.plays p 
              inner join cage.mlbapi.games_schedule gs using (game_pk)
              where 
					p.outs = 3
	                and 
	               (p.inning < 9 or p.half_inning = 'top')
		) c ON me.game_pk = c.game_pk 
							 AND me.inn_ct = c.inning  
							 AND me.BAT_HOME_ID = (CASE WHEN c.half_inning = 'top' THEN 0 
													   WHEN c.half_inning = 'bottom' THEN 1 
													   ELSE null end) 
WHERE me.event_cd != 17 and me.level_id = 1 and me.season = ", season,
"GROUP BY me.season, me.level_id, me.startbases_cd, me.outs_ct, EVENT", sep = "")
# Removed and me.game_type = 'R' from above query because warehouse_events no longer has that column.


batter_lwts_official.data <- dbGetQuery(cage, batter_lwts_official.query) 

# Get the re_diff data 
re_diff.query <- paste("select 
      sum(num_events) as num_events,
      season,
      level_id,
      coalesce(outs_pre, 0) as outs_ct,
      (CASE WHEN onfirst_pre = 't' THEN 1 ELSE 0 end 
      + 
      CASE WHEN onsecond_pre = 't' THEN 2 ELSE 0 end
      + 
      CASE WHEN onthird_pre = 't' THEN 4 ELSE 0 end) as startbases_cd,
      coalesce(outs_post - outs_pre, 0) as event_outs_ct,
      (CASE WHEN onfirst_post = 't' THEN 1 ELSE 0 end 
      + 
      CASE WHEN onsecond_post = 't' THEN 2 ELSE 0 end
      + 
      CASE WHEN onthird_post = 't' THEN 4 ELSE 0 end) as endbases_cd,
      coalesce(sum(re_diff * num_events::numeric) / sum(num_events), 0) AS re_diff
    from cage.models.lwts_event_baseout_retrosheet lebr
    where level_id = 1 
    and season = ", season, 
    "GROUP BY season,
      level_id,
      coalesce(outs_pre, 0) ,
      (CASE WHEN onfirst_pre = 't' THEN 1 ELSE 0 end 
      + 
      CASE WHEN onsecond_pre = 't' THEN 2 ELSE 0 end
      + 
      CASE WHEN onthird_pre = 't' THEN 4 ELSE 0 end) ,
      coalesce(outs_post - outs_pre, 0),
      (CASE WHEN onfirst_post = 't' THEN 1 ELSE 0 end 
      + 
      CASE WHEN onsecond_post = 't' THEN 2 ELSE 0 end
      + 
      CASE WHEN onthird_post = 't' THEN 4 ELSE 0 end)", sep = "")
    #" GROUP BY season, level_id, outs_pre, onfirst_pre, onsecond_pre, onthird_pre, outs_post, onfirst_post, onsecond_post, onthird_post", sep = "")
re_diff.data <- dbGetQuery(cage, re_diff.query)

# Get the events setup 
events.query <- paste("SELECT
      season,
      level_id,
      game_pk,
      event_cd,
      fld_team,
      pos7_fld_id,  
      pos8_fld_id, 
      pos9_fld_id,
      ass1_fld_cd,
      ass2_fld_cd,
      ass3_fld_cd,
      outs_ct,
      startbases_cd,
      event_runs_ct,
      event_outs_ct,
      endbases_cd
      FROM cage.mlbapi.warehouse_events e
		  WHERE level_id = 1 
		  AND season=",season,sep = "")
# Removed and game_type = 'R' from above query because warehouse_events no longer has this column.


# Get the query and also recode all outs to singles (for the purposes of this)
events.data <- dbGetQuery(cage, events.query) %>% 
  mutate(event_cd = recode(event_cd, `2` = 20L))

combined.data <- events.data %>% 
  inner_join(re_diff.data,
             by = c("season", "level_id", "outs_ct", "startbases_cd", 
                    "endbases_cd", "event_outs_ct")) %>% 
  inner_join(batter_lwts_official.data, 
             by = c("season", "level_id", "outs_ct", "startbases_cd", 
                    "event_cd" = "event"))

# Complete the outfield assist query. The real magic, of course, is the final group_by/summarize.
# If you wanted a table with assist runs, etc., you'd lop that off.
combined.data.long <- combined.data %>% 
  pivot_longer(cols = contains("fld_id"),
               names_to = c("pos", ".value"),
               names_pattern = "pos(.+)_fld_(.+)") %>% 
  rename(fld_id = id)

outfield_assists.data <- combined.data.long %>% 
  filter(pos == ass1_fld_cd | pos == ass2_fld_cd | pos == ass3_fld_cd) %>%
  mutate(run_diff_vs_exp_play = if_else(pos == ass1_fld_cd | pos == ass2_fld_cd | pos == ass3_fld_cd,
                                        event_runs_ct + re_diff - lwts,0) ) %>%
  group_by(season, level_id, fld_team, fld_id, pos) %>% 
  summarize(off_ass = n(),
            run_diff_vs_expected = -sum(run_diff_vs_exp_play)) %>% ungroup()

# Now, incorporate 2 elements of `scratch_rob/fraa_by_pos.sql` and a few from the dyna tables:
# Namely, various normalizations and summaries of outfield assist runs. 

# First grouping: total assists and runs saved for a given fielder/team stint per league/season
# This is unnormalized.
outfield_assists.yr_lvl_team_player <- outfield_assists.data %>% 
  group_by(season, level_id, fld_team, fld_id) %>%
  summarize(of_ast = sum(off_ass),
            of_ast_fraa = sum(run_diff_vs_expected))

# Now, assuming we've run FRAA_pg.R or otherwise obtained a crosstab of games played:
# Let's join to that long table, since the values match with the official DB,
# and then calculate the relevant league/season-level FRAA/Game
# The full join ensures that all fielders are joined in, even ones who have
# not made an assist. Outfielders are selected via the filter.
# The `coalesce` is used similar to the legacy code, ensuring outfielders with 
# `NA` (i.e. none) outfield assists (and thus no run expectancy) are appropriately counted.
outfield_assists.norm.data <-outfield_assists.data %>% 
  full_join(pos_games.data.long %>% mutate(pos_num = as.character(pos_num)) , 
             by = c("season", "level_id", "fld_team", "fld_id", "pos" = "pos_num")) %>%
  filter(pos %in% c(7,8,9)) %>%
  group_by(season, level_id) %>%
  mutate(lg_FRAA_PER_G = sum(coalesce(run_diff_vs_expected,0))/sum(coalesce(G,0))) %>% ungroup()

# This is the normalized version of the above process.
# This provides the of_ast_fraa in the dyna tables.
# Coalesce is used here as well. 
outfield_assists.norm.yr_lvl_team_player <- outfield_assists.norm.data %>%
  group_by(season, level_id, fld_team, fld_id) %>%
  summarize(of_ast = sum(coalesce(off_ass,0)),
            of_ast_fraa = sum(coalesce(run_diff_vs_expected,0)) - sum(coalesce(G,0)*lg_FRAA_PER_G)) %>%
  ungroup() %>%
  inner_join(teams_xrefs, by = c("fld_team" = "xref_id")) %>%
  inner_join(people_xrefs, by = c("fld_id" = "xref_id")) %>%
  rename(team_id = teams_id) %>%
  add_column(version = max_date) %>%
  select(season, level_id, team_id, bpid, of_ast, of_ast_fraa, version)

dbSendQuery(cage, paste0("DELETE FROM models.ofa_daily WHERE version = '", max_date, "'", sep=""))
dbWriteTable(cage, "ofa_daily", outfield_assists.norm.yr_lvl_team_player, row.names=FALSE, append=TRUE)

# This last table is lines 22 to 25 of the TEMP_DELETE0 table creation in
# fraa_by_pos.sql. As noted, one more use of coalesce. 

outfield_assists.norm.yr_lvl_team_player_pos <- outfield_assists.norm.data %>% 
  group_by(season, level_id, fld_team, fld_id, pos) %>%
  summarize(of_ast = sum(coalesce(off_ass,0)),
            of_ast_fraa = sum(coalesce(run_diff_vs_expected,0)) - sum(coalesce(G,0)*lg_FRAA_PER_G))

save(pos_games.data.long, max_date, teams_xrefs, people_xrefs,
  outfield_assists.norm.yr_lvl_team_player,
  outfield_assists.norm.yr_lvl_team_player_pos, file="FRAA.RData")
