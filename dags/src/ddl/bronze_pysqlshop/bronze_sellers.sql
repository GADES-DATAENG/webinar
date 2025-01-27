CREATE OR REPLACE TABLE `GCP_PROJECT_ID.DATASET_ID.bronze_sellers`
(
    seller_id STRING,
    seller_zip_code_prefix INT64,
    seller_city STRING,
    seller_state STRING,
    filename STRING,
    audit_load_at TIMESTAMP
)
PARTITION BY DATE(audit_load_at)