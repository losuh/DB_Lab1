DROP TABLE IF EXISTS address CASCADE;
DROP TABLE IF EXISTS delivery CASCADE;
DROP TABLE IF EXISTS address_list CASCADE;


CREATE TABLE IF NOT EXISTS address(
    id SERIAL PRIMARY KEY,
    address TEXT NOT NULL UNIQUE
);


CREATE TABLE IF NOT EXISTS address_list(
    customer_id INT NOT NULL,
    address_id INT NOT NULL,
    tag VARCHAR(5),
    CONSTRAINT pk_address_list PRIMARY KEY (customer_id, address_id),
    CONSTRAINT chk_address_tag CHECK (tag IN ('work', 'home', 'school') OR tag IS NULL),
    CONSTRAINT fk_address_list_customer FOREIGN KEY (customer_id)
        REFERENCES customer(id) ON DELETE CASCADE,
    CONSTRAINT fk_address_list_address FOREIGN KEY (address_id)
        REFERENCES address(id) ON DELETE RESTRICT
);



CREATE TABLE IF NOT EXISTS delivery(
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    address_id INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    shipping_date TIMESTAMP,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_delivery_order FOREIGN KEY (order_id)
        REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_delivery_customer_address FOREIGN KEY (customer_id, address_id)
        REFERENCES address_list(customer_id, address_id) ON DELETE RESTRICT,
    CONSTRAINT chk_delivery_status CHECK (status IN ('Pending', 'Paid', 'Shipped', 'Delivered', 'Cancelled'))
);
