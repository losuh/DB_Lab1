INSERT INTO category (name) VALUES
    ('Electronics'),
    ('Clothing'),
    ('Books'),
    ('Sports');

INSERT INTO customer (name, email) VALUES
    ('Alice Smith', 'alice@example.com'),
    ('Bob Jones', 'bob@example.com'),
    ('Charlie Brown', 'charlie@example.com'),
    ('Diana Prince', 'diana@example.com');

INSERT INTO product (category_id, name, price, amount) VALUES
    (1, 'Phone', 500.00, 10),
    (1, 'Laptop', 1200.00, 5),
    (2, 'T-Shirt', 20.00, 50),
    (2, 'Jeans', 50.00, 30),
    (3, 'Novel', 15.00, 100),
    (4, 'Ball', 25.00, 40);

INSERT INTO orders (customer_id, status, date) VALUES
    (1, 'Paid', '2026-10-01 10:00:00'),
    (2, 'Pending', '2026-10-02 12:30:00'),
    (3, 'Shipped', '2026-10-03 15:45:00'),
    (4, 'Delivered', '2026-10-04 09:15:00');

INSERT INTO order_item (order_id, product_id, price, amount) VALUES
    (1, 1, 500.00, 1),
    (1, 3, 20.00, 2),
    (2, 2, 1200.00, 1),
    (3, 4, 50.00, 1),
    (3, 5, 15.00, 3),
    (4, 6, 25.00, 2);

insert into address (id, customer_id, address, tag) VALUES
                                                    (0,1, 'abc', NULL),
                                                    (1,2, 'abc', NULL);


SELECT * FROM address