{% if execute and is_incremental() %}
    {% set query = 'select COALESCE(max(audit_updated_at), CAST(\'2000-01-01 00:00:00\' AS TIMESTAMP)) from {}'.format(this) %}
    {% set result = run_query(query).columns[0].values()[0] %}
{% endif %}

WITH inc_data AS (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY source_table.dsc_payment_type ORDER BY source_table.audit_updated_at DESC) AS _r
    FROM {{ ref('silver_order_payments') }} source_table
    {% if is_incremental() %}
    WHERE
        source_table.audit_updated_at > '{{ result }}'
    {% endif %}
)

SELECT
    '-1' AS sk_payment_type,
    'N/A' AS dsc_payment_type,
    CURRENT_TIMESTAMP AS audit_created_at,
    CURRENT_TIMESTAMP AS audit_updated_at
UNION ALL

SELECT
    TO_BASE64(SHA256(source_table.dsc_payment_type)) AS sk_payment_type,
    source_table.dsc_payment_type,

    CURRENT_TIMESTAMP AS audit_created_at,
    CURRENT_TIMESTAMP AS audit_updated_at
FROM(
    SELECT
        DISTINCT dsc_payment_type
    FROM inc_data
    WHERE
        inc_data._r = 1
) source_table