TRUNCATE TABLE
    delivery,
    address_list,
    order_item,
    orders,
    product,
    address,
    category,
    customer
RESTART IDENTITY CASCADE;

INSERT INTO category (name) VALUES
    ('Electronics'),
    ('Clothing'),
    ('Books'),
    ('Sports'),
    ('Home'),
    ('Beauty'),
    ('Toys');

INSERT INTO customer (name, email) VALUES
    ('Alice Smith', 'alice@example.com'),
    ('Bob Jones', 'bob@example.com'),
    ('Charlie Brown', 'charlie@example.com'),
    ('Diana Prince', 'diana@example.com'),
    ('Ethan Clark', 'ethan@example.com'),
    ('Fiona Green', 'fiona@example.com'),
    ('George Hall', 'george@example.com'),
    ('Hannah King', 'hannah@example.com'),
    ('Ivan Lewis', 'ivan@example.com'),
    ('Julia Moore', 'julia@example.com'),
    ('Kevin Nelson', 'kevin@example.com'),
    ('Laura Parker', 'laura@example.com'),
    ('Michael Reed', 'michael@example.com'),
    ('Nina Scott', 'nina@example.com'),
    ('Oliver Taylor', 'oliver@example.com'),
    ('Paula Walker', 'paula@example.com'),
    ('Quentin Young', 'quentin@example.com'),
    ('Rachel Adams', 'rachel@example.com'),
    ('Samuel Baker', 'samuel@example.com'),
    ('Tina Carter', 'tina@example.com');

INSERT INTO product (category_id, name, price, amount) VALUES
    (1, 'Smartphone', 599.90, 18),
    (1, 'Laptop', 1299.00, 7),
    (1, 'Wireless Headphones', 149.50, 32),
    (1, 'Smart Watch', 249.00, 15),
    (1, 'USB-C Charger', 35.90, 60),
    (1, 'Web Camera', 89.00, 0),
    (2, 'T-Shirt', 24.90, 70),
    (2, 'Jeans', 69.00, 40),
    (2, 'Jacket', 139.90, 12),
    (2, 'Sneakers', 94.50, 25),
    (2, 'Cap', 19.00, 55),
    (2, 'Socks', 8.50, 100),
    (3, 'Database Systems', 79.90, 14),
    (3, 'SQL Handbook', 45.00, 28),
    (3, 'Modern Fiction', 18.90, 46),
    (3, 'History Atlas', 32.00, 20),
    (3, 'Cookbook', 27.50, 24),
    (3, 'Free Catalogue', 0.00, 200),
    (4, 'Football', 29.90, 35),
    (4, 'Yoga Mat', 39.00, 22),
    (4, 'Dumbbell Set', 119.00, 9),
    (4, 'Tennis Racket', 84.90, 13),
    (4, 'Water Bottle', 16.50, 80),
    (4, 'Fitness Band', 12.00, 0),
    (5, 'Desk Lamp', 54.90, 19),
    (5, 'Coffee Mug', 14.50, 65),
    (5, 'Blanket', 49.00, 17),
    (5, 'Wall Clock', 31.90, 30),
    (5, 'Storage Box', 22.00, 42),
    (5, 'Kitchen Scale', 44.00, 16),
    (6, 'Face Cream', 28.90, 33),
    (6, 'Shampoo', 12.50, 75),
    (6, 'Perfume', 89.90, 11),
    (6, 'Hand Soap', 6.90, 90),
    (6, 'Hair Dryer', 64.00, 18),
    (6, 'Cosmetic Bag', 21.00, 26);

INSERT INTO orders (customer_id, status, date)
SELECT
    ((number - 1) % 18) + 1,
    CASE (number - 1) % 5
        WHEN 0 THEN 'Pending'
        WHEN 1 THEN 'Paid'
        WHEN 2 THEN 'Shipped'
        WHEN 3 THEN 'Delivered'
        ELSE 'Cancelled'
    END,
    make_timestamp(
        2026,
        ((number - 1) / 15) + 1,
        ((number - 1) % 15) + 1,
        9 + ((number - 1) % 8),
        (number * 7) % 60,
        0
    )
FROM generate_series(1, 45) AS series(number);

INSERT INTO order_item (order_id, product_id, price, amount)
SELECT
    order_data.id,
    product_data.id,
    product_data.price,
    1 + (order_data.id % 3)
FROM orders AS order_data
JOIN product AS product_data
    ON product_data.id = ((order_data.id * 2 - 1) % 36) + 1
UNION ALL
SELECT
    order_data.id,
    product_data.id,
    product_data.price,
    1 + ((order_data.id + 1) % 2)
FROM orders AS order_data
JOIN product AS product_data
    ON product_data.id = ((order_data.id * 2 + 5) % 36) + 1;

INSERT INTO address (address) VALUES
    ('12 Green Street, Moscow'),
    ('45 River Road, Moscow'),
    ('8 Central Avenue, Moscow'),
    ('21 Park Lane, Moscow'),
    ('5 Forest Street, Moscow'),
    ('73 Lake Road, Moscow'),
    ('16 Garden Avenue, Moscow'),
    ('34 Sunrise Lane, Moscow'),
    ('91 North Street, Moscow'),
    ('27 South Road, Moscow'),
    ('10 Market Square, Moscow'),
    ('62 Station Avenue, Moscow'),
    ('18 School Lane, Moscow'),
    ('39 University Street, Moscow'),
    ('7 Victory Road, Moscow'),
    ('55 Peace Avenue, Moscow'),
    ('23 Oak Street, Moscow'),
    ('81 Maple Road, Moscow'),
    ('14 Pine Lane, Moscow'),
    ('66 Birch Street, Moscow'),
    ('4 Office Park, Moscow'),
    ('19 Industrial Road, Moscow'),
    ('2 Academic Avenue, Moscow'),
    ('88 Riverside Lane, Moscow'),
    ('31 Central Square, Moscow');

INSERT INTO address_list (customer_id, address_id, tag)
SELECT
    number,
    number,
    CASE number % 4
        WHEN 0 THEN NULL
        WHEN 1 THEN 'home'
        WHEN 2 THEN 'work'
        ELSE 'school'
    END
FROM generate_series(1, 20) AS series(number);

INSERT INTO address_list (customer_id, address_id, tag) VALUES
    (1, 21, 'work'),
    (2, 22, 'work'),
    (3, 23, 'school'),
    (4, 24, NULL),
    (5, 25, 'home');

INSERT INTO delivery (order_id, address_id, status, shipping_date, creation_date)
SELECT
    order_data.id,
    order_data.customer_id,
    CASE order_data.status
        WHEN 'Shipped' THEN 'Shipped'
        WHEN 'Delivered' THEN 'Delivered'
        ELSE 'Pending'
    END,
    CASE
        WHEN order_data.status IN ('Shipped', 'Delivered')
            THEN order_data.date + INTERVAL '1 day'
        ELSE NULL
    END,
    order_data.date + INTERVAL '1 hour'
FROM orders AS order_data
WHERE order_data.status <> 'Cancelled';
