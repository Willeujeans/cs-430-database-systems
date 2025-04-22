-- Removes all previous tables from the schema
DO $$ DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public')
    LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END $$;


CREATE TABLE faa_test (
  test_number INT PRIMARY KEY,
  name TEXT NOT NULL,
  max_score INT
);
CREATE TABLE airplane_model (
  model_number TEXT PRIMARY KEY,
  capacity INT CHECK (capacity > 0),
  weight INT CHECK (weight > 0)
);
CREATE TABLE airplane (
  reg_number TEXT PRIMARY KEY,
  model_number TEXT NOT NULL,
  FOREIGN KEY (model_number) REFERENCES airplane_model (model_number)
);
CREATE TABLE employee (
  ssn VARCHAR(9) PRIMARY KEY,
  name TEXT NOT NULL,
  password TEXT,
  address TEXT,
  phone TEXT,
  salary NUMERIC(10, 2) CHECK (salary > 0)
);
CREATE TABLE technician (
  ssn VARCHAR(9) PRIMARY KEY,
  FOREIGN KEY (ssn) REFERENCES employee (ssn)
);
CREATE TABLE manager (
  ssn VARCHAR(9) PRIMARY KEY,
  FOREIGN KEY (ssn) REFERENCES employee (ssn)
);
CREATE TABLE atc (
  ssn VARCHAR(9) PRIMARY KEY,
  FOREIGN KEY (ssn) REFERENCES employee (ssn)
);
CREATE TABLE test_event (
  test_number INT NOT NULL,
  ssn VARCHAR(9) NOT NULL,
  reg_number TEXT NOT NULL,
  date DATE NOT NULL,
  duration INT CHECK (duration > 0),
  score INT,
  PRIMARY KEY (test_number, ssn, reg_number, date),
  FOREIGN KEY (test_number) REFERENCES faa_test (test_number),
  FOREIGN KEY (reg_number) REFERENCES airplane (reg_number),
  FOREIGN KEY (ssn) REFERENCES technician (ssn)
);
CREATE TABLE expert (
  ssn VARCHAR(9) NOT NULL,
  model_number TEXT NOT NULL,
  PRIMARY KEY (ssn, model_number),
  FOREIGN KEY (ssn) REFERENCES technician (ssn),
  FOREIGN KEY (model_number) REFERENCES airplane_model (model_number)
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
  -- Get max_score from faa_test
  SELECT max_score INTO v_max_score
  FROM faa_test
  WHERE test_number = p_test_number;
  IF p_score > v_max_score THEN
    RAISE EXCEPTION 'Score % exceeds max allowed score % for test %', p_score, v_max_score, p_test_number;
  END IF;
  -- Get airplane model from registration
  SELECT model_number INTO v_plane_model
  FROM airplane
  WHERE reg_number = p_reg_number;
  -- Verify expert qualification
  SELECT model_number INTO v_expert_model
  FROM expert
  WHERE ssn = p_ssn
  AND model_number = v_plane_model;
  IF v_expert_model IS NULL THEN
    RAISE EXCEPTION 'Expert % is not qualified for model %', p_ssn, v_plane_model;
  END IF;
  -- Insert test event
  INSERT INTO test_event (test_number, ssn, reg_number, date, duration, score)
  VALUES (p_test_number, p_ssn, p_reg_number, p_date, p_duration, p_score);
END;
$$ LANGUAGE plpgsql;