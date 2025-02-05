WITH order_keys AS (
    SELECT
        order_id,
        ROW_NUMBER() OVER (ORDER BY order_id) AS order_key
    FROM {{ ref('stg_orders') }}
)

SELECT
    order_key,
    order_id
FROM order_keys