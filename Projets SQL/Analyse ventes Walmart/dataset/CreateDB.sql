CREATE TABLE sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    vat DECIMAL(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date TIMESTAMP NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT,
    gross_income DECIMAL(12, 4),
    rating DECIMAL(3,1)
);

\copy sales FROM 'WalmartSalesData.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';

ALTER TABLE salesADD COLUMN time_of_day VARCHAR(30);

UPDATE sales
SET time_of_day = CASE
    WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'morning'
    WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'afternoon'
    ELSE 'evening'
END;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = TRIM(TO_CHAR(date, 'Day'));


ALTER TABLE sales ADD COLUMN month_name VARCHAR(15);

UPDATE sales
SET month_name = TRIM(TO_CHAR(date, 'Month'));


