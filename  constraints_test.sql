INSERT INTO customer (name, email)
VALUES ('Eve White', 'alice@example.com');

INSERT INTO product (category_id, name, price, amount)
VALUES (1, 'Broken Item', -10.00, 5);

INSERT INTO orders (customer_id, status)
VALUES (1, 'UnknownStatus');

INSERT INTO category (name)
VALUES (NULL);

INSERT INTO product (category_id, name, price, amount)
VALUES (999, 'Ghost Item', 100.00, 10);