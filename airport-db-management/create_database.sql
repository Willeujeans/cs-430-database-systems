DROP SCHEMA IF EXISTS airport CASCADE;

CREATE SCHEMA airport;

CREATE TABLE airport.faa_test (
  test_number INT PRIMARY KEY,
  name TEXT,
  max_score INT
);
CREATE TABLE airport.airplane_model (
  model_number TEXT PRIMARY KEY,
  capacity INT CHECK (capacity > 0),
  weight INT CHECK (weight > 0)
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
  salary NUMERIC(10, 2) CHECK (salary > 0)
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
  date DATE,
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
CREATE OR REPLACE FUNCTION InsertTestEvent (
  p_test_number INT,
  p_ssn VARCHAR(9),
  p_reg_number TEXT,
  p_date DATE,
  p_duration INT,
  p_score INT
) RETURNS void AS $$
DECLARE
  v_max_score INT;
  v_plane_model TEXT;
  v_expert_model TEXT;
BEGIN
  -- Date validation
  IF p_date > CURRENT_DATE THEN
    RAISE EXCEPTION 'Date cannot be in the future';
  END IF;
  -- Get max_score from airport.faa_test
  SELECT max_score INTO v_max_score
  FROM airport.faa_test
  WHERE test_number = p_test_number;
  IF p_score > v_max_score THEN
    RAISE EXCEPTION 'Score % exceeds max allowed score % for test %', p_score, v_max_score, p_test_number;
  END IF;
  -- Get airport.airplane model from registration
  SELECT model_number INTO v_plane_model
  FROM airport.airplane
  WHERE reg_number = p_reg_number;
  -- Verify expert qualification
  SELECT model_number INTO v_expert_model
  FROM airport.expert
  WHERE ssn = p_ssn
  AND model_number = v_plane_model;
  IF v_expert_model IS NULL THEN
    RAISE EXCEPTION 'Expert % is not qualified for model %', p_ssn, v_plane_model;
  END IF;
  -- Insert test event
  INSERT INTO airport.test_event (test_number, ssn, reg_number, date, duration, score)
  VALUES (p_test_number, p_ssn, p_reg_number, p_date, p_duration, p_score);
END;
$$ LANGUAGE plpgsql;