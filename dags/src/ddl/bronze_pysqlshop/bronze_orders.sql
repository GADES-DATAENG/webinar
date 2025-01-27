CREATE OR REPLACE TABLE `GCP_PROJECT_ID.DATASET_ID.bronze_orders`
(
    order_id STRING,
    customer_id STRING,
    order_status STRING,
    order_purchase_timestamp STRING,
    order_approved_at STRING,
    order_delivered_carrier_date STRING,
    order_delivered_customer_date STRING,
    order_estimated_delivery_date STRING,
    filename STRING,
    audit_load_at TIMESTAMP
)
PARTITION BY DATE(audit_load_at)
