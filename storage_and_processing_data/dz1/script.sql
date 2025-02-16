CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(200),
    postcode VARCHAR(10),
    state VARCHAR(50),
    country VARCHAR(50),
    property_valuation INT,
    CONSTRAINT uk_customer_email UNIQUE (email)
);

CREATE TABLE Brands (
    brand_id SERIAL PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL,
    CONSTRAINT uk_brand_name UNIQUE (brand_name)
);

CREATE TABLE Product_Lines (
    product_line_id SERIAL PRIMARY KEY,
    product_line_name VARCHAR(50) NOT NULL,
    CONSTRAINT uk_product_line_name UNIQUE (product_line_name)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    brand_id INT NOT NULL,
    product_line_id INT NOT NULL,
    product_class VARCHAR(50),
    product_size VARCHAR(20),
    list_price DECIMAL(10,2),
    standard_cost DECIMAL(10,2),
    CONSTRAINT fk_brand FOREIGN KEY (brand_id) REFERENCES Brands(brand_id),
    CONSTRAINT fk_product_line FOREIGN KEY (product_line_id) REFERENCES Product_Lines(product_line_id)
);

CREATE TABLE Order_Status (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    CONSTRAINT uk_status_name UNIQUE (status_name)
);

CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    transaction_date TIMESTAMP NOT NULL,
    online_order BOOLEAN DEFAULT FALSE,
    status_id INT NOT NULL,
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES Products(product_id),
    CONSTRAINT fk_status FOREIGN KEY (status_id) REFERENCES Order_Status(status_id)
);

INSERT INTO Order_Status (status_name) VALUES
    ('Approved'),
    ('Cancelled');

INSERT INTO Brands (brand_name) VALUES
    ('Solex'),
    ('Trek Bicycles'),
    ('OHM Cycles'),
    ('Norco Bicycles'),
    ('Giant Bicycles'),
    ('WeareA2B');

INSERT INTO Product_Lines (product_line_name) VALUES
    ('Standard'),
    ('Road'),
    ('Mountain'),
    ('Touring');

INSERT INTO Customers (
    customer_id, 
    first_name, 
    last_name, 
    email, 
    phone, 
    address, 
    postcode, 
    state, 
    country, 
    property_valuation
) VALUES 
    (2950, 'John', 'Doe', 'john.doe@email.com', '1234567890', '123 Main St', '12345', 'CA', 'USA', 1000000),
    (3120, 'Jane', 'Smith', 'jane.smith@email.com', '0987654321', '456 Oak St', '67890', 'NY', 'USA', 1200000);

INSERT INTO Products (
    product_id,
    brand_id,
    product_line_id,
    product_class,
    product_size,
    list_price,
    standard_cost
) VALUES 
    (2, (SELECT brand_id FROM Brands WHERE brand_name = 'Solex'),
        (SELECT product_line_id FROM Product_Lines WHERE product_line_name = 'Standard'),
        'medium', 'medium', 71.49, 53.62),
    (3, (SELECT brand_id FROM Brands WHERE brand_name = 'Trek Bicycles'),
        (SELECT product_line_id FROM Product_Lines WHERE product_line_name = 'Standard'),
        'medium', 'large', 2091.47, 388.92);

INSERT INTO Transactions (
    transaction_id,
    customer_id,
    product_id,
    transaction_date,
    online_order,
    status_id
) VALUES 
    (1, 2950, 2, '2017-02-24 23:00:00', FALSE,
        (SELECT status_id FROM Order_Status WHERE status_name = 'Approved')),
    (2, 3120, 3, '2017-05-20 22:00:00', TRUE,
        (SELECT status_id FROM Order_Status WHERE status_name = 'Approved'));
