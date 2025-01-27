CREATE OR REPLACE TABLE `GCP_PROJECT_ID.DATASET_ID.bronze_product_category_translation`
(
    product_category_name STRING,
    product_category_name_english STRING,
    filename STRING,
    audit_load_at TIMESTAMP
)
PARTITION BY DATE(audit_load_at)