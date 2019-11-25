
-- Drop table

-- DROP TABLE stats.stats_catching;

CREATE TABLE stats.stats_catching (
	bpid int4 NOT NULL,
	season int4 NOT NULL,
	team_id int4 NOT NULL,
	"timestamp" timestamptz NOT NULL,
	games_played int4 NULL,
	runs int4 NULL,
	home_runs int4 NULL,
	strike_outs int4 NULL,
	base_on_balls int4 NULL,
	intentional_walks int4 NULL,
	hits int4 NULL,
	avg float4 NULL,
	at_bats int4 NULL,
	obp float4 NULL,
	slg float4 NULL,
	ops float4 NULL,
	caught_stealing int4 NULL,
	stolen_bases int4 NULL,
	stolen_base_percentage float4 NULL,
	era float4 NULL,
	earned_runs int4 NULL,
	whip float4 NULL,
	batters_faced int4 NULL,
	games_pitched int4 NULL,
	hit_batsmen int4 NULL,
	wild_pitches int4 NULL,
	pickoffs int4 NULL,
	total_bases int4 NULL,
	strikeout_walk_ratio float4 NULL,
	strikeouts_per_9_inn float4 NULL,
	walks_per_9_inn float4 NULL,
	hits_per_9_inn float4 NULL,
	catchers_interference int4 NULL,
	sac_bunts int4 NULL,
	sac_flies int4 NULL,
	id serial NOT NULL,
	CONSTRAINT stats_catching_pkey PRIMARY KEY (bpid, season, team_id, "timestamp")
);

-- Drop table

-- DROP TABLE stats.stats_fielding;

CREATE TABLE stats.stats_fielding (
	bpid int4 NOT NULL,
	season int4 NOT NULL,
	team_id int4 NOT NULL,
	"position" text NOT NULL,
	"timestamp" timestamptz NOT NULL,
	assists int4 NULL,
	put_outs int4 NULL,
	errors int4 NULL,
	chances int4 NULL,
	fielding float4 NULL,
	range_factor_per_game float4 NULL,
	range_factor_per_9_inn float4 NULL,
	innings float4 NULL,
	games int4 NULL,
	games_started int4 NULL,
	double_plays int4 NULL,
	triple_plays int4 NULL,
	throwing_errors int4 NULL,
	CONSTRAINT stats_fielding_pkey PRIMARY KEY (bpid, season, team_id, "position", "timestamp")
);

-- Drop table

-- DROP TABLE stats.stats_hitting;

CREATE TABLE stats.stats_hitting (
	bpid int4 NOT NULL,
	season int4 NOT NULL,
	team_id int4 NOT NULL,
	"timestamp" timestamptz NOT NULL,
	games_played int4 NULL,
	ground_outs int4 NULL,
	air_outs int4 NULL,
	runs int4 NULL,
	doubles int4 NULL,
	triples int4 NULL,
	home_runs int4 NULL,
	strike_outs int4 NULL,
	base_on_balls int4 NULL,
	intentional_walks int4 NULL,
	hits int4 NULL,
	hit_by_pitch int4 NULL,
	avg float4 NULL,
	at_bats int4 NULL,
	obp float4 NULL,
	slg float4 NULL,
	ops float4 NULL,
	caught_stealing int4 NULL,
	stolen_bases int4 NULL,
	stolen_base_percentage float4 NULL,
	ground_into_double_play int4 NULL,
	number_of_pitches int4 NULL,
	plate_appearances int4 NULL,
	total_bases int4 NULL,
	rbi int4 NULL,
	left_on_base int4 NULL,
	sac_bunts int4 NULL,
	sac_flies int4 NULL,
	babip float4 NULL,
	ground_outs_to_airouts float4 NULL,
	at_bats_per_home_run float4 NULL,
	id serial NOT NULL,
	CONSTRAINT stats_hitting_pkey PRIMARY KEY (bpid, season, team_id, "timestamp")
);

