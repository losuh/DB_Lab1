-- Scenario 1: adding a new entity and related records with INSERT

BEGIN;

DO $$
DECLARE
    new_customer_id INT;
    new_address_id INT;
    new_order_id INT;
    selected_product_id INT;
    selected_product_price NUMERIC(10, 2);
    selected_product_amount INT;
    ordered_amount INT := 2;
BEGIN
    INSERT INTO customer (name, email)
    VALUES ('Eve White', 'eve@example.com')
    RETURNING id INTO new_customer_id;

    INSERT INTO address (address)
    VALUES ('123 Main St, Springfield, USA')
    RETURNING id INTO new_address_id;

    INSERT INTO address_list (customer_id, address_id, tag)
    VALUES (new_customer_id, new_address_id, 'home');

    SELECT id, price, amount
    INTO selected_product_id, selected_product_price, selected_product_amount
    FROM product
    WHERE name = 'Smartphone'
    ORDER BY id
    LIMIT 1
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Product Smartphone not found';
    END IF;

    IF selected_product_amount < ordered_amount THEN
        RAISE EXCEPTION 'Not enough products in stock';
    END IF;

    INSERT INTO orders (customer_id, status)
    VALUES (new_customer_id, 'Pending')
    RETURNING id INTO new_order_id;

    INSERT INTO order_item (order_id, product_id, price, amount)
    VALUES (
        new_order_id,
        selected_product_id,
        selected_product_price,
        ordered_amount
    );

    UPDATE product
    SET amount = amount - ordered_amount
    WHERE id = selected_product_id;

    INSERT INTO delivery (order_id, address_id, status)
    VALUES (new_order_id, new_address_id, 'Pending');
END
$$;

SELECT
    customer_data.id AS customer_id,
    customer_data.email,
    address_data.address,
    order_data.id AS order_id,
    product_data.name AS product,
    order_item_data.price,
    order_item_data.amount,
    delivery_data.status AS delivery_status
FROM customer AS customer_data
JOIN address_list AS address_list_data
    ON address_list_data.customer_id = customer_data.id
JOIN address AS address_data
    ON address_data.id = address_list_data.address_id
JOIN orders AS order_data
    ON order_data.customer_id = customer_data.id
JOIN order_item AS order_item_data
    ON order_item_data.order_id = order_data.id
JOIN product AS product_data
    ON product_data.id = order_item_data.product_id
JOIN delivery AS delivery_data
    ON delivery_data.order_id = order_data.id
WHERE customer_data.email = 'eve@example.com';

ROLLBACK;

-- Scenario 2: changing the state of an existing operation with UPDATE

SELECT id, status
FROM orders
WHERE id = 1;

BEGIN;

UPDATE orders
SET status = 'Paid'
WHERE id = 1
  AND status = 'Pending'
RETURNING id, status;

SELECT id, status
FROM orders
WHERE id = 1;

ROLLBACK;

SELECT id, status
FROM orders
WHERE id = 1;

-- Scenario 3: mass update by a meaningful condition

SELECT product_data.id, product_data.name, product_data.price
FROM product AS product_data
JOIN category AS category_data
    ON category_data.id = product_data.category_id
WHERE category_data.name = 'Electronics'
  AND product_data.price < 200
ORDER BY product_data.id;

BEGIN;

UPDATE product
SET price = ROUND(price * 1.07, 2)
WHERE category_id = (
    SELECT id
    FROM category
    WHERE name = 'Electronics'
)
  AND price < 200
RETURNING id, name, price;

ROLLBACK;

SELECT product_data.id, product_data.name, product_data.price
FROM product AS product_data
JOIN category AS category_data
    ON category_data.id = product_data.category_id
WHERE category_data.name = 'Electronics'
  AND product_data.price < 200
ORDER BY product_data.id;

-- Scenario 4: deletion with existing integrity constraints

SELECT id, status
FROM orders
WHERE id = 5
  AND status = 'Cancelled';

SELECT order_id, product_id, price, amount
FROM order_item
WHERE order_id = 5;

BEGIN;

DELETE FROM orders
WHERE id = 5
  AND status = 'Cancelled'
RETURNING id, status;

SELECT order_id, product_id, price, amount
FROM order_item
WHERE order_id = 5;

ROLLBACK;

SELECT id, status
FROM orders
WHERE id = 5;

SELECT order_id, product_id, price, amount
FROM order_item
WHERE order_id = 5;

-- Scenario 5: cancelling changes with ROLLBACK

SELECT id, status
FROM orders
WHERE id = 1;

SELECT id, name, amount
FROM product
WHERE id = 1;

BEGIN;

UPDATE orders
SET status = 'Paid'
WHERE id = 1
  AND status = 'Pending'
RETURNING id, status;

UPDATE product
SET amount = amount - 3
WHERE id = 1
  AND amount >= 3
RETURNING id, name, amount;

SELECT id, status
FROM orders
WHERE id = 1;

SELECT id, name, amount
FROM product
WHERE id = 1;

ROLLBACK;

SELECT id, status
FROM orders
WHERE id = 1;

SELECT id, name, amount
FROM product
WHERE id = 1;
