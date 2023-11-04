----------------------------------
---------- PATIENT DATA ----------
----------------------------------

-- to get information about the medicines given to a particular patient and his recovery status from the beginning 
SELECT dp.patient_id, dp.name, dd.visit_date, m.medicine_name, d_o.recovery_status
FROM dim_patient_data dp
JOIN dim_diagnosis dd ON dp.patient_id =dd.patient_id
JOIN fact_treatment ft ON dd.diagnosis_id = ft.diagnosis_id
JOIN treatment_bridge_meds tbm ON tbm.treatment_id = ft.treatment_id
JOIN medicines m ON m.medicine_id = tbm.medicine_id 
JOIN dim_outcomes d_o ON d_o.treatment_id = ft.treatment_id
WHERE dp.patient_id = 34
ORDER BY ft.end_date DESC
LIMIT 10;

SELECT dp.patient_id, dp.name, dd.visit_date, ft.begin_date, ft.end_date, m.medicine_name, d_o.recovery_status
FROM dim_patient_data dp
JOIN dim_diagnosis dd ON dp.patient_id =dd.patient_id
JOIN fact_treatment ft ON dd.diagnosis_id = ft.diagnosis_id
JOIN treatment_bridge_meds tbm ON tbm.treatment_id = ft.treatment_id
JOIN medicines m ON m.medicine_id = tbm.medicine_id 
JOIN dim_outcomes d_o ON d_o.treatment_id = ft.treatment_id
WHERE dp.patient_id = 70
ORDER BY ft.end_date DESC;


----------------------------------
--------- INSURANCE DATA ---------
----------------------------------

-- to know the insurance type of patients whose bills generated amount to more than 1000 
SELECT dpd.name, fic.insurance_type, fbi.total_amt
FROM dim_patient_data dpd
JOIN dim_diagnosis dd ON dd.patient_id = dd.patient_id 
JOIN fact_treatment ft ON ft.diagnosis_id = dd.diagnosis_id 
JOIN fact_billing_info fbi ON fbi.treatment_id = ft.treatment_id 
JOIN fact_insurance_claims fic ON fic.patient_id = dpd.patient_id 
WHERE fbi.total_amt > 1000
ORDER BY fbi.total_amt DESC
LIMIT 10;