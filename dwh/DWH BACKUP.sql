--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1
-- Dumped by pg_dump version 15.1

-- Started on 2023-06-28 20:41:44 EDT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 885 (class 1247 OID 50116)
-- Name: blood_group_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.blood_group_enum AS ENUM (
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
);


ALTER TYPE public.blood_group_enum OWNER TO postgres;

--
-- TOC entry 882 (class 1247 OID 50109)
-- Name: gender_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.gender_enum AS ENUM (
    'M',
    'F',
    'O'
);


ALTER TYPE public.gender_enum OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 50416)
-- Name: insert_dim_diagnosis(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_dim_diagnosis() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO dim_diagnosis (diagnosis_id, patient_id, doctor_id, nurse_id, visit_date, symptoms, case_details, clinical_notes)
    VALUES (NEW.diagnosis_id, NEW.patient_id, NEW.doctor_id, NEW.nurse_id, NEW.visit_date, NEW.symptoms, NEW.case_details, NEW.clinical_notes);
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_dim_diagnosis() OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 50412)
-- Name: insert_dim_doctors(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_dim_doctors() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO dim_doctors (doctor_id, doctor_name, gender, contact_number, specialty)
    VALUES (NEW.doctor_id, CONCAT(NEW.first_name, ' ', NEW.last_name), NEW.gender, NEW.contact_number, NEW.specialty);
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_dim_doctors() OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 50420)
-- Name: insert_dim_lab_results(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_dim_lab_results() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO dim_lab_results (lr_id, diagnosis_id, tests, test_results)
    VALUES (NEW.lr_id, NEW.diagnosis_id, NEW.tests, NEW.test_results);
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_dim_lab_results() OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 50418)
-- Name: insert_dim_medical_history(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_dim_medical_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO dim_medical_history (mh_id, patient_id, surgeries, allergies, medical_conditions)
    VALUES (NEW.mh_id, NEW.patient_id, NEW.surgeries, NEW.allergies, NEW.medical_conditions);
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_dim_medical_history() OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 50414)
-- Name: insert_dim_nurses(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_dim_nurses() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO dim_nurses (nurse_id, nurse_name, gender, contact_number)
    VALUES (NEW.nurse_id, CONCAT(NEW.first_name, ' ', NEW.last_name), NEW.gender, NEW.contact_number);
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_dim_nurses() OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 57875)
-- Name: insert_dim_outcomes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_dim_outcomes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO dim_outcomes (o_id, treatment_id, recovery_status)
    VALUES (NEW.o_id, NEW.treatment_id, NEW.recovery_status);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_dim_outcomes() OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 50410)
-- Name: insert_dim_patient_data(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_dim_patient_data() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO dim_patient_data (patient_id, name, address, dob, gender, contact, blood_group)
    VALUES (NEW.patient_id, NEW.name, NEW.address, NEW.dob, NEW.gender, NEW.contact, NEW.blood_group);
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_dim_patient_data() OWNER TO postgres;

--
-- TOC entry 270 (class 1255 OID 57944)
-- Name: insert_fact_billing_info(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_fact_billing_info() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
	total_amt DECIMAL(10,2);
BEGIN
	total_amt = NEW.amt*1.1;
	
	INSERT INTO fact_billing_info (treatment_id, bill_number, bill_date, amt, total_amt, payment_type, payment_status, payment_date)
    VALUES (NEW.treatment_id, NEW.bill_number, NEW.bill_date, NEW.amt, total_amt, NEW.payment_type, NEW.payment_status, NEW.payment_date);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_fact_billing_info() OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 50426)
-- Name: insert_fact_insurance_claims(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_fact_insurance_claims() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO fact_insurance_claims (insurance_id, patient_id, provider_name, insurance_type, expiry)
    VALUES (NEW.insurance_id, NEW.patient_id, NEW.provider_name, NEW.insurance_type, NEW.expiry);
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_fact_insurance_claims() OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 50422)
-- Name: insert_fact_treatment(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_fact_treatment() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO fact_treatment (treatment_id, diagnosis_id, begin_date, end_date)
    VALUES (NEW.treatment_id, NEW.diagnosis_id, NEW.begin_date, NEW.end_date);
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_fact_treatment() OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 57873)
-- Name: insert_fact_vital_signs(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_fact_vital_signs() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
	bmi DECIMAL(5,2);
BEGIN
    bmi = NEW.weight / ((NEW.height / 100.0) * (NEW.height / 100.0));
	
    INSERT INTO fact_vital_signs (vs_id, diagnosis_id, blood_pressure, oxygen, temperature, heart_rate, weight, height, bmi)
    VALUES (NEW.vs_id, NEW.diagnosis_id, NEW.blood_pressure, NEW.oxygen, NEW.temperature, NEW.heart_rate, NEW.weight, NEW.height, bmi);
	RETURN NEW; 
END;
$$;


ALTER FUNCTION public.insert_fact_vital_signs() OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 50432)
-- Name: prevent_delete_function(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.prevent_delete_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    RAISE EXCEPTION 'Deletion from DWH table is not allowed!';
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.prevent_delete_function() OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 57924)
-- Name: bill_number; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bill_number
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;


ALTER TABLE public.bill_number OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 246 (class 1259 OID 57925)
-- Name: billing_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.billing_info (
    treatment_id numeric(8,0) NOT NULL,
    bill_number integer NOT NULL,
    bill_date date NOT NULL,
    amt numeric(10,2) NOT NULL,
    payment_type character varying(20) NOT NULL,
    payment_status character varying(20) NOT NULL,
    payment_date date NOT NULL,
    CONSTRAINT billing_info_payment_status_check CHECK ((lower((payment_status)::text) = ANY (ARRAY['pending'::text, 'overdue'::text, 'paid'::text])))
);


ALTER TABLE public.billing_info OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 50173)
-- Name: diagnosis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diagnosis (
    diagnosis_id character varying(8) NOT NULL,
    patient_id numeric(5,0) NOT NULL,
    doctor_id character varying(7) NOT NULL,
    nurse_id character varying(7) NOT NULL,
    visit_date date NOT NULL,
    symptoms character varying(100) NOT NULL,
    case_details character varying(200),
    clinical_notes character varying(200),
    CONSTRAINT diagnosis_diagnosis_id_check CHECK (((diagnosis_id)::text ~ '^\d{3}[A-Za-z]{3}\d[A-Za-z]$'::text))
);


ALTER TABLE public.diagnosis OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 50196)
-- Name: diagnosis_bridge_tests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diagnosis_bridge_tests (
    diagnosis_id character varying(8) NOT NULL,
    test_id integer NOT NULL
);


ALTER TABLE public.diagnosis_bridge_tests OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 50311)
-- Name: dim_diagnosis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_diagnosis (
    diagnosis_id character varying(8) NOT NULL,
    patient_id numeric(5,0) NOT NULL,
    doctor_id character varying(7) NOT NULL,
    nurse_id character varying(7) NOT NULL,
    visit_date date NOT NULL,
    symptoms character varying(100) NOT NULL,
    case_details character varying(200),
    clinical_notes character varying(200)
);


ALTER TABLE public.dim_diagnosis OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 50299)
-- Name: dim_doctors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_doctors (
    doctor_id character varying(7) NOT NULL,
    doctor_name character varying(40) NOT NULL,
    gender public.gender_enum NOT NULL,
    contact_number character varying(15),
    specialty character varying(50),
    CONSTRAINT dim_doctors_doctor_id_check CHECK (((doctor_id)::text ~ '^DOC\d{4}$'::text))
);


ALTER TABLE public.dim_doctors OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 50343)
-- Name: dim_lab_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_lab_results (
    lr_id integer NOT NULL,
    diagnosis_id character varying(8) NOT NULL,
    tests character varying(200) NOT NULL,
    test_results character varying(100) NOT NULL
);


ALTER TABLE public.dim_lab_results OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 50333)
-- Name: dim_medical_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_medical_history (
    mh_id integer NOT NULL,
    patient_id numeric(5,0) NOT NULL,
    surgeries character varying(40),
    allergies character varying(40),
    medical_conditions character varying(100)
);


ALTER TABLE public.dim_medical_history OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 50305)
-- Name: dim_nurses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_nurses (
    nurse_id character varying(7) NOT NULL,
    nurse_name character varying(40) NOT NULL,
    gender public.gender_enum NOT NULL,
    contact_number character varying(15),
    CONSTRAINT dim_nurses_nurse_id_check CHECK (((nurse_id)::text ~ '^NUR\d{4}$'::text))
);


ALTER TABLE public.dim_nurses OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 50368)
-- Name: dim_outcomes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_outcomes (
    o_id integer NOT NULL,
    treatment_id numeric(8,0) NOT NULL,
    recovery_status character varying(10) NOT NULL
);


ALTER TABLE public.dim_outcomes OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 50294)
-- Name: dim_patient_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_patient_data (
    patient_id numeric(5,0) NOT NULL,
    name character varying(100) NOT NULL,
    address character varying(100) NOT NULL,
    dob date NOT NULL,
    gender public.gender_enum NOT NULL,
    contact numeric(10,0) NOT NULL,
    blood_group public.blood_group_enum NOT NULL
);


ALTER TABLE public.dim_patient_data OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 50161)
-- Name: doctors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doctors (
    doctor_id character varying(7) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    gender public.gender_enum NOT NULL,
    contact_number character varying(15),
    specialty character varying(50),
    CONSTRAINT doctors_doctor_id_check CHECK (((doctor_id)::text ~ '^DOC\d{4}$'::text))
);


ALTER TABLE public.doctors OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 57936)
-- Name: fact_billing_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fact_billing_info (
    treatment_id numeric(8,0) NOT NULL,
    bill_number integer NOT NULL,
    bill_date date NOT NULL,
    amt numeric(10,2) NOT NULL,
    total_amt numeric(10,2),
    payment_type character varying(20) NOT NULL,
    payment_status character varying(20) NOT NULL,
    payment_date date NOT NULL
);


ALTER TABLE public.fact_billing_info OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 50379)
-- Name: fact_insurance_claims; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fact_insurance_claims (
    insurance_id integer NOT NULL,
    patient_id numeric(5,0) NOT NULL,
    provider_name character varying(8) NOT NULL,
    insurance_type character varying(20) NOT NULL,
    expiry date NOT NULL
);


ALTER TABLE public.fact_insurance_claims OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 50358)
-- Name: fact_treatment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fact_treatment (
    treatment_id numeric(8,0) NOT NULL,
    diagnosis_id character varying(8) NOT NULL,
    begin_date date NOT NULL,
    end_date date NOT NULL
);


ALTER TABLE public.fact_treatment OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 57865)
-- Name: fact_vital_signs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fact_vital_signs (
    vs_id integer,
    diagnosis_id character varying(8) NOT NULL,
    blood_pressure integer NOT NULL,
    oxygen integer NOT NULL,
    temperature numeric(4,2) NOT NULL,
    heart_rate integer NOT NULL,
    weight numeric(4,2) NOT NULL,
    height integer NOT NULL,
    bmi numeric(5,2)
);


ALTER TABLE public.fact_vital_signs OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 50268)
-- Name: insurance_claims; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.insurance_claims (
    insurance_id integer NOT NULL,
    patient_id numeric(5,0) NOT NULL,
    provider_name character varying(8) NOT NULL,
    insurance_type character varying(20) NOT NULL,
    expiry date NOT NULL,
    CONSTRAINT insurance_claims_insurance_type_check CHECK ((lower((insurance_type)::text) = ANY (ARRAY['bronze'::text, 'silver'::text, 'gold'::text, 'platinum'::text])))
);


ALTER TABLE public.insurance_claims OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 50258)
-- Name: lab_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lab_results (
    lr_id integer NOT NULL,
    diagnosis_id character varying(8) NOT NULL,
    tests character varying(200) NOT NULL,
    test_results character varying(100) NOT NULL
);


ALTER TABLE public.lab_results OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 50146)
-- Name: medical_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medical_history (
    mh_id integer NOT NULL,
    patient_id numeric(5,0) NOT NULL,
    surgeries character varying(40),
    allergies character varying(40),
    medical_conditions character varying(100)
);


ALTER TABLE public.medical_history OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 50135)
-- Name: medicine_id_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.medicine_id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999
    CACHE 1;


ALTER TABLE public.medicine_id_sequence OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 50219)
-- Name: medicines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medicines (
    medicine_id numeric(7,0) NOT NULL,
    medicine_name character varying(20) NOT NULL,
    times_a_day integer NOT NULL,
    extra_doc_notes character varying(200)
);


ALTER TABLE public.medicines OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 50167)
-- Name: nurses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nurses (
    nurse_id character varying(7) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    gender public.gender_enum NOT NULL,
    contact_number character varying(15),
    CONSTRAINT nurses_nurse_id_check CHECK (((nurse_id)::text ~ '^NUR\d{4}$'::text))
);


ALTER TABLE public.nurses OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 57877)
-- Name: outcomes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.outcomes (
    o_id integer NOT NULL,
    treatment_id numeric(8,0) NOT NULL,
    recovery_status character varying(10) NOT NULL,
    CONSTRAINT outcomes_recovery_status_check CHECK ((lower((recovery_status)::text) = ANY (ARRAY['critical'::text, 'stable'::text, 'recovered'::text, 'improving'::text])))
);


ALTER TABLE public.outcomes OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 50141)
-- Name: patient_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_data (
    patient_id numeric(5,0) NOT NULL,
    name character varying(100) NOT NULL,
    address character varying(100) NOT NULL,
    dob date NOT NULL,
    gender public.gender_enum NOT NULL,
    contact numeric(10,0) NOT NULL,
    blood_group public.blood_group_enum NOT NULL
);


ALTER TABLE public.patient_data OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 50133)
-- Name: patient_id_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.patient_id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999
    CACHE 1;


ALTER TABLE public.patient_id_sequence OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 50139)
-- Name: seq_lr_id; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_lr_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;


ALTER TABLE public.seq_lr_id OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 50137)
-- Name: seq_mh_id; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_mh_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;


ALTER TABLE public.seq_mh_id OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 57889)
-- Name: seq_o_id; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_o_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;


ALTER TABLE public.seq_o_id OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 57864)
-- Name: seq_vs_id; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_vs_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;


ALTER TABLE public.seq_vs_id OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 50156)
-- Name: tests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tests (
    test_id integer NOT NULL,
    test_nm character varying(100) NOT NULL
);


ALTER TABLE public.tests OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 50209)
-- Name: treatment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.treatment (
    treatment_id numeric(8,0) NOT NULL,
    diagnosis_id character varying(8) NOT NULL,
    begin_date date NOT NULL,
    end_date date NOT NULL
);


ALTER TABLE public.treatment OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 50224)
-- Name: treatment_bridge_meds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.treatment_bridge_meds (
    treatment_id numeric(8,0) NOT NULL,
    medicine_id numeric(7,0) NOT NULL
);


ALTER TABLE public.treatment_bridge_meds OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 50134)
-- Name: treatment_id_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.treatment_id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;


ALTER TABLE public.treatment_id_sequence OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 50446)
-- Name: vital_signs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vital_signs (
    vs_id integer NOT NULL,
    diagnosis_id character varying(8) NOT NULL,
    blood_pressure integer NOT NULL,
    oxygen integer NOT NULL,
    temperature numeric(4,2) NOT NULL,
    heart_rate integer NOT NULL,
    weight numeric(4,2) NOT NULL,
    height integer NOT NULL
);


ALTER TABLE public.vital_signs OWNER TO postgres;

--
-- TOC entry 3838 (class 0 OID 57925)
-- Dependencies: 246
-- Data for Name: billing_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.billing_info (treatment_id, bill_number, bill_date, amt, payment_type, payment_status, payment_date) FROM stdin;
1	1	2023-05-19	123.07	Debit Card	Overdue	2023-06-13
2	2	2022-12-20	597.61	Credit Card	Paid	2023-01-16
3	3	2022-10-19	355.72	Check	Pending	2022-10-30
4	4	2023-06-06	962.89	Credit Card	Paid	2023-06-24
5	5	2022-06-24	303.45	Check	Overdue	2022-06-29
6	6	2023-05-28	92.03	Credit Card	Paid	2023-06-12
7	7	2023-02-26	498.68	Cash	Paid	2023-03-26
8	8	2022-07-28	495.80	Check	Paid	2022-08-17
9	9	2023-03-31	96.50	Credit Card	Overdue	2023-04-28
10	10	2022-09-12	731.58	Cash	Paid	2022-09-29
11	11	2023-01-29	774.94	Check	Pending	2023-02-05
12	12	2023-02-26	934.74	Cash	Pending	2023-03-20
13	13	2023-06-10	635.63	Check	Paid	2023-07-06
14	14	2023-04-07	990.74	Debit Card	Overdue	2023-05-07
15	15	2023-01-29	825.04	Debit Card	Paid	2023-02-06
16	16	2022-09-16	809.63	Check	Overdue	2022-10-07
17	17	2023-02-23	494.66	Debit Card	Pending	2023-02-26
18	18	2022-10-22	246.14	Check	Paid	2022-11-02
19	19	2023-05-06	242.42	Debit Card	Pending	2023-05-25
20	20	2022-07-26	834.83	Credit Card	Pending	2022-07-30
21	21	2023-04-11	599.16	Check	Paid	2023-04-17
22	22	2023-01-16	51.31	Check	Overdue	2023-02-04
23	23	2022-09-04	626.49	Check	Overdue	2022-09-28
24	24	2023-02-17	866.44	Cash	Paid	2023-02-23
25	25	2023-04-03	240.83	Credit Card	Paid	2023-04-29
26	26	2022-10-20	400.73	Cash	Overdue	2022-10-24
27	27	2023-06-01	71.79	Credit Card	Pending	2023-06-20
28	28	2022-10-20	336.81	Check	Overdue	2022-10-29
29	29	2023-06-07	838.59	Credit Card	Paid	2023-06-22
30	30	2023-04-01	397.17	Debit Card	Pending	2023-04-14
31	31	2023-05-28	830.21	Check	Overdue	2023-06-17
32	32	2022-09-30	149.03	Credit Card	Overdue	2022-10-16
33	33	2022-11-01	590.47	Credit Card	Paid	2022-11-08
34	34	2022-12-14	520.45	Debit Card	Pending	2022-12-30
35	35	2023-02-16	191.99	Check	Pending	2023-03-17
36	36	2023-04-13	524.25	Debit Card	Paid	2023-04-14
37	37	2022-08-04	168.41	Debit Card	Paid	2022-08-18
38	38	2022-10-21	416.24	Credit Card	Pending	2022-11-05
39	39	2023-05-07	804.48	Cash	Pending	2023-05-24
40	40	2022-10-01	597.18	Credit Card	Paid	2022-10-10
41	41	2023-03-09	959.11	Credit Card	Pending	2023-03-27
42	42	2023-06-09	138.90	Credit Card	Overdue	2023-06-26
43	43	2023-02-04	817.59	Cash	Overdue	2023-02-06
44	44	2022-12-28	987.01	Debit Card	Overdue	2022-12-30
45	45	2022-10-02	256.23	Credit Card	Paid	2022-11-01
46	46	2022-11-05	510.65	Debit Card	Pending	2022-11-15
47	47	2022-08-23	509.59	Check	Paid	2022-09-12
48	48	2022-09-22	82.85	Check	Paid	2022-10-14
49	49	2022-12-31	209.08	Check	Pending	2023-01-05
50	50	2023-04-11	732.87	Credit Card	Paid	2023-05-04
51	51	2023-05-15	186.98	Credit Card	Overdue	2023-05-19
52	52	2023-02-21	143.92	Debit Card	Paid	2023-03-02
53	53	2022-06-20	53.33	Debit Card	Overdue	2022-07-13
54	54	2023-03-06	609.66	Credit Card	Overdue	2023-03-14
55	55	2022-09-27	575.63	Cash	Paid	2022-10-26
56	56	2022-09-30	827.42	Credit Card	Paid	2022-10-30
57	57	2022-10-28	879.60	Credit Card	Paid	2022-11-27
58	58	2023-05-14	240.38	Check	Paid	2023-05-16
59	59	2023-01-02	879.86	Credit Card	Overdue	2023-01-03
60	60	2023-01-31	274.99	Check	Paid	2023-02-09
61	61	2022-07-14	938.08	Cash	Paid	2022-07-15
62	62	2022-06-27	574.14	Credit Card	Pending	2022-07-17
63	63	2022-09-14	747.98	Debit Card	Pending	2022-09-23
64	64	2023-05-08	69.03	Debit Card	Pending	2023-05-28
65	65	2022-09-18	972.28	Check	Pending	2022-10-15
66	66	2022-12-09	961.41	Debit Card	Paid	2022-12-15
67	67	2022-09-19	687.73	Debit Card	Paid	2022-09-26
68	68	2022-11-19	83.96	Credit Card	Paid	2022-11-20
69	69	2022-07-20	429.06	Debit Card	Paid	2022-08-05
70	70	2023-01-15	552.97	Credit Card	Paid	2023-01-20
71	71	2022-07-29	573.18	Cash	Pending	2022-07-31
72	72	2022-07-30	860.00	Credit Card	Pending	2022-08-06
73	73	2023-05-18	242.36	Debit Card	Pending	2023-05-23
74	74	2022-11-13	493.36	Credit Card	Paid	2022-11-15
75	75	2023-02-07	819.52	Credit Card	Pending	2023-03-01
76	76	2023-02-20	817.39	Credit Card	Overdue	2023-03-22
77	77	2022-11-08	612.30	Debit Card	Pending	2022-11-11
78	78	2023-04-30	900.23	Debit Card	Overdue	2023-05-08
79	79	2022-09-24	195.80	Cash	Paid	2022-10-20
80	80	2022-10-17	507.92	Check	Pending	2022-11-13
\.


