-- models/intermediate/int_lab_summary.sql

{{ config(materialized='table') }}

WITH base AS (

    SELECT
        encounter_id,
        patient_nbr,
        num_lab_procedures,

        -- Clean max_glu_serum values: convert text categories to numeric ranges or NULL
        CASE
            WHEN max_glu_serum = 'None' THEN NULL
            WHEN max_glu_serum = 'Norm' THEN 100
            WHEN max_glu_serum = '>200' THEN 201
            WHEN max_glu_serum = '>300' THEN 301
            ELSE NULL
        END AS max_glu_serum_value,

        -- Clean A1C result values: approximate numeric mapping
        CASE
            WHEN A1Cresult = 'None' THEN NULL
            WHEN A1Cresult = 'Norm' THEN 5.0
            WHEN A1Cresult = '>7' THEN 7.1
            WHEN A1Cresult = '>8' THEN 8.1
            ELSE NULL
        END AS A1C_value

    FROM {{ ref('stg_diabetes') }}

),

agg AS (
    SELECT
        patient_nbr,
        COUNT(DISTINCT encounter_id) AS total_encounters,
        AVG(num_lab_procedures) AS avg_lab_procedures_per_encounter,
        MAX(num_lab_procedures) AS max_lab_procedures_per_encounter,
        AVG(max_glu_serum_value) AS avg_max_glucose,
        MAX(max_glu_serum_value) AS peak_max_glucose,
        AVG(A1C_value) AS avg_a1c,
        MAX(A1C_value) AS peak_a1c
    FROM base
    GROUP BY patient_nbr
)

SELECT *
FROM agg