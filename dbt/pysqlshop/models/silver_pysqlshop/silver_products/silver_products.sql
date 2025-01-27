{% if execute and is_incremental() %}
    {% set query = 'select COALESCE(max(audit_updated_at), CAST(\'2000-01-01 00:00:00\' AS TIMESTAMP)) from {}'.format(this) %}
    {% set result = run_query(query).columns[0].values()[0] %}
{% endif %}

WITH inc_data AS (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY source_table.product_id ORDER BY source_table.audit_load_at DESC) AS _r
    FROM {{ source('raw', 'bronze_products') }} source_table
    {% if is_incremental() %}
    WHERE
        source_table.audit_load_at > '{{ result }}'
    {% endif %}
)

SELECT
    source_table.product_id AS code_product,
    source_table.product_category_name AS dsc_product_category_name,
    source_table.product_name_lenght AS mtr_product_name_lenght,
    source_table.product_description_lenght AS mtr_product_description_lenght,
    source_table.product_photos_qty AS mtr_product_photos_qty,
    source_table.product_weight_g AS mtr_product_weight_g,
    source_table.product_length_cm AS mtr_product_length_cm,
    source_table.product_height_cm AS mtr_product_height_cm,
    source_table.product_width_cm AS mtr_product_width_cm,

    CURRENT_TIMESTAMP AS audit_created_at,
    CURRENT_TIMESTAMP AS audit_updated_at
FROM inc_data AS source_table
WHERE
    source_table._r = 1