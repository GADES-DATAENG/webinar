CREATE OR REPLACE TABLE `GCP_PROJECT_ID.DATASET_ID.bronze_customers`
(
    customer_id STRING,
    customer_unique_id STRING,
    customer_zip_code_prefix INT64,
    customer_city STRING,
    customer_state STRING,
    filename STRING,
    audit_load_at TIMESTAMP
)
PARTITION BY DATE(audit_load_at)