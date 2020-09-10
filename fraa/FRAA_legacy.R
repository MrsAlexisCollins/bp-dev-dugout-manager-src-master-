### set season ###

season <- 2019

### load packages ###

if (!require("pacman")) install.packages("pacman")
pacman::p_load(RMySQL,
               tidyverse,
               readxl,
               arm,
               baseballr,
               rstanarm,
               scales,
               loo)

### acquire data ###

## Open DB Connection (requires my.con1.maker.R) ####
source("my.con1.maker.R") #your con1 <- mysql with your credentials
con1 <- dbConnect(RMySQL::MySQL(),user=con1.user,password=con1.password,dbname=con1.dbname,host=con1.host)
rm(con1.password)
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
# Method 1: getting it raw, from a query:
query_play_value_raw <- paste(
  "SELECT
	  e.YEAR_ID
	  , e.LVL
	  , IF((FLD_CD BETWEEN 1 AND 6 AND FLD_CD IN (PO1_FLD_CD,ASS1_FLD_CD)) OR (FLD_CD BETWEEN 7 AND 9 AND FLD_CD = PO1_FLD_CD),1,0) AS PM
	  , (CASE WHEN BUNT_FL = \'T\' THEN \'B\'
		        WHEN BAT_FLD_CD = 1 THEN \'P\'
		        ELSE \'N\' END) AS BAT_TYPE
	  , COUNT(1) AS BIP
	  , AVG(e.EVENT_OUTS_CT) AS Outs
	  , AVG(e.EVENT_RUNS_CT+r.RE_DIFF) AS LWTS
	  FROM warehouse.events e
	  INNER JOIN (lwts.complete_innings c, lwts.re_diff r)
	  ON (e.EVENT_CD IN (2,18,19,20,21,22)
	  AND e.GAME_ID = c.GAME_ID
	  AND e.INN_CT = c.INN_CT
	  AND e.BAT_HOME_ID = c.BAT_HOME_ID
	  AND e.YEAR_ID = r.YEAR_ID
	  AND e.LVL = r.LVL
	  AND e.START_BASES_CD = r.START_BASES_CD
	  AND e.OUTS_CT = r.OUTS_CT
	  AND e.END_BASES_CD = r.END_BASES_CD
	  AND e.EVENT_OUTS_CT = r.EVENT_OUTS_CT)
  	WHERE e.LVL = \'mlb\' 
    AND e.YEAR_ID =",
    season,
    "AND c.YEAR_ID = e.YEAR_ID
	  AND r.YEAR_ID = e.YEAR_ID
	  GROUP BY e.YEAR_ID, e.LVL, PM, BAT_TYPE;",
    sep = " "
)
play_value_raw_SQL <- dbGetQuery(con1, query_play_value_raw)

# First things first: let's get events from complete innings -- maybe let's focus on just MLB
# Let's yank Judge's code, perhaps, from the OAA events testing script
# What do we need from warehouse.events?
# year_idX, levelX, fld_cdX, po1_fld_cdX, ass1_fld_cdX, bunt_flX, bat_fld_cdX, event_outs_ct, event_runs_ct in the select/elsewhere
# event_cdX in general FROM,  game_idX, inn_ctX, bat_home_idX for complete inning join, start_bases_cdX, outs_ctX, end_bases_cd for the run expectancy differences join.
query_events_PVR_ms <- paste("SELECT
         e.year_id
		   , e.lvl
		   , e.game_id
       , e.inn_ct
		   , e.bat_home_id
		   , event_cd 
		   , fld_cd
		   , po1_fld_cd 
		   , ass1_fld_cd 
		   , bunt_fl
		   , bat_fld_cd
		   , start_bases_cd
		   , outs_ct
		   , end_bases_cd
		   , event_outs_ct
		   , event_runs_ct
       FROM warehouse.events e
		   INNER JOIN (lwts.complete_innings c)
		   ON ( e.GAME_ID = c.GAME_ID 
		   AND e.INN_CT = c.INN_CT 
		   AND e.BAT_HOME_ID = c.BAT_HOME_ID)
		   WHERE e.year_id = c.year_id
		   AND e.lvl='mlb'
		   AND e.year_id=",season,sep = "")

events_PVR_ms <- dbGetQuery(con1, query_events_PVR_ms) %>% 
  filter(event_cd %in% FRAA_qualifying_event_codes) # Get only the qualifying event codes

# Get the run expectancy differences for ((base,out)_initial, (base,out)_final) pairs
query_re_diff_ms <- paste("SELECT 
      Num,
		   year_id
		   , lvl
		   , start_bases_cd
		   , outs_ct
		   , end_bases_cd
		   , event_outs_ct
		   , RE_DIFF
		   FROM lwts.re_diff 
		   WHERE lvl = 'mlb'
		   AND year_id=",season,sep = "")
re_diff_data_ms <- dbGetQuery(con1, query_re_diff_ms)

# Join the events to the run expectancy differences
events_PVR_ms <- events_PVR_ms %>% 
  inner_join(re_diff_data_ms, 
             by = c("year_id", "lvl", "start_bases_cd", 
                    "outs_ct", "end_bases_cd", "event_outs_ct")) # Now we've joined the dataframes

# Create "play_made", "bat_type" (really, play type), play_lwts variables for every play
events_PVR_ms <- events_PVR_ms %>% 
  mutate(
# Debug portions of the Play Made condition codes, separating each statement.
# A means to discover contradictions in the original errors. 
#    PM_IF_code = if_else(fld_cd %in% all_infield_code, 1, 0),
#    PM_IF_PO_field = if_else(fld_cd == po1_fld_cd, 1, 0),
#    PM_IF_ASS_field = if_else(fld_cd == ass1_fld_cd, 1, 0),
#    PM_OF_code = if_else(fld_cd %in% outfield_code, 1, 0),
#    PM_OF_field = if_else(fld_cd == po1_fld_cd, 1, 0),
# Finalized Play Made conditions -- use an OR statement to get the conditions I expected
    PM = case_when(
      fld_cd %in% all_infield_code & (fld_cd == po1_fld_cd | fld_cd == ass1_fld_cd) ~ 1, 
      fld_cd %in% outfield_code & fld_cd == po1_fld_cd ~ 1, 
      TRUE ~ 0
    ),
# This is the original set of conditions for trying to assess a play being made
# I was trying to be cute with the comparison of the fielder code to the 
# putout/assist fielder code by using %in% and a vector, but I think it failed 
# miserably. A notable example from the testing was where:
# - fld_cd == 6
# - po1_fld_cd AND ass1_fld_cd == 0 (because it was a single!)
# This matches the first infield condition, but ALSO matches the SECOND infield
# conditions for reasons I cannot understand yet -- perhaps because the elements
# in the vector are equal? End result: a play marked as "made," when it was a hit!
#     if_else( 
#     (fld_cd %in% all_infield_code & fld_cd %in% c(po1_fld_cd, ass1_fld_cd)) |
#      (fld_cd %in% outfield_code & fld_cd == po1_fld_cd), 1, 0),
    BAT_TYPE = case_when(
      bunt_fl == "T" ~ "B",
      bat_fld_cd == pitcher_code ~ "P",
      TRUE ~ "N"),
    play_lwts = event_runs_ct + RE_DIFF)

# Now we need to aggregate & transmute to get the final data frame
play_value_raw_R_ms <- events_PVR_ms %>% 
  group_by(year_id, lvl, PM, BAT_TYPE) %>% 
  summarize(BIP = n(), 
            Outs = mean(event_outs_ct), 
            LWTS_avg = mean(play_lwts))

# Debugging code for the events related to play_value_raw
# This is essentially identical to query_play_value_raw, with the notable 
# exception of excluding the aggregation/group by statements.
# Hence, after getting the query, events_SQL should be IDENTICAL to events_PVR
# A later revision should turn this into an *ACTUAL TEST* for test-driven dev.
query_events_SQL <- paste(
  "SELECT
	  e.YEAR_ID
	  , e.LVL
		   , e.game_id
       , e.inn_ct
		   , e.bat_home_id
		   , event_cd 
		   , fld_cd
		   , po1_fld_cd 
		   , ass1_fld_cd 
		   , bunt_fl
		   , bat_fld_cd
		   , e.start_bases_cd
		   , e.outs_ct
		   , e.end_bases_cd
		   , e.event_outs_ct
		   , e.event_runs_ct 
		   , r.RE_DIFF
	  	 , IF((FLD_CD BETWEEN 1 AND 6 AND FLD_CD IN (PO1_FLD_CD,ASS1_FLD_CD)) OR (FLD_CD BETWEEN 7 AND 9 AND FLD_CD = PO1_FLD_CD),1,0) AS PM
	  , (CASE WHEN BUNT_FL = \'T\' THEN \'B\'
		        WHEN BAT_FLD_CD = 1 THEN \'P\'
		        ELSE \'N\' END) AS BAT_TYPE
	  , e.EVENT_RUNS_CT+r.RE_DIFF as play_lwts
	  FROM warehouse.events e
	  INNER JOIN (lwts.complete_innings c, lwts.re_diff r)
	  ON (e.EVENT_CD IN (2,18,19,20,21,22)
	  AND e.GAME_ID = c.GAME_ID
	  AND e.INN_CT = c.INN_CT
	  AND e.BAT_HOME_ID = c.BAT_HOME_ID
	  AND e.YEAR_ID = r.YEAR_ID
	  AND e.LVL = r.LVL
	  AND e.START_BASES_CD = r.START_BASES_CD
	  AND e.OUTS_CT = r.OUTS_CT
	  AND e.END_BASES_CD = r.END_BASES_CD
	  AND e.EVENT_OUTS_CT = r.EVENT_OUTS_CT)
  	WHERE e.LVL = \'mlb\' 
    AND e.YEAR_ID =",
  season,
  "AND c.YEAR_ID = e.YEAR_ID
	  AND r.YEAR_ID = e.YEAR_ID;",
  sep = " "
)

events_SQL <- dbGetQuery(con1, query_events_SQL)

## 2 - play_value table
# This should be easy, because it appears to be a simple aggregation?
play_value_R_ms <- play_value_raw_R_ms %>% 
  group_by(year_id, lvl, BAT_TYPE) %>% 
  summarize(LWTS = sum(LWTS_avg[PM == 0]) - sum(LWTS_avg[PM == 1]))

query_play_value <- paste(
  "SELECT YEAR_ID, LVL
	, BAT_TYPE
	, SUM(IF(PM=0,LWTS,0))-SUM(IF(PM=1,LWTS,0)) AS LWTS
  FROM fact_field3.play_value_raw r
  WHERE r.YEAR_ID =", season,
  "GROUP BY YEAR_ID, LVL, BAT_TYPE;", 
  sep = " ")

play_value_SQL <- dbGetQuery(con1, query_play_value)

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
    & (.data$bat_hand_cd == "L" |  .data$bunt_fl == "T") ~ 1,
  .data$fld_cd == pitcher_code 
    & .data$fld_cd == .data$po1_fld_cd 
    & .data$bat_play_tx == .data$fld_cd 
    & .data$bunt_fl == "T" ~ 1,
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
    & .data$bunt_fl == "F" ~ 1,
  .data$fld_cd == pitcher_code 
    & .data$fld_cd == .data$po1_fld_cd 
    & .data$bat_play_tx == .data$fld_cd
    & .data$bunt_fl == "F" ~ 1,
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
query_events_LAPPraw_ms <- paste("SELECT
        year_id
		   , lvl
		   , game_id
       , inn_ct
		   , bat_home_id
		   , home_team_id
		   , away_team_id
		   , pit_id
		   , fld_team_id
		   , event_cd 
		   , h_cd
		   , battedball_cd
		   , fld_cd
		   , po1_fld_cd 
		   , ass1_fld_cd 
		   , bunt_fl
		   , bat_fld_cd
		   , bat_hand_cd
		   , bat_play_tx
		   , start_bases_cd
		   , outs_ct
		   , end_bases_cd
		   , event_outs_ct
		   , event_runs_ct
		   , run1_origin_event_id 
		   , run2_origin_event_id
       FROM warehouse.events e
		   WHERE lvl='mlb'
		   AND year_id=",season,sep = "")

events_LAPPraw_ms <- dbGetQuery(con1, query_events_LAPPraw_ms) 

events_LAPPraw_ms <- events_LAPPraw_ms %>% 
  filter(event_cd %in% FRAA_qualifying_event_codes
           & bunt_fl == "F" 
           & bat_fld_cd > 1
           & bat_play_tx != 99) # Get only the qualifying events for park factors

# Add markers if the play is made in the "base" classes of playmaking -- 
# these are essentially one-hot vectors & also roll up Air Ball and Total classes
events_LAPPraw_ms <- events_LAPPraw_ms %>% 
  mutate(IF_GB_PM = case_when(!!! IF_GB_play_made_cases),
         IF_AiB_PM = case_when(!!! IF_AiB_play_made_cases), 
         OF_PM = case_when(!!! OF_play_made_cases), 
         AiB_PM = if_else(IF_AiB_PM == 1 | OF_PM == 1, 1, 0),
         TM_PM = if_else(IF_GB_PM == 1 | AiB_PM == 1, 1, 0))

# Get the home field behavior
data_LAPPraw_home_ms <- events_LAPPraw_ms %>% 
  group_by(year_id, lvl, home_team_id) %>% 
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
# But also we need to consider how the home_team_id is involved
# Solution: just "rename" the column.
events_LAPPraw_ms <- events_LAPPraw_ms %>% ungroup() # Reset the DF

data_LAPPraw_away_ms <- events_LAPPraw_ms %>% 
  group_by(year_id, lvl, away_team_id) %>% 
  summarize(IF_GB_PM = mean(IF_GB_PM),
            IF_AiB_PM = mean(IF_AiB_PM),
            OF_PM = mean(OF_PM),
            AiB_PM = mean(AiB_PM),
            TM_PM = mean(TM_PM),
            BIP = n()) # Think about renaming the variables for airball and total for readability 
data_LAPPraw_away_ms <- data_LAPPraw_away_ms %>%
  rename(home_team_id = away_team_id) #renaming column SOLELY for joining purposes

# The data at this point should be:
# YEAR_ID, LVL, HOME_TEAM_ID, HOME_FL....ah, bind_rows acts as the union
data_LAPPraw_ms <- bind_rows(list(`0` = data_LAPPraw_away_ms, `1` = data_LAPPraw_home_ms), 
                          .id = "home_fl") #%>% rename_all(tolower)

query_LAPPraw_SQL <- paste("SELECT * FROM fact_field3.lg_avg_pm_park_raw WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
data_LAPPraw_SQL <-dbGetQuery(con1, query_LAPPraw_SQL) %>% rename_all(tolower)

## 4 -- Regressed park factors 
two_factor_regression <- function(x, y, w1, w2) {
  data_vec <- c(x,y)
  w1_vec <- c(w1,(1-w1))
  w2*(x/sum(data_vec*w1_vec)) + (1-w2)
}

test1 <- two_factor_regression(5,6,0.6,0.35)


data_regressed_pf_ms <- data_LAPPraw_ms %>% 
  group_by(year_id, lvl, home_team_id) %>%
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

query_regressed_pf_SQL <- paste("SELECT * FROM fact_field3.regressed_pf WHERE lvl = \'mlb\' AND year_id = ", season, sep = " ")
data_regressed_pf_SQL <- dbGetQuery(con1, query_regressed_pf_SQL)

## 5 -- League Average Plays Made table
# The SQL query for this essentially looks like the one for LAPP, but for
# the calculation of DER and GB%. Thus, we can use events_LAPPraw for this,
# but change the grouping/summary to only year and level.
# We're going to fix events_LAPPraw to support this instead.
events_LAPPraw_ms <- events_LAPPraw_ms %>% ungroup() # Reset the DF

data_LAPMG_ms <- events_LAPPraw_ms %>%
  group_by(year_id, lvl) %>% 
  summarize(DER = 1-mean(if_else(h_cd %in% c(1:3), 1, 0)),
            GB_PCT = sum(if_else(battedball_cd == "G", 1, 0))/sum(if_else(battedball_cd != "", 1, 0)),
            IF_GB_PM = mean(IF_GB_PM),
            IF_AiB_PM = mean(IF_AiB_PM),
            OF_PM = mean(OF_PM),
            AiB_PM = mean(AiB_PM),
            TM_PM = mean(TM_PM),
            BIP = n())
events_LAPPraw_ms <- events_LAPPraw_ms %>% ungroup()

query_LAPMG_SQL <- paste("SELECT * FROM fact_field3.lg_avg_pm_group WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
data_LAPMG_SQL <- dbGetQuery(con1, query_LAPMG_SQL)

## 6 -- Base-Out State Average Plays Made table
data_BOSAPM_ms <- events_LAPPraw_ms %>%
  group_by(year_id, lvl, start_bases_cd, outs_ct) %>% 
  summarize(DER = 1-mean(if_else(h_cd %in% c(1:3), 1, 0)),
            GB_PCT = sum(if_else(battedball_cd == "G", 1, 0))/sum(if_else(battedball_cd != "", 1, 0)),
            IF_GB_PM = mean(IF_GB_PM),
            IF_AiB_PM = mean(IF_AiB_PM),
            OF_PM = mean(OF_PM),
            AiB_PM = mean(AiB_PM),
            TM_PM = mean(TM_PM),
            BIP = n())
events_LAPPraw_ms <- events_LAPPraw_ms %>% ungroup()

query_BOSAPM_SQL <- paste("SELECT * FROM fact_field3.state_avg_pm_group WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
data_BOSAPM_SQL <- dbGetQuery(con1, query_BOSAPM_SQL)

## 7 -- Base-Out State Average Plays Made, Adjusted By League Average table
data_state_adj_ms <- left_join(data_BOSAPM_ms, data_LAPMG_ms, by=c("year_id", "lvl")) %>%
  group_by(year_id,lvl, start_bases_cd, outs_ct) %>%
  summarize(IF_GB_PM_FCT = IF_GB_PM.x/IF_GB_PM.y,
            IF_AiB_PM_FCT = IF_GB_PM.x/IF_AiB_PM.y,
            OF_PM_FCT = IF_GB_PM.x/IF_GB_PM.y,
            BIP = BIP.x)
query_state_adj_SQL <- paste("SELECT * FROM fact_field3.state_adj WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
data_state_adj_SQL <- dbGetQuery(con1, query_state_adj_SQL)

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
    (.data$bat_hand_cd == "L" |  .data$bunt_fl == "T") ~ 1,
  TRUE ~ 0
)
# In observing the above, this is basically where IF_GB_PM occurs with a first baseman fielding
# Perhaps this would be better served by a filter?
# Or an if_else with condition IF_GB_PM == 1 and fld_cd == first_base_cd?

# Let's try the first thing
data_steal_plays_raw_ms <- events_LAPPraw_ms %>%
  group_by(year_id, lvl) %>%
  summarize(first_base_PM_avg = mean(case_when(!!! first_base_PM_cases)))

# Let's validate the results
query_SPR_SQL <- paste("SELECT * FROM fact_field3.steal_plays_raw WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
data_steal_plays_raw_SQL <- dbGetQuery(con1, query_SPR_SQL)

events_LAPPraw_ms <- events_LAPPraw_ms %>% ungroup()
## 9 -- Steal Plays, Adjusted 
# First, add the steal play flag 

data_steal_plays_adj_ms <- events_LAPPraw_ms %>% 
  mutate(steal_flag = if_else(run1_origin_event_id > 0 & run2_origin_event_id == 0, 1, 0),
         first_base_PM = case_when(!!! first_base_PM_cases)) %>%
  inner_join(data_state_adj, by = c("year_id", "lvl", "start_bases_cd", "outs_ct")) %>%
  inner_join(data_steal_plays_raw, by = c("year_id", "lvl")) %>% 
  group_by(year_id, lvl, steal_flag) %>%
  summarize(first_base_PM_ADJ = sum(first_base_PM)/sum(first_base_PM_avg/IF_GB_PM_FCT))


# Let's validate the results
query_SPA_SQL <- paste("SELECT * FROM fact_field3.steal_plays_adj WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
data_steal_plays_adj_SQL <- dbGetQuery(con1, query_SPA_SQL)

## 10 -- Average plays made per pitcher/defense combo
# Surprise, this is the same as Base-Out state PM, but just with a different group_by!
# Consider making the summarize here a function in a refactor
data_pit_avg_pm_group_ms <- events_LAPPraw_ms %>%
  group_by(year_id, lvl, pit_id, fld_team_id) %>% 
  summarize(DER = 1-mean(if_else(h_cd %in% c(1:3), 1, 0)),
            GB_PCT = sum(if_else(battedball_cd == "G", 1, 0))/sum(if_else(battedball_cd != "", 1, 0)),
            IF_GB_PM = mean(IF_GB_PM),
            IF_AiB_PM = mean(IF_AiB_PM),
            OF_PM = mean(OF_PM),
            AiB_PM = mean(AiB_PM),
            TM_PM = mean(TM_PM),
            BIP = n())

query_PAPMG_SQL <- paste("SELECT * FROM fact_field3.pit_avg_pm_group WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
data_PAPMG_SQL <- dbGetQuery(con1, query_PAPMG_SQL)

events_LAPPraw_ms <- events_LAPPraw_ms %>% ungroup()
## 11 -- League Average Play Likelihoods for Plays in #10
# This could perhaps be managed with a clever join beforehand? 

# We're also probably going to need a function.
# We could borrow from http://jonthegeek.com/2018/06/04/writing-custom-tidyverse-functions/

data_pit_lg_pm_group_ms <- events_LAPPraw_ms %>% 
  inner_join(data_regressed_pf_ms %>% dplyr::select(!BIP), 
             by = c("year_id", "lvl", "home_team_id")) %>% 
  inner_join(data_BOSAPM_ms %>% 
               dplyr::rename_with(~ paste0(.x, "_state"), ends_with("PM")) %>% 
               dplyr::select(-c(BIP, DER, GB_PCT)),
             by = c("year_id", "lvl","start_bases_cd", "outs_ct")) %>%
  group_by(year_id, lvl, pit_id, fld_team_id) %>% 
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
#              by = c("year_id", "lvl", "home_team_id")) %>%
#   inner_join(data_BOSAPM %>%
#                dplyr::rename_with(~ paste0(.x, "_state"), ends_with("PM")) %>%
#                dplyr::select(-c(BIP, DER, GB_PCT)),
#              by = c("year_id", "lvl","start_bases_cd", "outs_ct")) # %>%
# test %>% group_by(year_id, lvl, pit_id, fld_team_id) %>% #dplyr::summarize(across(ends_with("PM_state"), ~ sum(is.na(.x)))
#    dplyr::summarize(across(ends_with("PM_state"),
#                            ~ weighted.mean(.x, str_replace(cur_column(), "PM_state", "PF")), 
#                            .names = "{col}_temp")) #,
#              #across(contains("PF"), mean, .names = "{col}_temp"))

query_PLPMG_SQL <- paste("SELECT * FROM fact_field3.pit_lg_pm_group WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
data_PLPMG_SQL <- dbGetQuery(con1, query_PLPMG_SQL)  

events_LAPPraw_ms <- events_LAPPraw_ms %>% ungroup()
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

data_gb_aib_adj_pit_raw_ms <- data_pit_avg_pm_group_ms %>% 
  dplyr::rename_with(~ paste0(.x, "_stint"), ends_with("PM")) %>% 
  dplyr::inner_join(data_pit_lg_pm_group_ms %>% 
                      dplyr::rename_with(~ paste0(.x, "_league"), ends_with("PM")),
                    by = c("year_id", "lvl", "pit_id", "fld_team_id")) %>% 
  dplyr::transmute(
    year_id, 
    lvl,
    pit_id,
    fld_team_id,
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

query_GAAPR_SQL <- paste("SELECT * FROM fact_field3.gb_aib_adj_pit_raw WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
data_GAAPR_SQL <- dbGetQuery(con1, query_GAAPR_SQL)  

## 13 -- Intermediate normalization table for GB/AiB adjustments -- gb_aib_adj_pit_fix
data_gb_aib_adj_pit_fix_ms <- data_gb_aib_adj_pit_raw_ms %>%
  group_by(year_id, lvl) %>% 
  dplyr::summarize(across(ends_with("_adj"), ~ sum(.x * BIP)/sum(BIP), #weighted.mean(.x, BIP), 
                              .names = "{col}_temp")) 
# Look how small that is!
query_GAAPF_SQL <- paste("SELECT * FROM fact_field3.gb_aib_adj_pit_fix WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
data_GAAPF_SQL <- dbGetQuery(con1, query_GAAPF_SQL) 
# We have a bit of an error accumulation issue here, I think. Particularly in the infield fly ball category.

## 14 -- Finalized GB/AiB split adjustments per pitcher/team stint -- gb_aib_adj_pit
# Technically, we don't need the last table *at all* for this.  
data_gb_aib_adj_pit_ms <- data_gb_aib_adj_pit_raw_ms %>% 
  group_by(year_id, lvl) %>% 
  dplyr::transmute(year_id, lvl, pit_id, fld_team_id, BIP,
                   across(ends_with("_adj"), ~ (.x - sum(.x * BIP)/sum(BIP) + 1), #weighted.mean(.x, BIP), 
                          .names = "{col}"))

query_GAAP_SQL <- paste("SELECT * FROM fact_field3.gb_aib_adj_pit WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
data_GAAP_SQL <- dbGetQuery(con1, query_GAAP_SQL)  

## 15 -- League-average plays made per position -- lg_avg_pm
# Note: this is NOT lg_avg_pm_group from Table 5!! 
# We're bringing in a new event query, because technically, the one we've used previously
# has filters on situations we need now. 
# This mirrors events_LAPPraw, but has new elements.
query_events_plays_made_raw_ms<- paste("SELECT
        year_id
		   , lvl
		   , game_id
		   , seq_events
       , inn_ct
		   , bat_home_id
		   , home_team_id
		   , away_team_id
		   , pit_start_fl
		   , pit_id
		   , pos2_fld_id
		   , pos3_fld_id
		   , pos4_fld_id
		   , pos5_fld_id
		   , pos6_fld_id
		   , pos7_fld_id
		   , pos8_fld_id
		   , pos9_fld_id
		   , fld_team_id
		   , event_cd 
		   , h_cd
		   , battedball_cd
		   , fld_cd
		   , po1_fld_cd 
		   , ass1_fld_cd 
		   , bunt_fl
		   , bat_fld_cd
		   , bat_hand_cd
		   , bat_play_tx
		   , start_bases_cd
		   , outs_ct
		   , end_bases_cd
		   , event_outs_ct
		   , event_runs_ct
		   , run1_origin_event_id 
		   , run2_origin_event_id
       FROM warehouse.events e
		   WHERE lvl='mlb'
		   AND year_id=",season,sep = "")

events_plays_made_raw_ms<- dbGetQuery(con1, query_events_plays_made_raw_ms) 

# First, filter out a few things 
events_plays_made_raw_ms<- events_plays_made_raw_ms%>% 
  filter(event_cd %in% FRAA_qualifying_event_codes
         & bat_play_tx != 99) # Get only the qualifying events for park factors

# Next, let's append a few things onto the events:
# - the batted ball types,
# - a steal play flag (which we saw before!) 
events_plays_made_raw_ms<- events_plays_made_raw_ms%>% 
  mutate(bat_type = case_when(
    bunt_fl == "T" ~ "B",
    bat_fld_cd == pitcher_code ~ "P",
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
  & .data$bunt_fl == "T" ~ 1,
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
data_lg_avg_pm_ms <- events_plays_made_raw_ms%>% 
  group_by(year_id, lvl, bat_hand_cd, bat_type) %>% 
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

query_LAPM_SQL <- paste("SELECT * FROM fact_field3.lg_avg_pm WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
data_LAPM_SQL <- dbGetQuery(con1, query_LAPM_SQL)  

## 16 -- Observed plays made "raw" -- obs_pm_raw 
# First, build up the data with copious inner joins.
data_obs_pm_raw_ms <- events_plays_made_raw_ms %>% 
  inner_join(data_lg_avg_pm_ms %>% 
               dplyr::rename_with(~ paste0(.x, "_lg"), ends_with("avg")) %>%
               dplyr::select(-BIP),
             by = c("year_id", "lvl", "bat_hand_cd", "bat_type")) %>% 
  inner_join(data_regressed_pf_ms %>% 
               dplyr::select(year_id, lvl, home_team_id, GB_PF, OF_PF), 
             by = c("year_id", "lvl", "home_team_id")) %>%
  inner_join(data_gb_aib_adj_pit %>% 
               dplyr::select(-c(BIP, IF_AiB_adj)),
             by = c("year_id", "lvl", "fld_team_id", "pit_id")) %>% 
  inner_join(data_steal_plays_adj, 
             by = c("year_id", "lvl", "steal_flag")) %>% 
  inner_join(data_state_adj %>% 
               dplyr::select(-BIP), 
             by = c("year_id", "lvl", "start_bases_cd", "outs_ct"))

data_obs_pm_raw_ms <- data_obs_pm_raw_ms %>%
  transmute(year_id, game_id, seq_events, lvl, fld_team_id,
            bat_hand_cd, bat_type, pit_start_fl, home_team_id,
            pit_id, pos2_fld_id, pos3_fld_id, pos4_fld_id,
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
data_obs_pm_long_ms<- data_obs_pm_raw_ms %>% 
  rename(
    pitcher_PM_id = pit_id, 
    catcher_PM_id = pos2_fld_id, 
    first_base_PM_id = pos3_fld_id,
    second_base_PM_id = pos4_fld_id,
    third_base_PM_id = pos5_fld_id, 
    shortstop_PM_id = pos6_fld_id, 
    LF_PM_id = pos7_fld_id, 
    RF_PM_id = pos8_fld_id, 
    CF_PM_id = pos9_fld_id) %>%
  pivot_longer(cols = contains("PM"),
               names_to = c("pos", ".value"),
               names_pattern = "(.+)_PM_(.+)") %>%
  group_by(year_id, lvl, pos) %>% 
  mutate(PM_avg = mean(play - avg_lg) + avg_lg) %>%
  rename(PM_play = play) %>%
  ungroup() %>% 
  dplyr::select(-avg_lg)

# This is essentially for display only
data_obs_pm_ms <- data_obs_pm_long_ms%>%   
  pivot_wider(
    names_from = pos,
    names_glue = "{pos}_{.value}",
    values_from = c(id, PM_play, PM_avg)
  )

## 19 -- moe_pm (margin of error for observed PM data)
# Turns out, the pivot_longer table makes this *insanely easy*
# We're just going to extend the longer pivot table! 
data_obs_pm_long_ms<- data_obs_pm_long_ms%>% 
  group_by(year_id, lvl, bat_hand_cd, bat_type, pos) %>% 
  mutate(Num = n(),
    PM_moe = sd(PM_play - PM_avg)) %>% 
  ungroup() 

# Again, for display only.  
data_moe_pm_ms <- data_obs_pm_long_ms%>%
  group_by(year_id, lvl, bat_hand_cd, bat_type, pos) %>% 
  summarize(Num = n(),
         PM_moe = sd(PM_play - PM_avg)) %>% 
  ungroup() %>% 
  pivot_wider(
    names_from = pos,
    names_glue = "{pos}_{.value}",
    values_from = c(PM_moe)
  )
query_MOEPM_SQL <- paste("SELECT * FROM fact_field3.moe_pm WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
data_MOEPM_SQL <- dbGetQuery(con1, query_MOEPM_SQL)  

## 20 -- The Beginnings of FRAA - fld_year_pm
# First, let's set up a position key to recode positions as Robert (and the original SQL) suggests
position_key <- c(pitcher = 1, catcher = 2, first_base = 3, 
                  second_base = 4, third_base = 5, shortstop = 6, 
                  LF = 7, CF = 8, RF = 9)

data_obs_pm_long_ms<- data_obs_pm_long_ms%>% 
  mutate(pos_num = recode(pos, !!!position_key))
# This works!

# Now, let's join in the linear weights.
data_obs_pm_long_ms<- data_obs_pm_long_ms%>% 
  inner_join(play_value_R, 
             by = c("year_id", "lvl", "bat_type" = "BAT_TYPE"))


# Finally, let's get fld_year_pm together
data_fld_year_pm_ms <- data_obs_pm_long_ms%>% 
  group_by(year_id, lvl, fld_team_id, id, pos_num) %>% 
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
  
query_FYPM_SQL <- paste("SELECT * FROM fact_field3.fld_year_pm WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
data_FYPM_SQL <- dbGetQuery(con1, query_FYPM_SQL)  

## 21 -- "Regression" of Margin of Error - moe_regress 
## 22 & 23 -- The End: fld_year_pm_reg 
# Strictly speaking, we don't need to do much more than grab maximums and mutate for moe_regress.
# The rest is done via mutates! 
data_fld_year_pm_reg_ms <- data_fld_year_pm_ms %>% 
  group_by(year_id, lvl, pos_num) %>% 
  mutate(max_moe_PM = max(moe_PM)/max(chances),
         max_moe_Runs = max(moe_Runs)/max(chances)) %>%
  ungroup() %>% 
  mutate(PAA_reg = PAA/(1 + moe_PM/(max_moe_PM*chances)),
         RAA_reg = RAA/(1 + moe_Runs/(max_moe_Runs*chances))) %>% 
  group_by(year_id, lvl, pos_num) %>% 
  mutate(RAA_reg_final = RAA_reg - chances*sum(RAA_reg)/sum(chances)) %>%
  ungroup()

query_FYPMR_SQL <- paste("SELECT * FROM fact_field3.fld_year_pm_reg WHERE lvl = \'mlb\' AND year_id =", season, sep = " ")
data_FYPMR_SQL <- dbGetQuery(con1, query_FYPMR_SQL)  

# RAA_reg_final IS batted ball FRAA. We're done. 

# Tra la, all's done! 
