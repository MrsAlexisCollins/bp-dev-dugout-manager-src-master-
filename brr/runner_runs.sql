DROP TABLE IF EXISTS legacy_models.runner_runs;

CREATE TABLE legacy_models.runner_runs (
    season      int4,
    level_id    int4,
    outs        int4,
    base        int4,
    runs        int4,
    total       int4
);

GRANT SELECT ON legacy_models.runner_runs TO public;
GRANT ALL PRIVILEGES ON legacy_models.runner_runs TO models;
