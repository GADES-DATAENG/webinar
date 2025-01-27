{% if execute and is_incremental() %}
    {% set query = 'select COALESCE(max(audit_updated_at), CAST(\'2000-01-01 00:00:00\' AS TIMESTAMP)) from {}'.format(this) %}
    {% set result = run_query(query).columns[0].values()[0] %}
{% endif %}

WITH inc_data AS (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY source_table.code_order ORDER BY source_table.audit_updated_at DESC) AS _r
    FROM {{ ref('silver_orders') }} source_table
    {% if is_incremental() %}
    WHERE
        source_table.audit_updated_at > '{{ result }}'
    {% endif %}
),
order_items_totals AS (
    SELECT
        source_table.code_order,
        SUM(source_table.mtr_order_item_price) AS mtr_order_price,
        SUM(source_table.mtr_order_item_freight_value) AS mtr_order_freight_value
    FROM {{ ref('silver_order_items') }} source_table
    JOIN inc_data ON source_table.code_order = inc_data.code_order
    GROUP BY
        source_table.code_order
),
order_reviews AS (
    SELECT
        innerQ.code_order,
        innerQ.mtr_review_score
    FROM(
    SELECT
        source_table.code_order,
        source_table.mtr_review_score,
        ROW_NUMBER() OVER(PARTITION BY source_table.code_order ORDER BY source_table.date_review_answer DESC) AS _r
    FROM {{ ref('silver_order_reviews') }} source_table
    JOIN inc_data ON source_table.code_order = inc_data.code_order
    ) innerQ
    WHERE
        innerQ._r = 1
)


SELECT
    source_table.code_order AS dd_code_order,
    TO_BASE64(SHA256(COALESCE(source_table.code_customer, '-1'))) AS sk_customer,
    TO_BASE64(SHA256(COALESCE(source_table.dsc_order_status, '-1'))) AS sk_order_status,
    TO_BASE64(SHA256(COALESCE(op.dsc_payment_type, '-1'))) AS sk_payment_type,

    -- ORDER METRICS
    oit.mtr_order_price,
    oit.mtr_order_freight_value,
    op.mtr_payment_value,
    orev.mtr_review_score,

    CURRENT_TIMESTAMP AS audit_created_at,
    CURRENT_TIMESTAMP AS audit_updated_at
FROM inc_data AS source_table
LEFT JOIN order_items_totals oit ON source_table.code_order = oit.code_order
LEFT JOIN {{ ref('silver_order_payments') }} op ON source_table.code_order = op.code_order
LEFT JOIN order_reviews orev ON source_table.code_order = orev.code_order
WHERE
    source_table._r = 1