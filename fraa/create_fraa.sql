DROP TABLE IF EXISTS models.fraa_daily;

CREATE TABLE models.fraa_daily (
    season          int4,
    level_id        int4 REFERENCES mlbapi.levels (id),
    team_id         int4,
    bpid            int4,
    pos             int4,
    chances         int4,
    plays_made      int4,
    avg_plays_made  double precision,
    paa             double precision,
    moe_pm          double precision,
    paa_reg         double precision,
    raa             double precision,
    moe_runs        double precision,
    raa_reg         double precision,
    version         date,
    primary key (season, level_id, team_id, bpid, pos)
);

GRANT ALL PRIVILEGES ON models.fraa_daily TO models;
GRANT SELECT ON models.fraa_daily TO PUBLIC;