--
-- TOC entry 3816 (class 0 OID 50173)
-- Dependencies: 224
-- Data for Name: diagnosis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnosis (diagnosis_id, patient_id, doctor_id, nurse_id, visit_date, symptoms, case_details, clinical_notes) FROM stdin;
447SHA8O	1	DOC0003	NUR0004	2021-05-22	Pneumonia	Continue with regular physical therapy sessions.	Patient diagnosed with Flu.
519HZZ2Z	2	DOC0003	NUR0015	2023-12-28	Hypertension	Advise patient to maintain a balanced diet and exercise regularly.	Patient diagnosed with Bronchitis.
292TUW1D	3	DOC0019	NUR0008	2022-10-12	Bronchitis	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
975GZD5M	4	DOC0009	NUR0026	2023-06-17	Diabetes	Patient requires rest and medication.	Patient is asymptomatic.
927NUP2N	5	DOC0004	NUR0026	2022-09-28	Hypertension	Refer patient to a specialist for further evaluation.	Patient diagnosed with Flu.
837VAQ7U	6	DOC0014	NUR0012	2021-02-22	Influenza	Patient requires rest and medication.	Patient is asymptomatic.
879LCG1S	7	DOC0012	NUR0007	2020-05-15	Pneumonia	Continue with regular physical therapy sessions.	Patient is asymptomatic.
751VTH0M	8	DOC0009	NUR0020	2023-07-23	Hypertension	Advise patient to maintain a balanced diet and exercise regularly.	Patient diagnosed with Depression.
629PXL3S	9	DOC0007	NUR0005	2022-07-28	Influenza	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
207AUM8U	10	DOC0001	NUR0003	2021-12-03	Hypertension	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
473CLQ4I	11	DOC0007	NUR0002	2021-11-16	Diabetes	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
511ZUS5W	12	DOC0002	NUR0008	2023-03-22	Diabetes	Continue with regular physical therapy sessions.	Patient is asymptomatic.
629VTJ2Q	13	DOC0012	NUR0020	2023-10-14	Hypertension	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
957OZT3M	14	DOC0015	NUR0018	2022-08-08	Influenza	Continue with regular physical therapy sessions.	Patient is asymptomatic.
494CYH2D	15	DOC0006	NUR0019	2020-12-20	Pneumonia	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
424MMC3N	16	DOC0015	NUR0018	2022-04-02	Hypertension	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
277XVU0N	17	DOC0010	NUR0004	2021-01-26	Bronchitis	Advise patient to maintain a balanced diet and exercise regularly.	Patient diagnosed with Migraine.
482KHG2D	18	DOC0008	NUR0029	2020-07-24	Influenza	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
400VZL5M	19	DOC0004	NUR0004	2023-11-10	Bronchitis	Refer patient to a specialist for further evaluation.	Patient diagnosed with Diabetes.
560EZZ0D	20	DOC0017	NUR0028	2022-10-24	Diabetes	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
135QPV4Q	21	DOC0010	NUR0009	2020-06-13	Hypertension	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
728BNN6Q	22	DOC0005	NUR0017	2021-12-27	Hypertension	Patient requires rest and medication.	Patient diagnosed with Migraine.
528BNO9C	23	DOC0018	NUR0022	2021-12-15	Influenza	Prescribe pain management medication and recommend hot/cold compresses.	Patient diagnosed with Flu.
236XWX5X	24	DOC0006	NUR0016	2022-12-03	Diabetes	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
826JUY7B	25	DOC0010	NUR0023	2020-03-08	Bronchitis	Advise patient to maintain a balanced diet and exercise regularly.	Patient diagnosed with Migraine.
152AGT0F	26	DOC0004	NUR0010	2023-10-06	Diabetes	Continue with regular physical therapy sessions.	Patient diagnosed with Pneumonia.
754TJC0O	27	DOC0019	NUR0025	2020-03-10	Influenza	Refer patient to a specialist for further evaluation.	Patient diagnosed with Depression.
679EWC3R	28	DOC0016	NUR0012	2021-02-14	Hypertension	Continue with regular physical therapy sessions.	Patient is asymptomatic.
366TUO4H	29	DOC0004	NUR0019	2023-08-21	Bronchitis	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
913EDR1M	30	DOC0007	NUR0029	2020-02-17	Diabetes	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
329ZGS3D	31	DOC0013	NUR0011	2023-09-04	Pneumonia	Patient requires rest and medication.	Patient diagnosed with Migraine.
688OAD0C	32	DOC0006	NUR0005	2020-02-20	Hypertension	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
823MWO5M	33	DOC0002	NUR0030	2021-12-26	Influenza	Prescribe pain management medication and recommend hot/cold compresses.	Patient diagnosed with Arthritis.
362FOX2P	34	DOC0001	NUR0025	2022-04-18	Hypertension	Patient requires rest and medication.	Patient is asymptomatic.
863WKE4Z	35	DOC0018	NUR0006	2023-07-21	Influenza	Continue with regular physical therapy sessions.	Patient is asymptomatic.
354EQN7S	36	DOC0018	NUR0003	2021-11-14	Diabetes	Continue with regular physical therapy sessions.	Patient is asymptomatic.
309AIX7G	37	DOC0020	NUR0001	2022-02-19	Bronchitis	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
931VWY0O	38	DOC0009	NUR0016	2023-05-23	Pneumonia	Patient requires rest and medication.	Patient is asymptomatic.
277MSR6L	39	DOC0008	NUR0024	2021-10-08	Diabetes	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
269UME1Q	40	DOC0016	NUR0021	2020-06-12	Bronchitis	Patient requires rest and medication.	Patient is asymptomatic.
516GNU8G	41	DOC0013	NUR0027	2020-01-03	Influenza	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
745BXS4B	42	DOC0019	NUR0010	2020-10-01	Influenza	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
832SCR7O	43	DOC0012	NUR0010	2020-04-20	Influenza	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
955MOZ1M	44	DOC0001	NUR0027	2022-03-09	Pneumonia	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
837NKA9B	45	DOC0018	NUR0020	2021-11-13	Bronchitis	Patient requires rest and medication.	Patient diagnosed with Arthritis.
401TAF0H	46	DOC0014	NUR0017	2020-08-16	Hypertension	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
610ZBX6T	47	DOC0005	NUR0013	2023-07-10	Hypertension	Continue with regular physical therapy sessions.	Patient is asymptomatic.
261JDX0P	48	DOC0016	NUR0009	2023-07-09	Bronchitis	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
739MOK2H	49	DOC0017	NUR0007	2021-07-23	Influenza	Patient requires rest and medication.	Patient is asymptomatic.
391IFN2P	50	DOC0008	NUR0017	2023-01-01	Diabetes	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
111XDO3P	51	DOC0007	NUR0013	2020-06-24	Diabetes	Prescribe pain management medication and recommend hot/cold compresses.	Patient diagnosed with Migraine.
238RTX9A	52	DOC0012	NUR0014	2022-07-08	Hypertension	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
789AXJ7E	53	DOC0015	NUR0001	2023-04-15	Hypertension	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
769MSB7W	54	DOC0020	NUR0022	2022-12-11	Bronchitis	Patient requires rest and medication.	Patient is asymptomatic.
972XMM8E	55	DOC0002	NUR0024	2020-11-21	Bronchitis	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
976OTV4A	56	DOC0016	NUR0015	2022-01-10	Pneumonia	Patient requires rest and medication.	Patient is asymptomatic.
134RLM8B	57	DOC0011	NUR0015	2021-01-05	Bronchitis	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
473YKX1H	58	DOC0017	NUR0002	2020-10-03	Bronchitis	Refer patient to a specialist for further evaluation.	Patient diagnosed with Hypertension.
148ORC2A	59	DOC0020	NUR0018	2023-06-18	Diabetes	Patient requires rest and medication.	Patient is asymptomatic.
555GMH3Y	60	DOC0005	NUR0030	2020-02-09	Hypertension	Continue with regular physical therapy sessions.	Patient is asymptomatic.
185UJB9C	61	DOC0014	NUR0014	2021-08-01	Diabetes	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
273AEL4M	62	DOC0010	NUR0005	2021-03-08	Diabetes	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
201UJK5G	63	DOC0011	NUR0014	2022-03-19	Diabetes	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
669KNY3U	64	DOC0008	NUR0016	2020-11-09	Bronchitis	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
178DBH0P	65	DOC0020	NUR0009	2020-07-20	Bronchitis	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
887FAB8N	66	DOC0009	NUR0007	2022-02-22	Hypertension	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
769GIH5C	67	DOC0002	NUR0008	2023-06-09	Pneumonia	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
601SPK2I	68	DOC0011	NUR0003	2022-07-02	Diabetes	Continue with regular physical therapy sessions.	Patient is asymptomatic.
192MOO0S	69	DOC0013	NUR0002	2020-09-13	Diabetes	Continue with regular physical therapy sessions.	Patient is asymptomatic.
696WXF3X	70	DOC0003	NUR0006	2020-02-08	Hypertension	Patient requires rest and medication.	Patient diagnosed with Asthma.
439TQR6M	71	DOC0013	NUR0028	2020-09-20	Influenza	Continue with regular physical therapy sessions.	Patient is asymptomatic.
270OWK6L	72	DOC0003	NUR0023	2021-08-12	Influenza	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
447YXX9Z	73	DOC0001	NUR0006	2021-02-08	Bronchitis	Continue with regular physical therapy sessions.	Patient is asymptomatic.
354RVE2A	74	DOC0015	NUR0011	2022-01-23	Diabetes	Patient requires rest and medication.	Patient diagnosed with Pneumonia.
636LLM1F	75	DOC0011	NUR0001	2020-11-12	Influenza	Continue with regular physical therapy sessions.	Patient is asymptomatic.
875JRK1J	76	DOC0005	NUR0011	2023-09-14	Hypertension	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
324MPR8S	77	DOC0019	NUR0012	2023-10-16	Diabetes	Continue with regular physical therapy sessions.	Patient diagnosed with Bronchitis.
258HQN7I	78	DOC0014	NUR0019	2023-08-25	Pneumonia	Continue with regular physical therapy sessions.	Patient diagnosed with Arthritis.
688TZX9Q	79	DOC0006	NUR0013	2022-12-23	Hypertension	Advise patient to maintain a balanced diet and exercise regularly.	Patient diagnosed with Bronchitis.
902YEX3J	80	DOC0017	NUR0021	2020-10-20	Hypertension	Continue with regular physical therapy sessions.	Patient diagnosed with Asthma.
\.


--
-- TOC entry 3817 (class 0 OID 50196)
-- Dependencies: 225
-- Data for Name: diagnosis_bridge_tests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnosis_bridge_tests (diagnosis_id, test_id) FROM stdin;
447SHA8O	89485
447SHA8O	87943
519HZZ2Z	87943
292TUW1D	67821
975GZD5M	54637
927NUP2N	89485
927NUP2N	54637
927NUP2N	67821
837VAQ7U	87943
879LCG1S	54637
751VTH0M	89485
629PXL3S	89485
207AUM8U	67821
473CLQ4I	13234
473CLQ4I	67821
511ZUS5W	54637
629VTJ2Q	13234
957OZT3M	89485
494CYH2D	67821
424MMC3N	89485
277XVU0N	67821
277XVU0N	54637
482KHG2D	13234
400VZL5M	63542
560EZZ0D	65172
135QPV4Q	67821
728BNN6Q	87943
528BNO9C	63542
236XWX5X	89485
826JUY7B	89485
152AGT0F	54637
754TJC0O	13234
679EWC3R	63542
366TUO4H	54637
913EDR1M	65172
329ZGS3D	63542
688OAD0C	87943
823MWO5M	54637
362FOX2P	13234
863WKE4Z	63542
354EQN7S	89485
309AIX7G	67821
931VWY0O	63542
277MSR6L	67821
277MSR6L	54637
269UME1Q	13234
516GNU8G	13234
745BXS4B	54637
832SCR7O	67821
955MOZ1M	54637
837NKA9B	89485
401TAF0H	67821
610ZBX6T	87943
261JDX0P	54637
739MOK2H	65172
391IFN2P	63542
111XDO3P	13234
238RTX9A	89485
789AXJ7E	13234
769MSB7W	13234
972XMM8E	54637
976OTV4A	89485
134RLM8B	54637
473YKX1H	65172
148ORC2A	13234
148ORC2A	67821
555GMH3Y	54637
185UJB9C	87943
273AEL4M	63542
201UJK5G	63542
669KNY3U	87943
178DBH0P	87943
887FAB8N	63542
769GIH5C	87943
601SPK2I	13234
192MOO0S	89485
696WXF3X	67821
439TQR6M	89485
270OWK6L	87943
447YXX9Z	87943
354RVE2A	67821
636LLM1F	65172
875JRK1J	87943
324MPR8S	87943
258HQN7I	87943
688TZX9Q	65172
902YEX3J	67821
\.


