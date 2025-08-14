-- models/marts/readmission_labels.sql

{{ config(
    materialized='table'
) }}

WITH base AS (
    SELECT
        encounter_id,
        patient_nbr,

        -- Create binary target label: 1 if "<30", else 0
        CASE 
            WHEN LOWER(readmitted) = '<30' THEN 1
            ELSE 0
        END AS readmission_30d

    FROM {{ ref('stg_diabetes') }}
)

SELECT *
FROM base;