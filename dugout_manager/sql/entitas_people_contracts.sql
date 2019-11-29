
-- Drop table

-- DROP TABLE entitas.people_contracts;

CREATE TABLE entitas.people_contracts (
	contract_id int4 NOT NULL,
	bpid int4 NOT NULL,
	signed_date date NULL,
	terminated_date date NULL,
	duration_years_max int4 NULL,
	duration_years_base int4 NULL,
	duration_years_actual int4 NULL,
	signing_org_id int4 NULL,
	first_season int4 NULL,
	updated_timestamp timestamp null, 
	CONSTRAINT contract_pk PRIMARY KEY (contract_id)
);

ALTER TABLE entitas.people_contracts ADD CONSTRAINT signing_fk FOREIGN KEY (signing_org_id) REFERENCES entitas.organizations(org_id);
