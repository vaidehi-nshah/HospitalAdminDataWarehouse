----------------------------------------
----------   CREATING TYPES   ----------
----------------------------------------
CREATE TYPE gender_enum AS ENUM ('M', 'F', 'O');
CREATE TYPE blood_group_enum AS ENUM ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-');

----------------------------------------
---------- CREATING SEQUENCES ----------
----------------------------------------
CREATE SEQUENCE patient_id_sequence
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 99999
    NO CYCLE;

CREATE SEQUENCE treatment_id_sequence
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 99999999
    NO CYCLE;

CREATE SEQUENCE medicine_id_sequence
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 9999999
    NO CYCLE;

CREATE SEQUENCE bill_number
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 99999999
    NO CYCLE;

CREATE SEQUENCE seq_mh_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 99999999
    NO CYCLE;

CREATE SEQUENCE seq_vs_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 99999999
    NO CYCLE;

CREATE SEQUENCE seq_lr_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 99999999
    NO CYCLE;

CREATE SEQUENCE seq_o_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 99999999
    NO CYCLE;


----------------------------------------
----------  CREATING  TABLES  ----------
----------------------------------------

-------------------- PATIENT_DATA --------------------
CREATE TABLE patient_data (
    patient_id NUMERIC(5) NOT NULL,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(100) NOT NULL,
    dob DATE NOT NULL,    
    gender gender_enum NOT NULL,
    contact NUMERIC(10) NOT NULL,
    blood_group blood_group_enum NOT NULL,
    CONSTRAINT pd_patient_id_pk PRIMARY KEY (patient_id)
);

-------------------- MEDICAL_HISTORY --------------------
CREATE TABLE medical_history (
    mh_id INT NOT NULL,
    patient_id NUMERIC(5) NOT NULL,
    surgeries VARCHAR(40),
    allergies VARCHAR(40),
    medical_conditions VARCHAR(100),
    CONSTRAINT mh_mh_id_pk PRIMARY KEY (mh_id),
    CONSTRAINT mh_patient_id_fk FOREIGN KEY (patient_id) REFERENCES patient_data(patient_id)
);

-------------------- TESTS --------------------
CREATE TABLE tests (
    test_id INT NOT NULL,
    test_nm VARCHAR(100) NOT NULL, 
    CONSTRAINT t_test_id_pk PRIMARY KEY (test_id)
);

-------------------- DOCTORS --------------------
CREATE TABLE doctors (
    doctor_id VARCHAR(7) PRIMARY KEY CHECK (doctor_id ~ '^DOC\d{4}$') NOT NULL,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    gender gender_enum NOT NULL,
    contact_number VARCHAR(15),
    specialty VARCHAR(50)
);

-------------------- NURSES --------------------
CREATE TABLE nurses (
    nurse_id VARCHAR(7) PRIMARY KEY CHECK (nurse_id ~ '^NUR\d{4}$') NOT NULL,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    gender gender_enum NOT NULL,
    contact_number VARCHAR(15)
);


-------------------- DIAGNOSIS --------------------
CREATE TABLE diagnosis (
    diagnosis_id VARCHAR(8) PRIMARY KEY CHECK (diagnosis_id ~ '^\d{3}[A-Za-z]{3}\d[A-Za-z]$'),
    patient_id NUMERIC(5) NOT NULL,
    doctor_id VARCHAR (7) NOT NULL,
    nurse_id VARCHAR(7) NOT NULL, 
    visit_date DATE NOT NULL,
    symptoms VARCHAR(100)  NOT NULL,
    case_details VARCHAR(200),
    clinical_notes VARCHAR(200), 
    CONSTRAINT d_patient_id_fk FOREIGN KEY (patient_id) REFERENCES patient_data(patient_id),
    CONSTRAINT d_doctor_id_fk FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
    CONSTRAINT d_nurse_id_fk FOREIGN KEY (nurse_id) REFERENCES nurses(nurse_id)
);

-------------------- DIAGNODID_BRIDGE_TESTS --------------------
CREATE TABLE diagnosis_bridge_tests (
    diagnosis_id VARCHAR(8) NOT NULL,
    test_id INT NOT NULL,
    CONSTRAINT dbt_diagnosis_id FOREIGN KEY (diagnosis_id) REFERENCES diagnosis(diagnosis_id),
    CONSTRAINT dbt_test_id FOREIGN KEY (test_id) REFERENCES tests(test_id)
)

