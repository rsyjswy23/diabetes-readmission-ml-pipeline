-- models/marts/patient_features.sql

{{ config(
    materialized='table'
) }}

WITH base AS (
    SELECT
        encounter_id,
        patient_nbr,
        
        -- Clean gender (replace unknown/other with NULL)
        CASE 
            WHEN LOWER(gender) IN ('male', 'female') THEN INITCAP(gender)
            ELSE NULL
        END AS gender,
        
        -- Clean race (replace '?' with NULL)
        NULLIF(race, '?') AS race,

        -- Age bucket is already in string form like '[50-60)'
        age,

        -- Convert admission type codes to labels
        CASE admission_type_id
            WHEN 1 THEN 'Emergency'
            WHEN 2 THEN 'Urgent'
            WHEN 3 THEN 'Elective'
            WHEN 4 THEN 'Newborn'
            WHEN 5 THEN 'Not Available'
            WHEN 6 THEN 'NULL'
            WHEN 7 THEN 'Trauma Center'
            WHEN 8 THEN 'Not Mapped'
        END AS admission_type,

        -- Convert discharge disposition codes to labels (partial list)
        CASE discharge_disposition_id
            WHEN 1 THEN 'Discharged to Home'
            WHEN 2 THEN 'Discharged to Another Hospital'
            WHEN 7 THEN 'Left Against Medical Advice'
            WHEN 18 THEN 'Hospice - Home'
            WHEN 19 THEN 'Hospice - Medical Facility'
            ELSE 'Other'
        END AS discharge_disposition,

        -- Convert admission source codes to labels (partial list)
        CASE admission_source_id
            WHEN 1 THEN 'Physician Referral'
            WHEN 2 THEN 'Clinic Referral'
            WHEN 4 THEN 'Transfer from Hospital'
            WHEN 7 THEN 'Emergency Room'
            WHEN 9 THEN 'Information Not Available'
            ELSE 'Other'
        END AS admission_source,

        time_in_hospital,
        payer_code,
        NULLIF(medical_specialty, '?') AS medical_specialty,
        num_lab_procedures,
        num_procedures,
        num_medications,
        number_outpatient,
        number_emergency,
        number_inpatient,
        number_diagnoses,
        max_glu_serum,
        A1Cresult

    FROM {{ ref('stg_diabetes') }}
)

SELECT *
FROM base;