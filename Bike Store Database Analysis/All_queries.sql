-- ------------------ DATABASE CREATION & INITIAL EXPLORATION ------------------
-- Create the database
CREATE DATABASE Bike_Store;

-- Select the database for use
USE Bike_Store;

-- View all tables and their data
SELECT * FROM brands;
SELECT * FROM categories;
SELECT * FROM customers;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM staffs;
SELECT * FROM stocks;
SELECT * FROM stores;


-- ------------------ DATA CLEANING & DATA TYPE CORRECTION ------------------
-- Change the data type of order_date, shipped_date, and required_date to DATE for accurate date operations
ALTER TABLE orders  
MODIFY COLUMN order_date DATE,  
MODIFY COLUMN shipped_date DATE,  
MODIFY COLUMN required_date DATE;


-- ------------------ ASSIGNING PRIMARY KEYS ------------------
-- Ensure each table has a unique identifier
ALTER TABLE brands ADD PRIMARY KEY (brand_id);
ALTER TABLE categories ADD PRIMARY KEY (category_id);
ALTER TABLE customers ADD PRIMARY KEY (customer_id);
ALTER TABLE orders ADD PRIMARY KEY (order_id);
ALTER TABLE products ADD PRIMARY KEY (product_id);
ALTER TABLE staffs ADD PRIMARY KEY (staff_id);
ALTER TABLE stores ADD PRIMARY KEY (store_id);


-- ------------------ ESTABLISHING FOREIGN KEY RELATIONSHIPS ------------------
-- Link order_items table to orders and products tables
ALTER TABLE order_items  
ADD CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES orders(order_id),  
ADD CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id);


-- Link orders table to customers, stores, and staffs tables
ALTER TABLE orders
ADD CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),  
ADD CONSTRAINT fk_stores FOREIGN KEY (store_id) REFERENCES stores(store_id),
ADD CONSTRAINT fk_staff FOREIGN KEY (staff_id) REFERENCES staffs(staff_id);


-- Link products table to brands and categories tables
ALTER TABLE products
ADD CONSTRAINT fk_brand FOREIGN KEY (brand_id) REFERENCES brands(brand_id),
ADD CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES categories(category_id);


-- Link staffs table to stores table
ALTER TABLE staffs
ADD FOREIGN KEY (store_id) REFERENCES stores(store_id);


-- Link stocks table to stores and products tables
ALTER TABLE stocks
ADD FOREIGN KEY fK_store (store_id) REFERENCES stores(store_id),
ADD FOREIGN KEY fK_product (product_id) REFERENCES products(product_id);

-- ======================= PROJECT BUSINESS QUESTIONS =======================  
-- BELOW ARE SOME KEY BUSINESS QUESTIONS I IDENTIFIED AND SOLVED IN THIS PROJECT.  
-- THEY AIM TO PROVIDE INSIGHTS INTO SALES PERFORMANCE, PRODUCT POPULARITY, AND STORE-LEVEL ANALYSIS.  

use bike_store;

-- 1. WHAT IS THE TOTAL SALES AMOUNT?
SELECT ROUND(SUM(quantity * list_price * (1 - discount)),2) AS total_sales
FROM order_items;

-- 2. WHAT IS THE TOTAL QUANTITY SOLD
SELECT SUM(quantity) AS total_quantity_sold
FROM order_items;

-- 3. WHAT ARE THE TOP 5 MOST POPULAR PRODUCTS BASED ON TOTAL QUANTITY SOLD?  
SELECT p.product_name,
	SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
JOIN products p
USING (product_id)
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- 4. WHAT ARE THE TOTAL SALES BY EACH STORE?
SELECT s.store_name,
	ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2) AS total_sales
FROM order_items oi
JOIN orders o USING (order_id)
JOIN stores s USING (store_id)
GROUP BY s.store_name;

-- 5. WHAT IS THE TOTAL QUANTITY SOLD BY EACH STORE?  
SELECT s.store_name,
	SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
JOIN orders o USING (order_id)
JOIN stores s USING (store_id)
GROUP BY s.store_name;

-- 6. WHO ARE THE TOP 5 CUSTOMERS BASED ON QUANTITY PURCHASED?  
SELECT c.customer_id, c.first_name, c.last_name,
    SUM(oi.quantity) AS quantity
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY quantity DESC
LIMIT 5;

-- 7. WHO ARE THE TOP 5 CUSTOMERS BASED ON TOTAL SALES?
SELECT c.customer_id, c.first_name, c.last_name,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2) AS total_sales
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_sales DESC
LIMIT 5;

-- 8. WHO IS THE TOP SALESPERSON BASED ON TOTAL SALES?  
SELECT s.first_name, s.last_name,
	ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2) AS total_sales
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN staffs s ON o.staff_id = s.staff_id
GROUP BY s.first_name, s.last_name
ORDER BY total_sales DESC
LIMIT 1;

-- 9. WHAT ARE THE TOP 5 MOST POPULAR PRODUCTS BASED ON TOTAL SALES? 
SELECT p.product_name,
	ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2) AS total_sales
FROM order_items oi
JOIN products p
USING (product_id)
GROUP BY p.product_name
ORDER BY total_sales DESC
LIMIT 5;

-- 10. WHAT IS THE MOST SOLD PRODUCT BY BRAND?  
SELECT b.brand_name, p.product_name,
	ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN brands b ON p.brand_id = b.brand_id
GROUP BY p.product_name, b.brand_name
ORDER BY total_sales DESC
LIMIT 5;

-- 11. WHAT IS THE MOST SOLD PRODUCT CATEGORY?  
SELECT c.category_name,
	ROUND(SUM(oi.quantity * oi.list_price* (1 - oi.discount)),2) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_sales DESC
LIMIT 1;

-- 12. HOW MANY PRODUCTS ARE THERE IN EACH CATEGORY?
SELECT c.category_name,
	COUNT(DISTINCT p.product_name) AS total_products
FROM products p
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_products DESC;

-- 13. WHAT IS THE AVERAGE SHIPPING TIME IN DAYS?
SELECT ROUND(AVG(DATEDIFF(shipped_date, order_date))) AS avg_shipping_days
FROM orders
WHERE shipped_date IS NOT NULL;

-- 14. WHAT IS THE TOTAL STOCK QUANTITY AVAILABLE FOR EACH PRODUCT IN EACH STORE?
SELECT str.store_name, p.product_name,
	SUM(quantity) AS available_qty
FROM stocks stk
JOIN stores str ON stk.store_id = str.store_id
JOIN products p ON stk.product_id = p.product_id
GROUP BY str.store_name, p.product_name
ORDER BY str.store_name, available_qty;

-- 15. HOW MANY CUSTOMERS ARE THERE IN EACH CITY & STATE?
SELECT c.city, c.state, COUNT(customer_id) AS num_of_customers
FROM customers c
GROUP BY c.city, c.state
ORDER BY c.state;

-- 16. WHAT ARE TOTAL SALES IN EACH STATE?
SELECT c.state,
	ROUND(SUM(oi.quantity * oi.list_price * (1 - discount)),2) total_sales
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.state
ORDER BY total_sales DESC;

-- 17. WHAT ARE TOTAL SALES IN EACH CITY?
SELECT c.city,
	ROUND(SUM(oi.quantity * oi.list_price * (1 - discount)),2) total_sales
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY total_sales DESC;
