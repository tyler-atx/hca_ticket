DROP TABLE IF EXISTS external;

CREATE TABLE external AS (
    SELECT
        external_patient_id                                             AS external_patient_id
        , LOWER(SPLIT_PART(LOWER(first_name), ' ', 1))                  AS first_name
        , TRIM(BOTH '.' FROM SPLIT_PART(LOWER(first_name), ' ', 2))     AS middle_name
        , LEFT(
            TRIM(BOTH '.' FROM SPLIT_PART(LOWER(first_name), ' ', 2)),
            1)                                                          AS middle_initial
        , LOWER(last_name)                                              AS last_name
        , TO_DATE(dob, 'DD-Mon-YYYY')                                   AS dob
        , TO_CHAR(TO_DATE(dob, 'DD-Mon-YYYY'), 'MM-DD')                 AS birthday
        , sex :: CHAR                                                   AS sex
        , CASE
            WHEN LENGTH(phone_number) > 8
                THEN SPLIT_PART(phone_number, '-', 1)
            ELSE NULL
          END                                                           AS area_code
        , CASE
              WHEN LENGTH(phone_number) > 8
                  THEN RIGHT(phone_number, 8)
              ELSE phone_number
            END                                                         AS phone_number
        , LOWER(REPLACE(address, '.', ''))                              AS address_full
        , (REGEXP_MATCHES(LOWER(REPLACE(address, '.', '')),
            '^(\d+)'))[1]                                               AS street_number
        , (REGEXP_MATCHES(LOWER(REPLACE(address, '.', '')),
            '^\d+\s+(.*?)(?:\s+(?:suite|apt)\s+\d+)?$'))[1]             AS street_name
        , (REGEXP_MATCHES(LOWER(REPLACE(address, '.', '')),
            '\d+$'))[1]                                                 AS street_unit_number
        , LOWER(city)                                                   AS city
        , LOWER(zip_code)                                               AS zip_code
    FROM staging.stg_external
);

DROP TABLE IF EXISTS internal;

CREATE TABLE internal AS (
    SELECT
        internal_patient_id                                             AS internal_patient_id
        , LOWER(SPLIT_PART(LOWER(first_name), ' ', 1))                  AS first_name
        , TRIM(BOTH '.' FROM SPLIT_PART(LOWER(first_name), ' ', 2))     AS middle_name
        , LEFT(
            TRIM(BOTH '.' FROM SPLIT_PART(LOWER(first_name), ' ', 2)),
            1)                                                          AS middle_initial
        , LOWER(last_name)                                              AS last_name
        , to_date(dob, 'YYYY-MM-DD')                                    AS dob
        , TO_CHAR(TO_DATE(dob, 'YYYY-MM-DD'), 'MM-DD')                  AS birthday
        , sex :: CHAR                                                   AS sex
        , CASE
            WHEN LENGTH(phone_number) > 8
                THEN SPLIT_PART(phone_number, '-', 1)
            ELSE NULL
          END                                                           AS area_code
        , CASE
              WHEN LENGTH(phone_number) > 8
                  THEN RIGHT(phone_number, 8)
              ELSE phone_number
            END                                                         AS phone_number
        , LOWER(REPLACE(address, '.', ''))                              AS address_full
        , (REGEXP_MATCHES(LOWER(REPLACE(address, '.', '')),
            '^(\d+)'))[1]                                               AS street_number
        , (REGEXP_MATCHES(LOWER(REPLACE(address, '.', '')),
            '^\d+\s+(.*?)(?:\s+(?:suite|apt)\s+\d+)?$'))[1]             AS street_name
        , (REGEXP_MATCHES(LOWER(REPLACE(address, '.', '')),
            '\d+$'))[1]                                                 AS street_unit_number
        , LOWER(city)                                                   AS city
        , LOWER(zip_code)                                               AS zip_code
    FROM staging.stg_internal
);

DROP VIEW IF EXISTS all_patients;

CREATE VIEW all_patients AS (
    SELECT
    'internal'                                      AS dataset
    , internal_patient_id                           AS patient_id
    , first_name                                    AS first_name
    , middle_name                                   AS middle_name
    , middle_initial                                AS middle_initial
    , last_name                                     AS last_name
    , dob                                           AS dob
    , birthday                                      AS birthday
    , sex                                           AS sex
    , area_code                                     AS area_code
    , phone_number                                  AS phone_number
    , address_full                                  AS address_full
    , street_number                                 AS street_number
    , street_name                                   AS street_name
    , street_unit_number                            AS street_unit_number
    , city                                          AS city
    , zip_code                                      AS zip_code
FROM internal

UNION ALL

SELECT
    'external'                                       AS dataset
     , external_patient_id                           AS patient_id
     , first_name                                    AS first_name
     , middle_name                                   AS middle_name
     , middle_initial                                AS middle_initial
     , last_name                                     AS last_name
     , dob                                           AS dob
     , birthday                                      AS birthday
     , sex                                           AS sex
     , area_code                                     AS area_code
     , phone_number                                  AS phone_number
     , address_full                                  AS address_full
     , street_number                                 AS street_number
     , street_name                                   AS street_name
     , street_unit_number                            AS street_unit_number
     , city                                          AS city
     , zip_code                                      AS zip_code
FROM external
);