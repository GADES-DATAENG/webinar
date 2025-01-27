CREATE OR REPLACE TABLE `GCP_PROJECT_ID.DATASET_ID.bronze_products`
(
    product_id STRING,
    product_category_name STRING,
    product_name_lenght INT64,
    product_description_lenght INT64,
    product_photos_qty INT64,
    product_weight_g INT64,
    product_length_cm INT64,
    product_height_cm INT64,
    product_width_cm INT64,
    filename STRING,
    audit_load_at TIMESTAMP
)
PARTITION BY DATE(audit_load_at)
