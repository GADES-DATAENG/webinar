CREATE OR REPLACE TABLE `GCP_PROJECT_ID.DATASET_ID.bronze_order_payments`
(
    order_id STRING,
    payment_sequential INT64,
    payment_type STRING,
    payment_installments INT64,
    payment_value FLOAT64,
    filename STRING,
    audit_load_at TIMESTAMP
)
PARTITION BY DATE(audit_load_at)