--
-- TOC entry 3826 (class 0 OID 50311)
-- Dependencies: 234
-- Data for Name: dim_diagnosis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dim_diagnosis (diagnosis_id, patient_id, doctor_id, nurse_id, visit_date, symptoms, case_details, clinical_notes) FROM stdin;
447SHA8O	1	DOC0003	NUR0004	2021-05-22	Pneumonia	Continue with regular physical therapy sessions.	Patient diagnosed with Flu.
519HZZ2Z	2	DOC0003	NUR0015	2023-12-28	Hypertension	Advise patient to maintain a balanced diet and exercise regularly.	Patient diagnosed with Bronchitis.
292TUW1D	3	DOC0019	NUR0008	2022-10-12	Bronchitis	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
975GZD5M	4	DOC0009	NUR0026	2023-06-17	Diabetes	Patient requires rest and medication.	Patient is asymptomatic.
927NUP2N	5	DOC0004	NUR0026	2022-09-28	Hypertension	Refer patient to a specialist for further evaluation.	Patient diagnosed with Flu.
837VAQ7U	6	DOC0014	NUR0012	2021-02-22	Influenza	Patient requires rest and medication.	Patient is asymptomatic.
879LCG1S	7	DOC0012	NUR0007	2020-05-15	Pneumonia	Continue with regular physical therapy sessions.	Patient is asymptomatic.
751VTH0M	8	DOC0009	NUR0020	2023-07-23	Hypertension	Advise patient to maintain a balanced diet and exercise regularly.	Patient diagnosed with Depression.
629PXL3S	9	DOC0007	NUR0005	2022-07-28	Influenza	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
207AUM8U	10	DOC0001	NUR0003	2021-12-03	Hypertension	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
473CLQ4I	11	DOC0007	NUR0002	2021-11-16	Diabetes	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
511ZUS5W	12	DOC0002	NUR0008	2023-03-22	Diabetes	Continue with regular physical therapy sessions.	Patient is asymptomatic.
629VTJ2Q	13	DOC0012	NUR0020	2023-10-14	Hypertension	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
957OZT3M	14	DOC0015	NUR0018	2022-08-08	Influenza	Continue with regular physical therapy sessions.	Patient is asymptomatic.
494CYH2D	15	DOC0006	NUR0019	2020-12-20	Pneumonia	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
424MMC3N	16	DOC0015	NUR0018	2022-04-02	Hypertension	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
277XVU0N	17	DOC0010	NUR0004	2021-01-26	Bronchitis	Advise patient to maintain a balanced diet and exercise regularly.	Patient diagnosed with Migraine.
482KHG2D	18	DOC0008	NUR0029	2020-07-24	Influenza	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
400VZL5M	19	DOC0004	NUR0004	2023-11-10	Bronchitis	Refer patient to a specialist for further evaluation.	Patient diagnosed with Diabetes.
560EZZ0D	20	DOC0017	NUR0028	2022-10-24	Diabetes	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
135QPV4Q	21	DOC0010	NUR0009	2020-06-13	Hypertension	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
728BNN6Q	22	DOC0005	NUR0017	2021-12-27	Hypertension	Patient requires rest and medication.	Patient diagnosed with Migraine.
528BNO9C	23	DOC0018	NUR0022	2021-12-15	Influenza	Prescribe pain management medication and recommend hot/cold compresses.	Patient diagnosed with Flu.
236XWX5X	24	DOC0006	NUR0016	2022-12-03	Diabetes	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
826JUY7B	25	DOC0010	NUR0023	2020-03-08	Bronchitis	Advise patient to maintain a balanced diet and exercise regularly.	Patient diagnosed with Migraine.
152AGT0F	26	DOC0004	NUR0010	2023-10-06	Diabetes	Continue with regular physical therapy sessions.	Patient diagnosed with Pneumonia.
754TJC0O	27	DOC0019	NUR0025	2020-03-10	Influenza	Refer patient to a specialist for further evaluation.	Patient diagnosed with Depression.
679EWC3R	28	DOC0016	NUR0012	2021-02-14	Hypertension	Continue with regular physical therapy sessions.	Patient is asymptomatic.
366TUO4H	29	DOC0004	NUR0019	2023-08-21	Bronchitis	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
913EDR1M	30	DOC0007	NUR0029	2020-02-17	Diabetes	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
329ZGS3D	31	DOC0013	NUR0011	2023-09-04	Pneumonia	Patient requires rest and medication.	Patient diagnosed with Migraine.
688OAD0C	32	DOC0006	NUR0005	2020-02-20	Hypertension	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
823MWO5M	33	DOC0002	NUR0030	2021-12-26	Influenza	Prescribe pain management medication and recommend hot/cold compresses.	Patient diagnosed with Arthritis.
362FOX2P	34	DOC0001	NUR0025	2022-04-18	Hypertension	Patient requires rest and medication.	Patient is asymptomatic.
863WKE4Z	35	DOC0018	NUR0006	2023-07-21	Influenza	Continue with regular physical therapy sessions.	Patient is asymptomatic.
354EQN7S	36	DOC0018	NUR0003	2021-11-14	Diabetes	Continue with regular physical therapy sessions.	Patient is asymptomatic.
309AIX7G	37	DOC0020	NUR0001	2022-02-19	Bronchitis	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
931VWY0O	38	DOC0009	NUR0016	2023-05-23	Pneumonia	Patient requires rest and medication.	Patient is asymptomatic.
277MSR6L	39	DOC0008	NUR0024	2021-10-08	Diabetes	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
269UME1Q	40	DOC0016	NUR0021	2020-06-12	Bronchitis	Patient requires rest and medication.	Patient is asymptomatic.
516GNU8G	41	DOC0013	NUR0027	2020-01-03	Influenza	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
745BXS4B	42	DOC0019	NUR0010	2020-10-01	Influenza	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
832SCR7O	43	DOC0012	NUR0010	2020-04-20	Influenza	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
955MOZ1M	44	DOC0001	NUR0027	2022-03-09	Pneumonia	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
837NKA9B	45	DOC0018	NUR0020	2021-11-13	Bronchitis	Patient requires rest and medication.	Patient diagnosed with Arthritis.
401TAF0H	46	DOC0014	NUR0017	2020-08-16	Hypertension	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
610ZBX6T	47	DOC0005	NUR0013	2023-07-10	Hypertension	Continue with regular physical therapy sessions.	Patient is asymptomatic.
261JDX0P	48	DOC0016	NUR0009	2023-07-09	Bronchitis	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
739MOK2H	49	DOC0017	NUR0007	2021-07-23	Influenza	Patient requires rest and medication.	Patient is asymptomatic.
391IFN2P	50	DOC0008	NUR0017	2023-01-01	Diabetes	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
111XDO3P	51	DOC0007	NUR0013	2020-06-24	Diabetes	Prescribe pain management medication and recommend hot/cold compresses.	Patient diagnosed with Migraine.
238RTX9A	52	DOC0012	NUR0014	2022-07-08	Hypertension	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
789AXJ7E	53	DOC0015	NUR0001	2023-04-15	Hypertension	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
769MSB7W	54	DOC0020	NUR0022	2022-12-11	Bronchitis	Patient requires rest and medication.	Patient is asymptomatic.
972XMM8E	55	DOC0002	NUR0024	2020-11-21	Bronchitis	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
976OTV4A	56	DOC0016	NUR0015	2022-01-10	Pneumonia	Patient requires rest and medication.	Patient is asymptomatic.
134RLM8B	57	DOC0011	NUR0015	2021-01-05	Bronchitis	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
473YKX1H	58	DOC0017	NUR0002	2020-10-03	Bronchitis	Refer patient to a specialist for further evaluation.	Patient diagnosed with Hypertension.
148ORC2A	59	DOC0020	NUR0018	2023-06-18	Diabetes	Patient requires rest and medication.	Patient is asymptomatic.
555GMH3Y	60	DOC0005	NUR0030	2020-02-09	Hypertension	Continue with regular physical therapy sessions.	Patient is asymptomatic.
185UJB9C	61	DOC0014	NUR0014	2021-08-01	Diabetes	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
273AEL4M	62	DOC0010	NUR0005	2021-03-08	Diabetes	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
201UJK5G	63	DOC0011	NUR0014	2022-03-19	Diabetes	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
669KNY3U	64	DOC0008	NUR0016	2020-11-09	Bronchitis	Advise patient to maintain a balanced diet and exercise regularly.	Patient is asymptomatic.
178DBH0P	65	DOC0020	NUR0009	2020-07-20	Bronchitis	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
887FAB8N	66	DOC0009	NUR0007	2022-02-22	Hypertension	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
769GIH5C	67	DOC0002	NUR0008	2023-06-09	Pneumonia	Refer patient to a specialist for further evaluation.	Patient is asymptomatic.
601SPK2I	68	DOC0011	NUR0003	2022-07-02	Diabetes	Continue with regular physical therapy sessions.	Patient is asymptomatic.
192MOO0S	69	DOC0013	NUR0002	2020-09-13	Diabetes	Continue with regular physical therapy sessions.	Patient is asymptomatic.
696WXF3X	70	DOC0003	NUR0006	2020-02-08	Hypertension	Patient requires rest and medication.	Patient diagnosed with Asthma.
439TQR6M	71	DOC0013	NUR0028	2020-09-20	Influenza	Continue with regular physical therapy sessions.	Patient is asymptomatic.
270OWK6L	72	DOC0003	NUR0023	2021-08-12	Influenza	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
447YXX9Z	73	DOC0001	NUR0006	2021-02-08	Bronchitis	Continue with regular physical therapy sessions.	Patient is asymptomatic.
354RVE2A	74	DOC0015	NUR0011	2022-01-23	Diabetes	Patient requires rest and medication.	Patient diagnosed with Pneumonia.
636LLM1F	75	DOC0011	NUR0001	2020-11-12	Influenza	Continue with regular physical therapy sessions.	Patient is asymptomatic.
875JRK1J	76	DOC0005	NUR0011	2023-09-14	Hypertension	Prescribe pain management medication and recommend hot/cold compresses.	Patient is asymptomatic.
324MPR8S	77	DOC0019	NUR0012	2023-10-16	Diabetes	Continue with regular physical therapy sessions.	Patient diagnosed with Bronchitis.
258HQN7I	78	DOC0014	NUR0019	2023-08-25	Pneumonia	Continue with regular physical therapy sessions.	Patient diagnosed with Arthritis.
688TZX9Q	79	DOC0006	NUR0013	2022-12-23	Hypertension	Advise patient to maintain a balanced diet and exercise regularly.	Patient diagnosed with Bronchitis.
902YEX3J	80	DOC0017	NUR0021	2020-10-20	Hypertension	Continue with regular physical therapy sessions.	Patient diagnosed with Asthma.
\.


--
-- TOC entry 3824 (class 0 OID 50299)
-- Dependencies: 232
-- Data for Name: dim_doctors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dim_doctors (doctor_id, doctor_name, gender, contact_number, specialty) FROM stdin;
DOC0001	John Kelly	M	3954612629	Surgeon
DOC0002	Stephanie Willis	F	5894612025	Physician Executive
DOC0003	Jessica Strong	M	4811071322	Oncologist
DOC0004	Alan Wilson	F	6157027105	Pediatrician
DOC0005	William Skinner	M	2452251405	Ophthalmologist
DOC0006	Cynthia Hobbs	M	4233498682	Radiologist
DOC0007	Deborah Frederick	F	1286751529	Dermatologist
DOC0008	Dylan Williams	F	1028987805	Surgeon
DOC0009	Timothy Mccarty	M	5356928248	Neurologist
DOC0010	Joshua Watson	M	6683759129	Oncologist
DOC0011	Joseph Church	M	4377438375	Gastroenterologist
DOC0012	Candice Diaz	F	7178521028	Infectious Disease
DOC0013	Mary Jensen	M	9201226808	Obstetrician/Gynecologist (OBGYN)
DOC0014	Ryan Ramirez	M	4743026850	Physician Executive
DOC0015	Bryce Duke	F	3663662341	Pulmonologist
DOC0016	Joshua Greene	F	7167708092	Infectious Disease
DOC0017	Natalie Thomas	M	8227973487	Endocrinologist
DOC0018	Suzanne Burgess	M	8369256764	Family Medicine
DOC0019	Jasmine Miller	F	4591428062	Gastroenterologist
DOC0020	Daniel Sharp	M	7789338173	Anesthesiologist
\.


--
-- TOC entry 3828 (class 0 OID 50343)
-- Dependencies: 236
-- Data for Name: dim_lab_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dim_lab_results (lr_id, diagnosis_id, tests, test_results) FROM stdin;
1	447SHA8O	89485, 87943	Normal , No abnormalities detected
2	519HZZ2Z	87943	No abnormalities detected
3	292TUW1D	67821	Abnormal
4	975GZD5M	54637	Sinus rhythm
5	927NUP2N	89485, 54637, 67821	Normal, Sinus rhythm, Normal
6	837VAQ7U	87943	No abnormalities detected
7	879LCG1S	54637	Sinus rhythm
8	751VTH0M	89485	Abnormal
9	629PXL3S	89485	Normal
10	207AUM8U	67821	Normal
11	473CLQ4I	13234, 67821	Normal, Normal
12	511ZUS5W	54637	Ventricular tachycardia
13	629VTJ2Q	13234	Normal
14	957OZT3M	89485	Abnormal
15	494CYH2D	67821	Abnormal
16	424MMC3N	89485	Normal
17	277XVU0N	67821, 54637	Normal, Ventricular tachycardia
18	482KHG2D	13234	Abnormal
19	400VZL5M	63542	No fractures detected
20	560EZZ0D	65172	Abnormal
21	135QPV4Q	67821	Normal
22	728BNN6Q	87943	Tumor found
23	528BNO9C	63542	No fractures detected
24	236XWX5X	89485	Normal
25	826JUY7B	89485	Normal
26	152AGT0F	54637	Ventricular tachycardia
27	754TJC0O	13234	Abnormal
28	679EWC3R	63542	No fractures detected
29	366TUO4H	54637	Ventricular tachycardia
30	913EDR1M	65172	5.6
31	329ZGS3D	63542	No fractures detected
32	688OAD0C	87943	No abnormalities detected
33	823MWO5M	54637	Ventricular tachycardia
34	362FOX2P	13234	Normal
35	863WKE4Z	63542	No fractures detected
36	354EQN7S	89485	Normal
37	309AIX7G	67821	Normal
38	931VWY0O	63542	Fracture found
39	277MSR6L	67821, 54637	Tumor found, Atrial fibrillation
40	269UME1Q	13234	Normal
41	516GNU8G	13234	Abnormal
42	745BXS4B	54637	Ventricular tachycardia
43	832SCR7O	67821	Normal
44	955MOZ1M	54637	Ventricular tachycardia
45	837NKA9B	89485	Normal
46	401TAF0H	67821	Abnormal
47	610ZBX6T	87943	No abnormalities detected
48	261JDX0P	54637	Atrial fibrillation
49	739MOK2H	65172	6.7
50	391IFN2P	63542	Fracture found
51	111XDO3P	13234	Abnormal
52	238RTX9A	89485	Normal
53	789AXJ7E	13234	Normal
54	769MSB7W	13234	Normal
55	972XMM8E	54637	Sinus rhythm
56	976OTV4A	89485	Normal
57	134RLM8B	54637	Atrial fibrillation
58	473YKX1H	65172	3.5
59	148ORC2A	13234, 67821	Tumor found, Abnormal
60	555GMH3Y	54637	Sinus rhythm
61	185UJB9C	87943	No abnormalities detected
62	273AEL4M	63542	Fracture found
63	201UJK5G	63542	Fracture found
64	669KNY3U	87943	No abnormalities detected
65	178DBH0P	87943	No abnormalities detected
66	887FAB8N	63542	No fractures detected
67	769GIH5C	87943	No abnormalities detected
68	601SPK2I	13234	Normal
69	192MOO0S	89485	Abnormal
70	696WXF3X	67821	Normal
71	439TQR6M	89485	Normal
72	270OWK6L	87943	No abnormalities detected
73	447YXX9Z	87943	Normal
74	354RVE2A	67821	Abnormal
75	636LLM1F	65172	8.7
76	875JRK1J	87943	No abnormalities detected
77	324MPR8S	87943	No abnormalities detected
78	258HQN7I	87943	No abnormalities detected
79	688TZX9Q	65172	14
80	902YEX3J	67821	Normal
\.


--
-- TOC entry 3827 (class 0 OID 50333)
-- Dependencies: 235
-- Data for Name: dim_medical_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dim_medical_history (mh_id, patient_id, surgeries, allergies, medical_conditions) FROM stdin;
1	1	Hernia Repair	Shellfish	Bronchitis
2	2	Appendectomy	Dust	Arthritis
3	3	Cataract Surgery	Peanuts	Bronchitis
4	4	Hernia Repair	Peanuts	Migraine
5	5	Hernia Repair	Dust	Diabetes
6	6	Appendectomy	Dust	Arthritis
7	7	Gallbladder Removal	None	Bronchitis
8	8	Hernia Repair	Latex	Migraine
9	9	Hernia Repair	Dust	None
10	10	Knee Replacement	Latex	Depression
11	11	None	Dust	Bronchitis
12	12	Gallbladder Removal	Shellfish	Flu
13	13	Gallbladder Removal	Peanuts	Hypertension
14	14	Gallbladder Removal	Dust	Hypertension
15	15	Hernia Repair	Dust	Depression
16	16	Knee Replacement	Shellfish	Asthma
17	17	None	None	Diabetes
18	18	Hernia Repair	None	Pneumonia
19	19	None	Shellfish	Flu
20	20	Hernia Repair	Latex	Bronchitis
21	21	Gallbladder Removal	Dust	Pneumonia
22	22	Hernia Repair	Peanuts	Hypertension
23	23	Appendectomy	None	Flu
24	24	Hernia Repair	Dust	Asthma
25	25	Hernia Repair	Penicillin	None
26	26	Gallbladder Removal	Peanuts	Bronchitis
27	27	Hernia Repair	None	Depression
28	28	Appendectomy	Dust	Arthritis
29	29	Appendectomy	Dust	Migraine
30	30	Cataract Surgery	Latex	Asthma
31	31	Hernia Repair	Latex	Flu
32	32	Appendectomy	Shellfish	Flu
33	33	None	Penicillin	Migraine
34	34	None	Penicillin	Migraine
35	35	None	Penicillin	Arthritis
36	36	None	Latex	Hypertension
37	37	Knee Replacement	Peanuts	Bronchitis
38	38	Hernia Repair	None	Hypertension
39	39	Appendectomy	Peanuts	Pneumonia
40	40	None	Penicillin	Flu
41	41	None	Shellfish	Bronchitis
42	42	Knee Replacement	Latex	Diabetes
43	43	Cataract Surgery	Penicillin	Flu
44	44	Gallbladder Removal	Peanuts	None
45	45	Gallbladder Removal	None	Bronchitis
46	46	Gallbladder Removal	Peanuts	Arthritis
47	47	Hernia Repair	None	Hypertension
48	48	None	Penicillin	Arthritis
49	49	Cataract Surgery	Penicillin	Depression
50	50	Cataract Surgery	Latex	Depression
51	51	Gallbladder Removal	None	Arthritis
52	52	Appendectomy	Shellfish	Hypertension
53	53	Knee Replacement	Latex	Asthma
54	54	Gallbladder Removal	Penicillin	Migraine
55	55	Cataract Surgery	Latex	Pneumonia
56	56	Hernia Repair	Peanuts	Flu
57	57	Hernia Repair	Dust	Flu
58	58	Knee Replacement	Peanuts	Diabetes
59	59	Gallbladder Removal	None	Migraine
60	60	None	Latex	Asthma
61	61	Hernia Repair	Penicillin	Bronchitis
62	62	None	Peanuts	Arthritis
63	63	Knee Replacement	Peanuts	Arthritis
64	64	Cataract Surgery	Shellfish	Asthma
65	65	Knee Replacement	Shellfish	Depression
66	66	Knee Replacement	None	Pneumonia
67	67	Appendectomy	Latex	Diabetes
68	68	None	Peanuts	Depression
69	69	Appendectomy	Latex	Asthma
70	70	Hernia Repair	Dust	Diabetes
71	71	Appendectomy	Latex	Asthma
72	72	Gallbladder Removal	Penicillin	Asthma
73	73	Hernia Repair	None	Asthma
74	74	Gallbladder Removal	Penicillin	Pneumonia
75	75	Hernia Repair	Latex	Diabetes
76	76	Hernia Repair	None	Diabetes
77	77	Hernia Repair	Latex	Asthma
78	78	Appendectomy	Shellfish	Migraine
79	79	Gallbladder Removal	Dust	Depression
80	80	Appendectomy	Dust	None
\.


--
-- TOC entry 3825 (class 0 OID 50305)
-- Dependencies: 233
-- Data for Name: dim_nurses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dim_nurses (nurse_id, nurse_name, gender, contact_number) FROM stdin;
NUR0001	Lindsey Morrison	F	7537619434
NUR0002	Will Barr	M	5884967181
NUR0003	Helen Young	F	1662874152
NUR0004	Andrea Gonzales	F	3444542813
NUR0005	Michelle Byrd	F	7975765201
NUR0006	Nate Martin	M	8344647969
NUR0007	Sara Watkins	F	5021887831
NUR0008	Ardian Brown	M	6565438505
NUR0009	Jennifer Adkins	F	4226755509
NUR0010	Chris Copeland	M	1261683871
NUR0011	Sherry Stevens	F	1352313366
NUR0012	Janet Thomas	F	6106326795
NUR0013	Armor White	M	2864486390
NUR0014	Daniel Hayes	M	5932973442
NUR0015	Maria Crawford	F	1571319440
NUR0016	Amy Jones	F	4707406055
NUR0017	Leo Manning	M	9261454360
NUR0018	Alan Wilson	M	7733994355
NUR0019	Dorothy Logan	F	4239945344
NUR0020	Jackie Weber	F	2976649182
NUR0021	Adam Gomez	M	8137261330
NUR0022	Andrea Turner	F	5356276939
NUR0023	Luke Leonard	M	9916019301
NUR0024	Hex Gibson	M	2522484122
NUR0025	Lindsey Mcclure	F	1237758164
NUR0026	Cole Sparks	M	2264959893
NUR0027	Jasmine Smith	F	3999218750
NUR0028	Jake Rogers	M	5622762030
NUR0029	Alfred Martin	M	5982136233
NUR0030	Joey Olsen	M	9406749079
NUR0031	Linda Moore	F	7787789434
\.


