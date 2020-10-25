CREATE TABLE IF NOT EXISTS models.brr_daily (
    season      int4,
    level_id    int4,
    bpid        int4,
    brr_opps    int4,
    brr         double precision,
    sbr_opps    int4,
    sbr         double precision,
    har_opps    int4,
    har         double precision,
    gar_opps    int4,
    gar         double precision,
    aar_opps    int4,
    aar         double precision,
    oar_opps    int4,
    oar         double precision,
    version     date
);

GRANT SELECT ON models.brr_daily TO public;
GRANT ALL PRIVILEGES ON models.brr_daily TO models;

CREATE TABLE IF NOT EXISTS models.brr_team_daily (
    season      int4,
    level_id    int4,
    bpid        int4,
    team_id     int4,
    brr_opps    int4,
    brr         double precision,
    sbr_opps    int4,
    sbr         double precision,
    har_opps    int4,
    har         double precision,
    gar_opps    int4,
    gar         double precision,
    aar_opps    int4,
    aar         double precision,
    oar_opps    int4,
    oar         double precision,
    version     date
);

GRANT SELECT ON models.brr_team_daily TO public;
GRANT ALL PRIVILEGES ON models.brr_team_daily TO models;

CREATE TABLE IF NOT EXISTS models.brr_arm_daily (
    season      int4,
    level_id    int4,
    bpid        int4,
    fld_cd      int4,
    team_id     int4,
    brr_arm     double precision,
    count       int4,
    brr_arm_per_cnt double precision,
	hbr         double precision,
	gbr         double precision,
	abr         double precision,
    version     date
);

GRANT SELECT ON models.brr_arm_daily TO public;
GRANT ALL PRIVILEGES ON models.brr_arm_daily TO models;
