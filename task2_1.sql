-- Query 1: detailed information about orders and related entities

SELECT
    order_data.id AS order_id,
    order_data.date AS order_date,
    order_data.status AS order_status,
    customer_data.name AS customer,
    customer_data.email,
    product_data.name AS product,
    category_data.name AS category,
    order_item_data.amount,
    order_item_data.price AS unit_price,
    ROUND(order_item_data.price * order_item_data.amount, 2) AS line_total,
    COALESCE(delivery_data.status, 'Not created') AS delivery_status,
    address_data.address AS delivery_address
FROM orders AS order_data
JOIN customer AS customer_data
    ON customer_data.id = order_data.customer_id
JOIN order_item AS order_item_data
    ON order_item_data.order_id = order_data.id
JOIN product AS product_data
    ON product_data.id = order_item_data.product_id
JOIN category AS category_data
    ON category_data.id = product_data.category_id
LEFT JOIN delivery AS delivery_data
    ON delivery_data.order_id = order_data.id
LEFT JOIN address AS address_data
    ON address_data.id = delivery_data.address_id
ORDER BY order_data.date, order_data.id, product_data.name;

-- Query 2: products that have never appeared in an order

SELECT
    product_data.id AS product_id,
    product_data.name AS product,
    category_data.name AS category,
    product_data.price,
    product_data.amount AS stock_amount
FROM product AS product_data
JOIN category AS category_data
    ON category_data.id = product_data.category_id
LEFT JOIN order_item AS order_item_data
    ON order_item_data.product_id = product_data.id
LEFT JOIN orders AS order_data
    ON order_data.id = order_item_data.order_id
WHERE order_item_data.product_id IS NULL
ORDER BY category_data.name, product_data.name;

-- Query 3: shipped or delivered orders sent to a saved home address

SELECT
    order_data.id AS order_id,
    order_data.date AS order_date,
    customer_data.id AS customer_id,
    customer_data.name AS customer,
    order_data.status AS order_status,
    delivery_data.status AS delivery_status,
    address_data.address,
    address_list_data.tag
FROM customer AS customer_data
JOIN orders AS order_data
    ON order_data.customer_id = customer_data.id
JOIN delivery AS delivery_data
    ON delivery_data.order_id = order_data.id
JOIN address AS address_data
    ON address_data.id = delivery_data.address_id
JOIN address_list AS address_list_data
    ON address_list_data.customer_id = customer_data.id
   AND address_list_data.address_id = delivery_data.address_id
WHERE order_data.status IN ('Shipped', 'Delivered')
  AND delivery_data.status IN ('Shipped', 'Delivered')
  AND address_list_data.tag = 'home'
  AND order_data.date >= TIMESTAMP '2026-01-01 00:00:00'
  AND order_data.date < TIMESTAMP '2026-04-01 00:00:00'
ORDER BY order_data.date, order_data.id;
