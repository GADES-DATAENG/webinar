{% if execute and is_incremental() %}
    {% set query = 'select COALESCE(max(audit_updated_at), CAST(\'2000-01-01 00:00:00\' AS TIMESTAMP)) from {}'.format(this) %}
    {% set result = run_query(query).columns[0].values()[0] %}
{% endif %}

WITH inc_data AS (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY source_table.order_id ORDER BY source_table.audit_load_at DESC) AS _r
    FROM {{ source('raw', 'bronze_orders') }} source_table
    {% if is_incremental() %}
    WHERE
        source_table.audit_load_at > '{{ result }}'
    {% endif %}
)

SELECT
    source_table.order_id AS code_order,
    source_table.customer_id AS code_customer,
    source_table.order_status AS dsc_order_status,
    CAST(source_table.order_purchase_timestamp AS TIMESTAMP) AS date_order_purchase,
    CAST(source_table.order_approved_at AS TIMESTAMP) AS date_order_approved,
    CAST(source_table.order_delivered_carrier_date AS TIMESTAMP) AS date_order_delivered_carrier,
    CAST(source_table.order_delivered_customer_date AS TIMESTAMP) AS date_order_delivered_customer,
    CAST(source_table.order_estimated_delivery_date AS TIMESTAMP) AS date_order_estimated_delivery,

    CURRENT_TIMESTAMP AS audit_created_at,
    CURRENT_TIMESTAMP AS audit_updated_at
FROM inc_data AS source_table
WHERE
    source_table._r = 1