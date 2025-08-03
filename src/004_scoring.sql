DROP TABLE IF EXISTS scoring CASCADE;

CREATE TABLE scoring AS (

    WITH vars AS (

        SELECT
            0.5 AS MATCH_THRESHOLD
            , 0.75 AS PHONE_MATCH_THRESHOLD
            , 1 AS DUAL_NAME_THRESHOLD
            , 0.75 AS DOB_MATCH_THRESHOLD

    ), matches_added AS (

        SELECT
            *
            , (similarity_first_name >
               (SELECT MATCH_THRESHOLD FROM vars))                          AS match_first_name
            , (similarity_last_name >
               (SELECT MATCH_THRESHOLD FROM vars))                          AS match_last_name
            , (similarity_phone_number >
               (SELECT PHONE_MATCH_THRESHOLD FROM vars))                    AS match_phone_number
            , (similarity_first_name + similarity_last_name) >
               (SELECT DUAL_NAME_THRESHOLD FROM vars)                       AS match_both_names
            , similarity_street_name >
               (SELECT MATCH_THRESHOLD FROM vars)                           AS match_street_name
            , (similarity_phone_number
                + similarity_street_name) >
              1.5                                                           AS match_supporting_information
            , (similarity_dob) >
               (SELECT DOB_MATCH_THRESHOLD FROM vars)                       AS match_dob
        FROM comparison

    )

    SELECT
        CASE
            WHEN match_first_name
                AND match_dob
                AND (match_last_name OR match_female_sex)
            THEN 'clean_match_dob'
            WHEN match_both_names
                AND match_dob
                AND (match_last_name OR match_female_sex)
                THEN 'dual_match_dob'
--             WHEN match_first_name
--                 AND match_birthday
--                 AND (match_last_name OR match_female_sex)
--                 THEN 'clean_match_birthday'
            WHEN match_both_names
                AND match_birthday
                AND (match_last_name OR match_female_sex)
                THEN 'dual_match_birthday'
            WHEN (match_first_name OR match_last_name)
                AND match_phone_number
                THEN 'clean_match_phone_number'
--             WHEN (match_first_name OR match_last_name)
--                 AND match_sex
--                 AND match_street_name
--                 THEN 'dual_match_street_name'
              /* Difficult to find good matches with street names */
            WHEN (match_supporting_information) AND match_sex
                THEN 'match_supporting_information'
            END                                                                 AS match_type
        , *
    FROM matches_added

);

DROP VIEW IF EXISTS matches;

CREATE VIEW matches AS (
    SELECT
        external_patient_id                                                 AS ExternalPatientId
        , internal_patient_id                                               AS InternalPatientId
        , match_type                                                        AS match_type
        , external_first_name                                               AS external_first_name
        , internal_first_name                                               AS internal_first_name
        , similarity_first_name                                             AS similarity_first_name
        , external_last_name                                                AS external_last_name
        , internal_last_name                                                AS internal_last_name
        , similarity_last_name                                              AS similarity_last_name
        , external_dob                                                      AS external_dob
        , internal_dob                                                      AS internal_dob
        , similarity_dob                                                    AS similarity_dob
        , external_birthday                                                 AS external_birthday
        , internal_birthday                                                 AS internal_birthday
        , external_sex                                                      AS external_sex
        , internal_sex                                                      AS internal_sex
        , match_female_sex                                                  AS match_female_sex
        , external_phone_number                                             AS external_phone_number
        , internal_phone_number                                             AS internal_phone_number
        , similarity_phone_number                                           AS similarity_phone_number
        , external_address_full                                             AS external_address_full
        , external_street_name                                              AS external_street_name
        , external_street_number                                            AS external_street_number
        , external_street_unit_number                                       AS external_street_unit_number
        , internal_address_full                                             AS internal_address_full
        , internal_street_name                                              AS internal_street_name
        , internal_street_number                                            AS internal_street_number
        , internal_street_unit_number                                       AS internal_street_unit_number
        , similarity_street_name                                            AS similarity_street_name
    FROM scoring
    WHERE match_type IS NOT NULL
);

COPY (SELECT * FROM matches) TO '/data/matches.csv' DELIMITER ',' CSV HEADER;