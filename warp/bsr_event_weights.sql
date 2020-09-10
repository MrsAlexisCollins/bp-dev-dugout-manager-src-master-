-- bp_warp.roe_est_lg

DROP TABLE IF EXISTS legacy_models.bsr_event_weights;

CREATE TABLE legacy_models.bsr_event_weights (
  event text,
  a double precision,
  b double precision,
  c double precision,
  d double precision
);

INSERT INTO legacy_models.bsr_event_weights VALUES 
  ('B1',  1, 0.78,  0, 0),
  ('B2',  1, 2.34,  0, 0),
  ('B3',  1, 3.90,  0, 0),
  ('HR',  0, 2.34,  0, 0),
  ('BB',  1, 0.039, 0, 0),
  ('ROE', 1, 0.78,  0, 0),
  ('eO',  0, 0,     1, 0),
  ('SB',  0, 1.14,  0, 0),
  ('CS', -1, 0,     1, 0);

GRANT SELECT ON legacy_models.bsr_event_weights TO PUBLIC;
GRANT ALL PRIVILEGES ON legacy_models.bsr_event_weights TO models;

