CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.stg_external;

CREATE TABLE staging.stg_external (
    external_patient_id VARCHAR,
    first_name          VARCHAR,
    last_name           VARCHAR,
    dob                 VARCHAR,
    sex                 VARCHAR,
    phone_number        VARCHAR,
    address             VARCHAR,
    city                VARCHAR,
    zip_code            VARCHAR
);

COPY staging.stg_external FROM '/data/external.csv' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS staging.stg_internal;

CREATE TABLE staging.stg_internal (
    internal_patient_id VARCHAR,
    first_name          VARCHAR,
    last_name           VARCHAR,
    dob                 VARCHAR,
    sex                 VARCHAR,
    phone_number        VARCHAR,
    address             VARCHAR,
    city                VARCHAR,
    zip_code            VARCHAR
);

COPY staging.stg_internal FROM '/data/internal.csv' DELIMITER ',' CSV HEADER;