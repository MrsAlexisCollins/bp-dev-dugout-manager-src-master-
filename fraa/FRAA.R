### set season ###

season <- 2020

### load packages ###

if (!require("pacman")) install.packages("pacman")
pacman::p_load(RPostgreSQL,
               RMySQL,
               tidyverse)

### acquire data ###

## Open DB Connection (requires my.cage.maker.R) ####
source("creds.R") #your cage <- mysql with your credentials
cage <- dbConnect(RPostgreSQL::PostgreSQL(),user=cage.user,password=cage.password,dbname=cage.dbname,host=cage.host,options="-c search_path=models")
rm(cage.password)

mysql <- dbConnect(RMySQL::MySQL(),user=mysql.user,password=mysql.password,dbname=mysql.dbname,host=mysql.host)
rm(mysql.password)

## 0 - Variables for use later
FRAA_qualifying_event_codes <- c(2,18,19,20,21,22) # This is a powerful set of variables 

# Player position codes
pitcher_code <- 1
catcher_code <- 2
first_base_code <- 3
all_infield_code <- c(1:6)
special_infield_code <- c(1:3)
typical_infield_code <- c(4:6)
outfield_code <- c(7:9)

## 1 - fact_field3.play_value_raw

# First things first: let's get events from complete innings -- maybe let's focus on just MLB
# Let's yank Judge's code, perhaps, from the OAA events testing script
# What do we need from warehouse.events?
# seasonX, levelX, fld_cdX, po1_fld_cdX, ass1_fld_cdX, bunt_flX, bat_fld_cdX, event_outs_ct, event_runs_ct in the select/elsewhere
# event_cdX in general FROM,  game_pkX, inn_ctX, bat_home_idX for complete inning join, startbases_cdX, outs_ctX, endbases_cd for the run expectancy differences join.
query_events_PVR <- paste("SELECT
         e.season
		   , e.level_id
		   , e.game_pk
       , e.inn_ct
		   , e.bat_home_id
		   , e.event_cd 
		   , e.fld_cd
		   , e.po1_fld_cd 
		   , e.ass1_fld_cd 
		   , e.bunt_fl
		   , e.is_pitcher_hitting
		   , e.startbases_cd
		   , e.outs_ct
		   , e.endbases_cd
		   , e.event_outs_ct
		   , e.event_runs_ct
       FROM cage.mlbapi.warehouse_events e
		   INNER JOIN ( select distinct gs.season, gs.level_id, 
		                 p.game_pk, p.inning, p.half_inning 
                    from cage.mlbapi.plays p 
                    inner join cage.mlbapi.games_schedule gs using (game_pk)
                    where 
	                    p.outs = 3
	                    and 
	                    (p.inning < 9 or p.half_inning = 'top')
	                   and gs.game_type = 'R' and left(gs.status_code, 1) = 'F') C
		   ON e.game_pk = c.game_pk 
		   	AND e.inn_ct = c.inning  
		   	AND e.BAT_HOME_ID = (CASE WHEN c.half_inning = 'top' THEN 0 
		   							  WHEN c.half_inning = 'bottom' THEN 1 ELSE null end)
		   WHERE e.season = c.season
		   	AND e.level_id = c.level_id
		   	AND e.level_id = 1 AND e.game_type = 'R'
		   AND e.season =",season,sep = "")

events_PVR <- dbGetQuery(cage, query_events_PVR) %>% 
  filter(event_cd %in% FRAA_qualifying_event_codes) # Get only the qualifying event codes

# Get the run expectancy differences for ((base,out)_initial, (base,out)_final) pairs
# query_re_diff <- paste("SELECT 
# 		   season
# 		   , level_id
# 		   , startbases_cd
# 		   , outs_ct
# 		   , endbases_cd
# 		   , event_outs_ct
# 		   , RE_DIFF
# 		   FROM lwts.re_diff 
# 		   WHERE level_id = 'mlb'
# 		   AND season=",season,sep = "")
query_re_diff <- paste("select 
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
re_diff_data <- dbGetQuery(cage, query_re_diff)


# Join the events to the run expectancy differences
events_PVR <- events_PVR %>% 
  inner_join(re_diff_data, 
             by = c("season", "level_id", "startbases_cd", 
                    "outs_ct", "endbases_cd", "event_outs_ct")) # Now we've joined the dataframes

# Create "play_made", "bat_type" (really, play type), play_lwts variables for every play
events_PVR <- events_PVR %>% 
  mutate(
    # Finalized Play Made conditions -- use an OR statement to get the conditions I expected
    PM = case_when(
      fld_cd %in% all_infield_code & (fld_cd == po1_fld_cd | fld_cd == ass1_fld_cd) ~ 1, 
      fld_cd %in% outfield_code & fld_cd == po1_fld_cd ~ 1, 
      TRUE ~ 0
    ),
    bat_type = case_when(
      bunt_fl == 1 ~ "B",
      is_pitcher_hitting == 1 ~ "P",
      TRUE ~ "N"),
    play_lwts = event_runs_ct + re_diff)

# Now we need to aggregate & transmute to get the final data frame
play_value_raw_R <- events_PVR %>% 
  group_by(season, level_id, PM, bat_type) %>% 
  summarize(BIP = n(), 
            Outs = mean(event_outs_ct), 
            LWTS_avg = mean(play_lwts))

## 2 - play_value table
# This should be easy, because it appears to be a simple aggregation?
play_value_R <- play_value_raw_R %>% 
  group_by(season, level_id, bat_type) %>% 
  summarize(LWTS = sum(LWTS_avg[PM == 0]) - sum(LWTS_avg[PM == 1]))


## 3 - League Average Plays Made with park flag "raw"		
# First, construct the suite of conditions for each type of "play made"
IF_GB_play_made_cases <- quos(
  .data$fld_cd %in% special_infield_code 
  & .data$fld_cd == .data$ass1_fld_cd ~ 1,
  .data$fld_cd %in% special_infield_code 
  & .data$fld_cd == .data$po1_fld_cd
  & .data$bat_play_tx != .data$fld_cd ~ 1,
  .data$fld_cd == first_base_code 
  & .data$fld_cd == .data$po1_fld_cd
  & .data$bat_play_tx == .data$fld_cd 
  & (.data$bat_hand_cd == "L" |  .data$bunt_fl == 1) ~ 1,
  .data$fld_cd == pitcher_code 
  & .data$fld_cd == .data$po1_fld_cd 
  & .data$bat_play_tx == .data$fld_cd 
  & .data$bunt_fl == 1 ~ 1,
  .data$fld_cd %in% c(2, 4:6) 
  & (.data$fld_cd == .data$po1_fld_cd | .data$fld_cd == .data$ass1_fld_cd)
  #& .data$fld_cd %in% c(.data$po1_fld_cd, .data$ass1_fld_cd) 
  & .data$bat_play_tx != .data$fld_cd ~ 1,
  TRUE ~ 0)
IF_AiB_play_made_cases <- quos(
  .data$fld_cd %in% c(2, 4:6) 
  & (.data$fld_cd == .data$po1_fld_cd | .data$fld_cd == .data$ass1_fld_cd)
  & .data$bat_play_tx == .data$fld_cd ~ 1,
  .data$fld_cd == first_base_code 
  & .data$fld_cd == .data$po1_fld_cd
  & .data$bat_play_tx == .data$fld_cd 
  & .data$bat_hand_cd == "R" 
  & .data$bunt_fl == 0 ~ 1,
  .data$fld_cd == pitcher_code 
  & .data$fld_cd == .data$po1_fld_cd 
  & .data$bat_play_tx == .data$fld_cd
  & .data$bunt_fl == 0 ~ 1,
  TRUE ~ 0)
OF_play_made_cases <- quos(
  .data$fld_cd %in% outfield_code
  & .data$fld_cd == .data$po1_fld_cd ~ 1,
  TRUE ~ 0)
# Every set after this point is only COMBINING cases
# An airball play is made if an OF or IF AiB play is made
# A play is made if any of the play made conditions are true
#AiB_play_made_cases <- quos(
#	.data$OF_PM == 1 | data$IF_AiB_PM == 1 ~ 1,
#	TRUE ~ 0)
# So we might want to instead try something like summations over multiple rows 
# mutate(AiB_PM = select(., IF_AiB_PM, OF_PM) %>% rowSums(na.rm = TRUE),
# TM_PM = select(., IF_GB_PM, IF_AiB_PM, OF_PM) %>% rowSums(na.rm = TRUE))
# NOTE: This has to be done BEFORE group_by, because the purpose of this part is MERELY to set up the indication if a play is made or not.

# We're pre-emptively adding a bunch of columns to ensure this query/event pack 
# is useable for other dataframes elsewhere in the process 
query_events_LAPPraw <- paste("SELECT
        season
		   , level_id
		   , game_pk
       , inn_ct
		   , bat_home_id
		   , home_team
		   , away_team
		   , pitcher_id
		   , fld_team
		   , event_cd 
		   , h_cd
		   , battedball_cd
		   , fld_cd
		   , po1_fld_cd 
		   , ass1_fld_cd 
		   , bunt_fl
		   , is_pitcher_hitting 
		   , bat_hand_cd
		   , bat_play_tx
		   , startbases_cd
		   , outs_ct
		   , endbases_cd
		   , event_outs_ct
		   , event_runs_ct
		   , run1_origin_event_id 
		   , run2_origin_event_id
       FROM cage.mlbapi.warehouse_events e
		   WHERE level_id = 1 AND game_type = 'R'
		   AND season=",season,sep = "")

events_LAPPraw <- dbGetQuery(cage, query_events_LAPPraw) 

events_LAPPraw <- events_LAPPraw %>% 
  filter(event_cd %in% FRAA_qualifying_event_codes
         & bunt_fl == 0 
         & is_pitcher_hitting == 0
         & bat_play_tx != 99) # Get only the qualifying events for park factors

# Add markers if the play is made in the "base" classes of playmaking -- 
# these are essentially one-hot vectors & also roll up Air Ball and Total classes
events_LAPPraw <- events_LAPPraw %>% 
  mutate(IF_GB_PM = case_when(!!! IF_GB_play_made_cases),
         IF_AiB_PM = case_when(!!! IF_AiB_play_made_cases), 
         OF_PM = case_when(!!! OF_play_made_cases), 
         AiB_PM = if_else(IF_AiB_PM == 1 | OF_PM == 1, 1, 0),
         TM_PM = if_else(IF_GB_PM == 1 | AiB_PM == 1, 1, 0))

# Get the home field behavior
data_LAPPraw_home <- events_LAPPraw %>% 
  group_by(season, level_id, home_team) %>% 
  summarize(IF_GB_PM = mean(IF_GB_PM),
            IF_AiB_PM = mean(IF_AiB_PM),
            OF_PM = mean(OF_PM),
            AiB_PM = mean(AiB_PM),
            TM_PM = mean(TM_PM),
            BIP = n()) # Think about renaming the variables for airball and total for readability

# This (above) should probably be made a function with a selector for home and away
# since this section is ~36 lines with a lot of cruft. That said, think hard about
# where the filters would need to be defined to have appropriate scope
# BZZT WRONG -- you only need to mark every play AND THEN group_by/pivot
# But also we need to consider how the home_team is involved
# Solution: just "rename" the column.
events_LAPPraw <- events_LAPPraw %>% ungroup() # Reset the DF

data_LAPPraw_away <- events_LAPPraw %>% 
  group_by(season, level_id, away_team) %>% 
  summarize(IF_GB_PM = mean(IF_GB_PM),
            IF_AiB_PM = mean(IF_AiB_PM),
            OF_PM = mean(OF_PM),
            AiB_PM = mean(AiB_PM),
            TM_PM = mean(TM_PM),
            BIP = n()) # Think about renaming the variables for airball and total for readability 
data_LAPPraw_away <- data_LAPPraw_away %>%
  rename(home_team = away_team) #renaming column SOLELY for joining purposes

# The data at this point should be:
# season, level_id, home_team, HOME_FL....ah, bind_rows acts as the union
data_LAPPraw <- bind_rows(list(`0` = data_LAPPraw_away, `1` = data_LAPPraw_home), 
                          .id = "home_fl") #%>% rename_all(tolower)

#query_LAPPraw_SQL <- paste("SELECT * FROM fact_field3.lg_avg_pm_park_raw WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
#data_LAPPraw_SQL <-dbGetQuery(mysql, query_LAPPraw_SQL) %>% rename_all(tolower)

## 4 -- Regressed park factors 
two_factor_regression <- function(x, y, w1, w2) {
  data_vec <- c(x,y)
  w1_vec <- c(w1,(1-w1))
  w2*(x/sum(data_vec*w1_vec)) + (1-w2)
}

test1 <- two_factor_regression(5,6,0.6,0.35)


data_regressed_pf <- data_LAPPraw %>% 
  group_by(season, level_id, home_team) %>%
  summarize(BIP = (BIP[home_fl == 1] + BIP[home_fl == 0])/2, 
            GB_PF = two_factor_regression(IF_GB_PM[home_fl == 1], 
                                          IF_GB_PM[home_fl == 0], 
                                          0.06, 
                                          0.35), 
            IF_AiB_PF = two_factor_regression(IF_AiB_PM[home_fl == 1], 
                                              IF_AiB_PM[home_fl == 0], 
                                              0.06, 
                                              0.35),
            OF_PF = two_factor_regression(OF_PM[home_fl == 1], 
                                          OF_PM[home_fl == 0], 
                                          0.06, 
                                          0.35),
            AiB_PF = two_factor_regression(AiB_PM[home_fl == 1], 
                                           AiB_PM[home_fl == 0], 
                                           0.06, 
                                           0.45),
            TM_PF = two_factor_regression(TM_PM[home_fl == 1], 
                                          TM_PM[home_fl == 0], 
                                          0.06, 
                                          0.45)
  )

#query_regressed_pf_SQL <- paste("SELECT * FROM fact_field3.regressed_pf WHERE level_id = \'mlb\' AND season = ", season, sep = " ")
#data_regressed_pf_SQL <- dbGetQuery(mysql, query_regressed_pf_SQL)

## 5 -- League Average Plays Made table
# The SQL query for this essentially looks like the one for LAPP, but for
# the calculation of DER and GB%. Thus, we can use events_LAPPraw for this,
# but change the grouping/summary to only year and level.
# We're going to fix events_LAPPraw to support this instead.
events_LAPPraw <- events_LAPPraw %>% ungroup() # Reset the DF

data_LAPMG <- events_LAPPraw %>%
  group_by(season, level_id) %>% 
  summarize(DER = 1-mean(if_else(h_cd %in% c(1:3), 1, 0)),
            GB_PCT = sum(if_else(battedball_cd == "G", 1, 0))/sum(if_else(battedball_cd != "", 1, 0)),
            IF_GB_PM = mean(IF_GB_PM),
            IF_AiB_PM = mean(IF_AiB_PM),
            OF_PM = mean(OF_PM),
            AiB_PM = mean(AiB_PM),
            TM_PM = mean(TM_PM),
            BIP = n())
events_LAPPraw <- events_LAPPraw %>% ungroup()

#query_LAPMG_SQL <- paste("SELECT * FROM fact_field3.lg_avg_pm_group WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
#data_LAPMG_SQL <- dbGetQuery(mysql, query_LAPMG_SQL)

## 6 -- Base-Out State Average Plays Made table
data_BOSAPM <- events_LAPPraw %>%
  group_by(season, level_id, startbases_cd, outs_ct) %>% 
  summarize(DER = 1-mean(if_else(h_cd %in% c(1:3), 1, 0)),
            GB_PCT = sum(if_else(battedball_cd == "G", 1, 0))/sum(if_else(battedball_cd != "", 1, 0)),
            IF_GB_PM = mean(IF_GB_PM),
            IF_AiB_PM = mean(IF_AiB_PM),
            OF_PM = mean(OF_PM),
            AiB_PM = mean(AiB_PM),
            TM_PM = mean(TM_PM),
            BIP = n())
events_LAPPraw <- events_LAPPraw %>% ungroup()

#query_BOSAPM_SQL <- paste("SELECT * FROM fact_field3.state_avg_pm_group WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
#data_BOSAPM_SQL <- dbGetQuery(mysql, query_BOSAPM_SQL)

## 7 -- Base-Out State Average Plays Made, Adjusted By League Average table
data_state_adj <- left_join(data_BOSAPM, data_LAPMG, by=c("season", "level_id")) %>%
  group_by(season,level_id, startbases_cd, outs_ct) %>%
  summarize(IF_GB_PM_FCT = IF_GB_PM.x/IF_GB_PM.y,
            IF_AiB_PM_FCT = IF_GB_PM.x/IF_AiB_PM.y,
            OF_PM_FCT = IF_GB_PM.x/IF_GB_PM.y,
            BIP = BIP.x)
#query_state_adj_SQL <- paste("SELECT * FROM fact_field3.state_adj WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
#data_state_adj_SQL <- dbGetQuery(mysql, query_state_adj_SQL)

## 8 -- Steal plays - league average "raw" plays
# That is, what's the league average play made rate on a subclass of plays for the first baseman.
# First things first: construct a quote for this class of plays
first_base_PM_cases <- quos(
  .data$fld_cd == first_base_code &
    .data$fld_cd == .data$ass1_fld_cd ~ 1,
  .data$fld_cd == first_base_code &
    .data$fld_cd == .data$po1_fld_cd &
    .data$bat_play_tx != .data$fld_cd ~ 1,
  .data$fld_cd == first_base_code &
    .data$fld_cd == .data$po1_fld_cd & 
    .data$bat_play_tx == .data$fld_cd & 
    (.data$bat_hand_cd == "L" |  .data$bunt_fl == 1) ~ 1,
  TRUE ~ 0
)
# In observing the above, this is basically where IF_GB_PM occurs with a first baseman fielding
# Perhaps this would be better served by a filter?
# Or an if_else with condition IF_GB_PM == 1 and fld_cd == first_base_cd?

# Let's try the first thing
data_steal_plays_raw <- events_LAPPraw %>%
  group_by(season, level_id) %>%
  summarize(first_base_PM_avg = mean(case_when(!!! first_base_PM_cases)))

# Let's validate the results
#query_SPR_SQL <- paste("SELECT * FROM fact_field3.steal_plays_raw WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
#data_steal_plays_raw_SQL <- dbGetQuery(mysql, query_SPR_SQL)

events_LAPPraw <- events_LAPPraw %>% ungroup()
## 9 -- Steal Plays, Adjusted 
# First, add the steal play flag 

data_steal_plays_adj <- events_LAPPraw %>% 
  mutate(steal_flag = if_else(run1_origin_event_id > 0 & run2_origin_event_id == 0, 1, 0),
         first_base_PM = case_when(!!! first_base_PM_cases)) %>%
  inner_join(data_state_adj, by = c("season", "level_id", "startbases_cd", "outs_ct")) %>%
  inner_join(data_steal_plays_raw, by = c("season", "level_id")) %>% 
  group_by(season, level_id, steal_flag) %>%
  summarize(first_base_PM_ADJ = sum(first_base_PM)/sum(first_base_PM_avg/IF_GB_PM_FCT))


# Let's validate the results
#query_SPA_SQL <- paste("SELECT * FROM fact_field3.steal_plays_adj WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
#data_steal_plays_adj_SQL <- dbGetQuery(mysql, query_SPA_SQL)

## 10 -- Average plays made per pitcher/defense combo
# Surprise, this is the same as Base-Out state PM, but just with a different group_by!
# Consider making the summarize here a function in a refactor
data_pit_avg_pm_group <- events_LAPPraw %>%
  group_by(season, level_id, pitcher_id, fld_team) %>% 
  summarize(DER = 1-mean(if_else(h_cd %in% c(1:3), 1, 0)),
            GB_PCT = sum(if_else(battedball_cd == "G", 1, 0))/sum(if_else(battedball_cd != "", 1, 0)),
            IF_GB_PM = mean(IF_GB_PM),
            IF_AiB_PM = mean(IF_AiB_PM),
            OF_PM = mean(OF_PM),
            AiB_PM = mean(AiB_PM),
            TM_PM = mean(TM_PM),
            BIP = n())

#query_PAPMG_SQL <- paste("SELECT * FROM fact_field3.pit_avg_pm_group WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
#data_PAPMG_SQL <- dbGetQuery(mysql, query_PAPMG_SQL)

events_LAPPraw <- events_LAPPraw %>% ungroup()
## 11 -- League Average Play Likelihoods for Plays in #10
# This could perhaps be managed with a clever join beforehand? 

# We're also probably going to need a function.
# We could borrow from http://jonthegeek.com/2018/06/04/writing-custom-tidyverse-functions/

data_pit_lg_pm_group <- events_LAPPraw %>% 
  inner_join(data_regressed_pf %>% dplyr::select(!BIP), 
             by = c("season", "level_id", "home_team")) %>% 
  inner_join(data_BOSAPM %>% 
               dplyr::rename_with(~ paste0(.x, "_state"), ends_with("PM")) %>% 
               dplyr::select(-c(BIP, DER, GB_PCT)),
             by = c("season", "level_id","startbases_cd", "outs_ct")) %>%
  group_by(season, level_id, pitcher_id, fld_team) %>% 
  summarize(IF_GB_PM = mean(IF_GB_PM_state*GB_PF),
            IF_AiB_PM = mean(IF_AiB_PM_state*IF_AiB_PF),
            OF_PM = mean(OF_PM_state*OF_PF),
            AiB_PM = mean(AiB_PM_state*AiB_PF),
            TM_PM = mean(TM_PM_state*TM_PF),
            across(contains("PF"), mean, .names = "{col}"))
# IF_GB_PF = mean(GB_PF),
# IF_AiB_PF = mean(IF_AiB_PF),
# OF_PF = mean(OF_PF),
# AiB_PF = mean(AiB_PF),
# TM_PF = mean(TM_PF))
# The summarize above is *incredibly* ugly, not to mention the fact that we can 
# probably use weighted.mean instead of mean for the _PM parts. 
# Indeed, fiddling around has shown that the park factor parts can be done with
# summarize(across(contains("PF"), mean, .names = "{col}"))
#
# This doesn't work right now, stop fiddling with it. 
# paste0(str_extract(cur_column(),"\\w+(?=_PM_state)"), "_PF")),
# test <- events_LAPPraw %>%
#   inner_join(data_regressed_pf %>% dplyr::select(!BIP),
#              by = c("season", "level_id", "home_team")) %>%
#   inner_join(data_BOSAPM %>%
#                dplyr::rename_with(~ paste0(.x, "_state"), ends_with("PM")) %>%
#                dplyr::select(-c(BIP, DER, GB_PCT)),
#              by = c("season", "level_id","startbases_cd", "outs_ct")) # %>%
# test %>% group_by(season, level_id, pitcher_id, fld_team) %>% #dplyr::summarize(across(ends_with("PM_state"), ~ sum(is.na(.x)))
#    dplyr::summarize(across(ends_with("PM_state"),
#                            ~ weighted.mean(.x, str_replace(cur_column(), "PM_state", "PF")), 
#                            .names = "{col}_temp")) #,
#              #across(contains("PF"), mean, .names = "{col}_temp"))

#query_PLPMG_SQL <- paste("SELECT * FROM fact_field3.pit_lg_pm_group WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
#data_PLPMG_SQL <- dbGetQuery(mysql, query_PLPMG_SQL)  

events_LAPPraw <- events_LAPPraw %>% ungroup()
## 12 -- GB/AiB Adjustment "Raw" table for Pitcher/Defense pair -- gb_aib_adj_pit_raw
one_factor_regression <- function(x, y, const) {
  data_vec <- c(x,y)
  w = const[[1]] / sum(const)
  w_vec <- c(w,(1-w))
  sum(data_vec*w_vec)
}

test <- one_factor_regression(0.5, 0.88, c(500,100))

adjust_factor_selection <- function(norm_factor, base_factor, base_factor_plus, comp_factor, default) {
  case_when(
    abs(norm_factor - 1) <= abs(base_factor_plus - comp_factor) &
      sign(norm_factor - 1) == sign(base_factor_plus - 1) ~ base_factor/norm_factor,
    abs(norm_factor - 1) <= abs(base_factor_plus - comp_factor) &
      sign(norm_factor - 1) != sign(base_factor_plus - 1) ~ base_factor,
    TRUE ~ default
  )
}

data_gb_aib_adj_pit_raw <- data_pit_avg_pm_group %>% 
  dplyr::rename_with(~ paste0(.x, "_stint"), ends_with("PM")) %>% 
  dplyr::inner_join(data_pit_lg_pm_group %>% 
                      dplyr::rename_with(~ paste0(.x, "_league"), ends_with("PM")),
                    by = c("season", "level_id", "pitcher_id", "fld_team")) %>% 
  dplyr::transmute(
    season, 
    level_id,
    pitcher_id,
    fld_team,
    BIP,
    GB_rate = one_factor_regression(IF_GB_PM_stint, IF_GB_PM_league*GB_PF, c(BIP, 100)),
    OF_rate = one_factor_regression(OF_PM_stint, OF_PM_league*OF_PF, c(BIP, 100)),
    IF_AiB_rate = one_factor_regression(IF_AiB_PM_stint, IF_AiB_PM_league*IF_AiB_PF, c(BIP,100)),
    AiB_rate = OF_rate + IF_AiB_rate,
    TM_rate = AiB_rate + GB_rate, 
    GB_plus = GB_rate/(IF_GB_PM_league*GB_PF),
    AiB_plus = AiB_rate/(AiB_PM_league*AiB_PF),
    TM_plus = TM_rate/(TM_PM_league*TM_PF),
    IF_GB_PM_league,
    AiB_PM_league,
    adj_IF_GB_PM_league = adjust_factor_selection(TM_plus, GB_rate, GB_plus, AiB_plus, IF_GB_PM_league),
    adj_AiB_PM_league = adjust_factor_selection(TM_plus, AiB_rate, AiB_plus, GB_plus, AiB_PM_league),
    IF_GB_adj = adj_IF_GB_PM_league/IF_GB_PM_league,
    AiB_adj = adj_AiB_PM_league/AiB_PM_league,
    IF_AiB_plus = IF_AiB_rate/(IF_AiB_PM_league*IF_AiB_PF*AiB_adj),
    OF_AiB_plus = OF_rate/(OF_PM_league*OF_PF),
    AiB_PM_plus_2 = IF_AiB_plus + OF_AiB_plus - 1,
    adj_IF_AiB_PM_league = adjust_factor_selection(AiB_PM_plus_2, IF_AiB_rate, IF_AiB_plus, OF_AiB_plus, IF_AiB_PM_league),
    adj_OF_PM_league = adjust_factor_selection(AiB_PM_plus_2, OF_rate, OF_AiB_plus, IF_AiB_plus, OF_PM_league),
    IF_AiB_adj = adj_IF_AiB_PM_league/(IF_AiB_PM_league*AiB_adj),
    OF_adj = adj_OF_PM_league/(OF_PM_league*AiB_adj)
  )

#query_GAAPR_SQL <- paste("SELECT * FROM fact_field3.gb_aib_adj_pit_raw WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
#data_GAAPR_SQL <- dbGetQuery(mysql, query_GAAPR_SQL)  

## 13 -- Intermediate normalization table for GB/AiB adjustments -- gb_aib_adj_pit_fix
data_gb_aib_adj_pit_fix <- data_gb_aib_adj_pit_raw %>%
  group_by(season, level_id) %>% 
  dplyr::summarize(across(ends_with("_adj"), ~ sum(.x * BIP)/sum(BIP), #weighted.mean(.x, BIP), 
                          .names = "{col}_temp")) 
# Look how small that is!
#query_GAAPF_SQL <- paste("SELECT * FROM fact_field3.gb_aib_adj_pit_fix WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
#data_GAAPF_SQL <- dbGetQuery(mysql, query_GAAPF_SQL) 
# We have a bit of an error accumulation issue here, I think. Particularly in the infield fly ball category.

## 14 -- Finalized GB/AiB split adjustments per pitcher/team stint -- gb_aib_adj_pit
# Technically, we don't need the last table *at all* for this.  
data_gb_aib_adj_pit <- data_gb_aib_adj_pit_raw %>% 
  group_by(season, level_id) %>% 
  dplyr::transmute(season, level_id, pitcher_id, fld_team, BIP,
                   across(ends_with("_adj"), ~ (.x - sum(.x * BIP)/sum(BIP) + 1), #weighted.mean(.x, BIP), 
                          .names = "{col}"))

#query_GAAP_SQL <- paste("SELECT * FROM fact_field3.gb_aib_adj_pit WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
#data_GAAP_SQL <- dbGetQuery(mysql, query_GAAP_SQL)  

## 15 -- League-average plays made per position -- lg_avg_pm
# Note: this is NOT lg_avg_pm_group from Table 5!! 
# We're bringing in a new event query, because technically, the one we've used previously
# has filters on situations we need now. 
# This mirrors events_LAPPraw, but has new elements.
query_events_plays_made_raw <- paste("SELECT
        season
		   , level_id
		   , game_pk
		   , event_id
       , inn_ct
		   , bat_home_id
		   , home_team
		   , away_team
		   , pitcher_id
		   , pos2_fld_id
		   , pos3_fld_id
		   , pos4_fld_id
		   , pos5_fld_id
		   , pos6_fld_id
		   , pos7_fld_id
		   , pos8_fld_id
		   , pos9_fld_id
		   , fld_team
		   , event_cd 
		   , h_cd
		   , battedball_cd
		   , fld_cd
		   , po1_fld_cd 
		   , ass1_fld_cd 
		   , bunt_fl
		   , is_pitcher_hitting 
		   , bat_hand_cd
		   , bat_play_tx
		   , startbases_cd
		   , outs_ct
		   , endbases_cd
		   , event_outs_ct
		   , event_runs_ct
		   , run1_origin_event_id 
		   , run2_origin_event_id
       FROM cage.mlbapi.warehouse_events e
		   WHERE level_id = 1 and game_type = 'R'
		   AND season=",season,sep = "")

events_plays_made_raw <- dbGetQuery(cage, query_events_plays_made_raw) 

# First, filter out a few things 
events_plays_made_raw <- events_plays_made_raw %>% 
  filter(event_cd %in% FRAA_qualifying_event_codes
         & bat_play_tx != 99) # Get only the qualifying events for park factors

# Next, let's append a few things onto the events:
# - the batted ball types,
# - a steal play flag (which we saw before!) 
events_plays_made_raw <- events_plays_made_raw %>% 
  mutate(bat_type = case_when(
    bunt_fl == 1 ~ "B",
    is_pitcher_hitting == 1 ~ "P",
    TRUE ~ "N"),
    steal_flag = 
      if_else(run1_origin_event_id > 0 & run2_origin_event_id == 0, 1, 0))

# Now we need to have per-position checks for plays made 
# First base has already been handled above
pitcher_PM_cases <- quos(
  .data$fld_cd == pitcher_code 
  & .data$fld_cd == .data$ass1_fld_cd ~ 1,
  .data$fld_cd == pitcher_code 
  & .data$fld_cd == .data$po1_fld_cd 
  & .data$bat_play_tx != .data$fld_cd  ~ 1,
  .data$fld_cd == pitcher_code 
  & .data$fld_cd == .data$po1_fld_cd 
  & .data$bat_play_tx == .data$fld_cd 
  & .data$bunt_fl == 1 ~ 1,
  TRUE ~ 0
)
catcher_PM_cases <- quos(
  .data$fld_cd == catcher_code 
  & (.data$fld_cd == .data$po1_fld_cd | .data$fld_cd == .data$ass1_fld_cd)
  & .data$bat_play_tx != .data$fld_cd ~ 1,
  TRUE ~ 0
)
second_base_PM_cases <- quos(
  .data$fld_cd == 4
  & (.data$fld_cd == .data$po1_fld_cd | .data$fld_cd == .data$ass1_fld_cd)
  & .data$bat_play_tx != .data$fld_cd ~ 1,
  TRUE ~ 0
)
third_base_PM_cases <- quos(
  .data$fld_cd == 5
  & (.data$fld_cd == .data$po1_fld_cd | .data$fld_cd == .data$ass1_fld_cd)
  & .data$bat_play_tx != .data$fld_cd ~ 1,
  TRUE ~ 0
)
shortstop_PM_cases <- quos(
  .data$fld_cd == 6
  & (.data$fld_cd == .data$po1_fld_cd | .data$fld_cd == .data$ass1_fld_cd)
  & .data$bat_play_tx != .data$fld_cd ~ 1,
  TRUE ~ 0
)
LF_PM_cases <- quos(
  .data$fld_cd == 7
  & .data$fld_cd == .data$po1_fld_cd ~ 1,
  TRUE ~ 0
)
CF_PM_cases <- quos(
  .data$fld_cd == 8
  & .data$fld_cd == .data$po1_fld_cd ~ 1,
  TRUE ~ 0
)
RF_PM_cases <- quos(
  .data$fld_cd == 9
  & .data$fld_cd == .data$po1_fld_cd ~ 1,
  TRUE ~ 0
)

# Get the summary table done.
data_lg_avg_pm <- events_plays_made_raw %>% 
  group_by(season, level_id, bat_hand_cd, bat_type) %>% 
  summarize(
    pitcher_PM_avg = mean(case_when(!!! pitcher_PM_cases)),
    catcher_PM_avg = mean(case_when(!!! catcher_PM_cases)),
    first_base_PM_avg = mean(case_when(!!! first_base_PM_cases)),
    second_base_PM_avg = mean(case_when(!!! second_base_PM_cases)),
    third_base_PM_avg = mean(case_when(!!! third_base_PM_cases)),
    shortstop_PM_avg = mean(case_when(!!! shortstop_PM_cases)),
    LF_PM_avg = mean(case_when(!!! LF_PM_cases)),
    CF_PM_avg = mean(case_when(!!! CF_PM_cases)),
    RF_PM_avg = mean(case_when(!!! RF_PM_cases)),
    BIP = n())

#query_LAPM_SQL <- paste("SELECT * FROM fact_field3.lg_avg_pm WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
#data_LAPM_SQL <- dbGetQuery(mysql, query_LAPM_SQL)  

## 16 -- Observed plays made "raw" -- obs_pm_raw 
# First, build up the data with copious inner joins.
data_obs_pm_raw <- events_plays_made_raw  %>% 
  inner_join(data_lg_avg_pm %>% 
               dplyr::rename_with(~ paste0(.x, "_lg"), ends_with("avg")) %>%
               dplyr::select(-BIP),
             by = c("season", "level_id", "bat_hand_cd", "bat_type")) %>% 
  inner_join(data_regressed_pf %>% 
               dplyr::select(season, level_id, home_team, GB_PF, OF_PF), 
             by = c("season", "level_id", "home_team")) %>%
  inner_join(data_gb_aib_adj_pit %>% 
               dplyr::select(-c(BIP, IF_AiB_adj)),
             by = c("season", "level_id", "fld_team", "pitcher_id")) %>% 
  inner_join(data_steal_plays_adj, 
             by = c("season", "level_id", "steal_flag")) %>% 
  inner_join(data_state_adj %>% 
               dplyr::select(-BIP), 
             by = c("season", "level_id", "startbases_cd", "outs_ct"))

data_obs_pm_raw <- data_obs_pm_raw %>%
  transmute(season, game_pk, event_id, level_id, fld_team,
            bat_hand_cd, bat_type, home_team,
            pitcher_id, pos2_fld_id, pos3_fld_id, pos4_fld_id,
            pos5_fld_id, pos6_fld_id, pos7_fld_id, pos8_fld_id, pos9_fld_id,
            pitcher_PM_play = case_when(!!! pitcher_PM_cases),
            catcher_PM_play  = case_when(!!! catcher_PM_cases),
            first_base_PM_play  = case_when(!!! first_base_PM_cases),
            second_base_PM_play  = case_when(!!! second_base_PM_cases),
            third_base_PM_play  = case_when(!!! third_base_PM_cases),
            shortstop_PM_play  = case_when(!!! shortstop_PM_cases),
            LF_PM_play  = case_when(!!! LF_PM_cases),
            CF_PM_play  = case_when(!!! CF_PM_cases),
            RF_PM_play  = case_when(!!! RF_PM_cases),
            across(c(pitcher_PM_avg_lg, 
                     catcher_PM_avg_lg, 
                     second_base_PM_avg_lg, 
                     third_base_PM_avg_lg, 
                     shortstop_PM_avg_lg),
                   ~(.x*if_else(bat_type != "N", 
                                1,
                                GB_PF*IF_GB_adj*IF_GB_PM_FCT))
            ),
            first_base_PM_avg_lg = 
              first_base_PM_avg_lg*if_else(bat_type != "N", 1, GB_PF*IF_GB_adj*IF_GB_PM_FCT*first_base_PM_ADJ),
            across(c(LF_PM_avg_lg, 
                     CF_PM_avg_lg, 
                     RF_PM_avg_lg),
                   ~(.x*if_else(bat_type != "N", 
                                1,
                                OF_PF*AiB_adj*OF_adj*OF_PM_FCT))
            )
            
  ) 

## 17 AND 18 -- obs_pm_shim (which is a normalizing process) into obs_pm (the full observed plays made)
# We're going to use pivot_longer, I think, to make the future math easier
# Now using Robert Au's suggestion to rename fielder ID in a way such that the 
# pivot_longer() catches it 
data_obs_pm_long <- data_obs_pm_raw %>% 
  rename(
    pitcher_PM_id = pitcher_id, 
    catcher_PM_id = pos2_fld_id, 
    first_base_PM_id = pos3_fld_id,
    second_base_PM_id = pos4_fld_id,
    third_base_PM_id = pos5_fld_id, 
    shortstop_PM_id = pos6_fld_id, 
    LF_PM_id = pos7_fld_id, 
    CF_PM_id = pos8_fld_id, 
    RF_PM_id = pos9_fld_id) %>%
  pivot_longer(cols = contains("PM"),
               names_to = c("pos", ".value"),
               names_pattern = "(.+)_PM_(.+)") %>%
  group_by(season, level_id, pos) %>% 
  mutate(PM_avg = mean(play - avg_lg) + avg_lg) %>%
  rename(PM_play = play) %>%
  ungroup() %>% 
  dplyr::select(-avg_lg)

# This is essentially for display only
data_obs_pm <- data_obs_pm_long %>%   
  pivot_wider(
    names_from = pos,
    names_glue = "{pos}_{.value}",
    values_from = c(id, PM_play, PM_avg)
  )

## 19 -- moe_pm (margin of error for observed PM data)
# Turns out, the pivot_longer table makes this *insanely easy*
# We're just going to extend the longer pivot table! 
data_obs_pm_long <- data_obs_pm_long %>% 
  group_by(season, level_id, bat_hand_cd, bat_type, pos) %>% 
  mutate(Num = n(),
         PM_moe = sd(PM_play - PM_avg)) %>% 
  ungroup() 

# Again, for display only.  
data_moe_pm <- data_obs_pm_long %>%
  group_by(season, level_id, bat_hand_cd, bat_type, pos) %>% 
  summarize(Num = n(),
            PM_moe = sd(PM_play - PM_avg)) %>% 
  ungroup() %>% 
  pivot_wider(
    names_from = pos,
    names_glue = "{pos}_{.value}",
    values_from = c(PM_moe)
  )
#query_MOEPM_SQL <- paste("SELECT * FROM fact_field3.moe_pm WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
#data_MOEPM_SQL <- dbGetQuery(mysql, query_MOEPM_SQL)  

## 20 -- The Beginnings of FRAA - fld_year_pm
# First, let's set up a position key to recode positions as Robert (and the original SQL) suggests
position_key <- c(pitcher = 1, catcher = 2, first_base = 3, 
                  second_base = 4, third_base = 5, shortstop = 6, 
                  LF = 7, CF = 8, RF = 9)

data_obs_pm_long <- data_obs_pm_long %>% 
  mutate(pos_num = recode(pos, !!!position_key))
# This works!

# Now, let's join in the linear weights.
data_obs_pm_long <- data_obs_pm_long %>% 
  inner_join(play_value_R, 
             by = c("season", "level_id", "bat_type" = "bat_type"))


# Finally, let's get fld_year_pm together
data_fld_year_pm <- data_obs_pm_long %>% 
  group_by(season, level_id, fld_team, id, pos_num) %>% 
  summarize(
    chances = n(),
    plays_made = sum(PM_play),
    avg_plays_made = sum(PM_avg),
    PAA = plays_made - avg_plays_made,
    moe_PM = sqrt(sum(PM_moe^2)), 
    RAA = sum(PM_play*LWTS) - sum(PM_avg*LWTS),
    moe_Runs = sqrt(sum((PM_moe*LWTS)^2))
  ) %>%
  ungroup()

#query_FYPM_SQL <- paste("SELECT * FROM fact_field3.fld_year_pm WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
#data_FYPM_SQL <- dbGetQuery(mysql, query_FYPM_SQL)  

## 21 -- "Regression" of Margin of Error - moe_regress 
## 22 & 23 -- The End: fld_year_pm_reg 
# Strictly speaking, we don't need to do much more than grab maximums and mutate for moe_regress.
# The rest is done via mutates! 
people_xrefs <- dbGetQuery(cage, paste0("SELECT * FROM xrefs.people_refs WHERE xref_type='mlb'"))  %>%
  mutate_at(vars(xref_id), list(as.numeric))
teams_xrefs <- dbGetQuery(cage, paste0("SELECT * FROM xrefs.teams_refs WHERE xref_type='mlbam'")) %>%
  mutate_at(vars(xref_id), list(as.numeric))
max_date <- dbGetQuery(cage, paste("SELECT max(official_date)::date::text FROM mlbapi.games_schedule WHERE game_type = 'R' AND level_id=1 AND left(status_code, 1) = 'F' AND season=", season, sep=""));
max_date <- max_date$max[1]

data_fld_year_pm_reg <- data_fld_year_pm %>% 
  group_by(season, level_id, pos_num) %>% 
  mutate(max_moe_PM = max(moe_PM)/max(chances),
         max_moe_Runs = max(moe_Runs)/max(chances)) %>%
  ungroup() %>% 
  mutate(PAA_reg = PAA/(1 + moe_PM/(max_moe_PM*chances)),
         RAA_reg = RAA/(1 + moe_Runs/(max_moe_Runs*chances))) %>% 
  group_by(season, level_id, pos_num) %>% 
  mutate(RAA_reg_final = RAA_reg - chances*sum(RAA_reg)/sum(chances)) %>%
  ungroup() %>%
  select(-c(max_moe_PM, max_moe_Runs, RAA_reg)) %>%
  inner_join(teams_xrefs, by = c("fld_team" = "xref_id")) %>%
  inner_join(people_xrefs, by = c("id" = "xref_id")) %>%
  rename(raa_reg = RAA_reg_final,
      team_id = teams_id,
      pos = pos_num,
      paa = PAA,
      moe_pm = moe_PM,
      paa_reg = PAA_reg,
      raa = RAA,
      moe_runs = moe_Runs) %>%
  add_column(version = max_date) %>%
  select(season, level_id, team_id, bpid, pos, chances, plays_made, avg_plays_made, paa, moe_pm, paa_reg, raa, moe_runs, raa_reg, version)

dbSendQuery(cage, paste0("DELETE FROM models.fraa_daily WHERE version = '", max_date, "'", sep=""))
dbWriteTable(cage, "fraa_daily", data_fld_year_pm_reg, row.names=FALSE, append=TRUE)

#query_FYPMR_SQL <- paste("SELECT * FROM fact_field3.fld_year_pm_reg WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
#data_FYPMR_SQL <- dbGetQuery(mysql, query_FYPMR_SQL)  

# RAA_reg_final IS batted ball FRAA. We're done. 

# Tra la, all's done! 
# NOT SO FAST, MY FRIEND. We need game crosstabs for use elsewhere.
# These processes are indeed present in fielding.sql, but they're mostly used elsewhere,
# particularly for outfield assists.

# First, let's get the games count from the play data. 
data_obs_pm_long <- data_obs_pm_long %>% ungroup()

pos_games.data.long <- data_obs_pm_long %>% 
  group_by(season, level_id, fld_team, id, pos_num) %>% 
  summarize(G = n_distinct(game_pk)) %>%
  rename(fld_id = id)
  
# Now recode (just for naming consistency) and pivot wider to match
position_rev_abbrev_key <- c(`1` = "P", 
                             `2` = "C", 
                             `3` = "1B",
                             `4` = "2B", 
                             `5` = "3B",
                             `6` = "SS",
                             `7` = "LF", 
                             `8` = "CF", 
                             `9` = "RF")

pos_games.data <- pos_games.data.long %>% 
  mutate(pos = recode(pos_num, !!! position_rev_abbrev_key)) %>%
  dplyr::select(-pos_num) %>%
  pivot_wider(
    names_from = pos,
    names_glue = "{.value}_{pos}",
    values_from = c(G),
    values_fill = 0
  )

pos_games_crosstab_official.query <- paste("SELECT season, level_id, player_id AS mlbid, team_id,
  COUNT(game_pk) FILTER (WHERE position='P')  AS G_P,
  COUNT(game_pk) FILTER (WHERE position='C')  AS G_C,
  COUNT(game_pk) FILTER (WHERE position='1B') AS G_1B,
  COUNT(game_pk) FILTER (WHERE position='2B') AS G_2B,
  COUNT(game_pk) FILTER (WHERE position='3B') AS G_3B,
  COUNT(game_pk) FILTER (WHERE position='SS') AS G_SS,
  COUNT(game_pk) FILTER (WHERE position='LF') AS G_LF,
  COUNT(game_pk) FILTER (WHERE position='CF') AS G_CF,
  COUNT(game_pk) FILTER (WHERE position='RF') AS G_RF,
  COUNT(game_pk) FILTER (WHERE position IN ('LF', 'CF', 'RF')) AS G_OF
  FROM (
    SELECT DISTINCT gplayers.player_id, 
    CASE away_home WHEN 'away' THEN gs.away_team ELSE gs.home_team END as team_id, 
    gs.season, gs.level_id, gpos.game_pk, position
    FROM mlbapi.games_positions gpos
    LEFT JOIN mlbapi.games_players gplayers
    USING (game_pk, away_home, player_type, player_index)
    LEFT JOIN xrefs.people_refs x
    ON x.xref_type = 'mlb' AND gplayers.player_id = x.xref_id::int
    LEFT JOIN mlbapi.games_schedule_deduped gs ON gs.game_pk = gpos.game_pk
    where LEFT(gs.status_code, 1) = 'F'
    AND gs.game_type = 'R'
  ) positions
  WHERE level_id = 1 AND season =", season,
  "GROUP BY season, level_id, player_id, team_id", sep = "")

pos_games_crosstab_official.data <- dbGetQuery(cage, pos_games_crosstab_official.query) %>% 
  dplyr::rename(fld_id = mlbid, fld_team = team_id)

save(pos_games.data.long, file="FRAA.RData")
# Tra la, all's done! 
