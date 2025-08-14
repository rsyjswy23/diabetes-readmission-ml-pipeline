{{ config(materialized='view') }}

with source as (

    select
        encounter_id,
        patient_nbr,
        
        -- Standardize categorical values
        case
            when lower(gender) in ('male', 'm') then 'Male'
            when lower(gender) in ('female', 'f') then 'Female'
            else 'Unknown'
        end as gender,
        
        case
            when race is null or race = '?' then 'Unknown'
            else initcap(race)
        end as race,

        age, -- Already binned in dataset
        weight,

        cast(admission_type_id as int64) as admission_type_id,
        cast(discharge_disposition_id as int64) as discharge_disposition_id,
        cast(admission_source_id as int64) as admission_source_id,

        cast(time_in_hospital as int64) as time_in_hospital,
        payer_code,
        
        case
            when medical_specialty is null or medical_specialty = '?' then 'Unknown'
            else initcap(medical_specialty)
        end as medical_specialty,

        cast(num_lab_procedures as int64) as num_lab_procedures,
        cast(num_procedures as int64) as num_procedures,
        cast(num_medications as int64) as num_medications,
        cast(number_outpatient as int64) as number_outpatient,
        cast(number_emergency as int64) as number_emergency,
        cast(number_inpatient as int64) as number_inpatient,
        cast(number_diagnoses as int64) as number_diagnoses,

        diag_1,
        diag_2,
        diag_3,

        -- Normalize lab result indicators
        upper(max_glu_serum) as max_glu_serum,
        upper(A1Cresult) as A1Cresult,

        -- Normalize medication usage: map 'Yes', 'No', 'Steady', 'Up', 'Down'
        {% for med in [
            'metformin','repaglinide','nateglinide','chlorpropamide',
            'glimepiride','acetohexamide','glipizide','glyburide','tolbutamide',
            'pioglitazone','rosiglitazone','acarbose','miglitol','troglitazone',
            'tolazamide','examide','citoglipton','insulin',
            'glyburide-metformin','glipizide-metformin',
            'glimepiride-pioglitazone','metformin-rosiglitazone',
            'metformin-pioglitazone'
        ] %}
            case
                when lower({{ med }}) in ('yes', 'steady', 'up', 'down') then 1
                else 0
            end as {{ med }}_flag,
        {% endfor %}

        case when lower(change) = 'ch' then 1 else 0 end as change_flag,
        case when lower(diabetesMed) = 'yes' then 1 else 0 end as diabetes_med_flag,

        -- Target: readmitted within 30 days
        case
            when lower(readmitted) = '<30' then 1
            else 0
        end as readmitted_30days

    from {{ source('diabetes', 'raw_diabetes_data') }}

)

select * from source;