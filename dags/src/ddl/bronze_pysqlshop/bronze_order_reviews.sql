CREATE OR REPLACE TABLE `GCP_PROJECT_ID.DATASET_ID.bronze_order_reviews`
(
    review_id STRING,
    order_id STRING,
    review_score INT64,
    review_comment_title STRING,
    review_comment_message STRING,
    review_creation_date STRING,
    review_answer_timestamp STRING,
    filename STRING,
    audit_load_at TIMESTAMP
)
PARTITION BY DATE(audit_load_at)