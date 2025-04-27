DROP SCHEMA IF EXISTS airport CASCADE;

CREATE SCHEMA airport;

CREATE TABLE airport.faa_test (
  test_number INT PRIMARY KEY,
  name TEXT,
  max_score INT
);
CREATE TABLE airport.airplane_model (
  model_number TEXT PRIMARY KEY,
  capacity INT,
  weight INT
);
CREATE TABLE airport.airplane (
  reg_number TEXT PRIMARY KEY,
  model_number TEXT NOT NULL,
  FOREIGN KEY (model_number) REFERENCES airport.airplane_model (model_number)
);
CREATE TABLE airport.employee (
  ssn VARCHAR(9) PRIMARY KEY,
  name TEXT,
  password TEXT,
  address TEXT,
  phone TEXT,
  salary NUMERIC(10, 2)
);
CREATE TABLE airport.technician (
  ssn VARCHAR(9) PRIMARY KEY,
  FOREIGN KEY (ssn) REFERENCES airport.employee (ssn)
);
CREATE TABLE airport.manager (
  ssn VARCHAR(9) PRIMARY KEY,
  FOREIGN KEY (ssn) REFERENCES airport.employee (ssn)
);
CREATE TABLE airport.atc (
  ssn VARCHAR(9) PRIMARY KEY,
  FOREIGN KEY (ssn) REFERENCES airport.employee (ssn)
);
CREATE TABLE airport.test_event (
  test_number INT NOT NULL,
  ssn VARCHAR(9) NOT NULL,
  reg_number TEXT NOT NULL,
  date DATE NOT NULL,
  duration INTERVAL,
  score INT,
  PRIMARY KEY (test_number, ssn, reg_number, date),
  FOREIGN KEY (test_number) REFERENCES airport.faa_test (test_number),
  FOREIGN KEY (reg_number) REFERENCES airport.airplane (reg_number),
  FOREIGN KEY (ssn) REFERENCES airport.technician (ssn)
);
CREATE TABLE airport.expert (
  ssn VARCHAR(9) NOT NULL,
  model_number TEXT NOT NULL,
  PRIMARY KEY (ssn, model_number),
  FOREIGN KEY (ssn) REFERENCES airport.technician (ssn),
  FOREIGN KEY (model_number) REFERENCES airport.airplane_model (model_number)
);
CREATE OR REPLACE PROCEDURE airport.insert_expert(
    p_ssn VARCHAR(9),
    p_model_number TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    model_exists BOOLEAN;
BEGIN
    -- Check if model number exists in airplane_model table
    SELECT EXISTS(
        SELECT 1 
        FROM airport.airplane_model 
        WHERE model_number = p_model_number
    ) INTO model_exists;
    
    -- If model exists, insert into expert table
    IF model_exists THEN
        INSERT INTO airport.expert(ssn, model_number)
        VALUES (p_ssn, p_model_number);
        
        RAISE NOTICE 'Inserted expert SSN % model %', p_ssn, p_model_number;
    ELSE
        RAISE EXCEPTION 'Error: Model number % does not exist', p_model_number;
    END IF;
END;
$$;