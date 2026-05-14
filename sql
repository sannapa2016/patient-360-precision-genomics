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

-- Join Genomic Mutation Data with Claims Treatment History
CREATE OR REPLACE TABLE patient_360_genomics_gold AS
SELECT 
    p.patient_id,
    g.biomarker_variant,
    g.mutation_status,
    c.treatment_line,
    DATEDIFF('day', c.diagnosis_date, c.treatment_start_date) AS days_to_treatment,
    c.event_observed -- 1 if treatment successful, 0 if censored
FROM patient_registry p
JOIN snowflake_genomics_lake g ON p.patient_id = g.patient_id
JOIN claims_fact c ON p.patient_id = c.patient_id
WHERE g.mutation_status = 'Positive';
/*
  PROJECT: Patient-360 Precision Genomics
  MODULE: Cost-Optimized Clinical Sandboxes
  DESCRIPTION: This script utilizes Snowflake's Zero-Copy Cloning to spin up 
  experimental environments for Line of Therapy (LOT) mapping without 
  physical data duplication.
*/

-- 1. Create a development clone of the massive production genomics lake
-- This provides an instant, isolated environment for Data Science testing at zero cost.
CREATE OR REPLACE TABLE dev_genomics_sandbox 
CLONE prod_genomics_lake.clinical.patient_360_gold;

-- 2. Test new 'High-Priority' patient identification logic
-- Identifying patients with KRAS-G12C mutation who have failed 2+ prior therapies.
UPDATE dev_genomics_sandbox
SET target_priority = 'Tier_1'
WHERE biomarker_variant = 'KRAS-G12C' 
  AND prior_lot_count >= 2;

-- 3. Validate results before promoting to the main pipeline
SELECT 
    target_priority, 
    COUNT(DISTINCT patient_id) as patient_count 
FROM dev_genomics_sandbox
GROUP BY 1;
