CREATE SCHEMA xrefs AUTHORIZATION postgres;
grant all privileges on all tables in schema xrefs to basecoach;
grant all privileges on all sequences in schema xrefs to basecoach;
grant usage on schema xrefs to public;
CREATE TABLE xrefs.org_refs (
    org_ref_id serial NOT NULL,
    org_id int4 NOT NULL,
    xref_type text NOT NULL,
    xref_id varchar NOT NULL
);
CREATE TABLE xrefs.teams_refs (
    teams_ref_id serial NOT NULL,
    teams_id int4 NOT NULL,
    xref_type text NOT NULL,
    xref_id varchar NOT NULL
);
CREATE TABLE xrefs.people_refs (
    people_ref_id serial NOT NULL,
    bpid int4 NOT NULL,
    xref_type text NOT NULL,
    xref_id varchar NOT NULL
);
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (2,'bplegacy','ARI');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (3,'bplegacy','ATL');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (4,'bplegacy','BAL');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (5,'bplegacy','BOS');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (6,'bplegacy','CHA');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (7,'bplegacy','CHN');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (8,'bplegacy','CIN');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (9,'bplegacy','CLE');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (10,'bplegacy','COL');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (11,'bplegacy','DET');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (12,'bplegacy','HOU');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (13,'bplegacy','KCA');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (1,'bplegacy','LAA');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (14,'bplegacy','LAN');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (15,'bplegacy','MIA');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (16,'bplegacy','MIL');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (17,'bplegacy','MIN');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (30,'bplegacy','MON');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (18,'bplegacy','NYA');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (19,'bplegacy','NYN');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (20,'bplegacy','OAK');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (21,'bplegacy','PHI');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (22,'bplegacy','PIT');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (23,'bplegacy','SDN');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (24,'bplegacy','SEA');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (25,'bplegacy','SFN');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (26,'bplegacy','SLN');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (27,'bplegacy','TBA');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (28,'bplegacy','TEX');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (29,'bplegacy','TOR');
insert into xrefs.org_refs (org_id, xref_type, xref_id) values (30,'bplegacy','WAS');