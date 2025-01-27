{% if execute and is_incremental() %}
    {% set query = 'select COALESCE(max(audit_updated_at), CAST(\'2000-01-01 00:00:00\' AS TIMESTAMP)) from {}'.format(this) %}
    {% set result = run_query(query).columns[0].values()[0] %}
{% endif %}

WITH inc_data AS (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY source_table.customer_id ORDER BY source_table.audit_load_at DESC) AS _r
    FROM {{ source('raw', 'bronze_customers') }} source_table
    {% if is_incremental() %}
    WHERE
        source_table.audit_load_at > '{{ result }}'
    {% endif %}
)

SELECT
    source_table.customer_id AS code_customer,
    source_table.customer_unique_id AS code_customer_unique,
    source_table.customer_zip_code_prefix AS dsc_customer_zip_code_prefix,
    INITCAP(source_table.customer_city) AS dsc_customer_city,
    source_table.customer_state AS dsc_customer_state,

    CURRENT_TIMESTAMP AS audit_created_at,
    CURRENT_TIMESTAMP AS audit_updated_at
FROM inc_data AS source_table
WHERE
    source_table._r = 1