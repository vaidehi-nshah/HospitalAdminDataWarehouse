-- checking inserts 
SELECT * FROM patient_data 
SELECT * FROM diagnosis 
SELECT * FROM medical_history
SELECT * FROM tests 
SELECT * FROM doctors 
SELECT * FROM nurses 
SELECT * FROM treatment 
SELECT * FROM medicines 
SELECT * FROM outcomes 
SELECT * FROM lab_results
SELECT * FROM vital_signs 
SELECT * FROM insurance_claims 
SELECT * FROM billing_info 
SELECT * FROM diagnosis_bridge_tests 
SELECT * FROM treatment_bridge_meds 

-- delete from tables 
DELETE FROM tests 
DELETE FROM doctors 
DELETE FROM nurses 
DELETE FROM diagnosis_bridge_tests 
DELETE FROM treatment 
DELETE FROM medicines 
DELETE FROM treatment_bridge_meds 
DELETE FROM outcomes 
DELETE FROM lab_results  
DELETE FROM insurance_claims 
-- for retaining the tables back after transformations 
DELETE FROM patient_data
DELETE FROM diagnosis 
DELETE FROM billing_info 
DELETE FROM vital_signs 
ALTER TABLE diagnosis DROP COLUMN doctor_name;
ALTER TABLE billing_info DROP COLUMN total_amt;
ALTER TABLE vital_signs DROP COLUMN bmi

DROP SEQUENCE seq_vs_id
