{% if execute and is_incremental() %}
    {% set query = 'select COALESCE(max(audit_updated_at), CAST(\'2000-01-01 00:00:00\' AS TIMESTAMP)) from {}'.format(this) %}
    {% set result = run_query(query).columns[0].values()[0] %}
{% endif %}

WITH inc_data AS (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY source_table.order_id, source_table.order_item_id ORDER BY source_table.audit_load_at DESC) AS _r
    FROM {{ source('raw', 'bronze_order_items') }} source_table
    {% if is_incremental() %}
    WHERE
        source_table.audit_load_at > '{{ result }}'
    {% endif %}
)

SELECT
    source_table.order_id AS code_order,
    source_table.order_item_id AS code_order_item,
    source_table.product_id AS code_product,
    source_table.seller_id AS code_seller,
    CAST(source_table.shipping_limit_date AS TIMESTAMP) AS date_shipping_limit,
    source_table.price AS mtr_order_item_price,
    source_table.freight_value AS mtr_order_item_freight_value,

    CURRENT_TIMESTAMP AS audit_created_at,
    CURRENT_TIMESTAMP AS audit_updated_at
FROM inc_data AS source_table
WHERE
    source_table._r = 1