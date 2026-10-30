-- Customers with at least one delivered order worth more than 200

SELECT
    customer_data.id AS customer_id,
    customer_data.name AS customer,
    customer_data.email
FROM customer AS customer_data
WHERE EXISTS (
    SELECT 1
    FROM orders AS order_data
    JOIN order_item AS order_item_data
        ON order_item_data.order_id = order_data.id
    WHERE order_data.customer_id = customer_data.id
      AND order_data.status = 'Delivered'
    GROUP BY order_data.id
    HAVING SUM(order_item_data.price * order_item_data.amount) > 200
)
ORDER BY customer_data.id;