--
-- TOC entry 3830 (class 0 OID 50368)
-- Dependencies: 238
-- Data for Name: dim_outcomes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dim_outcomes (o_id, treatment_id, recovery_status) FROM stdin;
1	1	Critical
2	2	Stable
3	3	Critical
4	4	Critical
5	5	Stable
6	6	Stable
7	7	Recovered
8	8	Stable
9	9	Recovered
10	10	Recovered
11	11	Critical
12	12	Critical
13	13	Stable
14	14	Recovered
15	15	Stable
16	16	Critical
17	17	Stable
18	18	Improving
19	19	Stable
20	20	Improving
21	21	Improving
22	22	Stable
23	23	Recovered
24	24	Critical
25	25	Stable
26	26	Stable
27	27	Improving
28	28	Recovered
29	29	Stable
30	30	Improving
31	31	Improving
32	32	Improving
33	33	Recovered
34	34	Stable
35	35	Critical
36	36	Critical
37	37	Critical
38	38	Stable
39	39	Stable
40	40	Improving
41	41	Stable
42	42	Improving
43	43	Recovered
44	44	Improving
45	45	Recovered
46	46	Improving
47	47	Stable
48	48	Critical
49	49	Improving
50	50	Improving
51	51	Recovered
52	52	Recovered
53	53	Stable
54	54	Recovered
55	55	Improving
56	56	Critical
57	57	Recovered
58	58	Recovered
59	59	Stable
60	60	Stable
61	61	Improving
62	62	Improving
63	63	Recovered
64	64	Improving
65	65	Stable
66	66	Recovered
67	67	Critical
68	68	Stable
69	69	Critical
70	70	Stable
71	71	Improving
72	72	Stable
73	73	Critical
74	74	Recovered
75	75	Critical
76	76	Improving
77	77	Recovered
78	78	Critical
79	79	Stable
80	80	Improving
\.


--
-- TOC entry 3823 (class 0 OID 50294)
-- Dependencies: 231
-- Data for Name: dim_patient_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dim_patient_data (patient_id, name, address, dob, gender, contact, blood_group) FROM stdin;
1	Carlos Bates	824 Rodriguez Knoll, Lake Rebeccaside, MH 14071	1976-04-10	F	6641996166	O-
2	Allen Craig	USS Allen, FPO AA 28110	1979-05-18	M	7376831621	B-
3	Patricia Paul	997 Jeff Plains, Coopermouth, OK 98467	1980-08-11	M	2218027265	O+
4	Mrs. Mackenzie Holland DVM	01101 Matthew Plain Apt. 459, New Lawrence, WA 77247	1965-10-22	F	7002882922	O-
5	Kelly Grant	03303 Jason Mountain Apt. 389, West Kelly, TN 09932	1978-10-27	F	5494764033	B-
6	Clifford Norris	0509 Hayes Plains, Jacobsfurt, DE 27237	1980-03-09	M	4422531600	O-
7	Jennifer Elliott	USNV Davis, FPO AP 43235	2005-11-26	F	5817193846	B-
8	Tiffany Lutz	41950 Martinez Mission, New Jennifertown, MD 11972	2005-02-14	F	1979663871	AB+
9	Jasmine Carter	1353 Caldwell Squares, Alisonberg, NM 98471	1961-11-17	F	4974382213	AB-
10	Brandon Flores	1274 Jerry Shoal, Georgeside, ND 05614	1975-08-21	F	8831302299	AB+
11	Ebony Farmer	138 Pennington Square Apt. 280, Seanstad, MP 74643	1986-05-20	M	9797286398	O-
12	Casey Hernandez	9562 Jennifer Centers, Thompsonmouth, NM 98099	1995-03-25	M	3722196844	A+
13	Matthew Pierce	221 Moreno Points, New Melissashire, PW 52752	1979-10-21	F	9761577405	AB+
14	Jessica Beasley	364 Guzman Trafficway Apt. 084, New Nicholasburgh, IA 35082	1972-08-08	M	9759891198	O-
15	Taylor Campbell	57427 King Isle Suite 752, Leeside, TX 80202	1977-06-08	M	4341246992	A+
16	Luis Clark	252 Guzman Vista Suite 561, Lake Calebshire, WV 71055	1994-01-20	F	3959777900	O+
17	Michael Wright	34836 Linda Lights, Christyburgh, ND 81826	1964-03-13	F	9595872305	A+
18	Kathy Silva	USS Collins, FPO AA 64326	1966-08-19	F	6531193550	O+
19	Jason Graham	41418 Young Spring, Michellehaven, WY 12968	1963-01-11	M	5946968326	O+
20	James Lowe	740 Moore Village Suite 312, Josephbury, WA 57136	1965-12-15	F	7446431242	A+
21	Shawn Bennett	5790 Singleton Drive, Alexahaven, DE 90628	1988-04-14	M	3291777769	A+
22	David Chambers	Unit 2606 Box 3620, DPO AP 61744	1986-09-11	F	7581168845	O-
23	Renee Henson	99466 Bradley Highway Apt. 390, East Kristinafurt, IA 86207	1992-11-08	M	7956012171	O-
24	Jeanne Guzman	6729 Madison Ports, Lake Michaelchester, ID 12864	1996-08-08	M	8081058430	AB+
25	Jesse Chapman	98381 Gomez Ferry Suite 327, West Alexander, WI 24937	1992-05-16	M	5986324494	AB-
26	Mark Hensley	56484 Banks Parkways Suite 421, North Pamelaville, KS 23784	1965-12-15	M	2368921470	AB-
27	Hannah Caldwell	79203 Joseph Isle Suite 634, Johnhaven, VI 63795	1962-09-26	F	5579638359	B+
28	Jonathan Robinson	08071 Fernandez Valley Suite 675, North Kristyside, MD 73691	1997-02-25	F	8274358152	B+
29	Dr. Daniel Hill	07663 Kristy Stravenue Apt. 345, Bellfort, CT 62799	2003-08-14	M	1962085245	AB-
30	Doris Hicks	12790 Robles Circle, Ramirezland, NJ 73306	1997-06-16	M	3764291912	O+
31	Jennifer Garrett	9940 Smith Summit Suite 495, Shawnbury, SD 11377	1979-01-27	M	7416179263	AB+
32	Donald Sanchez	259 Nicholas Spring Apt. 620, New Susan, PA 57259	1994-03-22	M	9941717579	B+
33	Stephanie Koch	PSC 5754, Box 3876, APO AE 01410	1982-11-25	M	3086637509	O+
34	Thomas Little	368 David Mill Apt. 706, Port Angel, OH 67652	1997-04-01	F	2987184206	O+
35	Michael Brooks	134 Carter Drive Apt. 513, Courtneystad, WI 13017	1988-05-28	F	9999689294	O+
36	Victoria Young	138 Jamie Locks Apt. 469, Lewisfurt, SC 40913	1961-01-24	F	4071367069	A+
37	Christina Ware	983 Evan Green, Rogersbury, NY 07408	1996-09-24	M	3717084377	AB+
38	Ann Patel	86143 Joshua Wells Suite 477, West Kathrynville, ME 94602	1996-09-01	M	8004299328	B-
39	Brandi Graham	USNV Hunt, FPO AE 97097	2001-12-25	F	9464963025	A+
40	Sandra Schultz	2771 Grace Radial, North Taylorfurt, NJ 59371	1995-08-01	F	9188078468	B+
41	Valerie King	36906 Michele Viaduct, West Courtneyville, SC 57832	2002-11-05	M	8874248529	B-
42	Samantha Howard	Unit 0705 Box 6428, DPO AE 76262	2005-02-10	M	9682696502	O-
43	Amber Peters	448 Johnson Hill Suite 634, East Chrisville, WV 65189	2003-08-12	M	9955959323	B+
44	Michelle Bautista	89076 Briggs Roads Suite 318, Lisaborough, AZ 04859	1961-09-01	M	9257945800	A+
45	Richard Rojas	669 Ann Ranch Suite 157, Colemanhaven, GU 21635	1966-02-16	F	5624167955	O+
46	Spencer Williams	51686 Edwards Road, Gallagherbury, SD 29951	1966-02-23	F	5548462015	B-
47	Stuart Mann	PSC 6194, Box 3619, APO AA 36385	1992-11-11	M	9566633437	B+
48	George Poole	PSC 5168, Box 0097, APO AE 60929	1987-05-09	F	5555495986	O-
49	Dr. Teresa Johnson	3032 Denise Locks, South Robert, IL 11671	1981-11-22	M	8661115475	A+
50	Eric Carr	Unit 3275 Box 0290, DPO AA 76066	1987-10-01	M	7075445708	AB-
51	Amanda Taylor	123 Adams Ferry, Brittanybury, TX 19087	1988-03-09	M	8928937998	AB-
52	Julie Hall	142 Hicks Lane, Larsonside, IL 14586	1969-10-19	F	1004985311	B+
53	Alex Thornton DDS	068 Gonzales Forks Suite 458, Robertview, VA 66604	1993-09-19	M	7602747104	A+
54	Michael Montgomery	9160 Morris Drive, Heatherfort, KS 77844	1974-02-26	M	9431976153	A-
55	Tammy Davis	18601 Michael Knolls, East Jillianmouth, GA 75190	1974-02-19	F	9051352982	A-
56	Katie Wallace	046 Petty Cove, Lake Cody, MT 34332	2003-03-18	M	5808421207	O+
57	Elizabeth Taylor	113 Jennings Fork Suite 628, Port Robertfurt, MI 95371	1990-06-19	F	4676752314	A-
58	Taylor Diaz	2344 Tonya Meadows, Karenstad, NY 19371	2005-01-16	F	3433299018	AB+
59	Paul Oneill	PSC 9972, Box 6306, APO AA 28778	2001-08-10	F	3514541781	O-
60	Jose Lawrence	47006 Young Mountain Suite 377, Arianachester, MS 15537	1993-12-05	M	7276473605	B+
61	Kelsey Green	47253 Ortega Trail Suite 532, Barnettmouth, WA 17192	1969-09-04	M	5569753502	O-
62	Wayne Wallace	798 Snyder Valleys, South Thomas, GA 07622	1976-07-14	M	9158877015	A-
63	Tracie Williams	147 Gonzalez Plains, Moniquemouth, SD 32360	1971-10-27	M	8347718850	A-
64	Kelly Murray	1563 Randy Circle, Zunigaton, NC 45718	1967-09-10	M	5415291264	A+
65	Tyler Zhang	26488 Johnny Locks, East Ambertown, AS 66703	2004-12-04	M	4438585118	AB-
66	Christopher Simmons	0337 Ramsey Land Apt. 116, Mcgeestad, NM 30326	1976-06-09	M	6538196415	AB-
67	Kimberly Jackson	1497 Wilson Shoals Suite 418, North John, PW 33065	1998-11-27	M	4584368658	O-
68	Joseph Johnson	31746 Zavala Turnpike Apt. 592, East Sylvia, MT 90012	1967-01-20	M	9043252800	O+
69	Dorothy Bell	Unit 5451 Box 3451, DPO AE 31216	1974-10-27	F	7845906574	B-
70	Kevin Lee	6489 Stafford Crest Apt. 784, Dennisfort, ND 78454	1976-01-26	F	7893401584	A+
71	Matthew Webb	702 Wilkinson Roads Suite 885, North Nicoleshire, AZ 58342	2003-06-02	M	5492987487	A+
72	Nathan Larsen	6645 Carroll Island Apt. 588, Oliviaton, MP 84518	1999-01-25	M	1218035384	O-
73	Nicole Thomas	176 Heather Camp Suite 854, Thompsonside, MO 31970	1987-03-05	M	4141611556	A-
74	Stephanie Jones	227 David Roads, West Heidi, AZ 80214	1965-10-10	F	6682871595	O-
75	Jonathan Waters	8065 Schaefer Villages, Port Peter, UT 88980	1985-05-26	F	4043884294	AB+
76	Brenda Evans	0916 Williamson Park Suite 087, Jessicafort, CT 22713	1972-04-17	F	5472136709	A+
77	Holly Allen	93554 Rios Path, Steelebury, GU 93675	2004-04-10	F	8677673827	AB+
78	Lisa Davis	4379 Ferguson Route, Parkerbury, VA 69169	1963-08-16	F	4433812158	A-
79	Bruce Charles	4039 Boyer Via, Robbinstown, MD 51349	1987-02-20	M	2972031030	B-
80	Cynthia Garcia	736 Dakota Hill, Wrightmouth, ID 95799	1961-01-10	F	6417721116	O+
81	Michelle Rodriguez	369 Cherry Lane	1990-08-15	F	5551112222	B-
82	Emily Thompson	369 Pear Street	1992-10-10	F	5555556666	A-
83	John Doe	123 Main Street	1990-01-15	M	5551234567	A+
84	Jane Smith	456 Elm Street	1985-07-22	F	5559878543	AB+
85	Michael Johnson	789 Oak Avenue	1992-03-10	M	5557891234	B+
86	Emily Wilson	321 Pine Street	1988-09-27	F	5554567890	O-
87	David Lee	555 Maple Lane	1974-12-05	M	5552223333	A-
88	Sarah Anderson	987 Willow Road	1995-06-18	F	5554445555	B-
89	Robert Wilson	753 Elmwood Avenue	1982-11-30	M	5556668777	O+
90	Jennifer Brown	456 Oak Street	1998-02-12	F	5558889999	AB-
91	Daniel Thompson	987 Pine Avenue	1987-07-05	M	5551112222	B+
92	Jessica Evans	369 Maple Lane	1991-04-19	F	5553334444	A-
93	Andrew Davis	852 Elmwood Avenue	1979-09-03	M	5555556666	O+
94	Rachel Taylor	369 Willow Road	1984-12-28	F	5557778888	AB+
95	Michaela Moore	852 Pine Avenue	1993-05-08	F	5559990000	O-
\.


--
-- TOC entry 3814 (class 0 OID 50161)
-- Dependencies: 222
-- Data for Name: doctors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.doctors (doctor_id, first_name, last_name, gender, contact_number, specialty) FROM stdin;
DOC0001	John	Kelly	M	3954612629	Surgeon
DOC0002	Stephanie	Willis	F	5894612025	Physician Executive
DOC0003	Jessica	Strong	M	4811071322	Oncologist
DOC0004	Alan	Wilson	F	6157027105	Pediatrician
DOC0005	William	Skinner	M	2452251405	Ophthalmologist
DOC0006	Cynthia	Hobbs	M	4233498682	Radiologist
DOC0007	Deborah	Frederick	F	1286751529	Dermatologist
DOC0008	Dylan	Williams	F	1028987805	Surgeon
DOC0009	Timothy	Mccarty	M	5356928248	Neurologist
DOC0010	Joshua	Watson	M	6683759129	Oncologist
DOC0011	Joseph	Church	M	4377438375	Gastroenterologist
DOC0012	Candice	Diaz	F	7178521028	Infectious Disease
DOC0013	Mary	Jensen	M	9201226808	Obstetrician/Gynecologist (OBGYN)
DOC0014	Ryan	Ramirez	M	4743026850	Physician Executive
DOC0015	Bryce	Duke	F	3663662341	Pulmonologist
DOC0016	Joshua	Greene	F	7167708092	Infectious Disease
DOC0017	Natalie	Thomas	M	8227973487	Endocrinologist
DOC0018	Suzanne	Burgess	M	8369256764	Family Medicine
DOC0019	Jasmine	Miller	F	4591428062	Gastroenterologist
DOC0020	Daniel	Sharp	M	7789338173	Anesthesiologist
\.


--
-- TOC entry 3839 (class 0 OID 57936)
-- Dependencies: 247
-- Data for Name: fact_billing_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fact_billing_info (treatment_id, bill_number, bill_date, amt, total_amt, payment_type, payment_status, payment_date) FROM stdin;
1	1	2023-05-19	123.07	135.38	Debit Card	Overdue	2023-06-13
2	2	2022-12-20	597.61	657.37	Credit Card	Paid	2023-01-16
3	3	2022-10-19	355.72	391.29	Check	Pending	2022-10-30
4	4	2023-06-06	962.89	1059.18	Credit Card	Paid	2023-06-24
5	5	2022-06-24	303.45	333.80	Check	Overdue	2022-06-29
6	6	2023-05-28	92.03	101.23	Credit Card	Paid	2023-06-12
7	7	2023-02-26	498.68	548.55	Cash	Paid	2023-03-26
8	8	2022-07-28	495.80	545.38	Check	Paid	2022-08-17
9	9	2023-03-31	96.50	106.15	Credit Card	Overdue	2023-04-28
10	10	2022-09-12	731.58	804.74	Cash	Paid	2022-09-29
11	11	2023-01-29	774.94	852.43	Check	Pending	2023-02-05
12	12	2023-02-26	934.74	1028.21	Cash	Pending	2023-03-20
13	13	2023-06-10	635.63	699.19	Check	Paid	2023-07-06
14	14	2023-04-07	990.74	1089.81	Debit Card	Overdue	2023-05-07
15	15	2023-01-29	825.04	907.54	Debit Card	Paid	2023-02-06
16	16	2022-09-16	809.63	890.59	Check	Overdue	2022-10-07
17	17	2023-02-23	494.66	544.13	Debit Card	Pending	2023-02-26
18	18	2022-10-22	246.14	270.75	Check	Paid	2022-11-02
19	19	2023-05-06	242.42	266.66	Debit Card	Pending	2023-05-25
20	20	2022-07-26	834.83	918.31	Credit Card	Pending	2022-07-30
21	21	2023-04-11	599.16	659.08	Check	Paid	2023-04-17
22	22	2023-01-16	51.31	56.44	Check	Overdue	2023-02-04
23	23	2022-09-04	626.49	689.14	Check	Overdue	2022-09-28
24	24	2023-02-17	866.44	953.08	Cash	Paid	2023-02-23
25	25	2023-04-03	240.83	264.91	Credit Card	Paid	2023-04-29
26	26	2022-10-20	400.73	440.80	Cash	Overdue	2022-10-24
27	27	2023-06-01	71.79	78.97	Credit Card	Pending	2023-06-20
28	28	2022-10-20	336.81	370.49	Check	Overdue	2022-10-29
29	29	2023-06-07	838.59	922.45	Credit Card	Paid	2023-06-22
30	30	2023-04-01	397.17	436.89	Debit Card	Pending	2023-04-14
31	31	2023-05-28	830.21	913.23	Check	Overdue	2023-06-17
32	32	2022-09-30	149.03	163.93	Credit Card	Overdue	2022-10-16
33	33	2022-11-01	590.47	649.52	Credit Card	Paid	2022-11-08
34	34	2022-12-14	520.45	572.50	Debit Card	Pending	2022-12-30
35	35	2023-02-16	191.99	211.19	Check	Pending	2023-03-17
36	36	2023-04-13	524.25	576.68	Debit Card	Paid	2023-04-14
37	37	2022-08-04	168.41	185.25	Debit Card	Paid	2022-08-18
38	38	2022-10-21	416.24	457.86	Credit Card	Pending	2022-11-05
39	39	2023-05-07	804.48	884.93	Cash	Pending	2023-05-24
40	40	2022-10-01	597.18	656.90	Credit Card	Paid	2022-10-10
41	41	2023-03-09	959.11	1055.02	Credit Card	Pending	2023-03-27
42	42	2023-06-09	138.90	152.79	Credit Card	Overdue	2023-06-26
43	43	2023-02-04	817.59	899.35	Cash	Overdue	2023-02-06
44	44	2022-12-28	987.01	1085.71	Debit Card	Overdue	2022-12-30
45	45	2022-10-02	256.23	281.85	Credit Card	Paid	2022-11-01
46	46	2022-11-05	510.65	561.72	Debit Card	Pending	2022-11-15
47	47	2022-08-23	509.59	560.55	Check	Paid	2022-09-12
48	48	2022-09-22	82.85	91.14	Check	Paid	2022-10-14
49	49	2022-12-31	209.08	229.99	Check	Pending	2023-01-05
50	50	2023-04-11	732.87	806.16	Credit Card	Paid	2023-05-04
51	51	2023-05-15	186.98	205.68	Credit Card	Overdue	2023-05-19
52	52	2023-02-21	143.92	158.31	Debit Card	Paid	2023-03-02
53	53	2022-06-20	53.33	58.66	Debit Card	Overdue	2022-07-13
54	54	2023-03-06	609.66	670.63	Credit Card	Overdue	2023-03-14
55	55	2022-09-27	575.63	633.19	Cash	Paid	2022-10-26
56	56	2022-09-30	827.42	910.16	Credit Card	Paid	2022-10-30
57	57	2022-10-28	879.60	967.56	Credit Card	Paid	2022-11-27
58	58	2023-05-14	240.38	264.42	Check	Paid	2023-05-16
59	59	2023-01-02	879.86	967.85	Credit Card	Overdue	2023-01-03
60	60	2023-01-31	274.99	302.49	Check	Paid	2023-02-09
61	61	2022-07-14	938.08	1031.89	Cash	Paid	2022-07-15
62	62	2022-06-27	574.14	631.55	Credit Card	Pending	2022-07-17
63	63	2022-09-14	747.98	822.78	Debit Card	Pending	2022-09-23
64	64	2023-05-08	69.03	75.93	Debit Card	Pending	2023-05-28
65	65	2022-09-18	972.28	1069.51	Check	Pending	2022-10-15
66	66	2022-12-09	961.41	1057.55	Debit Card	Paid	2022-12-15
67	67	2022-09-19	687.73	756.50	Debit Card	Paid	2022-09-26
68	68	2022-11-19	83.96	92.36	Credit Card	Paid	2022-11-20
69	69	2022-07-20	429.06	471.97	Debit Card	Paid	2022-08-05
70	70	2023-01-15	552.97	608.27	Credit Card	Paid	2023-01-20
71	71	2022-07-29	573.18	630.50	Cash	Pending	2022-07-31
72	72	2022-07-30	860.00	946.00	Credit Card	Pending	2022-08-06
73	73	2023-05-18	242.36	266.60	Debit Card	Pending	2023-05-23
74	74	2022-11-13	493.36	542.70	Credit Card	Paid	2022-11-15
75	75	2023-02-07	819.52	901.47	Credit Card	Pending	2023-03-01
76	76	2023-02-20	817.39	899.13	Credit Card	Overdue	2023-03-22
77	77	2022-11-08	612.30	673.53	Debit Card	Pending	2022-11-11
78	78	2023-04-30	900.23	990.25	Debit Card	Overdue	2023-05-08
79	79	2022-09-24	195.80	215.38	Cash	Paid	2022-10-20
80	80	2022-10-17	507.92	558.71	Check	Pending	2022-11-13
\.


