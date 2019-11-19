
-- initial load of governing bodies and MLB organizations

INSERT INTO entitas.governing_bodies (gov_bod_id, gov_bod_name, updated_timestamp)
VALUES (1, 'Major League Baseball', now());

INSERT INTO entitas.governing_bodies (gov_bod_id, gov_bod_name, updated_timestamp)
VALUES (2, 'Nippon Professional Baseball Organization', now());

INSERT INTO entitas.governing_bodies (gov_bod_id, gov_bod_name, updated_timestamp)
VALUES (3, 'Korea Baseball Organization', now());

insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (1,'ANA',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (2,'ARI',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (3,'ATL',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (4,'BAL',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (5,'BOS',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (6,'CHA',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (7,'CHN',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (8,'CIN',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (9,'CLE',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (10,'COL',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (11,'DET',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (12,'HOU',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (13,'KCA',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (14,'LAN',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (15,'MIA',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (16,'MIL',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (17,'MIN',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (18,'NYA',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (19,'NYN',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (20,'OAK',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (21,'PHI',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (22,'PIT',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (23,'SDN',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (24,'SEA',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (25,'SFN',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (26,'SLN',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (27,'TBA',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (28,'TEX',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (29,'TOR',1,now());
insert into entitas.organizations (org_id, org_name, gov_bod_id, updated_timestamp) values (30,'WAS',1,now());