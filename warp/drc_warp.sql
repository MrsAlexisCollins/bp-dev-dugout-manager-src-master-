create table if not exists models.drc_warp (
	season			int4,
	level_id		int4,
	bpid			int4,
    drc_warp        double precision,
    draa            double precision,
    fraa            double precision,
    ofa             double precision,
    cda             double precision,
    pos_adj         double precision,
    rep_level       double precision,
    brr             double precision, 
    brr_arm         double precision, 
    rpw             double precision,
	version 		date,
	primary key (season, level_id, bpid)	
);

grant select on models.drc_warp to PUBLIC;
grant all privileges on models.drc_warp to models;