--
-- TOC entry 3831 (class 0 OID 50379)
-- Dependencies: 239
-- Data for Name: fact_insurance_claims; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fact_insurance_claims (insurance_id, patient_id, provider_name, insurance_type, expiry) FROM stdin;
66624	1	P-9	Bronze	2024-02-25
78597	2	P-10	Silver	2023-11-20
89839	3	P-4	Gold	2023-07-30
35084	4	P-4	Bronze	2023-10-18
40546	5	P-3	Gold	2024-01-22
28306	6	P-6	Bronze	2023-06-23
43967	7	P-3	Bronze	2023-10-09
93568	8	P-10	Platinum	2024-05-01
17350	9	P-9	Gold	2024-03-14
74957	10	P-1	Bronze	2023-12-02
33357	11	P-2	Platinum	2023-08-05
99038	12	P-1	Silver	2023-11-06
61453	13	P-2	Gold	2024-02-25
21391	14	P-3	Gold	2023-10-06
40249	15	P-5	Gold	2023-09-30
96263	16	P-10	Gold	2023-07-26
39677	17	P-6	Silver	2024-04-13
21731	18	P-1	Silver	2024-05-04
69641	19	P-6	Gold	2024-03-02
48783	20	P-2	Silver	2023-08-15
41583	21	P-1	Silver	2024-02-25
63211	22	P-3	Bronze	2023-08-08
75610	23	P-1	Bronze	2023-10-28
44875	24	P-6	Silver	2023-09-14
94583	25	P-7	Bronze	2023-12-17
94287	26	P-9	Platinum	2024-05-23
36127	27	P-4	Gold	2024-02-17
75906	28	P-7	Silver	2024-02-04
45218	29	P-2	Bronze	2024-03-08
51778	30	P-4	Silver	2023-11-21
21463	31	P-3	Silver	2024-04-26
88212	32	P-6	Silver	2024-01-25
28291	33	P-8	Gold	2024-03-13
85950	34	P-3	Silver	2024-02-10
22941	35	P-7	Platinum	2023-10-23
69838	36	P-4	Gold	2023-07-12
77665	37	P-10	Bronze	2023-09-05
47601	38	P-5	Platinum	2023-11-20
83717	39	P-10	Gold	2024-05-08
82617	40	P-8	Bronze	2024-04-16
92220	41	P-1	Bronze	2023-12-07
39404	42	P-1	Gold	2023-09-01
70534	43	P-8	Gold	2024-06-06
60859	44	P-5	Bronze	2023-08-04
95534	45	P-3	Gold	2023-11-02
97421	46	P-8	Bronze	2023-11-05
26212	47	P-10	Platinum	2023-09-19
74382	48	P-1	Platinum	2024-04-29
65832	49	P-7	Bronze	2023-12-26
96210	50	P-4	Platinum	2024-04-16
98991	51	P-8	Silver	2023-09-13
88376	52	P-6	Gold	2023-07-25
35868	53	P-5	Bronze	2024-01-25
53891	54	P-8	Platinum	2024-01-22
85226	55	P-4	Bronze	2024-04-28
78863	56	P-3	Platinum	2024-03-18
94355	57	P-8	Gold	2024-03-08
92632	58	P-6	Platinum	2024-01-05
70923	59	P-10	Platinum	2024-05-30
29019	60	P-1	Gold	2023-09-05
19945	61	P-8	Bronze	2023-10-05
79755	62	P-4	Gold	2024-01-11
61403	63	P-5	Platinum	2024-04-22
11219	64	P-7	Platinum	2024-04-18
95938	65	P-1	Silver	2023-09-25
91192	66	P-8	Silver	2024-05-05
63737	67	P-7	Platinum	2024-05-11
85752	68	P-9	Platinum	2024-05-04
75114	69	P-6	Silver	2023-07-11
22347	70	P-7	Bronze	2024-03-19
35962	71	P-2	Gold	2023-12-24
18762	72	P-8	Bronze	2024-06-08
40105	73	P-4	Bronze	2024-02-29
93598	74	P-2	Bronze	2023-10-15
68229	75	P-5	Silver	2023-08-13
92843	76	P-5	Silver	2024-03-06
85443	77	P-9	Platinum	2023-07-04
63630	78	P-7	Gold	2023-07-15
82939	79	P-1	Bronze	2024-06-14
41436	80	P-2	Silver	2023-11-29
\.


--
-- TOC entry 3829 (class 0 OID 50358)
-- Dependencies: 237
-- Data for Name: fact_treatment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fact_treatment (treatment_id, diagnosis_id, begin_date, end_date) FROM stdin;
1	447SHA8O	2023-03-08	2024-12-09
2	519HZZ2Z	2024-10-05	2024-05-18
3	292TUW1D	2023-08-02	2025-12-24
4	975GZD5M	2023-05-19	2025-07-16
5	927NUP2N	2023-12-04	2025-06-09
6	837VAQ7U	2023-11-10	2025-10-10
7	879LCG1S	2023-10-28	2024-05-01
8	751VTH0M	2023-01-26	2025-12-26
9	629PXL3S	2024-02-11	2024-02-15
10	207AUM8U	2024-05-11	2024-04-25
11	473CLQ4I	2023-07-28	2025-02-09
12	511ZUS5W	2023-03-06	2025-07-01
13	629VTJ2Q	2024-11-24	2025-02-21
14	957OZT3M	2024-05-01	2025-11-12
15	494CYH2D	2023-05-03	2024-03-27
16	424MMC3N	2023-04-28	2024-10-14
17	277XVU0N	2023-10-19	2025-06-06
18	482KHG2D	2024-07-02	2025-07-18
19	400VZL5M	2023-05-03	2025-07-04
20	560EZZ0D	2024-11-27	2024-12-13
21	135QPV4Q	2024-12-11	2024-03-27
22	728BNN6Q	2023-08-25	2024-02-16
23	528BNO9C	2024-08-18	2025-08-13
24	236XWX5X	2023-09-05	2024-11-20
25	826JUY7B	2023-09-26	2024-08-03
26	152AGT0F	2024-06-16	2025-10-08
27	754TJC0O	2024-08-06	2024-07-21
28	679EWC3R	2024-05-22	2024-01-08
29	366TUO4H	2023-11-04	2024-05-06
30	913EDR1M	2024-10-27	2024-03-16
31	329ZGS3D	2024-02-11	2024-08-24
32	688OAD0C	2024-11-15	2024-07-26
33	823MWO5M	2024-08-17	2025-10-17
34	362FOX2P	2023-06-28	2024-06-05
35	863WKE4Z	2024-04-12	2024-01-09
36	354EQN7S	2024-06-06	2024-12-28
37	309AIX7G	2023-05-01	2025-10-12
38	931VWY0O	2023-06-24	2024-03-03
39	277MSR6L	2023-10-10	2024-02-21
40	269UME1Q	2024-03-01	2024-06-09
41	516GNU8G	2023-03-16	2025-03-12
42	745BXS4B	2024-11-20	2025-09-02
43	832SCR7O	2024-06-04	2025-03-21
44	955MOZ1M	2023-04-21	2025-11-23
45	837NKA9B	2023-04-05	2024-05-18
46	401TAF0H	2023-10-20	2025-02-19
47	610ZBX6T	2023-08-19	2024-04-27
48	261JDX0P	2023-03-21	2024-03-07
49	739MOK2H	2023-05-10	2025-10-26
50	391IFN2P	2023-06-27	2024-09-05
51	111XDO3P	2023-01-02	2024-11-08
52	238RTX9A	2024-03-11	2025-03-26
53	789AXJ7E	2024-08-01	2024-12-23
54	769MSB7W	2023-12-01	2024-12-12
55	972XMM8E	2024-11-09	2025-11-09
56	976OTV4A	2024-06-22	2025-02-06
57	134RLM8B	2024-12-28	2024-07-15
58	473YKX1H	2023-02-09	2024-05-14
59	148ORC2A	2023-11-14	2025-10-11
60	555GMH3Y	2024-01-05	2024-03-20
61	185UJB9C	2023-09-01	2025-04-13
62	273AEL4M	2023-09-14	2024-03-21
63	201UJK5G	2024-10-04	2025-03-26
64	669KNY3U	2024-05-02	2025-12-11
65	178DBH0P	2023-09-06	2025-05-22
66	887FAB8N	2024-08-11	2024-05-08
67	769GIH5C	2024-11-10	2025-11-24
68	601SPK2I	2024-10-10	2025-04-28
69	192MOO0S	2024-11-11	2025-05-01
70	696WXF3X	2023-01-13	2024-09-11
71	439TQR6M	2024-11-27	2024-12-02
72	270OWK6L	2024-04-03	2024-08-26
73	447YXX9Z	2024-11-13	2025-10-08
74	354RVE2A	2023-01-01	2025-03-01
75	636LLM1F	2024-01-07	2025-08-20
76	875JRK1J	2023-02-26	2025-06-11
77	324MPR8S	2024-03-25	2024-11-10
78	258HQN7I	2024-12-05	2024-06-17
79	688TZX9Q	2023-09-20	2025-09-03
80	902YEX3J	2024-12-20	2025-01-16
\.


--
-- TOC entry 3834 (class 0 OID 57865)
-- Dependencies: 242
-- Data for Name: fact_vital_signs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fact_vital_signs (vs_id, diagnosis_id, blood_pressure, oxygen, temperature, heart_rate, weight, height, bmi) FROM stdin;
2	447SHA8O	137	100	36.20	62	99.30	189	27.80
3	519HZZ2Z	100	92	37.80	118	90.20	162	34.37
4	292TUW1D	104	98	38.70	72	81.00	161	31.25
5	975GZD5M	93	99	36.50	61	97.50	176	31.48
6	927NUP2N	85	98	37.40	82	78.10	163	29.40
7	837VAQ7U	98	94	38.00	66	96.90	150	43.07
8	879LCG1S	103	93	36.80	82	76.00	190	21.05
9	751VTH0M	136	100	36.90	77	96.50	170	33.39
10	629PXL3S	83	91	37.30	88	91.20	157	37.00
11	207AUM8U	87	100	36.90	63	88.10	158	35.29
12	473CLQ4I	87	91	38.90	101	91.30	162	34.79
13	511ZUS5W	134	94	36.90	111	58.80	167	21.08
14	629VTJ2Q	95	98	37.50	110	53.00	187	15.16
15	957OZT3M	113	94	38.80	105	83.30	157	33.79
16	494CYH2D	119	93	38.20	72	75.20	163	28.30
17	424MMC3N	88	96	36.50	62	67.30	151	29.52
18	277XVU0N	111	91	38.30	116	98.90	162	37.68
19	482KHG2D	122	97	39.00	64	95.70	151	41.97
20	400VZL5M	109	94	36.40	103	65.70	164	24.43
21	560EZZ0D	81	96	37.80	60	53.20	162	20.27
22	135QPV4Q	133	100	37.80	117	56.60	189	15.85
23	728BNN6Q	133	94	36.70	96	64.90	167	23.27
24	528BNO9C	118	97	36.80	119	73.40	186	21.22
25	236XWX5X	89	94	36.50	116	57.70	161	22.26
26	826JUY7B	82	94	38.10	117	92.00	172	31.10
27	152AGT0F	128	94	37.70	90	72.40	171	24.76
28	754TJC0O	122	95	37.70	75	51.40	172	17.37
29	679EWC3R	88	98	38.80	97	63.20	152	27.35
30	366TUO4H	115	96	36.10	113	77.50	172	26.20
31	913EDR1M	92	93	38.70	110	60.50	163	22.77
32	329ZGS3D	99	91	38.00	101	66.70	161	25.73
33	688OAD0C	138	99	37.10	76	91.20	158	36.53
34	823MWO5M	95	90	36.90	65	69.20	181	21.12
35	362FOX2P	81	100	37.40	87	98.30	188	27.81
36	863WKE4Z	124	90	38.40	91	53.80	168	19.06
37	354EQN7S	114	91	38.90	118	58.10	183	17.35
38	309AIX7G	88	96	38.80	76	77.80	188	22.01
39	931VWY0O	139	97	37.50	88	82.80	189	23.18
40	277MSR6L	100	100	37.30	90	70.50	157	28.60
41	269UME1Q	80	94	36.60	103	91.00	180	28.09
42	516GNU8G	82	91	38.10	82	86.40	186	24.97
43	745BXS4B	105	94	38.40	120	70.70	163	26.61
44	832SCR7O	117	99	37.80	63	50.80	162	19.36
45	955MOZ1M	112	93	36.70	64	66.00	175	21.55
46	837NKA9B	132	97	37.30	110	64.20	170	22.21
47	401TAF0H	139	91	38.80	97	58.70	187	16.79
48	610ZBX6T	81	93	38.90	96	68.70	159	27.17
49	261JDX0P	130	95	37.70	96	51.70	152	22.38
50	739MOK2H	127	100	37.50	65	93.50	179	29.18
51	391IFN2P	109	96	37.50	92	79.80	161	30.79
52	111XDO3P	114	95	38.50	86	98.00	180	30.25
53	238RTX9A	131	93	36.60	96	98.80	175	32.26
54	789AXJ7E	102	96	37.30	66	78.40	175	25.60
55	769MSB7W	122	100	37.80	94	67.70	179	21.13
56	972XMM8E	91	94	36.60	102	64.00	187	18.30
57	976OTV4A	129	100	36.80	77	76.80	187	21.96
58	134RLM8B	80	95	37.30	78	83.90	153	35.84
59	473YKX1H	130	91	36.30	77	75.50	188	21.36
60	148ORC2A	114	96	38.70	96	79.10	166	28.71
61	555GMH3Y	138	98	38.50	75	52.00	152	22.51
62	185UJB9C	128	99	37.30	105	56.40	173	18.84
63	273AEL4M	106	91	38.30	64	74.10	153	31.65
64	201UJK5G	97	93	36.10	111	80.60	177	25.73
65	669KNY3U	106	98	38.00	119	81.30	162	30.98
66	178DBH0P	90	90	38.50	115	54.30	175	17.73
67	887FAB8N	89	100	37.60	62	87.00	180	26.85
68	769GIH5C	95	96	38.10	104	52.40	150	23.29
69	601SPK2I	84	90	38.80	100	60.20	190	16.68
70	192MOO0S	115	92	36.10	111	78.40	186	22.66
71	696WXF3X	109	100	37.60	114	81.10	176	26.18
72	439TQR6M	139	92	36.80	95	97.80	161	37.73
73	270OWK6L	86	91	36.70	63	78.70	178	24.84
74	447YXX9Z	127	99	37.40	72	55.50	150	24.67
75	354RVE2A	89	98	38.80	114	86.20	161	33.25
76	636LLM1F	118	94	37.40	104	63.00	171	21.55
77	875JRK1J	99	98	37.80	101	52.80	189	14.78
78	324MPR8S	114	96	38.30	101	50.60	190	14.02
79	258HQN7I	109	95	39.00	77	83.00	189	23.24
80	688TZX9Q	99	100	36.40	101	98.80	176	31.90
81	902YEX3J	131	99	36.50	60	92.40	180	28.52
\.


