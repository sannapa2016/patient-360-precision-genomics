# patient-360-precision-genomics
This project implements a Cloud-Native Genomic Pipeline using Snowflake and R

Patient-360 Precision Genomics
Bridging Genomic Biomarkers and Real-World Treatment Journeys
This project implements a Cloud-Native Genomic Pipeline using Snowflake and R. It identifies high-value patient sub-populations by linking synthetic genomic variants with longitudinal claims data to perform clinical survival analysis.

Key Features
Snowflake SQL: Petabyte-scale JOINs between semi-structured genomic lakes and claims facts.

R Clinical Analytics: Kaplan-Meier survival modeling to determine treatment efficacy across cohorts.

FHIR Compatibility: Structured for Azure Health Data Services integration.

Strategic Outcome
Supports Integrated Evidence Generation (IEG) by proving drug efficacy in specific genetic niches, accelerating HTA and FDA approvals.

Folder Hierarchy
/sql: Contains Snowflake schema definitions and ETL scripts.

/scripts: The R analysis file (survival_analysis.R).

/data: Sample synthetic FHIR/Genomic datasets.

/docs: JPG of the Kaplan-Meier plot generated in R.
