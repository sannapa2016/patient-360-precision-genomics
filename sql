-- Create a Star Schema for Precision Medicine
CREATE OR REPLACE TABLE genomics_gold_standard AS
SELECT 
    p.patient_id,
    p.gender,
    p.birth_year,
    g.biomarker_variant,
    g.mutation_status,
    c.claim_id,
    c.service_date,
    c.diagnosis_code,
    c.treatment_line
FROM patients p
JOIN snowflake_genomics_lake g ON p.patient_id = g.patient_id
JOIN claims_fact c ON p.patient_id = c.patient_id
WHERE g.mutation_status = 'Positive' 
  AND c.service_date >= '2023-01-01';

-- Calculate 'Time to Treatment' for R analysis
CREATE OR REPLACE VIEW v_treatment_survival AS
SELECT 
    patient_id,
    biomarker_variant,
    DATEDIFF('day', diagnosis_date, treatment_start_date) as days_to_treatment,
    event_observed -- 1 if treatment started, 0 if censored
FROM genomics_gold_standard;
