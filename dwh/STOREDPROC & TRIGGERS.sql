-----------------------------------------------
---------- STORED PROCS AND TRIGGERS ----------
-----------------------------------------------

---------- PATIENT_DATA ----------
-- insert into dim_patient_data function
CREATE OR REPLACE FUNCTION insert_dim_patient_data()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO dim_patient_data (patient_id, name, address, dob, gender, contact, blood_group)
    VALUES (NEW.patient_id, NEW.name, NEW.address, NEW.dob, NEW.gender, NEW.contact, NEW.blood_group);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- automatic insert 
CREATE TRIGGER after_patient_insert
AFTER INSERT ON patient_data
FOR EACH ROW
EXECUTE FUNCTION insert_dim_patient_data();



---------- DOCTORS ----------
-- insert into dim_doctors function
CREATE OR REPLACE FUNCTION insert_dim_doctors()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO dim_doctors (doctor_id, doctor_name, gender, contact_number, specialty)
    VALUES (NEW.doctor_id, CONCAT(NEW.first_name, ' ', NEW.last_name), NEW.gender, NEW.contact_number, NEW.specialty);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- automatic insert 
CREATE TRIGGER after_doctor_insert
AFTER INSERT ON doctors
FOR EACH ROW
EXECUTE FUNCTION insert_dim_doctors();



---------- NURSES ----------
-- insert into dim_nurses
CREATE OR REPLACE FUNCTION insert_dim_nurses()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO dim_nurses (nurse_id, nurse_name, gender, contact_number)
    VALUES (NEW.nurse_id, CONCAT(NEW.first_name, ' ', NEW.last_name), NEW.gender, NEW.contact_number);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- automatic insert 
CREATE TRIGGER after_nurse_insert
AFTER INSERT ON nurses
FOR EACH ROW
EXECUTE FUNCTION insert_dim_nurses();



---------- DIAGNOSIS ----------
-- insert into dim_diagnosis
CREATE OR REPLACE FUNCTION insert_dim_diagnosis()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO dim_diagnosis (diagnosis_id, patient_id, doctor_id, nurse_id, visit_date, symptoms, case_details, clinical_notes)
    VALUES (NEW.diagnosis_id, NEW.patient_id, NEW.doctor_id, NEW.nurse_id, NEW.visit_date, NEW.symptoms, NEW.case_details, NEW.clinical_notes);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- automatic inserts 
CREATE TRIGGER after_diagnosis_insert
AFTER INSERT ON diagnosis
FOR EACH ROW
EXECUTE FUNCTION insert_dim_diagnosis();



---------- MEDICAL_HISTORY ----------
-- insert into dim_medical_history
CREATE OR REPLACE FUNCTION insert_dim_medical_history()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO dim_medical_history (mh_id, patient_id, surgeries, allergies, medical_conditions)
    VALUES (NEW.mh_id, NEW.patient_id, NEW.surgeries, NEW.allergies, NEW.medical_conditions);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- automatic inserts 
CREATE TRIGGER after_medical_history_insert
AFTER INSERT ON medical_history
FOR EACH ROW
EXECUTE FUNCTION insert_dim_medical_history();



---------- LAB_RESULTS ----------
-- insert into dim_lab_results 
CREATE OR REPLACE FUNCTION insert_dim_lab_results()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO dim_lab_results (lr_id, diagnosis_id, tests, test_results)
    VALUES (NEW.lr_id, NEW.diagnosis_id, NEW.tests, NEW.test_results);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- automatic inserts 
CREATE TRIGGER after_lab_results_insert
AFTER INSERT ON lab_results
FOR EACH ROW
EXECUTE FUNCTION insert_dim_lab_results();



---------- TREATMENT ----------
-- insert into fact_treatment
CREATE OR REPLACE FUNCTION insert_fact_treatment()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO fact_treatment (treatment_id, diagnosis_id, begin_date, end_date)
    VALUES (NEW.treatment_id, NEW.diagnosis_id, NEW.begin_date, NEW.end_date);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- automatic inserts 
CREATE TRIGGER after_treatment_insert
AFTER INSERT ON treatment
FOR EACH ROW
EXECUTE FUNCTION insert_fact_treatment();



---------- OUTCOMES ----------
-- insert into dim_outcomes 
CREATE OR REPLACE FUNCTION insert_dim_outcomes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO dim_outcomes (o_id, treatment_id, recovery_status)
    VALUES (NEW.o_id, NEW.treatment_id, NEW.recovery_status);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- automatic inserts 
