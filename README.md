# dugout-manager

repo for pulling data out of cage, and for accessing information from field&#39;s MQ


you need this in your local pg instance, in dugout

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
