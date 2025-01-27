{% if execute and is_incremental() %}
    {% set query = 'select COALESCE(max(audit_updated_at), CAST(\'2000-01-01 00:00:00\' AS TIMESTAMP)) from {}'.format(this) %}
    {% set result = run_query(query).columns[0].values()[0] %}
{% endif %}

WITH inc_data AS (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY source_table.product_category_name ORDER BY source_table.audit_load_at DESC) AS _r
    FROM {{ source('raw', 'bronze_product_category_translation') }} source_table
    {% if is_incremental() %}
    WHERE
        source_table.audit_load_at > '{{ result }}'
    {% endif %}
)

SELECT
    source_table.product_category_name AS dsc_product_category_name,
    source_table.product_category_name_english AS dsc_product_category_name_english,

    CURRENT_TIMESTAMP AS audit_created_at,
    CURRENT_TIMESTAMP AS audit_updated_at
FROM inc_data AS source_table
WHERE
    source_table._r = 1