CREATE TRIGGER after_outcomes_insert
AFTER INSERT ON outcomes
FOR EACH ROW
EXECUTE FUNCTION insert_dim_outcomes();



---------- INSURANCE_CLAIMS ----------
-- insert into fact_insurance_claims
CREATE OR REPLACE FUNCTION insert_fact_insurance_claims()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO fact_insurance_claims (insurance_id, patient_id, provider_name, insurance_type, expiry)
    VALUES (NEW.insurance_id, NEW.patient_id, NEW.provider_name, NEW.insurance_type, NEW.expiry);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- automatic inserts 
CREATE TRIGGER after_insurance_claims_insert
AFTER INSERT ON insurance_claims
FOR EACH ROW
EXECUTE FUNCTION insert_fact_insurance_claims();



---------- BILLING_INFO ----------
-- insert into fact_billing_info
CREATE OR REPLACE FUNCTION insert_fact_billing_info()
RETURNS TRIGGER AS $$
DECLARE 
	total_amt DECIMAL(10,2);
BEGIN
	total_amt = NEW.amt*1.1;
	
	INSERT INTO fact_billing_info (treatment_id, bill_number, bill_date, amt, total_amt, payment_type, payment_status, payment_date)
    VALUES (NEW.treatment_id, NEW.bill_number, NEW.bill_date, NEW.amt, total_amt, NEW.payment_type, NEW.payment_status, NEW.payment_date);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- automatic inserts 
CREATE TRIGGER before_billing_info_insert
BEFORE INSERT ON billing_info
FOR EACH ROW
EXECUTE FUNCTION insert_fact_billing_info();



---------- VITAL_SIGNS ----------
-- insert into fact_vital_signs
CREATE OR REPLACE FUNCTION insert_fact_vital_signs()
RETURNS TRIGGER AS $$
DECLARE 
	bmi DECIMAL(5,2);
BEGIN
    bmi = NEW.weight / ((NEW.height / 100.0) * (NEW.height / 100.0));
	
    INSERT INTO fact_vital_signs (vs_id, diagnosis_id, blood_pressure, oxygen, temperature, heart_rate, weight, height, bmi)
    VALUES (NEW.vs_id, NEW.diagnosis_id, NEW.blood_pressure, NEW.oxygen, NEW.temperature, NEW.heart_rate, NEW.weight, NEW.height, bmi);
	RETURN NEW; 
END;
$$ LANGUAGE plpgsql;
-- automatic inserts 
CREATE TRIGGER before_vital_signs_insert
BEFORE INSERT ON vital_signs
FOR EACH ROW
EXECUTE FUNCTION insert_fact_vital_signs();



-----------------------------------------------
------- PREVENT DELETION ON DWH TABLES --------
-----------------------------------------------

-- General "DELETION NOT ALLOWED" trigger
CREATE OR REPLACE FUNCTION prevent_delete_function()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Deletion from DWH table is not allowed!';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger for dim_patient_data
CREATE TRIGGER before_patient_deletion
BEFORE DELETE ON dim_patient_data
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_function();

-- Trigger for dim_doctors
CREATE TRIGGER before_doctor_deletion
BEFORE DELETE ON dim_doctors
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_function();

-- Trigger for dim_nurses
CREATE TRIGGER before_nurse_deletion
BEFORE DELETE ON dim_nurses
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_function();

-- Trigger for dim_diagnosis
CREATE TRIGGER before_diagnosis_deletion
BEFORE DELETE ON dim_diagnosis
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_function();

-- Trigger for dim_medical_history
CREATE TRIGGER before_medical_history_deletion
BEFORE DELETE ON dim_medical_history
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_function();

-- Trigger for dim_lab_results
CREATE TRIGGER before_lab_results_deletion
BEFORE DELETE ON dim_lab_results
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_function();

-- Trigger for fact_treatment
CREATE TRIGGER before_treatment_deletion
BEFORE DELETE ON fact_treatment
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_function();

-- Trigger for dim_outcomes
CREATE TRIGGER before_outcomes_deletion
BEFORE DELETE ON dim_outcomes
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_function();

-- Trigger for fact_insurance_claims
CREATE TRIGGER before_insurance_claims_deletion
BEFORE DELETE ON fact_insurance_claims
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_function();

-- Trigger for fact_billing_info
CREATE TRIGGER before_billing_info_deletion
BEFORE DELETE ON fact_billing_info
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_function();

-- Trigger for fact_vital_signs
CREATE TRIGGER before_vital_signs_deletion
BEFORE DELETE ON fact_vital_signs
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_function();
