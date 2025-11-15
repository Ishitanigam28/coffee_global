-- Create new database
CREATE DATABASE coffee_sales;
USE coffee_sales;

-- CUSTOMERS TABLE
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    country VARCHAR(100),
    city VARCHAR(100),
    signup_date DATE,
    loyalty_member BOOLEAN
);

-- PRODUCTS TABLE
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    size_ml INT,
    unit_price DECIMAL(6,2)
);

-- STORES TABLE
CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100),
    country VARCHAR(100),
    city VARCHAR(100),
    opened_date DATE,
    store_type VARCHAR(50)
);

-- ORDERS TABLE
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    store_id INT,
    order_date DATE,
    order_time TIME,
    payment_method VARCHAR(50),
    order_status VARCHAR(50),
    shipping_country VARCHAR(100),
    shipping_delay_days INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

-- ORDER_ITEMS TABLE
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    product_name VARCHAR(100),
    quantity INT,
    unit_price DECIMAL(6,2),
    total_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Allow local file loading (if disabled)
SET GLOBAL local_infile = 1;

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(customer_id, first_name, last_name, email, country, city, @signup_date, @loyalty_member)
SET 
signup_date = STR_TO_DATE(@signup_date, '%Y-%m-%d'),
loyalty_member = CASE 
    WHEN LOWER(@loyalty_member) IN ('true', 'yes', '1') THEN 1
    WHEN LOWER(@loyalty_member) IN ('false', 'no', '0') THEN 0
    ELSE NULL
END;



SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, product_name, category, size_ml, unit_price);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/stores.csv'
INTO TABLE stores
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(store_id, store_name, country, city, @opened_date, store_type)
SET opened_date = STR_TO_DATE(@opened_date, '%m/%d/%Y');


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, customer_id, store_id, @order_date, @order_time, payment_method, order_status, shipping_country, shipping_delay_days)
SET 
order_date = STR_TO_DATE(@order_date, '%Y-%m-%d'),
order_time = STR_TO_DATE(@order_time, '%H:%i:%s');

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_item_id, order_id, product_id, product_name, quantity, unit_price, total_price);

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM stores;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM stores;
SELECT * FROM orders;
SELECT * FROM order_items;

SELECT 
    ROUND(SUM(total_price), 2) AS total_revenue
FROM order_items;

SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    ROUND(SUM(oi.total_price), 2) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY month
ORDER BY month;

SELECT 
    oi.product_name,
    SUM(oi.quantity) AS total_sold,
    ROUND(SUM(oi.total_price), 2) AS revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY oi.product_name
ORDER BY revenue DESC
LIMIT 10;

SELECT 
    o.shipping_country AS country,
    ROUND(SUM(oi.total_price), 2) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY o.shipping_country
ORDER BY total_revenue DESC;

SELECT 
    s.store_name,
    s.country,
    ROUND(SUM(oi.total_price), 2) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN stores s ON o.store_id = s.store_id
WHERE o.order_status = 'Completed'
GROUP BY s.store_id
ORDER BY total_revenue DESC
LIMIT 10;





