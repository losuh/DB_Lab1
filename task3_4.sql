-- Individual order indicators calculated for every customer

SELECT
    customer_data.id AS customer_id,
    customer_data.name AS customer,
    customer_data.email,
    (
        SELECT COUNT(*)
        FROM orders AS order_data
        WHERE order_data.customer_id = customer_data.id
          AND order_data.status <> 'Cancelled'
    ) AS non_cancelled_order_count,
    ROUND(
        COALESCE(
            (
                SELECT SUM(order_item_data.price * order_item_data.amount)
                FROM orders AS order_data
                JOIN order_item AS order_item_data
                    ON order_item_data.order_id = order_data.id
                WHERE order_data.customer_id = customer_data.id
                  AND order_data.status <> 'Cancelled'
            ),
            0
        ),
        2
    ) AS non_cancelled_order_value,
    (
        SELECT MAX(order_data.date)
        FROM orders AS order_data
        WHERE order_data.customer_id = customer_data.id
    ) AS last_order_date
FROM customer AS customer_data
ORDER BY non_cancelled_order_value DESC, customer_data.id;
