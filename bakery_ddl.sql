DROP DATABASE IF EXISTS bakery;
CREATE SCHEMA IF NOT EXISTS bakery;
USE bakery;

DROP TABLE IF EXISTS bakery.customer;
CREATE TABLE bakery.customer (
  id INT PRIMARY KEY,
  firstname VARCHAR(100) NOT NULL,
  lastname VARCHAR(100) NOT NULL,
  birthdate DATE NOT NULL,
  phone CHAR(13) NOT NULL,
  email VARCHAR(100) NOT NULL,
  password VARCHAR(100) NOT NULL,
  street VARCHAR(100) NOT NULL,
  city VARCHAR(100) NOT NULL,
  state CHAR(2) NOT NULL,
  zipcode CHAR(5) NOT NULL,
  status VARCHAR(20) DEFAULT ('active'),
  CONSTRAINT CHECK (status IN ('active', 'disabled'))
);

DROP TABLE IF EXISTS bakery.credit_card;
CREATE TABLE bakery.credit_card (
    id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    number VARCHAR(25) NOT NULL UNIQUE,
    expiration_date DATE NOT NULL,
    cvn CHAR(3) NOT NULL,
    status VARCHAR(20) DEFAULT ('active'),
    CONSTRAINT CHECK (status IN ('active', 'disabled')),
    CONSTRAINT FOREIGN KEY (customer_id) REFERENCES customer(id)
);

DROP TABLE IF EXISTS bakery.pastry;
CREATE TABLE bakery.pastry (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    image_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT ('active'),
    CONSTRAINT CHECK (status IN ('active', 'disabled'))
);

DROP TABLE IF EXISTS bakery.review;
CREATE TABLE bakery.review (
    id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    pastry_id INT NOT NULL,
    rating INT NOT NULL,
    comment VARCHAR(500),
    submission_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT ('active'),
    CONSTRAINT CHECK (status IN ('active', 'disabled')),
    CONSTRAINT FOREIGN KEY (customer_id) REFERENCES bakery.customer(id),
    CONSTRAINT FOREIGN KEY (pastry_id) REFERENCES bakery.pastry(id)
);

DROP TABLE IF EXISTS bakery.wishlist;
CREATE TABLE bakery.wishlist (
    id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    pastry_id INT NOT NULL,
    submission_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT ('active'),
    CONSTRAINT CHECK (status IN ('active', 'disabled')),
    CONSTRAINT FOREIGN KEY (customer_id) REFERENCES bakery.customer(id),
    CONSTRAINT FOREIGN KEY (pastry_id) REFERENCES bakery.pastry(id)
);

DROP TABLE IF EXISTS bakery.invoice;
CREATE TABLE bakery.invoice (
    id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    card_id INT NOT NULL,
    submission_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    projected_delivery TIMESTAMP
        GENERATED ALWAYS AS (DATE_ADD(submission_time, INTERVAL 5 DAY)) STORED,
    real_delivery DATETIME,
    charge DECIMAL(10,2),
    tax DECIMAL(10,2) GENERATED ALWAYS AS (charge * 5/100) STORED,
    total_cost DECIMAL(10,2) GENERATED ALWAYS AS (charge + tax) STORED,
    status VARCHAR(20) NOT NULL DEFAULT ('active'),
    CONSTRAINT CHECK (status IN ('active', 'disabled')),
    CONSTRAINT FOREIGN KEY (customer_id) REFERENCES bakery.customer(id),
    CONSTRAINT FOREIGN KEY (card_id) REFERENCES bakery.credit_card(id)
);

DROP TABLE IF EXISTS bakery.invoice_item;
CREATE TABLE bakery.invoice_item (
    id INT NOT NULL PRIMARY KEY,
    invoice_id INT NOT NULL,
    pastry_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    cost DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT ('active'),
    CONSTRAINT CHECK (status IN ('active', 'disabled')),
    CONSTRAINT FOREIGN KEY (invoice_id) REFERENCES bakery.invoice(id),
    CONSTRAINT FOREIGN KEY (pastry_id) REFERENCES bakery.pastry(id)
);

DROP TABLE IF EXISTS bakery.return_request;
CREATE TABLE bakery.return_request (
    id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    invoice_id INT NOT NULL,
    item_id INT NOT NULL,
    request_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FOREIGN KEY (item_id) REFERENCES bakery.invoice_item(id),
    CONSTRAINT FOREIGN KEY (customer_id) REFERENCES bakery.customer(id),
    CONSTRAINT FOREIGN KEY (invoice_id) REFERENCES bakery.invoice(id)
);

DROP TABLE IF EXISTS bakery.approved_return;
CREATE TABLE bakery.approved_return (
    id INT PRIMARY KEY,
    request_id INT NOT NULL,
    approval_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_received DATETIME,
    CONSTRAINT FOREIGN KEY (request_id) REFERENCES bakery.return_request(id)
);
