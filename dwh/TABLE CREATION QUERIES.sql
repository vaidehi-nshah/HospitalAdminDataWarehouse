----------------------------------------
----------  DATA WAREHOUSING  ----------
----------------------------------------

---------- DIMENSION TABLES ----------
CREATE TABLE dim_patient_data (
    patient_id NUMERIC(5) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(100) NOT NULL,
    dob DATE NOT NULL,
    gender gender_enum NOT NULL,
    contact NUMERIC(10) NOT NULL,
    blood_group blood_group_enum NOT NULL
);

CREATE TABLE dim_doctors (
    doctor_id VARCHAR(7) PRIMARY KEY CHECK (doctor_id ~ '^DOC\d{4}$') NOT NULL,
    doctor_name VARCHAR (40) NOT NULL, 
    gender gender_enum NOT NULL,
    contact_number VARCHAR(15),
    specialty VARCHAR(50)
);

CREATE TABLE dim_nurses (
    nurse_id VARCHAR(7) PRIMARY KEY CHECK (nurse_id ~ '^NUR\d{4}$') NOT NULL,
    nurse_name VARCHAR(40) NOT NULL,
    gender gender_enum NOT NULL,
    contact_number VARCHAR(15)
);

CREATE TABLE dim_diagnosis (
    diagnosis_id VARCHAR(8) PRIMARY KEY,
    patient_id NUMERIC(5) NOT NULL,
    doctor_id VARCHAR (7) NOT NULL,
    nurse_id VARCHAR(7) NOT NULL,
    visit_date DATE NOT NULL,
    symptoms VARCHAR(100) NOT NULL,
    case_details VARCHAR(200),
    clinical_notes VARCHAR(200),
    FOREIGN KEY (patient_id) REFERENCES dim_patient_data(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES dim_doctors(doctor_id),
    FOREIGN KEY (nurse_id) REFERENCES dim_nurses(nurse_id)
);

CREATE TABLE dim_medical_history (
    mh_id INT PRIMARY KEY,
    patient_id NUMERIC(5) NOT NULL,
    surgeries VARCHAR(40),
    allergies VARCHAR(40),
    medical_conditions VARCHAR(100),
    FOREIGN KEY (patient_id) REFERENCES dim_patient_data(patient_id)
);

CREATE TABLE dim_lab_results (
    lr_id INT PRIMARY KEY,
    diagnosis_id VARCHAR(8) NOT NULL,
    tests VARCHAR(200) NOT NULL,
    test_results VARCHAR(100) NOT NULL,
    FOREIGN KEY (diagnosis_id) REFERENCES dim_diagnosis(diagnosis_id)
);

CREATE TABLE dim_outcomes (
    o_id INT PRIMARY KEY,
    treatment_id NUMERIC(8) NOT NULL,
    recovery_status VARCHAR(10) NOT NULL,
    FOREIGN KEY (treatment_id) REFERENCES fact_treatment(treatment_id)
);


---------- FACT TABLES ----------
CREATE TABLE fact_treatment (
    treatment_id NUMERIC(8) PRIMARY KEY,
    diagnosis_id VARCHAR(8) NOT NULL,
    begin_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (diagnosis_id) REFERENCES dim_diagnosis(diagnosis_id)
);

CREATE TABLE fact_insurance_claims (
    insurance_id INT PRIMARY KEY,
    patient_id NUMERIC(5) NOT NULL,
    provider_name VARCHAR(8) NOT NULL,
    insurance_type VARCHAR(20) NOT NULL,
    expiry DATE NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES dim_patient_data(patient_id)
);

CREATE TABLE fact_vital_signs (
    vs_id INT,
    diagnosis_id VARCHAR(8) NOT NULL,
    blood_pressure INT NOT NULL,
    oxygen INT NOT NULL,
    temperature DECIMAL(4, 2) NOT NULL,
    heart_rate INT NOT NULL,
    weight DECIMAL(4, 2) NOT NULL,
    height INT NOT NULL,
    bmi DECIMAL(5, 2),
    FOREIGN KEY (diagnosis_id) REFERENCES dim_diagnosis(diagnosis_id)
);

CREATE TABLE fact_billing_info (
    treatment_id NUMERIC(8) NOT NULL,
    bill_number INT NOT NULL,
    bill_date DATE NOT NULL,
    amt NUMERIC(10, 2) NOT NULL,
    total_amt NUMERIC(10, 2),
    payment_type VARCHAR(20) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    payment_date DATE,
    FOREIGN KEY (treatment_id) REFERENCES fact_treatment(treatment_id)
);