-------------------- TREAMTMENT --------------------
CREATE TABLE treatment (
    treatment_id NUMERIC(8) NOT NULL, 
    diagnosis_id VARCHAR(8) NOT NULL,
    begin_date DATE NOT NULL,
    end_date DATE NOT NULL,
	CONSTRAINT t_treatment_id PRIMARY KEY (treatment_id),
    CONSTRAINT t_diagnosis_id_fk FOREIGN KEY (diagnosis_id) REFERENCES diagnosis(diagnosis_id)
);

-------------------- MEDICINES --------------------
CREATE TABLE medicines (
    medicine_id NUMERIC(7) NOT NULL,
    medicine_name VARCHAR(20) NOT NULL, 
    times_a_day INT NOT NULL,
    extra_doc_notes VARCHAR(200),
    CONSTRAINT m_medicine_id_pk PRIMARY KEY (medicine_id)
)

-------------------- TREATMENT_BRIDGE_MEDS --------------------
CREATE TABLE treatment_bridge_meds (
    treatment_id NUMERIC(8) NOT NULL,
    medicine_id NUMERIC(7) NOT NULL, 
	CONSTRAINT tbm_treatment_id FOREIGN KEY (treatment_id) REFERENCES treatment(treatment_id),
    CONSTRAINT tbm_medicine_id FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id)
)

-------------------- OUTCOMES --------------------
CREATE TABLE outcomes (
    o_id INT NOT NULL,
    treatment_id NUMERIC(8) NOT NULL,
    recovery_status VARCHAR(10) CHECK (LOWER(recovery_status) IN ('critical', 'stable', 'recovered', 'improving')) NOT NULL,
    CONSTRAINT o_o_id_pk PRIMARY KEY (o_id),
    CONSTRAINT o_treatment_id_fk FOREIGN KEY (treatment_id) REFERENCES treatment(treatment_id)
);

-------------------- VITAL_SIGNS --------------------
CREATE TABLE vital_signs (
    vs_id INT NOT NULL,
    diagnosis_id VARCHAR(8) NOT NULL,
    blood_pressure INT NOT NULL,
    oxygen INT NOT NULL,
    temperature DECIMAL(4, 2) NOT NULL,
    heart_rate INT NOT NULL,
    weight DECIMAL(4, 2) NOT NULL,
    height INT NOT NULL,
    CONSTRAINT vs_vs_id_pk PRIMARY KEY (vs_id),
    CONSTRAINT vs_diagnosis_id_fk FOREIGN KEY (diagnosis_id) REFERENCES diagnosis(diagnosis_id)
);

-------------------- LAB_RESULTS --------------------
CREATE TABLE lab_results (
    lr_id INT NOT NULL,
    diagnosis_id VARCHAR(8) NOT NULL,
    tests VARCHAR(200) NOT NULL,
    test_results VARCHAR(100) NOT NULL,
    CONSTRAINT lr_lr_id_pk PRIMARY KEY (lr_id),
    CONSTRAINT lr_diagnosis_id_fk FOREIGN KEY (diagnosis_id) REFERENCES diagnosis(diagnosis_id)
);

-------------------- INSURANCE_CLAIMS --------------------
CREATE TABLE insurance_claims (
    insurance_id INT NOT NULL,
    patient_id NUMERIC(5) NOT NULL,
    provider_name VARCHAR(8) NOT NULL,
    insurance_type VARCHAR(20) CHECK (LOWER(insurance_type) IN ('bronze', 'silver', 'gold', 'platinum')) NOT NULL,
    expiry DATE NOT NULL, 
    CONSTRAINT ic_insurance_id_pk PRIMARY KEY (insurance_id),
    CONSTRAINT ic_patient_id_fk FOREIGN KEY (patient_id) REFERENCES patient_data(patient_id)
);

-------------------- BILLING_INFO --------------------
CREATE TABLE billing_info (
    treatment_id NUMERIC(8) NOT NULL,
	bill_number INT NOT NULL,
    bill_date DATE NOT NULL,
    amt NUMERIC(10, 2) NOT NULL,
    payment_type VARCHAR(20) NOT NULL,
    payment_status VARCHAR(20) CHECK (LOWER(payment_status) IN ('pending', 'overdue', 'paid')) NOT NULL,
    payment_date DATE NOT NULL,
    CONSTRAINT bi_bill_number PRIMARY KEY (bill_number), 
    CONSTRAINT bi_treatment_id_fk FOREIGN KEY (treatment_id) REFERENCES treatment(treatment_id)
);

----------------------------------------
----------  CREATING INDEXES  ----------
----------------------------------------
CREATE INDEX I_diagnosis_id ON diagnosis(diagnosis_id);
CREATE INDEX I_patient_id ON patient_data(patient_id);
CREATE INDEX I_treatment_id ON treatment(treatment_id);
CREATE INDEX I_medicine_id ON medicines(medicine_id);  