-- =======================================
-- Raw Table
-- =======================================

-- Table: customers
CREATE TABLE COWJACKET.RAW.CUSTOMERS (
    customer_id NUMBER IDENTITY(1, 1),
    full_name VARCHAR(50) NOT NULL,
    email VARCHAR(50) UNIQUE,
    join_date DATE NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id)
);


-- Table: products
CREATE TABLE COWJACKET.RAW.PRODUCTS (
    product_id NUMBER IDENTITY(1, 1),
    product_name VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price INTEGER NOT NULL,
    CONSTRAINT pk_products PRIMARY KEY (product_id)
);


-- Table: orders
CREATE TABLE COWJACKET.RAW.ORDERS (
    order_id NUMBER IDENTITY(1, 1),
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    total_amount INTEGER NOT NULL,
    CONSTRAINT pk_orders PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customer 
        FOREIGN KEY (customer_id)
        REFERENCES COWJACKET.RAW.CUSTOMERS(customer_id)
);


-- Table: order_items
CREATE TABLE COWJACKET.RAW.ORDER_ITEMS (
    order_item_id NUMBER IDENTITY(1, 1),
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    line_total INTEGER NOT NULL,
    CONSTRAINT pk_orders_items PRIMARY KEY (order_item_id),
    CONSTRAINT fk_items_order
        FOREIGN KEY (order_id) 
        REFERENCES COWJACKET.RAW.ORDERS(order_id),
    CONSTRAINT fk_items_product
        FOREIGN KEY (product_id)
        REFERENCES COWJACKET.RAW.PRODUCTS(product_id)
);


-- Table: loyalty_points
CREATE TABLE COWJACKET.RAW.LOYALTY_POINTS (
    loyalty_id NUMBER IDENTITY(1, 1),
    customer_id INTEGER NOT NULL,
    points_earned INTEGER NOT NULL,
    transaction_date DATE NOT NULL,
    source VARCHAR(50) NOT NULL,
    CONSTRAINT pk_loyalty_points PRIMARY KEY (loyalty_id),
    CONSTRAINT fk_loyalty_customer
        FOREIGN KEY (customer_id)
        REFERENCES COWJACKET.RAW.CUSTOMERS(customer_id)
);


-- =======================================
-- Metadata Table
-- =======================================

-- Table: dbt run logs
CREATE TABLE IF NOT EXISTS COWJACKET.OBSERVABILITY.DBT_RUN_LOGS (
    logged_at TIMESTAMP_NTZ,
    invocation_id STRING,
    run_started_at TIMESTAMP_NTZ,
    environment STRING,
    target_name STRING,
    target_database STRING,
    target_schema STRING,
    target_warehouse STRING,
    node_id STRING,
    resource_type STRING,
    model_name STRING,
    materialization STRING,
    status STRING,
    execution_time_seconds FLOAT,
    rows_affected NUMBER,
    message STRING
);