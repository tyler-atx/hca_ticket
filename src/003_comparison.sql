DROP TABLE IF EXISTS comparison;

CREATE TABLE comparison AS (
    SELECT
        external.external_patient_id
        , internal.internal_patient_id
        , external.first_name                       AS external_first_name
        , internal.first_name                       AS internal_first_name
        , hca_levenshtein_distance(
            external.first_name,
            internal.first_name)                    AS levenshtein_first_name
        , hca_similarity_ratio(
            external.first_name,
            internal.first_name)                    AS similarity_first_name
        , external.last_name                        AS external_last_name
        , internal.last_name                        AS internal_last_name
        , hca_levenshtein_distance(
            external.last_name,
            internal.last_name)                     AS levenshtein_last_name
        , hca_similarity_ratio(
            external.last_name,
            internal.last_name)                     AS similarity_last_name
        , external.dob                              AS external_dob
        , internal.dob                              AS internal_dob
        , ABS(external.dob - internal.dob)          AS dob_days_diff
        , hca_similarity_ratio(
            TO_CHAR(external.dob, 'YYYYMMDD'),
            TO_CHAR(internal.dob, 'YYYYMMDD')
          )                                         AS similarity_dob
        , external.dob = internal.dob               AS exact_match_dob
        , external.birthday                         AS external_birthday
        , internal.birthday                         AS internal_birthday
        , external.birthday = internal.birthday     AS match_birthday
        , external.sex                              AS external_sex
        , internal.sex                              AS internal_sex
        , external.sex = internal.sex               AS match_sex
        , external.sex = 'F' AND internal.sex = 'F' AS match_female_sex
        , external.phone_number                     AS external_phone_number
        , internal.phone_number                     AS internal_phone_number
        , CASE
              WHEN external.phone_number IS NULL
                  OR internal.phone_number IS NULL
                  THEN 0
              ELSE hca_similarity_ratio(
                           external.phone_number,
                           internal.phone_number
                   )
              END                                   AS similarity_phone_number
        , external.address_full                     AS external_address_full
        , external.street_number                    AS external_street_number
        , external.street_name                      AS external_street_name
        , external.street_unit_number               AS external_street_unit_number
        , internal.address_full                     AS internal_address_full
        , internal.street_number                    AS internal_street_number
        , internal.street_name                      AS internal_street_name
        , internal.street_unit_number               AS internal_street_unit_number
        , internal.street_number =
            external.street_number                  AS match_street_number
        , hca_similarity_ratio(
            internal.street_number
            , external.street_number)               AS similarity_street_number
        , hca_similarity_ratio(
            internal.street_name
            , external.street_name)                 AS similarity_street_name
    FROM external
        CROSS JOIN internal
)