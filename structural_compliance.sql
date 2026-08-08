-- ==========================================================
-- PROJECT: IS 456 Structural Compliance Database
-- AUTHOR: Pratik Priyadarshi Parida
-- DESCRIPTION: MySQL database automating structural cover 
--              checks and effective depth calculations.
-- ==========================================================

-- ----------------------------------------------------------
-- 1. DATABASE INITIALIZATION
-- ----------------------------------------------------------
CREATE DATABASE IF NOT EXISTS structural_compliance_db;
USE structural_compliance_db;

-- ----------------------------------------------------------
-- 2. TABLE CREATION (SCHEMA)
-- ----------------------------------------------------------
CREATE TABLE IS_References (
    reference_id VARCHAR(50) PRIMARY KEY, 
    parameter_name VARCHAR(100),
    min_limit DECIMAL(10,4),
    max_limit DECIMAL(10,4),
    unit VARCHAR(20)
);

CREATE TABLE RCC_Beams (
    beam_id INT AUTO_INCREMENT PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    total_depth_mm DECIMAL(8,2) NOT NULL,
    width_mm DECIMAL(8,2) NOT NULL,
    clear_cover_mm DECIMAL(8,2) NOT NULL,
    rebar_diameter_mm DECIMAL(8,2) NOT NULL,
    reinforcement_layers INT DEFAULT 1, 
    concrete_grade VARCHAR(10)
);

CREATE TABLE Design_Audits (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    beam_id INT,
    calculated_effective_depth_mm DECIMAL(8,2),
    compliance_status VARCHAR(10),
    audit_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (beam_id) REFERENCES RCC_Beams(beam_id)
);

-- ----------------------------------------------------------
-- 3. IS 456 REFERENCE DATA INSERTION
-- ----------------------------------------------------------
INSERT INTO IS_References (reference_id, parameter_name, min_limit, max_limit, unit)
VALUES ('IS_456_Cl_26_4_2', 'Nominal Cover for Moderate Exposure', 30.0, NULL, 'mm');

-- ----------------------------------------------------------
-- 4. BUSINESS LOGIC (TRIGGERS)
-- ----------------------------------------------------------
DELIMITER //

CREATE TRIGGER trg_audit_beam
AFTER INSERT ON RCC_Beams
FOR EACH ROW
BEGIN
    DECLARE eff_depth DECIMAL(8,2);
    DECLARE spacer_size DECIMAL(8,2) DEFAULT 25.0; 
    DECLARE required_cover DECIMAL(10,4);
    DECLARE stat VARCHAR(10);

    -- Calculate effective depth based on reinforcement layers
    IF NEW.reinforcement_layers = 1 THEN
        SET eff_depth = NEW.total_depth_mm - NEW.clear_cover_mm - (NEW.rebar_diameter_mm / 2.0);
    ELSEIF NEW.reinforcement_layers = 2 THEN
        SET eff_depth = NEW.total_depth_mm - NEW.clear_cover_mm - NEW.rebar_diameter_mm - (spacer_size / 2.0);
    END IF;

    -- Fetch the required minimum cover
    SELECT min_limit INTO required_cover
    FROM IS_References
    WHERE reference_id = 'IS_456_Cl_26_4_2';

    -- Evaluate Compliance
    IF NEW.clear_cover_mm >= required_cover THEN
        SET stat = 'PASS';
    ELSE
        SET stat = 'FAIL';
    END IF;

    -- Log the audit 
    INSERT INTO Design_Audits (beam_id, calculated_effective_depth_mm, compliance_status)
    VALUES (NEW.beam_id, eff_depth, stat);
END;
//

DELIMITER ;

-- ----------------------------------------------------------
-- 5. TEST DATA INSERTION
-- ----------------------------------------------------------
-- Compliant Beam (35mm cover >= 30mm)
INSERT INTO RCC_Beams (project_name, total_depth_mm, width_mm, clear_cover_mm, rebar_diameter_mm, reinforcement_layers)
VALUES ('Academic Block 1', 450.0, 250.0, 35.0, 16.0, 1);

-- Non-Compliant Beam (25mm cover < 30mm)
INSERT INTO RCC_Beams (project_name, total_depth_mm, width_mm, clear_cover_mm, rebar_diameter_mm, reinforcement_layers)
VALUES ('Academic Block 2', 450.0, 250.0, 25.0, 16.0, 1);