-- Customers who have never had a delivered order

SELECT
    customer_data.id AS customer_id,
    customer_data.name AS customer,
    customer_data.email
FROM customer AS customer_data
WHERE NOT EXISTS (
    SELECT 1
    FROM orders AS order_data
    WHERE order_data.customer_id = customer_data.id
      AND order_data.status = 'Delivered'
)
ORDER BY customer_data.id;
