DROP TABLE IF EXISTS order_item CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS category CASCADE;
DROP TABLE IF EXISTS customer CASCADE;

CREATE TABLE customer (
                          id SERIAL PRIMARY KEY,
                          name VARCHAR(255) NOT NULL,
                          email VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE category (
                          id SERIAL PRIMARY KEY,
                          name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE product (
                         id SERIAL PRIMARY KEY,
                         category_id INT NOT NULL,
                         name VARCHAR(255) NOT NULL,
                         price NUMERIC(10, 2) NOT NULL,
                         amount INT NOT NULL,
                         CONSTRAINT fk_product_category FOREIGN KEY (category_id)
                             REFERENCES category(id) ON DELETE RESTRICT,
                         CONSTRAINT chk_product_price CHECK (price >= 0),
                         CONSTRAINT chk_product_amount CHECK (amount >= 0)
);

CREATE TABLE orders (
                         id SERIAL PRIMARY KEY,
                         customer_id INT NOT NULL,
                         status VARCHAR(50) NOT NULL,
                         date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         CONSTRAINT fk_order_customer FOREIGN KEY (customer_id)
                             REFERENCES customer(id) ON DELETE CASCADE,
                         CONSTRAINT chk_order_status CHECK (status IN ('Pending', 'Paid', 'Shipped', 'Delivered', 'Cancelled'))
);

CREATE TABLE order_item (
                            order_id INT NOT NULL,
                            product_id INT NOT NULL,
                            price NUMERIC(10, 2) NOT NULL,
                            amount INT NOT NULL,
                            CONSTRAINT pk_order_item PRIMARY KEY (order_id, product_id),
                            CONSTRAINT fk_order_item_order FOREIGN KEY (order_id)
                                REFERENCES orders(id) ON DELETE CASCADE,
                            CONSTRAINT fk_order_item_product FOREIGN KEY (product_id)
                                REFERENCES product(id) ON DELETE RESTRICT,
                            CONSTRAINT chk_order_item_amount CHECK (amount > 0)
);

