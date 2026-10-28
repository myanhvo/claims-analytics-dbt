with source as (
    select * from {{ source('cms', 'beneficiary_summary_2008') }}
),

renamed as (
    select 
        desynpuf_id as beneficiary_id,
        2008 as file_year,
        strptime(bene_birth_dt, '%Y%m%d')::date as birth_date,
        strptime(bene_death_dt, '%Y%m%d')::date as death_date,
        case bene_sex_ident_cd 
            when '1' then 'Male'
            when '2' then 'Female'
            else 'Unknown'
        end as sex,
        bene_race_cd as race_code,
         sp_state_code as state_code,
        bene_county_cd as county_code,
        bene_esrd_ind = 'Y' as has_esrd,

        -- coverage months
        cast(bene_hi_cvrage_tot_mons as integer) as part_a_coverage_months,
        cast(bene_smi_cvrage_tot_mons as integer) as part_b_coverage_months,
        cast(bene_hmo_cvrage_tot_mons as integer) as hmo_coverage_months,
        cast(plan_cvrg_mos_num as integer) as part_d_coverage_months,

        -- chronic conditions (source uses 1 = yes, 2 = no)
        sp_alzhdmta = '1' as has_alzheimers,
        sp_chf = '1' as has_heart_failure,
        sp_chrnkidn = '1' as has_chronic_kidney_disease,
        sp_cncr = '1' as has_cancer,
        sp_copd = '1' as has_copd,
        sp_depressn = '1' as has_depression,
        sp_diabetes = '1' as has_diabetes,
        sp_ischmcht = '1' as has_ischemic_heart_disease,
        sp_osteoprs = '1' as has_osteoporosis,
        sp_ra_oa = '1' as has_rheumatoid_osteo_arthritis,
        sp_strketia = '1' as has_stroke_tia,

        -- annual payment amounts
        cast(medreimb_ip as decimal(12, 2)) as inpatient_medicare_paid,
        cast(benres_ip as decimal(12, 2)) as inpatient_beneficiary_paid,
        cast(pppymt_ip as decimal(12, 2)) as inpatient_primary_payer_paid,
        cast(medreimb_op as decimal(12, 2)) as outpatient_medicare_paid,
        cast(benres_op as decimal(12, 2)) as outpatient_beneficiary_paid,
        cast(pppymt_op as decimal(12, 2)) as outpatient_primary_payer_paid,
        cast(medreimb_car as decimal(12, 2)) as carrier_medicare_paid,
        cast(benres_car as decimal(12, 2)) as carrier_beneficiary_paid,
        cast(pppymt_car as decimal(12, 2)) as carrier_primary_payer_paid

    from source

)

select * from renamed
