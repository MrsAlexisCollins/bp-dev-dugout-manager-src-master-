#!/bin/sh

export PGPASSFILE=.pgpass

PGHOST=172.104.15.153
PGUSER=models
PGDB=cage
PSQL="psql -h $PGHOST -U $PGUSER -d $PGDB"

# Dependencies (flow is right and down)
#
# roe_est_lg - batting_roe_est - bsr_b_est - bsr_lwts_expanded - bsr_lwts
#                                                              \ 
#                                                               play_value
#                                                                    |
#                                                               warp_sd_raw
#                                                                    |
#                                                                 warp_sd
#               ip_split_team                                        |
# ip_split_lg <               > start_warp_raw - start_warp_rolling  |
#               ip_split_lg_2                              \         |
#                          \                                \        |
# lwts_runs_per_win_bylg  ------------------------------ rep_level_pitching
#                                                                    |
#                                                   dra_daily -- dra_warp

echo <<EOF | $PSQL
REFRESH MATERIALIZED VIEW legacy_models.roe_est_lg;
REFRESH MATERIALIZED VIEW legacy_models.batting_roe_est;
REFRESH MATERIALIZED VIEW legacy_models.bsr_b_est;
REFRESH MATERIALIZED VIEW legacy_models.bsr_lwts_expanded;
REFRESH MATERIALIZED VIEW legacy_models.bsr_lwts;
REFRESH MATERIALIZED VIEW legacy_models.play_value;
REFRESH MATERIALIZED VIEW legacy_models.ip_split_lg;
REFRESH MATERIALIZED VIEW legacy_models.ip_split_lg2;
REFRESH MATERIALIZED VIEW legacy_models.ip_split_team;
REFRESH MATERIALIZED VIEW legacy_models.lwts_runs_per_win_bylg;
REFRESH MATERIALIZED VIEW legacy_models.start_warp_raw;
REFRESH MATERIALIZED VIEW legacy_models.start_warp_rolling;
EOF

python3 warp_sd_raw.py

echo <<EOF | $PSQL
REFRESH MATERIALIZED VIEW legacy_models.rep_level_pitching;
EOF

$PSQL < dra_warp.sql
