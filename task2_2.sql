-- Query 1: order and customer counts by order status

SELECT
    order_data.status,
    COUNT(*) AS order_count,
    COUNT(DISTINCT order_data.customer_id) AS customer_count,
    MIN(order_data.date) AS first_order_date,
    MAX(order_data.date) AS last_order_date
FROM orders AS order_data
GROUP BY order_data.status
ORDER BY order_count DESC, order_data.status;

-- Query 2: category sales with revenue-based group filtering

SELECT
    category_data.id AS category_id,
    category_data.name AS category,
    COUNT(DISTINCT order_data.id) AS order_count,
    SUM(order_item_data.amount) AS units_sold,
    ROUND(SUM(order_item_data.price * order_item_data.amount), 2) AS revenue,
    ROUND(AVG(order_item_data.price * order_item_data.amount), 2) AS average_line_total
FROM category AS category_data
JOIN product AS product_data
    ON product_data.category_id = category_data.id
JOIN order_item AS order_item_data
    ON order_item_data.product_id = product_data.id
JOIN orders AS order_data
    ON order_data.id = order_item_data.order_id
GROUP BY category_data.id, category_data.name
HAVING SUM(order_item_data.price * order_item_data.amount) >= 1000
ORDER BY revenue DESC, category_data.name;

-- Query 3: comparison of order values by calendar month

SELECT
    monthly_orders.order_month,
    COUNT(*) AS order_count,
    ROUND(SUM(monthly_orders.order_total), 2) AS revenue,
    ROUND(AVG(monthly_orders.order_total), 2) AS average_order_total,
    MIN(monthly_orders.order_total) AS minimum_order_total,
    MAX(monthly_orders.order_total) AS maximum_order_total
FROM (
    SELECT
        order_data.id AS order_id,
        DATE_TRUNC('month', order_data.date)::DATE AS order_month,
        SUM(order_item_data.price * order_item_data.amount) AS order_total
    FROM orders AS order_data
    JOIN order_item AS order_item_data
        ON order_item_data.order_id = order_data.id
    GROUP BY
        order_data.id,
        DATE_TRUNC('month', order_data.date)::DATE
) AS monthly_orders
GROUP BY monthly_orders.order_month
ORDER BY monthly_orders.order_month;
