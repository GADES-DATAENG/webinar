CREATE OR REPLACE TABLE `GCP_PROJECT_ID.DATASET_ID.bronze_order_items`
(
    order_id STRING,
    order_item_id INT64,
    product_id STRING,
    seller_id STRING,
    shipping_limit_date STRING,
    price FLOAT64,
    freight_value FLOAT64,
    filename STRING,
    audit_load_at TIMESTAMP
)
PARTITION BY DATE(audit_load_at)