--
-- TOC entry 3822 (class 0 OID 50268)
-- Dependencies: 230
-- Data for Name: insurance_claims; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.insurance_claims (insurance_id, patient_id, provider_name, insurance_type, expiry) FROM stdin;
66624	1	P-9	Bronze	2024-02-25
78597	2	P-10	Silver	2023-11-20
89839	3	P-4	Gold	2023-07-30
35084	4	P-4	Bronze	2023-10-18
40546	5	P-3	Gold	2024-01-22
28306	6	P-6	Bronze	2023-06-23
43967	7	P-3	Bronze	2023-10-09
93568	8	P-10	Platinum	2024-05-01
17350	9	P-9	Gold	2024-03-14
74957	10	P-1	Bronze	2023-12-02
33357	11	P-2	Platinum	2023-08-05
99038	12	P-1	Silver	2023-11-06
61453	13	P-2	Gold	2024-02-25
21391	14	P-3	Gold	2023-10-06
40249	15	P-5	Gold	2023-09-30
96263	16	P-10	Gold	2023-07-26
39677	17	P-6	Silver	2024-04-13
21731	18	P-1	Silver	2024-05-04
69641	19	P-6	Gold	2024-03-02
48783	20	P-2	Silver	2023-08-15
41583	21	P-1	Silver	2024-02-25
63211	22	P-3	Bronze	2023-08-08
75610	23	P-1	Bronze	2023-10-28
44875	24	P-6	Silver	2023-09-14
94583	25	P-7	Bronze	2023-12-17
94287	26	P-9	Platinum	2024-05-23
36127	27	P-4	Gold	2024-02-17
75906	28	P-7	Silver	2024-02-04
45218	29	P-2	Bronze	2024-03-08
51778	30	P-4	Silver	2023-11-21
21463	31	P-3	Silver	2024-04-26
88212	32	P-6	Silver	2024-01-25
28291	33	P-8	Gold	2024-03-13
85950	34	P-3	Silver	2024-02-10
22941	35	P-7	Platinum	2023-10-23
69838	36	P-4	Gold	2023-07-12
77665	37	P-10	Bronze	2023-09-05
47601	38	P-5	Platinum	2023-11-20
83717	39	P-10	Gold	2024-05-08
82617	40	P-8	Bronze	2024-04-16
92220	41	P-1	Bronze	2023-12-07
39404	42	P-1	Gold	2023-09-01
70534	43	P-8	Gold	2024-06-06
60859	44	P-5	Bronze	2023-08-04
95534	45	P-3	Gold	2023-11-02
97421	46	P-8	Bronze	2023-11-05
26212	47	P-10	Platinum	2023-09-19
74382	48	P-1	Platinum	2024-04-29
65832	49	P-7	Bronze	2023-12-26
96210	50	P-4	Platinum	2024-04-16
98991	51	P-8	Silver	2023-09-13
88376	52	P-6	Gold	2023-07-25
35868	53	P-5	Bronze	2024-01-25
53891	54	P-8	Platinum	2024-01-22
85226	55	P-4	Bronze	2024-04-28
78863	56	P-3	Platinum	2024-03-18
94355	57	P-8	Gold	2024-03-08
92632	58	P-6	Platinum	2024-01-05
70923	59	P-10	Platinum	2024-05-30
29019	60	P-1	Gold	2023-09-05
19945	61	P-8	Bronze	2023-10-05
79755	62	P-4	Gold	2024-01-11
61403	63	P-5	Platinum	2024-04-22
11219	64	P-7	Platinum	2024-04-18
95938	65	P-1	Silver	2023-09-25
91192	66	P-8	Silver	2024-05-05
63737	67	P-7	Platinum	2024-05-11
85752	68	P-9	Platinum	2024-05-04
75114	69	P-6	Silver	2023-07-11
22347	70	P-7	Bronze	2024-03-19
35962	71	P-2	Gold	2023-12-24
18762	72	P-8	Bronze	2024-06-08
40105	73	P-4	Bronze	2024-02-29
93598	74	P-2	Bronze	2023-10-15
68229	75	P-5	Silver	2023-08-13
92843	76	P-5	Silver	2024-03-06
85443	77	P-9	Platinum	2023-07-04
63630	78	P-7	Gold	2023-07-15
82939	79	P-1	Bronze	2024-06-14
41436	80	P-2	Silver	2023-11-29
\.


--
-- TOC entry 3821 (class 0 OID 50258)
-- Dependencies: 229
-- Data for Name: lab_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lab_results (lr_id, diagnosis_id, tests, test_results) FROM stdin;
1	447SHA8O	89485, 87943	Normal , No abnormalities detected
2	519HZZ2Z	87943	No abnormalities detected
3	292TUW1D	67821	Abnormal
4	975GZD5M	54637	Sinus rhythm
5	927NUP2N	89485, 54637, 67821	Normal, Sinus rhythm, Normal
6	837VAQ7U	87943	No abnormalities detected
7	879LCG1S	54637	Sinus rhythm
8	751VTH0M	89485	Abnormal
9	629PXL3S	89485	Normal
10	207AUM8U	67821	Normal
11	473CLQ4I	13234, 67821	Normal, Normal
12	511ZUS5W	54637	Ventricular tachycardia
13	629VTJ2Q	13234	Normal
14	957OZT3M	89485	Abnormal
15	494CYH2D	67821	Abnormal
16	424MMC3N	89485	Normal
17	277XVU0N	67821, 54637	Normal, Ventricular tachycardia
18	482KHG2D	13234	Abnormal
19	400VZL5M	63542	No fractures detected
20	560EZZ0D	65172	Abnormal
21	135QPV4Q	67821	Normal
22	728BNN6Q	87943	Tumor found
23	528BNO9C	63542	No fractures detected
24	236XWX5X	89485	Normal
25	826JUY7B	89485	Normal
26	152AGT0F	54637	Ventricular tachycardia
27	754TJC0O	13234	Abnormal
28	679EWC3R	63542	No fractures detected
29	366TUO4H	54637	Ventricular tachycardia
30	913EDR1M	65172	5.6
31	329ZGS3D	63542	No fractures detected
32	688OAD0C	87943	No abnormalities detected
33	823MWO5M	54637	Ventricular tachycardia
34	362FOX2P	13234	Normal
35	863WKE4Z	63542	No fractures detected
36	354EQN7S	89485	Normal
37	309AIX7G	67821	Normal
38	931VWY0O	63542	Fracture found
39	277MSR6L	67821, 54637	Tumor found, Atrial fibrillation
40	269UME1Q	13234	Normal
41	516GNU8G	13234	Abnormal
42	745BXS4B	54637	Ventricular tachycardia
43	832SCR7O	67821	Normal
44	955MOZ1M	54637	Ventricular tachycardia
45	837NKA9B	89485	Normal
46	401TAF0H	67821	Abnormal
47	610ZBX6T	87943	No abnormalities detected
48	261JDX0P	54637	Atrial fibrillation
49	739MOK2H	65172	6.7
50	391IFN2P	63542	Fracture found
51	111XDO3P	13234	Abnormal
52	238RTX9A	89485	Normal
53	789AXJ7E	13234	Normal
54	769MSB7W	13234	Normal
55	972XMM8E	54637	Sinus rhythm
56	976OTV4A	89485	Normal
57	134RLM8B	54637	Atrial fibrillation
58	473YKX1H	65172	3.5
59	148ORC2A	13234, 67821	Tumor found, Abnormal
60	555GMH3Y	54637	Sinus rhythm
61	185UJB9C	87943	No abnormalities detected
62	273AEL4M	63542	Fracture found
63	201UJK5G	63542	Fracture found
64	669KNY3U	87943	No abnormalities detected
65	178DBH0P	87943	No abnormalities detected
66	887FAB8N	63542	No fractures detected
67	769GIH5C	87943	No abnormalities detected
68	601SPK2I	13234	Normal
69	192MOO0S	89485	Abnormal
70	696WXF3X	67821	Normal
71	439TQR6M	89485	Normal
72	270OWK6L	87943	No abnormalities detected
73	447YXX9Z	87943	Normal
74	354RVE2A	67821	Abnormal
75	636LLM1F	65172	8.7
76	875JRK1J	87943	No abnormalities detected
77	324MPR8S	87943	No abnormalities detected
78	258HQN7I	87943	No abnormalities detected
79	688TZX9Q	65172	14
80	902YEX3J	67821	Normal
\.


--
-- TOC entry 3812 (class 0 OID 50146)
-- Dependencies: 220
-- Data for Name: medical_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medical_history (mh_id, patient_id, surgeries, allergies, medical_conditions) FROM stdin;
1	1	Hernia Repair	Shellfish	Bronchitis
2	2	Appendectomy	Dust	Arthritis
3	3	Cataract Surgery	Peanuts	Bronchitis
4	4	Hernia Repair	Peanuts	Migraine
5	5	Hernia Repair	Dust	Diabetes
6	6	Appendectomy	Dust	Arthritis
7	7	Gallbladder Removal	None	Bronchitis
8	8	Hernia Repair	Latex	Migraine
9	9	Hernia Repair	Dust	None
10	10	Knee Replacement	Latex	Depression
11	11	None	Dust	Bronchitis
12	12	Gallbladder Removal	Shellfish	Flu
13	13	Gallbladder Removal	Peanuts	Hypertension
14	14	Gallbladder Removal	Dust	Hypertension
15	15	Hernia Repair	Dust	Depression
16	16	Knee Replacement	Shellfish	Asthma
17	17	None	None	Diabetes
18	18	Hernia Repair	None	Pneumonia
19	19	None	Shellfish	Flu
20	20	Hernia Repair	Latex	Bronchitis
21	21	Gallbladder Removal	Dust	Pneumonia
22	22	Hernia Repair	Peanuts	Hypertension
23	23	Appendectomy	None	Flu
24	24	Hernia Repair	Dust	Asthma
25	25	Hernia Repair	Penicillin	None
26	26	Gallbladder Removal	Peanuts	Bronchitis
27	27	Hernia Repair	None	Depression
28	28	Appendectomy	Dust	Arthritis
29	29	Appendectomy	Dust	Migraine
30	30	Cataract Surgery	Latex	Asthma
31	31	Hernia Repair	Latex	Flu
32	32	Appendectomy	Shellfish	Flu
33	33	None	Penicillin	Migraine
34	34	None	Penicillin	Migraine
35	35	None	Penicillin	Arthritis
36	36	None	Latex	Hypertension
37	37	Knee Replacement	Peanuts	Bronchitis
38	38	Hernia Repair	None	Hypertension
39	39	Appendectomy	Peanuts	Pneumonia
40	40	None	Penicillin	Flu
41	41	None	Shellfish	Bronchitis
42	42	Knee Replacement	Latex	Diabetes
43	43	Cataract Surgery	Penicillin	Flu
44	44	Gallbladder Removal	Peanuts	None
45	45	Gallbladder Removal	None	Bronchitis
46	46	Gallbladder Removal	Peanuts	Arthritis
47	47	Hernia Repair	None	Hypertension
48	48	None	Penicillin	Arthritis
49	49	Cataract Surgery	Penicillin	Depression
50	50	Cataract Surgery	Latex	Depression
51	51	Gallbladder Removal	None	Arthritis
52	52	Appendectomy	Shellfish	Hypertension
53	53	Knee Replacement	Latex	Asthma
54	54	Gallbladder Removal	Penicillin	Migraine
55	55	Cataract Surgery	Latex	Pneumonia
56	56	Hernia Repair	Peanuts	Flu
57	57	Hernia Repair	Dust	Flu
58	58	Knee Replacement	Peanuts	Diabetes
59	59	Gallbladder Removal	None	Migraine
60	60	None	Latex	Asthma
61	61	Hernia Repair	Penicillin	Bronchitis
62	62	None	Peanuts	Arthritis
63	63	Knee Replacement	Peanuts	Arthritis
64	64	Cataract Surgery	Shellfish	Asthma
65	65	Knee Replacement	Shellfish	Depression
66	66	Knee Replacement	None	Pneumonia
67	67	Appendectomy	Latex	Diabetes
68	68	None	Peanuts	Depression
69	69	Appendectomy	Latex	Asthma
70	70	Hernia Repair	Dust	Diabetes
71	71	Appendectomy	Latex	Asthma
72	72	Gallbladder Removal	Penicillin	Asthma
73	73	Hernia Repair	None	Asthma
74	74	Gallbladder Removal	Penicillin	Pneumonia
75	75	Hernia Repair	Latex	Diabetes
76	76	Hernia Repair	None	Diabetes
77	77	Hernia Repair	Latex	Asthma
78	78	Appendectomy	Shellfish	Migraine
79	79	Gallbladder Removal	Dust	Depression
80	80	Appendectomy	Dust	None
\.


--
-- TOC entry 3819 (class 0 OID 50219)
-- Dependencies: 227
-- Data for Name: medicines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medicines (medicine_id, medicine_name, times_a_day, extra_doc_notes) FROM stdin;
1	Amoxicillin	1	Avoid alcohol during treatment
2	Lisinopril	1	Do not skip doses
3	Atorvastatin	2	Take with meals
4	Metformin	3	Store in a cool place
5	Omeprazole	3	Store in a cool place
6	Paracetamol	2	Avoid alcohol during treatment
7	Ibuprofen	1	Take with food or milk
8	Simvastatin	1	Avoid consuming grapefruit
9	Warfarin	2	Maintain consistent vitamin K intake
10	Fluoxetine	3	Notify if you experience worsening depression or suicidal thoughts
11	Albuterol	2	Rinse your mouth with water after using
12	Lisinopril	1	Avoid salt or salt substitutes
13	Hydrochlorothiazide	2	Stay adequately hydrated
14	Levothyroxine	1	Take this medication on an empty stomach
15	Amlodipine	3	Avoid sudden discontinuation 
\.


--
-- TOC entry 3815 (class 0 OID 50167)
-- Dependencies: 223
-- Data for Name: nurses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nurses (nurse_id, first_name, last_name, gender, contact_number) FROM stdin;
NUR0001	Lindsey	Morrison	F	7537619434
NUR0002	Will	Barr	M	5884967181
NUR0003	Helen	Young	F	1662874152
NUR0004	Andrea	Gonzales	F	3444542813
NUR0005	Michelle	Byrd	F	7975765201
NUR0006	Nate	Martin	M	8344647969
NUR0007	Sara	Watkins	F	5021887831
NUR0008	Ardian	Brown	M	6565438505
NUR0009	Jennifer	Adkins	F	4226755509
NUR0010	Chris	Copeland	M	1261683871
NUR0011	Sherry	Stevens	F	1352313366
NUR0012	Janet	Thomas	F	6106326795
NUR0013	Armor	White	M	2864486390
NUR0014	Daniel	Hayes	M	5932973442
NUR0015	Maria	Crawford	F	1571319440
NUR0016	Amy	Jones	F	4707406055
NUR0017	Leo	Manning	M	9261454360
NUR0018	Alan	Wilson	M	7733994355
NUR0019	Dorothy	Logan	F	4239945344
NUR0020	Jackie	Weber	F	2976649182
NUR0021	Adam	Gomez	M	8137261330
NUR0022	Andrea	Turner	F	5356276939
NUR0023	Luke	Leonard	M	9916019301
NUR0024	Hex	Gibson	M	2522484122
NUR0025	Lindsey	Mcclure	F	1237758164
NUR0026	Cole	Sparks	M	2264959893
NUR0027	Jasmine	Smith	F	3999218750
NUR0028	Jake	Rogers	M	5622762030
NUR0029	Alfred	Martin	M	5982136233
NUR0030	Joey	Olsen	M	9406749079
NUR0031	Linda	Moore	F	7787789434
\.


--
-- TOC entry 3835 (class 0 OID 57877)
-- Dependencies: 243
-- Data for Name: outcomes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.outcomes (o_id, treatment_id, recovery_status) FROM stdin;
1	1	Critical
2	2	Stable
3	3	Critical
4	4	Critical
5	5	Stable
6	6	Stable
7	7	Recovered
8	8	Stable
9	9	Recovered
10	10	Recovered
11	11	Critical
12	12	Critical
13	13	Stable
14	14	Recovered
15	15	Stable
16	16	Critical
17	17	Stable
18	18	Improving
19	19	Stable
20	20	Improving
21	21	Improving
22	22	Stable
23	23	Recovered
24	24	Critical
25	25	Stable
26	26	Stable
27	27	Improving
28	28	Recovered
29	29	Stable
30	30	Improving
31	31	Improving
32	32	Improving
33	33	Recovered
34	34	Stable
35	35	Critical
36	36	Critical
37	37	Critical
38	38	Stable
39	39	Stable
40	40	Improving
41	41	Stable
42	42	Improving
43	43	Recovered
44	44	Improving
45	45	Recovered
46	46	Improving
47	47	Stable
48	48	Critical
49	49	Improving
50	50	Improving
51	51	Recovered
52	52	Recovered
53	53	Stable
54	54	Recovered
55	55	Improving
56	56	Critical
57	57	Recovered
58	58	Recovered
59	59	Stable
60	60	Stable
61	61	Improving
62	62	Improving
63	63	Recovered
64	64	Improving
65	65	Stable
66	66	Recovered
67	67	Critical
68	68	Stable
69	69	Critical
70	70	Stable
71	71	Improving
72	72	Stable
73	73	Critical
74	74	Recovered
75	75	Critical
76	76	Improving
77	77	Recovered
78	78	Critical
79	79	Stable
80	80	Improving
\.


