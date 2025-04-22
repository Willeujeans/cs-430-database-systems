CREATE DATABASE airport;

CREATE TABLE airplane (
    ssn varchar(9) PRIMARY KEY,
    reg_number text,
    model_number text,
    FOREIGN KEY (model_number) REFERENCES airplane_model(model_number)
);

CREATE TABLE employee (
    ssn varchar(9) PRIMARY KEY,
    name text,
    password text,
    address text,
    phone text,
    salary numeric(100, 2),
);

CREATE TABLE expert (
    -- Composite Key{
    ssn varchar(9) NOT NULL,
    model_number text NOT NULL,
    -- }Composite Key
    PRIMARY KEY (ssn, model_number),
);

CREATE TABLE airplane_model (
    model_number text PRIMARY KEY,
    capacity int,
    weight int,
);

CREATE TABLE employee (
    ssn varchar(9) PRIMARY KEY,
);

CREATE TABLE test_event (
    -- Composite Key{
    test_number int NOT NULL,
    ssn varchar(9) NOT NULL,
    reg_number text NOT NULL,
    test_date date NOT NULL,
    -- }Composite Key
    duration int,
    score int,
    PRIMARY KEY (test_number, ssn, reg_number, test_date),
);

CREATE TABLE faa_test (
    test_number int PRIMARY KEY,
    name text,
    max_score int,
);

CREATE TABLE technician (
    ssn varchar(9) PRIMARY KEY,
);

CREATE TABLE atc (
    ssn varchar(9) PRIMARY KEY,
);


CREATE PROCEDURE InsertTestEvent(
    IN p_test_name text,
    IN p_test_date date
)
AS
BEGIN
    IF p_test_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'test_date cannot be in the future';
    ELSE
        INSERT INTO test_event (test_name, test_date)
        VALUES (p_test_name, p_test_date);
    END IF;
END;