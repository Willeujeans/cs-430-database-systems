CREATE DATABASE airport;


-- Plane Tables --
CREATE TABLE faa_test (
    test_number INT PRIMARY KEY,
    name TEXT NOT NULL,
    max_score INT
);

CREATE TABLE airplane (
    reg_number TEXT PRIMARY KEY,
    model_number TEXT NOT NULL,
    FOREIGN KEY (model_number) REFERENCES airplane_model(model_number)
);

CREATE TABLE airplane_model (
    model_number TEXT PRIMARY KEY,
    capacity INT CHECK (capacity > 0),
    weight INT CHECK (weight > 0)
);

CREATE TABLE test_event (
    test_number INT NOT NULL,
    ssn VARCHAR(9) NOT NULL,
    reg_number TEXT NOT NULL,
    date DATE NOT NULL,
    duration INT CHECK (duration > 0),
    score INT,
    PRIMARY KEY (test_number, ssn, reg_number, date),
    FOREIGN KEY (test_number) REFERENCES faa_test(test_number),
    FOREIGN KEY (reg_number) REFERENCES airplane(reg_number),
    FOREIGN KEY (ssn) REFERENCES technician(ssn)
);


-- Employee Tables --
CREATE TABLE employee (
    ssn VARCHAR(9) PRIMARY KEY,
    name TEXT NOT NULL,
    password TEXT,
    address TEXT,
    phone TEXT,
    salary numeric(100, 2) CHECK (salary > 0)
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
    ssn VARCHAR(9) NOT NULL, -- This will not be unique
    model_number TEXT NOT NULL,
    PRIMARY KEY (ssn, model_number),
    FOREIGN KEY (ssn) REFERENCES technician(ssn),
    FOREIGN KEY (model_number) REFERENCES airplane_model(model_number)
);

-- Inherits from employee
CREATE TABLE atc (
    ssn VARCHAR(9) PRIMARY KEY,
    FOREIGN KEY (ssn) REFERENCES employee(ssn)
);


-- Procedures --

CREATE OR REPLACE PROCEDURE InsertTestEvent(
    IN p_test_number INT,
    IN p_ssn VARCHAR(9),
    IN p_reg_number TEXT,
    IN p_date DATE,
    IN p_duration INT,
    IN p_score INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_max_score INT;  -- Variable to store max_score from faa_test
BEGIN
    -- Check if the date is valid
    IF p_date > CURRENT_DATE THEN
        RAISE EXCEPTION 'Date cannot be in the future';
    END IF;

    -- Compare faa_test max_score with inputed score
    SELECT max_score INTO v_max_score
    FROM faa_test
    WHERE test_number = p_test_number;
    IF p_score > v_max_score THEN
        RAISE EXCEPTION 'Score % exceeds max allowed score % for test %';
    END IF;

    -- use reg_number to get model_number from plane_model
    -- use ssn to get plane_models from expert that is matching the ssn
    -- if the plane_model that is getting tested is the same as the experts plane_model we get with the ssn
    -- if not we cannot accept the test

    INSERT INTO test_event (test_number, ssn, reg_number, date, duration, score)
    VALUES(p_test_number, p_ssn, p_reg_number, p_date, p_duration, p_score);
END;
$$;

