CREATE DATABASE airport;


-- Plane Tables --
CREATE TABLE faa_test (
    test_number INT PRIMARY KEY,
    name TEXT NOT NULL,
    max_score INT,
);

CREATE TABLE airplane (
    reg_number TEXT PRIMARY KEY,
    model_number TEXT NOT NULL,
    FOREIGN KEY (model_number) REFERENCES airplane_model(model_number)
);

CREATE TABLE airplane_model (
    model_number TEXT PRIMARY KEY,
    capacity INT CHECK (capacity > 0),
    weight INT CHECK (weight > 0),
);

CREATE TABLE test_event (
    test_number INT NOT NULL,
    ssn VARCHAR(9) NOT NULL,
    reg_number TEXT NOT NULL,
    date DATE NOT NULL,
    duration INT CHECK (duration > 0),
    score INT CHECK,
    PRIMARY KEY (test_number, ssn, reg_number, date),
    FOREIGN KEY (test_number) REFERENCES faa_test(test_number),
    FOREIGN KEY (ssn) REFERENCES expert(ssn),
    FOREIGN KEY (reg_number) REFERENCES airplane(reg_number)
);


-- Employee Tables --
CREATE TABLE employee (
    ssn VARCHAR(9) PRIMARY KEY,
    name TEXT NOT NULL,
    password TEXT,
    address TEXT,
    phone TEXT,
    salary numeric(100, 2) CHECK (salary > 0),
);

-- Inherits from employee
CREATE TABLE manager (
    ssn VARCHAR(9) PRIMARY KEY,
    FOREIGN KEY (ssn) REFERENCES employee(ssn)
);

-- Inherits from employee
CREATE TABLE technician (
    ssn VARCHAR(9) PRIMARY KEY,
    FOREIGN KEY (ssn) REFERENCES employee(ssn)
);

-- Inherits from technician
CREATE TABLE expert (
    ssn VARCHAR(9) NOT NULL,
    model_number TEXT NOT NULL,
    PRIMARY KEY (ssn, model_number),
    FOREIGN KEY (model_number) REFERENCES airplane_model(model_number),
    FOREIGN KEY (ssn) REFERENCES technician(ssn)
);

-- Inherits from employee
CREATE TABLE atc (
    ssn VARCHAR(9) PRIMARY KEY,
    FOREIGN KEY (ssn) REFERENCES employee(ssn)
);


-- Procedures --
CREATE PROCEDURE InsertTestEvent(
    IN p_test_name TEXT,
    IN p_date DATE
)
AS
BEGIN
    IF p_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'date cannot be in the future';
    ELSE
        INSERT INTO test_event (test_name, date)
        VALUES (p_test_name, p_date);
    END IF;
END;