{% if execute and is_incremental() %}
    {% set query = 'select COALESCE(max(audit_updated_at), CAST(\'2000-01-01 00:00:00\' AS TIMESTAMP)) from {}'.format(this) %}
    {% set result = run_query(query).columns[0].values()[0] %}
{% endif %}

WITH inc_data AS (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY source_table.code_product ORDER BY source_table.audit_updated_at DESC) AS _r
    FROM {{ ref('silver_products') }} source_table
    {% if is_incremental() %}
    WHERE
        source_table.audit_updated_at > '{{ result }}'
    {% endif %}
)

SELECT
    '-1' AS sk_product,
    '-1' AS code_product,
    'N/A' AS dsc_product_category_name,
    'N/A' AS dsc_product_category_name_english,
    -1 AS mtr_product_name_lenght,
    -1 AS mtr_product_description_lenght,
    -1 AS mtr_product_photos_qty,
    -1 AS mtr_product_weight_g,
    -1 AS mtr_product_length_cm,
    -1 AS mtr_product_height_cm,
    -1 AS mtr_product_width_cm,
    CURRENT_TIMESTAMP AS audit_created_at,
    CURRENT_TIMESTAMP AS audit_updated_at
UNION ALL

SELECT
    TO_BASE64(SHA256(source_table.code_product)) AS sk_product,
    source_table.code_product,
    source_table.dsc_product_category_name,
    pct.dsc_product_category_name_english,
    source_table.mtr_product_name_lenght,
    source_table.mtr_product_description_lenght,
    source_table.mtr_product_photos_qty,
    source_table.mtr_product_weight_g,
    source_table.mtr_product_length_cm,
    source_table.mtr_product_height_cm,
    source_table.mtr_product_width_cm,

    CURRENT_TIMESTAMP AS audit_created_at,
    CURRENT_TIMESTAMP AS audit_updated_at
FROM inc_data AS source_table
LEFT JOIN {{ ref('silver_product_category_translation') }} pct ON source_table.dsc_product_category_name = pct.dsc_product_category_name
WHERE
    source_table._r = 1