--
-- TOC entry 3811 (class 0 OID 50141)
-- Dependencies: 219
-- Data for Name: patient_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patient_data (patient_id, name, address, dob, gender, contact, blood_group) FROM stdin;
1	Carlos Bates	824 Rodriguez Knoll, Lake Rebeccaside, MH 14071	1976-04-10	F	6641996166	O-
2	Allen Craig	USS Allen, FPO AA 28110	1979-05-18	M	7376831621	B-
3	Patricia Paul	997 Jeff Plains, Coopermouth, OK 98467	1980-08-11	M	2218027265	O+
4	Mrs. Mackenzie Holland DVM	01101 Matthew Plain Apt. 459, New Lawrence, WA 77247	1965-10-22	F	7002882922	O-
5	Kelly Grant	03303 Jason Mountain Apt. 389, West Kelly, TN 09932	1978-10-27	F	5494764033	B-
6	Clifford Norris	0509 Hayes Plains, Jacobsfurt, DE 27237	1980-03-09	M	4422531600	O-
7	Jennifer Elliott	USNV Davis, FPO AP 43235	2005-11-26	F	5817193846	B-
8	Tiffany Lutz	41950 Martinez Mission, New Jennifertown, MD 11972	2005-02-14	F	1979663871	AB+
9	Jasmine Carter	1353 Caldwell Squares, Alisonberg, NM 98471	1961-11-17	F	4974382213	AB-
10	Brandon Flores	1274 Jerry Shoal, Georgeside, ND 05614	1975-08-21	F	8831302299	AB+
11	Ebony Farmer	138 Pennington Square Apt. 280, Seanstad, MP 74643	1986-05-20	M	9797286398	O-
12	Casey Hernandez	9562 Jennifer Centers, Thompsonmouth, NM 98099	1995-03-25	M	3722196844	A+
13	Matthew Pierce	221 Moreno Points, New Melissashire, PW 52752	1979-10-21	F	9761577405	AB+
14	Jessica Beasley	364 Guzman Trafficway Apt. 084, New Nicholasburgh, IA 35082	1972-08-08	M	9759891198	O-
15	Taylor Campbell	57427 King Isle Suite 752, Leeside, TX 80202	1977-06-08	M	4341246992	A+
16	Luis Clark	252 Guzman Vista Suite 561, Lake Calebshire, WV 71055	1994-01-20	F	3959777900	O+
17	Michael Wright	34836 Linda Lights, Christyburgh, ND 81826	1964-03-13	F	9595872305	A+
18	Kathy Silva	USS Collins, FPO AA 64326	1966-08-19	F	6531193550	O+
19	Jason Graham	41418 Young Spring, Michellehaven, WY 12968	1963-01-11	M	5946968326	O+
20	James Lowe	740 Moore Village Suite 312, Josephbury, WA 57136	1965-12-15	F	7446431242	A+
21	Shawn Bennett	5790 Singleton Drive, Alexahaven, DE 90628	1988-04-14	M	3291777769	A+
22	David Chambers	Unit 2606 Box 3620, DPO AP 61744	1986-09-11	F	7581168845	O-
23	Renee Henson	99466 Bradley Highway Apt. 390, East Kristinafurt, IA 86207	1992-11-08	M	7956012171	O-
24	Jeanne Guzman	6729 Madison Ports, Lake Michaelchester, ID 12864	1996-08-08	M	8081058430	AB+
25	Jesse Chapman	98381 Gomez Ferry Suite 327, West Alexander, WI 24937	1992-05-16	M	5986324494	AB-
26	Mark Hensley	56484 Banks Parkways Suite 421, North Pamelaville, KS 23784	1965-12-15	M	2368921470	AB-
27	Hannah Caldwell	79203 Joseph Isle Suite 634, Johnhaven, VI 63795	1962-09-26	F	5579638359	B+
28	Jonathan Robinson	08071 Fernandez Valley Suite 675, North Kristyside, MD 73691	1997-02-25	F	8274358152	B+
29	Dr. Daniel Hill	07663 Kristy Stravenue Apt. 345, Bellfort, CT 62799	2003-08-14	M	1962085245	AB-
30	Doris Hicks	12790 Robles Circle, Ramirezland, NJ 73306	1997-06-16	M	3764291912	O+
31	Jennifer Garrett	9940 Smith Summit Suite 495, Shawnbury, SD 11377	1979-01-27	M	7416179263	AB+
32	Donald Sanchez	259 Nicholas Spring Apt. 620, New Susan, PA 57259	1994-03-22	M	9941717579	B+
33	Stephanie Koch	PSC 5754, Box 3876, APO AE 01410	1982-11-25	M	3086637509	O+
34	Thomas Little	368 David Mill Apt. 706, Port Angel, OH 67652	1997-04-01	F	2987184206	O+
35	Michael Brooks	134 Carter Drive Apt. 513, Courtneystad, WI 13017	1988-05-28	F	9999689294	O+
36	Victoria Young	138 Jamie Locks Apt. 469, Lewisfurt, SC 40913	1961-01-24	F	4071367069	A+
37	Christina Ware	983 Evan Green, Rogersbury, NY 07408	1996-09-24	M	3717084377	AB+
38	Ann Patel	86143 Joshua Wells Suite 477, West Kathrynville, ME 94602	1996-09-01	M	8004299328	B-
39	Brandi Graham	USNV Hunt, FPO AE 97097	2001-12-25	F	9464963025	A+
40	Sandra Schultz	2771 Grace Radial, North Taylorfurt, NJ 59371	1995-08-01	F	9188078468	B+
41	Valerie King	36906 Michele Viaduct, West Courtneyville, SC 57832	2002-11-05	M	8874248529	B-
42	Samantha Howard	Unit 0705 Box 6428, DPO AE 76262	2005-02-10	M	9682696502	O-
43	Amber Peters	448 Johnson Hill Suite 634, East Chrisville, WV 65189	2003-08-12	M	9955959323	B+
44	Michelle Bautista	89076 Briggs Roads Suite 318, Lisaborough, AZ 04859	1961-09-01	M	9257945800	A+
45	Richard Rojas	669 Ann Ranch Suite 157, Colemanhaven, GU 21635	1966-02-16	F	5624167955	O+
46	Spencer Williams	51686 Edwards Road, Gallagherbury, SD 29951	1966-02-23	F	5548462015	B-
47	Stuart Mann	PSC 6194, Box 3619, APO AA 36385	1992-11-11	M	9566633437	B+
48	George Poole	PSC 5168, Box 0097, APO AE 60929	1987-05-09	F	5555495986	O-
49	Dr. Teresa Johnson	3032 Denise Locks, South Robert, IL 11671	1981-11-22	M	8661115475	A+
50	Eric Carr	Unit 3275 Box 0290, DPO AA 76066	1987-10-01	M	7075445708	AB-
51	Amanda Taylor	123 Adams Ferry, Brittanybury, TX 19087	1988-03-09	M	8928937998	AB-
52	Julie Hall	142 Hicks Lane, Larsonside, IL 14586	1969-10-19	F	1004985311	B+
53	Alex Thornton DDS	068 Gonzales Forks Suite 458, Robertview, VA 66604	1993-09-19	M	7602747104	A+
54	Michael Montgomery	9160 Morris Drive, Heatherfort, KS 77844	1974-02-26	M	9431976153	A-
55	Tammy Davis	18601 Michael Knolls, East Jillianmouth, GA 75190	1974-02-19	F	9051352982	A-
56	Katie Wallace	046 Petty Cove, Lake Cody, MT 34332	2003-03-18	M	5808421207	O+
57	Elizabeth Taylor	113 Jennings Fork Suite 628, Port Robertfurt, MI 95371	1990-06-19	F	4676752314	A-
58	Taylor Diaz	2344 Tonya Meadows, Karenstad, NY 19371	2005-01-16	F	3433299018	AB+
59	Paul Oneill	PSC 9972, Box 6306, APO AA 28778	2001-08-10	F	3514541781	O-
60	Jose Lawrence	47006 Young Mountain Suite 377, Arianachester, MS 15537	1993-12-05	M	7276473605	B+
61	Kelsey Green	47253 Ortega Trail Suite 532, Barnettmouth, WA 17192	1969-09-04	M	5569753502	O-
62	Wayne Wallace	798 Snyder Valleys, South Thomas, GA 07622	1976-07-14	M	9158877015	A-
63	Tracie Williams	147 Gonzalez Plains, Moniquemouth, SD 32360	1971-10-27	M	8347718850	A-
64	Kelly Murray	1563 Randy Circle, Zunigaton, NC 45718	1967-09-10	M	5415291264	A+
65	Tyler Zhang	26488 Johnny Locks, East Ambertown, AS 66703	2004-12-04	M	4438585118	AB-
66	Christopher Simmons	0337 Ramsey Land Apt. 116, Mcgeestad, NM 30326	1976-06-09	M	6538196415	AB-
67	Kimberly Jackson	1497 Wilson Shoals Suite 418, North John, PW 33065	1998-11-27	M	4584368658	O-
68	Joseph Johnson	31746 Zavala Turnpike Apt. 592, East Sylvia, MT 90012	1967-01-20	M	9043252800	O+
69	Dorothy Bell	Unit 5451 Box 3451, DPO AE 31216	1974-10-27	F	7845906574	B-
70	Kevin Lee	6489 Stafford Crest Apt. 784, Dennisfort, ND 78454	1976-01-26	F	7893401584	A+
71	Matthew Webb	702 Wilkinson Roads Suite 885, North Nicoleshire, AZ 58342	2003-06-02	M	5492987487	A+
72	Nathan Larsen	6645 Carroll Island Apt. 588, Oliviaton, MP 84518	1999-01-25	M	1218035384	O-
73	Nicole Thomas	176 Heather Camp Suite 854, Thompsonside, MO 31970	1987-03-05	M	4141611556	A-
74	Stephanie Jones	227 David Roads, West Heidi, AZ 80214	1965-10-10	F	6682871595	O-
75	Jonathan Waters	8065 Schaefer Villages, Port Peter, UT 88980	1985-05-26	F	4043884294	AB+
76	Brenda Evans	0916 Williamson Park Suite 087, Jessicafort, CT 22713	1972-04-17	F	5472136709	A+
77	Holly Allen	93554 Rios Path, Steelebury, GU 93675	2004-04-10	F	8677673827	AB+
78	Lisa Davis	4379 Ferguson Route, Parkerbury, VA 69169	1963-08-16	F	4433812158	A-
79	Bruce Charles	4039 Boyer Via, Robbinstown, MD 51349	1987-02-20	M	2972031030	B-
80	Cynthia Garcia	736 Dakota Hill, Wrightmouth, ID 95799	1961-01-10	F	6417721116	O+
81	Michelle Rodriguez	369 Cherry Lane	1990-08-15	F	5551112222	B-
82	Emily Thompson	369 Pear Street	1992-10-10	F	5555556666	A-
83	John Doe	123 Main Street	1990-01-15	M	5551234567	A+
84	Jane Smith	456 Elm Street	1985-07-22	F	5559878543	AB+
85	Michael Johnson	789 Oak Avenue	1992-03-10	M	5557891234	B+
86	Emily Wilson	321 Pine Street	1988-09-27	F	5554567890	O-
87	David Lee	555 Maple Lane	1974-12-05	M	5552223333	A-
88	Sarah Anderson	987 Willow Road	1995-06-18	F	5554445555	B-
89	Robert Wilson	753 Elmwood Avenue	1982-11-30	M	5556668777	O+
90	Jennifer Brown	456 Oak Street	1998-02-12	F	5558889999	AB-
91	Daniel Thompson	987 Pine Avenue	1987-07-05	M	5551112222	B+
92	Jessica Evans	369 Maple Lane	1991-04-19	F	5553334444	A-
93	Andrew Davis	852 Elmwood Avenue	1979-09-03	M	5555556666	O+
94	Rachel Taylor	369 Willow Road	1984-12-28	F	5557778888	AB+
95	Michaela Moore	852 Pine Avenue	1993-05-08	F	5559990000	O-
\.


--
-- TOC entry 3813 (class 0 OID 50156)
-- Dependencies: 221
-- Data for Name: tests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tests (test_id, test_nm) FROM stdin;
65172	Complete Blood Count
67821	Urinalysis
54637	Electrocardiogram
87943	MRI
63542	X-ray
89485	Blood Chemistry
13234	Stool Sample
\.


--
-- TOC entry 3818 (class 0 OID 50209)
-- Dependencies: 226
-- Data for Name: treatment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.treatment (treatment_id, diagnosis_id, begin_date, end_date) FROM stdin;
1	447SHA8O	2023-03-08	2024-12-09
2	519HZZ2Z	2024-10-05	2024-05-18
3	292TUW1D	2023-08-02	2025-12-24
4	975GZD5M	2023-05-19	2025-07-16
5	927NUP2N	2023-12-04	2025-06-09
6	837VAQ7U	2023-11-10	2025-10-10
7	879LCG1S	2023-10-28	2024-05-01
8	751VTH0M	2023-01-26	2025-12-26
9	629PXL3S	2024-02-11	2024-02-15
10	207AUM8U	2024-05-11	2024-04-25
11	473CLQ4I	2023-07-28	2025-02-09
12	511ZUS5W	2023-03-06	2025-07-01
13	629VTJ2Q	2024-11-24	2025-02-21
14	957OZT3M	2024-05-01	2025-11-12
15	494CYH2D	2023-05-03	2024-03-27
16	424MMC3N	2023-04-28	2024-10-14
17	277XVU0N	2023-10-19	2025-06-06
18	482KHG2D	2024-07-02	2025-07-18
19	400VZL5M	2023-05-03	2025-07-04
20	560EZZ0D	2024-11-27	2024-12-13
21	135QPV4Q	2024-12-11	2024-03-27
22	728BNN6Q	2023-08-25	2024-02-16
23	528BNO9C	2024-08-18	2025-08-13
24	236XWX5X	2023-09-05	2024-11-20
25	826JUY7B	2023-09-26	2024-08-03
26	152AGT0F	2024-06-16	2025-10-08
27	754TJC0O	2024-08-06	2024-07-21
28	679EWC3R	2024-05-22	2024-01-08
29	366TUO4H	2023-11-04	2024-05-06
30	913EDR1M	2024-10-27	2024-03-16
31	329ZGS3D	2024-02-11	2024-08-24
32	688OAD0C	2024-11-15	2024-07-26
33	823MWO5M	2024-08-17	2025-10-17
34	362FOX2P	2023-06-28	2024-06-05
35	863WKE4Z	2024-04-12	2024-01-09
36	354EQN7S	2024-06-06	2024-12-28
37	309AIX7G	2023-05-01	2025-10-12
38	931VWY0O	2023-06-24	2024-03-03
39	277MSR6L	2023-10-10	2024-02-21
40	269UME1Q	2024-03-01	2024-06-09
41	516GNU8G	2023-03-16	2025-03-12
42	745BXS4B	2024-11-20	2025-09-02
43	832SCR7O	2024-06-04	2025-03-21
44	955MOZ1M	2023-04-21	2025-11-23
45	837NKA9B	2023-04-05	2024-05-18
46	401TAF0H	2023-10-20	2025-02-19
47	610ZBX6T	2023-08-19	2024-04-27
48	261JDX0P	2023-03-21	2024-03-07
49	739MOK2H	2023-05-10	2025-10-26
50	391IFN2P	2023-06-27	2024-09-05
51	111XDO3P	2023-01-02	2024-11-08
52	238RTX9A	2024-03-11	2025-03-26
53	789AXJ7E	2024-08-01	2024-12-23
54	769MSB7W	2023-12-01	2024-12-12
55	972XMM8E	2024-11-09	2025-11-09
56	976OTV4A	2024-06-22	2025-02-06
57	134RLM8B	2024-12-28	2024-07-15
58	473YKX1H	2023-02-09	2024-05-14
59	148ORC2A	2023-11-14	2025-10-11
60	555GMH3Y	2024-01-05	2024-03-20
61	185UJB9C	2023-09-01	2025-04-13
62	273AEL4M	2023-09-14	2024-03-21
63	201UJK5G	2024-10-04	2025-03-26
64	669KNY3U	2024-05-02	2025-12-11
65	178DBH0P	2023-09-06	2025-05-22
66	887FAB8N	2024-08-11	2024-05-08
67	769GIH5C	2024-11-10	2025-11-24
68	601SPK2I	2024-10-10	2025-04-28
69	192MOO0S	2024-11-11	2025-05-01
70	696WXF3X	2023-01-13	2024-09-11
71	439TQR6M	2024-11-27	2024-12-02
72	270OWK6L	2024-04-03	2024-08-26
73	447YXX9Z	2024-11-13	2025-10-08
74	354RVE2A	2023-01-01	2025-03-01
75	636LLM1F	2024-01-07	2025-08-20
76	875JRK1J	2023-02-26	2025-06-11
77	324MPR8S	2024-03-25	2024-11-10
78	258HQN7I	2024-12-05	2024-06-17
79	688TZX9Q	2023-09-20	2025-09-03
80	902YEX3J	2024-12-20	2025-01-16
\.


--
-- TOC entry 3820 (class 0 OID 50224)
-- Dependencies: 228
-- Data for Name: treatment_bridge_meds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.treatment_bridge_meds (treatment_id, medicine_id) FROM stdin;
1	1
1	8
2	2
2	2
3	3
4	2
5	2
6	4
6	15
7	3
8	3
8	14
9	5
10	3
10	2
11	1
12	6
12	12
13	6
14	3
15	4
16	6
17	6
18	2
19	5
20	5
21	2
21	10
22	4
22	3
23	5
24	5
25	6
26	4
27	2
28	5
29	3
30	2
31	5
32	3
33	5
34	3
35	2
35	1
36	3
36	1
37	1
37	7
38	2
39	6
39	9
40	2
41	1
42	4
43	4
44	5
45	4
46	6
47	1
48	2
49	5
50	2
51	2
52	4
52	9
53	1
53	9
54	6
54	1
54	10
55	1
56	1
57	2
58	6
59	5
60	3
60	2
60	15
61	2
62	3
63	5
64	2
64	14
65	6
65	14
65	15
66	6
67	5
68	5
69	3
70	5
71	3
71	8
72	3
73	2
73	7
74	5
75	5
76	1
77	5
78	4
79	6
79	4
79	8
80	1
\.


--
-- TOC entry 3832 (class 0 OID 50446)
-- Dependencies: 240
-- Data for Name: vital_signs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vital_signs (vs_id, diagnosis_id, blood_pressure, oxygen, temperature, heart_rate, weight, height) FROM stdin;
2	447SHA8O	137	100	36.20	62	99.30	189
3	519HZZ2Z	100	92	37.80	118	90.20	162
4	292TUW1D	104	98	38.70	72	81.00	161
5	975GZD5M	93	99	36.50	61	97.50	176
6	927NUP2N	85	98	37.40	82	78.10	163
7	837VAQ7U	98	94	38.00	66	96.90	150
8	879LCG1S	103	93	36.80	82	76.00	190
9	751VTH0M	136	100	36.90	77	96.50	170
10	629PXL3S	83	91	37.30	88	91.20	157
11	207AUM8U	87	100	36.90	63	88.10	158
12	473CLQ4I	87	91	38.90	101	91.30	162
13	511ZUS5W	134	94	36.90	111	58.80	167
14	629VTJ2Q	95	98	37.50	110	53.00	187
15	957OZT3M	113	94	38.80	105	83.30	157
16	494CYH2D	119	93	38.20	72	75.20	163
17	424MMC3N	88	96	36.50	62	67.30	151
18	277XVU0N	111	91	38.30	116	98.90	162
19	482KHG2D	122	97	39.00	64	95.70	151
20	400VZL5M	109	94	36.40	103	65.70	164
21	560EZZ0D	81	96	37.80	60	53.20	162
22	135QPV4Q	133	100	37.80	117	56.60	189
23	728BNN6Q	133	94	36.70	96	64.90	167
24	528BNO9C	118	97	36.80	119	73.40	186
25	236XWX5X	89	94	36.50	116	57.70	161
26	826JUY7B	82	94	38.10	117	92.00	172
27	152AGT0F	128	94	37.70	90	72.40	171
28	754TJC0O	122	95	37.70	75	51.40	172
29	679EWC3R	88	98	38.80	97	63.20	152
30	366TUO4H	115	96	36.10	113	77.50	172
31	913EDR1M	92	93	38.70	110	60.50	163
32	329ZGS3D	99	91	38.00	101	66.70	161
33	688OAD0C	138	99	37.10	76	91.20	158
34	823MWO5M	95	90	36.90	65	69.20	181
35	362FOX2P	81	100	37.40	87	98.30	188
36	863WKE4Z	124	90	38.40	91	53.80	168
37	354EQN7S	114	91	38.90	118	58.10	183
38	309AIX7G	88	96	38.80	76	77.80	188
39	931VWY0O	139	97	37.50	88	82.80	189
40	277MSR6L	100	100	37.30	90	70.50	157
41	269UME1Q	80	94	36.60	103	91.00	180
42	516GNU8G	82	91	38.10	82	86.40	186
43	745BXS4B	105	94	38.40	120	70.70	163
44	832SCR7O	117	99	37.80	63	50.80	162
45	955MOZ1M	112	93	36.70	64	66.00	175
46	837NKA9B	132	97	37.30	110	64.20	170
47	401TAF0H	139	91	38.80	97	58.70	187
48	610ZBX6T	81	93	38.90	96	68.70	159
49	261JDX0P	130	95	37.70	96	51.70	152
50	739MOK2H	127	100	37.50	65	93.50	179
51	391IFN2P	109	96	37.50	92	79.80	161
52	111XDO3P	114	95	38.50	86	98.00	180
53	238RTX9A	131	93	36.60	96	98.80	175
54	789AXJ7E	102	96	37.30	66	78.40	175
55	769MSB7W	122	100	37.80	94	67.70	179
56	972XMM8E	91	94	36.60	102	64.00	187
57	976OTV4A	129	100	36.80	77	76.80	187
58	134RLM8B	80	95	37.30	78	83.90	153
59	473YKX1H	130	91	36.30	77	75.50	188
60	148ORC2A	114	96	38.70	96	79.10	166
61	555GMH3Y	138	98	38.50	75	52.00	152
62	185UJB9C	128	99	37.30	105	56.40	173
63	273AEL4M	106	91	38.30	64	74.10	153
64	201UJK5G	97	93	36.10	111	80.60	177
65	669KNY3U	106	98	38.00	119	81.30	162
66	178DBH0P	90	90	38.50	115	54.30	175
67	887FAB8N	89	100	37.60	62	87.00	180
68	769GIH5C	95	96	38.10	104	52.40	150
69	601SPK2I	84	90	38.80	100	60.20	190
70	192MOO0S	115	92	36.10	111	78.40	186
71	696WXF3X	109	100	37.60	114	81.10	176
72	439TQR6M	139	92	36.80	95	97.80	161
73	270OWK6L	86	91	36.70	63	78.70	178
74	447YXX9Z	127	99	37.40	72	55.50	150
75	354RVE2A	89	98	38.80	114	86.20	161
76	636LLM1F	118	94	37.40	104	63.00	171
77	875JRK1J	99	98	37.80	101	52.80	189
78	324MPR8S	114	96	38.30	101	50.60	190
79	258HQN7I	109	95	39.00	77	83.00	189
80	688TZX9Q	99	100	36.40	101	98.80	176
81	902YEX3J	131	99	36.50	60	92.40	180
\.


