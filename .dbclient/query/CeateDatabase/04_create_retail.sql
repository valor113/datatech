-- Active: 1790427590514@@127.0.0.1@5432@retail
-- Active: 1790427590514@@127.0.0.1@5432@postgres
--Uloha1
CREATE DATABASE retail;
DROP TABLE IF EXISTS retail_sales;
CREATE Table retail_sales(   
    invoice_no VARCHAR(20),
    stock_code VARCHAR(50),
    description VARCHAR,
    quantity INTEGER,
    invoice_date TIMESTAMP,
    unit_price DECIMAL(10,2),
    customer_id INTEGER,
    country VARCHAR(100)
);
