{% if execute and is_incremental() %}
    {% set query = 'select COALESCE(max(audit_updated_at), CAST(\'2000-01-01 00:00:00\' AS TIMESTAMP)) from {}'.format(this) %}
    {% set result = run_query(query).columns[0].values()[0] %}
{% endif %}

WITH inc_data AS (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY source_table.code_seller ORDER BY source_table.audit_updated_at DESC) AS _r
    FROM {{ ref('silver_sellers') }} source_table
    {% if is_incremental() %}
    WHERE
        source_table.audit_updated_at > '{{ result }}'
    {% endif %}
)

SELECT
    '-1' AS sk_seller,
    '-1' AS code_seller,
    -1 AS dsc_seller_zip_code_prefix,
    'N/A' AS dsc_seller_city,
    'N/A' AS dsc_seller_state,
    CURRENT_TIMESTAMP AS audit_created_at,
    CURRENT_TIMESTAMP AS audit_updated_at
UNION ALL

SELECT
    TO_BASE64(SHA256(source_table.code_seller)) AS sk_seller,
    source_table.code_seller,
    source_table.dsc_seller_zip_code_prefix,
    source_table.dsc_seller_city,
    source_table.dsc_seller_state,

    CURRENT_TIMESTAMP AS audit_created_at,
    CURRENT_TIMESTAMP AS audit_updated_at
FROM inc_data AS source_table
WHERE
    source_table._r = 1