--
-- TOC entry 3845 (class 0 OID 0)
-- Dependencies: 245
-- Name: bill_number; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bill_number', 80, true);


--
-- TOC entry 3846 (class 0 OID 0)
-- Dependencies: 216
-- Name: medicine_id_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.medicine_id_sequence', 15, true);


--
-- TOC entry 3847 (class 0 OID 0)
-- Dependencies: 214
-- Name: patient_id_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patient_id_sequence', 95, true);


--
-- TOC entry 3848 (class 0 OID 0)
-- Dependencies: 218
-- Name: seq_lr_id; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_lr_id', 80, true);


--
-- TOC entry 3849 (class 0 OID 0)
-- Dependencies: 217
-- Name: seq_mh_id; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_mh_id', 80, true);


--
-- TOC entry 3850 (class 0 OID 0)
-- Dependencies: 244
-- Name: seq_o_id; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_o_id', 80, true);


--
-- TOC entry 3851 (class 0 OID 0)
-- Dependencies: 241
-- Name: seq_vs_id; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_vs_id', 81, true);


--
-- TOC entry 3852 (class 0 OID 0)
-- Dependencies: 215
-- Name: treatment_id_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.treatment_id_sequence', 80, true);


--
-- TOC entry 3619 (class 2606 OID 57930)
-- Name: billing_info bi_bill_number; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.billing_info
    ADD CONSTRAINT bi_bill_number PRIMARY KEY (bill_number);


--
-- TOC entry 3584 (class 2606 OID 50180)
-- Name: diagnosis diagnosis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnosis
    ADD CONSTRAINT diagnosis_pkey PRIMARY KEY (diagnosis_id);


--
-- TOC entry 3603 (class 2606 OID 50317)
-- Name: dim_diagnosis dim_diagnosis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_diagnosis
    ADD CONSTRAINT dim_diagnosis_pkey PRIMARY KEY (diagnosis_id);


--
-- TOC entry 3599 (class 2606 OID 50304)
-- Name: dim_doctors dim_doctors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_doctors
    ADD CONSTRAINT dim_doctors_pkey PRIMARY KEY (doctor_id);


--
-- TOC entry 3607 (class 2606 OID 50347)
-- Name: dim_lab_results dim_lab_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_lab_results
    ADD CONSTRAINT dim_lab_results_pkey PRIMARY KEY (lr_id);


--
-- TOC entry 3605 (class 2606 OID 50337)
-- Name: dim_medical_history dim_medical_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_medical_history
    ADD CONSTRAINT dim_medical_history_pkey PRIMARY KEY (mh_id);


--
-- TOC entry 3601 (class 2606 OID 50310)
-- Name: dim_nurses dim_nurses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_nurses
    ADD CONSTRAINT dim_nurses_pkey PRIMARY KEY (nurse_id);


--
-- TOC entry 3611 (class 2606 OID 50372)
-- Name: dim_outcomes dim_outcomes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_outcomes
    ADD CONSTRAINT dim_outcomes_pkey PRIMARY KEY (o_id);


--
-- TOC entry 3597 (class 2606 OID 50298)
-- Name: dim_patient_data dim_patient_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_patient_data
    ADD CONSTRAINT dim_patient_data_pkey PRIMARY KEY (patient_id);


--
-- TOC entry 3580 (class 2606 OID 50166)
-- Name: doctors doctors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_pkey PRIMARY KEY (doctor_id);


--
-- TOC entry 3613 (class 2606 OID 50383)
-- Name: fact_insurance_claims fact_insurance_claims_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_insurance_claims
    ADD CONSTRAINT fact_insurance_claims_pkey PRIMARY KEY (insurance_id);


--
-- TOC entry 3609 (class 2606 OID 50362)
-- Name: fact_treatment fact_treatment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_treatment
    ADD CONSTRAINT fact_treatment_pkey PRIMARY KEY (treatment_id);


--
-- TOC entry 3595 (class 2606 OID 50273)
-- Name: insurance_claims ic_insurance_id_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.insurance_claims
    ADD CONSTRAINT ic_insurance_id_pk PRIMARY KEY (insurance_id);


--
-- TOC entry 3593 (class 2606 OID 50262)
-- Name: lab_results lr_lr_id_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_results
    ADD CONSTRAINT lr_lr_id_pk PRIMARY KEY (lr_id);


--
-- TOC entry 3591 (class 2606 OID 50223)
-- Name: medicines m_medicine_id_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicines
    ADD CONSTRAINT m_medicine_id_pk PRIMARY KEY (medicine_id);


--
-- TOC entry 3576 (class 2606 OID 50150)
-- Name: medical_history mh_mh_id_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_history
    ADD CONSTRAINT mh_mh_id_pk PRIMARY KEY (mh_id);


--
-- TOC entry 3582 (class 2606 OID 50172)
-- Name: nurses nurses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nurses
    ADD CONSTRAINT nurses_pkey PRIMARY KEY (nurse_id);


--
-- TOC entry 3617 (class 2606 OID 57882)
-- Name: outcomes o_o_id_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outcomes
    ADD CONSTRAINT o_o_id_pk PRIMARY KEY (o_id);


--
-- TOC entry 3574 (class 2606 OID 50145)
-- Name: patient_data pd_patient_id_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_data
    ADD CONSTRAINT pd_patient_id_pk PRIMARY KEY (patient_id);


--
-- TOC entry 3578 (class 2606 OID 50160)
-- Name: tests t_test_id_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tests
    ADD CONSTRAINT t_test_id_pk PRIMARY KEY (test_id);


--
-- TOC entry 3588 (class 2606 OID 50213)
-- Name: treatment t_treatment_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.treatment
    ADD CONSTRAINT t_treatment_id PRIMARY KEY (treatment_id);


--
-- TOC entry 3615 (class 2606 OID 50450)
-- Name: vital_signs vs_vs_id_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vital_signs
    ADD CONSTRAINT vs_vs_id_pk PRIMARY KEY (vs_id);


--
-- TOC entry 3585 (class 1259 OID 50290)
-- Name: i_diagnosis_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_diagnosis_id ON public.diagnosis USING btree (diagnosis_id);


--
-- TOC entry 3589 (class 1259 OID 50293)
-- Name: i_medicine_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_medicine_id ON public.medicines USING btree (medicine_id);


--
-- TOC entry 3572 (class 1259 OID 50291)
-- Name: i_patient_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_patient_id ON public.patient_data USING btree (patient_id);


--
-- TOC entry 3586 (class 1259 OID 50292)
-- Name: i_treatment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX i_treatment_id ON public.treatment USING btree (treatment_id);


--
-- TOC entry 3648 (class 2620 OID 50417)
-- Name: diagnosis after_diagnosis_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_diagnosis_insert AFTER INSERT ON public.diagnosis FOR EACH ROW EXECUTE FUNCTION public.insert_dim_diagnosis();


--
-- TOC entry 3646 (class 2620 OID 50413)
-- Name: doctors after_doctor_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_doctor_insert AFTER INSERT ON public.doctors FOR EACH ROW EXECUTE FUNCTION public.insert_dim_doctors();


--
-- TOC entry 3651 (class 2620 OID 50427)
-- Name: insurance_claims after_insurance_claims_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_insurance_claims_insert AFTER INSERT ON public.insurance_claims FOR EACH ROW EXECUTE FUNCTION public.insert_fact_insurance_claims();


--
-- TOC entry 3650 (class 2620 OID 50421)
-- Name: lab_results after_lab_results_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_lab_results_insert AFTER INSERT ON public.lab_results FOR EACH ROW EXECUTE FUNCTION public.insert_dim_lab_results();


--
-- TOC entry 3645 (class 2620 OID 50419)
-- Name: medical_history after_medical_history_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_medical_history_insert AFTER INSERT ON public.medical_history FOR EACH ROW EXECUTE FUNCTION public.insert_dim_medical_history();


--
-- TOC entry 3647 (class 2620 OID 50415)
-- Name: nurses after_nurse_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_nurse_insert AFTER INSERT ON public.nurses FOR EACH ROW EXECUTE FUNCTION public.insert_dim_nurses();


--
-- TOC entry 3662 (class 2620 OID 57888)
-- Name: outcomes after_outcomes_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_outcomes_insert AFTER INSERT ON public.outcomes FOR EACH ROW EXECUTE FUNCTION public.insert_dim_outcomes();


--
-- TOC entry 3644 (class 2620 OID 50411)
-- Name: patient_data after_patient_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_patient_insert AFTER INSERT ON public.patient_data FOR EACH ROW EXECUTE FUNCTION public.insert_dim_patient_data();


--
-- TOC entry 3649 (class 2620 OID 50423)
-- Name: treatment after_treatment_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_treatment_insert AFTER INSERT ON public.treatment FOR EACH ROW EXECUTE FUNCTION public.insert_fact_treatment();


--
-- TOC entry 3663 (class 2620 OID 57945)
-- Name: billing_info before_billing_info_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_billing_info_insert BEFORE INSERT ON public.billing_info FOR EACH ROW EXECUTE FUNCTION public.insert_fact_billing_info();


--
-- TOC entry 3655 (class 2620 OID 50436)
-- Name: dim_diagnosis before_diagnosis_deletion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_diagnosis_deletion BEFORE DELETE ON public.dim_diagnosis FOR EACH ROW EXECUTE FUNCTION public.prevent_delete_function();


--
-- TOC entry 3653 (class 2620 OID 50434)
-- Name: dim_doctors before_doctor_deletion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_doctor_deletion BEFORE DELETE ON public.dim_doctors FOR EACH ROW EXECUTE FUNCTION public.prevent_delete_function();


--
-- TOC entry 3660 (class 2620 OID 50441)
-- Name: fact_insurance_claims before_insurance_claims_deletion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_insurance_claims_deletion BEFORE DELETE ON public.fact_insurance_claims FOR EACH ROW EXECUTE FUNCTION public.prevent_delete_function();


--
-- TOC entry 3657 (class 2620 OID 50438)
-- Name: dim_lab_results before_lab_results_deletion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_lab_results_deletion BEFORE DELETE ON public.dim_lab_results FOR EACH ROW EXECUTE FUNCTION public.prevent_delete_function();


--
-- TOC entry 3656 (class 2620 OID 50437)
-- Name: dim_medical_history before_medical_history_deletion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_medical_history_deletion BEFORE DELETE ON public.dim_medical_history FOR EACH ROW EXECUTE FUNCTION public.prevent_delete_function();


--
-- TOC entry 3654 (class 2620 OID 50435)
-- Name: dim_nurses before_nurse_deletion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_nurse_deletion BEFORE DELETE ON public.dim_nurses FOR EACH ROW EXECUTE FUNCTION public.prevent_delete_function();


--
-- TOC entry 3659 (class 2620 OID 50440)
-- Name: dim_outcomes before_outcomes_deletion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_outcomes_deletion BEFORE DELETE ON public.dim_outcomes FOR EACH ROW EXECUTE FUNCTION public.prevent_delete_function();


--
-- TOC entry 3652 (class 2620 OID 50433)
-- Name: dim_patient_data before_patient_deletion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_patient_deletion BEFORE DELETE ON public.dim_patient_data FOR EACH ROW EXECUTE FUNCTION public.prevent_delete_function();


--
-- TOC entry 3658 (class 2620 OID 50439)
-- Name: fact_treatment before_treatment_deletion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_treatment_deletion BEFORE DELETE ON public.fact_treatment FOR EACH ROW EXECUTE FUNCTION public.prevent_delete_function();


--
-- TOC entry 3661 (class 2620 OID 57874)
-- Name: vital_signs before_vital_signs_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_vital_signs_insert BEFORE INSERT ON public.vital_signs FOR EACH ROW EXECUTE FUNCTION public.insert_fact_vital_signs();


--
-- TOC entry 3642 (class 2606 OID 57931)
-- Name: billing_info bi_treatment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.billing_info
    ADD CONSTRAINT bi_treatment_id_fk FOREIGN KEY (treatment_id) REFERENCES public.treatment(treatment_id);


--
-- TOC entry 3621 (class 2606 OID 50186)
-- Name: diagnosis d_doctor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnosis
    ADD CONSTRAINT d_doctor_id_fk FOREIGN KEY (doctor_id) REFERENCES public.doctors(doctor_id);


--
-- TOC entry 3622 (class 2606 OID 50191)
-- Name: diagnosis d_nurse_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnosis
    ADD CONSTRAINT d_nurse_id_fk FOREIGN KEY (nurse_id) REFERENCES public.nurses(nurse_id);


--
-- TOC entry 3623 (class 2606 OID 50181)
-- Name: diagnosis d_patient_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnosis
    ADD CONSTRAINT d_patient_id_fk FOREIGN KEY (patient_id) REFERENCES public.patient_data(patient_id);


--
-- TOC entry 3624 (class 2606 OID 50199)
-- Name: diagnosis_bridge_tests dbt_diagnosis_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnosis_bridge_tests
    ADD CONSTRAINT dbt_diagnosis_id FOREIGN KEY (diagnosis_id) REFERENCES public.diagnosis(diagnosis_id);


--
-- TOC entry 3625 (class 2606 OID 50204)
-- Name: diagnosis_bridge_tests dbt_test_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnosis_bridge_tests
    ADD CONSTRAINT dbt_test_id FOREIGN KEY (test_id) REFERENCES public.tests(test_id);


--
-- TOC entry 3631 (class 2606 OID 50323)
-- Name: dim_diagnosis dim_diagnosis_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_diagnosis
    ADD CONSTRAINT dim_diagnosis_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.dim_doctors(doctor_id);


--
-- TOC entry 3632 (class 2606 OID 50328)
-- Name: dim_diagnosis dim_diagnosis_nurse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_diagnosis
    ADD CONSTRAINT dim_diagnosis_nurse_id_fkey FOREIGN KEY (nurse_id) REFERENCES public.dim_nurses(nurse_id);


--
-- TOC entry 3633 (class 2606 OID 50318)
-- Name: dim_diagnosis dim_diagnosis_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_diagnosis
    ADD CONSTRAINT dim_diagnosis_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.dim_patient_data(patient_id);


--
-- TOC entry 3635 (class 2606 OID 50348)
-- Name: dim_lab_results dim_lab_results_diagnosis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_lab_results
    ADD CONSTRAINT dim_lab_results_diagnosis_id_fkey FOREIGN KEY (diagnosis_id) REFERENCES public.dim_diagnosis(diagnosis_id);


--
-- TOC entry 3634 (class 2606 OID 50338)
-- Name: dim_medical_history dim_medical_history_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_medical_history
    ADD CONSTRAINT dim_medical_history_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.dim_patient_data(patient_id);


--
-- TOC entry 3637 (class 2606 OID 50373)
-- Name: dim_outcomes dim_outcomes_treatment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_outcomes
    ADD CONSTRAINT dim_outcomes_treatment_id_fkey FOREIGN KEY (treatment_id) REFERENCES public.fact_treatment(treatment_id);


--
-- TOC entry 3643 (class 2606 OID 57939)
-- Name: fact_billing_info fact_billing_info_treatment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_billing_info
    ADD CONSTRAINT fact_billing_info_treatment_id_fkey FOREIGN KEY (treatment_id) REFERENCES public.fact_treatment(treatment_id);


--
-- TOC entry 3638 (class 2606 OID 50384)
-- Name: fact_insurance_claims fact_insurance_claims_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_insurance_claims
    ADD CONSTRAINT fact_insurance_claims_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.dim_patient_data(patient_id);


--
-- TOC entry 3636 (class 2606 OID 50363)
-- Name: fact_treatment fact_treatment_diagnosis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_treatment
    ADD CONSTRAINT fact_treatment_diagnosis_id_fkey FOREIGN KEY (diagnosis_id) REFERENCES public.dim_diagnosis(diagnosis_id);


--
-- TOC entry 3640 (class 2606 OID 57868)
-- Name: fact_vital_signs fact_vital_signs_diagnosis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_vital_signs
    ADD CONSTRAINT fact_vital_signs_diagnosis_id_fkey FOREIGN KEY (diagnosis_id) REFERENCES public.dim_diagnosis(diagnosis_id);


--
-- TOC entry 3630 (class 2606 OID 50274)
-- Name: insurance_claims ic_patient_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.insurance_claims
    ADD CONSTRAINT ic_patient_id_fk FOREIGN KEY (patient_id) REFERENCES public.patient_data(patient_id);


--
-- TOC entry 3629 (class 2606 OID 50263)
-- Name: lab_results lr_diagnosis_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_results
    ADD CONSTRAINT lr_diagnosis_id_fk FOREIGN KEY (diagnosis_id) REFERENCES public.diagnosis(diagnosis_id);


--
-- TOC entry 3620 (class 2606 OID 50151)
-- Name: medical_history mh_patient_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_history
    ADD CONSTRAINT mh_patient_id_fk FOREIGN KEY (patient_id) REFERENCES public.patient_data(patient_id);


--
-- TOC entry 3641 (class 2606 OID 57883)
-- Name: outcomes o_treatment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outcomes
    ADD CONSTRAINT o_treatment_id_fk FOREIGN KEY (treatment_id) REFERENCES public.treatment(treatment_id);


--
-- TOC entry 3626 (class 2606 OID 50214)
-- Name: treatment t_diagnosis_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.treatment
    ADD CONSTRAINT t_diagnosis_id_fk FOREIGN KEY (diagnosis_id) REFERENCES public.diagnosis(diagnosis_id);


--
-- TOC entry 3627 (class 2606 OID 50232)
-- Name: treatment_bridge_meds tbm_medicine_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.treatment_bridge_meds
    ADD CONSTRAINT tbm_medicine_id FOREIGN KEY (medicine_id) REFERENCES public.medicines(medicine_id);


--
-- TOC entry 3628 (class 2606 OID 50227)
-- Name: treatment_bridge_meds tbm_treatment_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.treatment_bridge_meds
    ADD CONSTRAINT tbm_treatment_id FOREIGN KEY (treatment_id) REFERENCES public.treatment(treatment_id);


--
-- TOC entry 3639 (class 2606 OID 50451)
-- Name: vital_signs vs_diagnosis_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vital_signs
    ADD CONSTRAINT vs_diagnosis_id_fk FOREIGN KEY (diagnosis_id) REFERENCES public.diagnosis(diagnosis_id);


-- Completed on 2023-06-28 20:41:44 EDT

--
-- PostgreSQL database dump complete
--

