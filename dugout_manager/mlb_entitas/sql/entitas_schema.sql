
-- Drop table

-- DROP TABLE entitas.continents;

CREATE TABLE entitas.continents (
	continent_id int4 NOT NULL,
	continent_name text NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT continents_pkey PRIMARY KEY (continent_id)
);

-- Drop table

-- DROP TABLE entitas.governing_bodies;

CREATE TABLE entitas.governing_bodies (
	gov_bod_id int4 NOT NULL,
	gov_bod_name text NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT governing_bodies_pkey PRIMARY KEY (gov_bod_id)
);

-- Drop table

-- DROP TABLE entitas.nations;

CREATE TABLE entitas.nations (
	nation_id int4 NOT NULL,
	nation_name text NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT nations_pkey PRIMARY KEY (nation_id)
);

-- Drop table

-- DROP TABLE entitas.people;

CREATE TABLE entitas.people (
	bpid int4 NOT NULL,
	use_full_name text NOT NULL,
	use_sortable_name text NOT NULL,
	use_short_name text NULL,
	last_name text NULL,
	middle_name text NULL,
	middle_initial text NULL,
	matrilineal_name text NULL,
	first_name text NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT people_pk PRIMARY KEY (bpid)
);

-- Drop table

-- DROP TABLE entitas.provinces;

CREATE TABLE entitas.provinces (
	province_id int4 NOT NULL,
	province_name text NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT province_pkey PRIMARY KEY (province_id)
);

-- Drop table

-- DROP TABLE entitas.sub_continents;

CREATE TABLE entitas.sub_continents (
	sub_con_id int4 NOT NULL,
	sub_con_name text NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT sub_continents_pkey PRIMARY KEY (sub_con_id)
);

-- Drop table

-- DROP TABLE entitas.sub_regions;

CREATE TABLE entitas.sub_regions (
	sub_region_id int4 NOT NULL,
	sub_region_name text NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT sub_regions_pkey PRIMARY KEY (sub_region_id)
);

-- Drop table

-- DROP TABLE entitas.super_continents;

CREATE TABLE entitas.super_continents (
	super_con_id int4 NOT NULL,
	super_con_name text NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT super_continents_pkey PRIMARY KEY (super_con_id)
);

-- Drop table

-- DROP TABLE entitas.leagues;

CREATE TABLE entitas.leagues (
	league_id int4 NOT NULL,
	league_name text NULL,
	gov_bod_id int4 NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT leagues_pkey PRIMARY KEY (league_id),
	CONSTRAINT leagues_fk FOREIGN KEY (gov_bod_id) REFERENCES entitas.governing_bodies(gov_bod_id)
);

-- Drop table

-- DROP TABLE entitas.levels;

CREATE TABLE entitas.levels (
	level_id int4 NOT NULL,
	level_name text NULL,
	gov_bod_id int4 NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT levels_pkey PRIMARY KEY (level_id),
	CONSTRAINT levels_fk FOREIGN KEY (gov_bod_id) REFERENCES entitas.governing_bodies(gov_bod_id)
);

-- Drop table

-- DROP TABLE entitas.organizations;

CREATE TABLE entitas.organizations (
	org_id int4 NOT NULL,
	org_name text NULL,
	gov_bod_id int4 NOT NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT organizations_pkey PRIMARY KEY (org_id),
	CONSTRAINT organizations_fk FOREIGN KEY (gov_bod_id) REFERENCES entitas.governing_bodies(gov_bod_id)
);

-- Drop table

-- DROP TABLE entitas.people_aliases;

CREATE TABLE entitas.people_aliases (
	bpid int4 NOT NULL,
	alias_id int4 NOT NULL,
	use_full_alias text NOT NULL,
	use_sortable_alias text NOT NULL,
	use_short_alias text NOT NULL,
	last_alias text NULL,
	middle_alias text NULL,
	middle_initial_alias text NULL,
	matrilineal_alias text NULL,
	first_alias varchar NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT people_aliases_pk PRIMARY KEY (alias_id),
	CONSTRAINT people_aliases_fk FOREIGN KEY (bpid) REFERENCES entitas.people(bpid)
);

-- Drop table

-- DROP TABLE entitas.people_nicknames;

CREATE TABLE entitas.people_nicknames (
	bpid int4 NOT NULL,
	nickname_id int4 NOT NULL,
	nickname text NOT NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT people_nicknames_pk PRIMARY KEY (nickname_id),
	CONSTRAINT people_nicknames_fk FOREIGN KEY (bpid) REFERENCES entitas.people(bpid)
);

