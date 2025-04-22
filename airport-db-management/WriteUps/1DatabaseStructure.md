# Database Structure Creation
`create_database.sql`
This file should create a PostgreSQL database. 

Define the tables, primary keys, and foreign keys.
Ensure all required constraints (e.g., NOT NULL, CHECK, UNIQUE, FOREIGN KEY) are correctly implemented.
Implement at least one stored procedure to enforce a business rule at the database level.

CREATE TABLE OrderItems (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT,
    -- Define composite key here:
    PRIMARY KEY (order_id, product_id)
);

## Database
- employee
- technician
- atc
- expert
- airplane_model
- airplane
- test_event
- faa_test
- manager