{% if execute and is_incremental() %}
    {% set query = 'select COALESCE(max(audit_updated_at), CAST(\'2000-01-01 00:00:00\' AS TIMESTAMP)) from {}'.format(this) %}
    {% set result = run_query(query).columns[0].values()[0] %}
{% endif %}

WITH inc_data AS (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY source_table.review_id ORDER BY source_table.audit_load_at DESC) AS _r
    FROM {{ source('raw', 'bronze_order_reviews') }} source_table
    {% if is_incremental() %}
    WHERE
        source_table.audit_load_at > '{{ result }}'
    {% endif %}
)

SELECT
    source_table.review_id AS code_review,
    source_table.order_id AS code_order,
    source_table.review_score AS mtr_review_score,
    source_table.review_comment_title AS dsc_review_comment_title,
    source_table.review_comment_message AS dsc_review_comment_message,
    CAST(source_table.review_creation_date AS TIMESTAMP) AS date_review_creation,
    CAST(source_table.review_answer_timestamp AS TIMESTAMP) AS date_review_answer,

    CURRENT_TIMESTAMP AS audit_created_at,
    CURRENT_TIMESTAMP AS audit_updated_at
FROM inc_data AS source_table
WHERE
    source_table._r = 1