-- Drop table

-- DROP TABLE entitas.conferences;

CREATE TABLE entitas.conferences (
	conference_id int4 NOT NULL,
	conference_name text NULL,
	league_id int4 NULL,
	gov_bod_id int4 NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT conferences_pkey PRIMARY KEY (conference_id),
	CONSTRAINT conferences_fk FOREIGN KEY (league_id) REFERENCES entitas.leagues(league_id),
	CONSTRAINT conferences_fk_1 FOREIGN KEY (gov_bod_id) REFERENCES entitas.governing_bodies(gov_bod_id)
);

-- Drop table

-- DROP TABLE entitas.divisions;

CREATE TABLE entitas.divisions (
	division_id int4 NOT NULL,
	division_name text NULL,
	league_id int4 NULL,
	conference_id int4 NULL,
	gov_bod_id int4 NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT divisions_pkey PRIMARY KEY (division_id),
	CONSTRAINT divisions_fk FOREIGN KEY (conference_id) REFERENCES entitas.conferences(conference_id),
	CONSTRAINT divisions_fk_1 FOREIGN KEY (gov_bod_id) REFERENCES entitas.governing_bodies(gov_bod_id),
	CONSTRAINT divisions_fk_2 FOREIGN KEY (league_id) REFERENCES entitas.leagues(league_id)
);

-- Drop table

-- DROP TABLE entitas.teams;

CREATE TABLE entitas.teams (
	team_id int4 NOT NULL,
	team_name text NULL,
	org_id int4 NULL,
	league_id int4 NULL,
	level_id int4 NULL,
	conference_id int4 NULL,
	division_id int4 NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT teams_pkey PRIMARY KEY (team_id),
	CONSTRAINT teams_fk FOREIGN KEY (org_id) REFERENCES entitas.organizations(org_id),
	CONSTRAINT teams_fk_1 FOREIGN KEY (league_id) REFERENCES entitas.leagues(league_id),
	CONSTRAINT teams_fk_2 FOREIGN KEY (level_id) REFERENCES entitas.levels(level_id),
	CONSTRAINT teams_fk_3 FOREIGN KEY (division_id) REFERENCES entitas.divisions(division_id),
	CONSTRAINT teams_fk_4 FOREIGN KEY (conference_id) REFERENCES entitas.conferences(conference_id)
);

-- Drop table

-- DROP TABLE entitas.people_roster_entries;

CREATE TABLE entitas.people_roster_entries (
	bpid int4 NOT NULL,
	jersey_number text NULL,
	"position" text NULL,
	status text NULL,
	team int4 NULL,
	is_active bool NULL,
	start_date date NULL,
	end_date date NULL,
	status_date date NULL,
	is_active_forty_man bool NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT people_roster_pkey PRIMARY KEY (bpid),
	CONSTRAINT people_roster_entries_fk FOREIGN KEY (bpid) REFERENCES entitas.people(bpid),
	CONSTRAINT people_roster_entries_fk2 FOREIGN KEY (team) REFERENCES entitas.teams(team_id)
);

-- Drop table

-- DROP TABLE entitas.people_roster_status;

CREATE TABLE entitas.people_roster_status (
	bpid int4 NOT NULL,
	active bool NULL,
	current_team int4 NULL,
	last_played_date date NULL,
	mlb_debut_date date NULL,
	updated_timestamp timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT people_roster_status_pkey PRIMARY KEY (bpid),
	CONSTRAINT people_roster_status_fk FOREIGN KEY (bpid) REFERENCES entitas.people(bpid),
	CONSTRAINT people_roster_status_fk2 FOREIGN KEY (current_team) REFERENCES entitas.teams(team_id)
);

-- Drop table

-- DROP TABLE entitas.team_rosters;

CREATE TABLE entitas.team_rosters (
	team int4 NOT NULL,
	"timestamp" timestamptz NOT NULL,
	player int4 NOT NULL,
	jersey_number int4 NULL,
	"position" text NULL,
	status text NULL,
	CONSTRAINT team_rosters_pkey PRIMARY KEY (team, "timestamp", player),
	CONSTRAINT team_rosters_player_fkey FOREIGN KEY (player) REFERENCES entitas.people(bpid) ON DELETE RESTRICT,
	CONSTRAINT team_rosters_team_fkey FOREIGN KEY (team) REFERENCES entitas.teams(team_id) ON DELETE RESTRICT
);