-- Drop table

-- DROP TABLE stats.stats_pitching;

CREATE TABLE stats.stats_pitching (
	bpid int4 NOT NULL,
	season int4 NOT NULL,
	team_id int4 NOT NULL,
	"timestamp" timestamptz NOT NULL,
	games_played int4 NULL,
	games_started int4 NULL,
	ground_outs int4 NULL,
	air_outs int4 NULL,
	runs int4 NULL,
	doubles int4 NULL,
	triples int4 NULL,
	home_runs int4 NULL,
	strike_outs int4 NULL,
	base_on_balls int4 NULL,
	intentional_walks int4 NULL,
	hits int4 NULL,
	avg float4 NULL,
	at_bats int4 NULL,
	obp float4 NULL,
	slg float4 NULL,
	ops float4 NULL,
	caught_stealing int4 NULL,
	stolen_bases int4 NULL,
	stolen_base_percentage float4 NULL,
	ground_into_double_play int4 NULL,
	number_of_pitches int4 NULL,
	era float4 NULL,
	innings_pitched float4 NULL,
	wins int4 NULL,
	losses int4 NULL,
	saves int4 NULL,
	save_opportunities int4 NULL,
	holds int4 NULL,
	blown_saves int4 NULL,
	earned_runs int4 NULL,
	whip float4 NULL,
	batters_faced int4 NULL,
	games_pitched int4 NULL,
	complete_games int4 NULL,
	shutouts int4 NULL,
	strikes int4 NULL,
	strike_percentage float4 NULL,
	hit_batsmen int4 NULL,
	balks int4 NULL,
	wild_pitches int4 NULL,
	pickoffs int4 NULL,
	total_bases int4 NULL,
	ground_outs_to_airouts float4 NULL,
	win_percentage float4 NULL,
	pitches_per_inning float4 NULL,
	games_finished int4 NULL,
	strikeout_walk_ratio float4 NULL,
	strikeouts_per_9_inn float4 NULL,
	walks_per_9_inn float4 NULL,
	hits_per_9_inn float4 NULL,
	runs_scored_per_9 float4 NULL,
	home_runs_per_9 float4 NULL,
	inherited_runners int4 NULL,
	inherited_runners_scored int4 NULL,
	CONSTRAINT stats_pitching_pkey PRIMARY KEY (bpid, season, team_id, "timestamp")
);

ALTER TABLE stats.stats_catching ADD CONSTRAINT stats_catching_id_fkey FOREIGN KEY (bpid) REFERENCES entitas.people(bpid) ON DELETE RESTRICT;
ALTER TABLE stats.stats_catching ADD CONSTRAINT stats_catching_team_fkey FOREIGN KEY (team_id) REFERENCES entitas.teams(team_id);

ALTER TABLE stats.stats_fielding ADD CONSTRAINT stats_fielding_id_fkey FOREIGN KEY (bpid) REFERENCES entitas.people(bpid) ON DELETE RESTRICT;
ALTER TABLE stats.stats_fielding ADD CONSTRAINT stats_fielding_team_fkey FOREIGN KEY (team_id) REFERENCES entitas.teams(team_id);

ALTER TABLE stats.stats_hitting ADD CONSTRAINT stats_hitting_id_fkey FOREIGN KEY (bpid) REFERENCES entitas.people(bpid) ON DELETE RESTRICT;
ALTER TABLE stats.stats_hitting ADD CONSTRAINT stats_hitting_team_fkey FOREIGN KEY (team_id) REFERENCES entitas.teams(team_id);

ALTER TABLE stats.stats_pitching ADD CONSTRAINT stats_pitching_id_fkey FOREIGN KEY (bpid) REFERENCES entitas.people(bpid) ON DELETE RESTRICT;
ALTER TABLE stats.stats_pitching ADD CONSTRAINT stats_pitching_team_fkey FOREIGN KEY (team_id) REFERENCES entitas.teams(team_id);
