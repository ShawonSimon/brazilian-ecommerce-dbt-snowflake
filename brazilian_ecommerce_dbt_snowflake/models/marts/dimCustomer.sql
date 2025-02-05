WITH customer_keys AS (
    SELECT 
        customer_id,
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS customer_key
    FROM {{ ref('stg_customers') }}
),
select_customers AS (
    SELECT DISTINCT
        customer_keys.customer_key,
        stg_customers.customer_id,
        stg_customers.customer_unique_id,
        stg_customers.customer_city,
        stg_customers.customer_state,
        FIRST_VALUE(stg_geolocation.geolocation_lat) OVER (
            PARTITION BY stg_customers.customer_id
            ORDER BY stg_customers.customer_id
        ) AS geolocation_lat,
        FIRST_VALUE(stg_geolocation.geolocation_lng) OVER (
            PARTITION BY stg_customers.customer_id
            ORDER BY stg_customers.customer_id
        ) AS geolocation_lng
    FROM {{ ref('stg_customers') }}
    LEFT JOIN customer_keys ON stg_customers.customer_id = customer_keys.customer_id
    LEFT JOIN {{ ref('stg_geolocation') }} ON stg_customers.customer_zip_code_prefix = stg_geolocation.geolocation_zip_code_prefix
)
SELECT *
FROM select_customers
ORDER BY customer_key ASC

