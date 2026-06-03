--
-- PostgreSQL database dump
--

\restrict j3PMBASTTGuG3GR7uTgACEPi0JKlm3ahCRGefz23MDJ1hUicwIdeqZpn7fp0aSX

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: attendance_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.attendance_status AS ENUM (
    'on_time',
    'late',
    'early_leave',
    'absent',
    'late_early_leave'
);


ALTER TYPE public.attendance_status OWNER TO postgres;

--
-- Name: contract_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.contract_type AS ENUM (
    'probation',
    'fixed_1y',
    'fixed_3y',
    'indefinite'
);


ALTER TYPE public.contract_type OWNER TO postgres;

--
-- Name: decision_form; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.decision_form AS ENUM (
    'money',
    'gift',
    'warning',
    'certificate',
    'fire'
);


ALTER TYPE public.decision_form OWNER TO postgres;

--
-- Name: decision_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.decision_type AS ENUM (
    'reward',
    'discipline'
);


ALTER TYPE public.decision_type OWNER TO postgres;

--
-- Name: employee_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.employee_status AS ENUM (
    'active',
    'on_leave',
    'inactive'
);


ALTER TYPE public.employee_status OWNER TO postgres;

--
-- Name: explanation_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.explanation_type AS ENUM (
    'forgot_checkin',
    'forgot_checkout',
    'system_error',
    'late_arrival',
    'early_leave'
);


ALTER TYPE public.explanation_type OWNER TO postgres;

--
-- Name: leave_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.leave_type AS ENUM (
    'annual',
    'sick',
    'unpaid',
    'ot',
    'maternity',
    'bereavement'
);


ALTER TYPE public.leave_type OWNER TO postgres;

--
-- Name: location_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.location_type AS ENUM (
    'branch',
    'client_site',
    'wfh',
    'department_site'
);


ALTER TYPE public.location_type OWNER TO postgres;

--
-- Name: notification_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.notification_type AS ENUM (
    'info',
    'warning',
    'system',
    'system_info',
    'system_warning'
);


ALTER TYPE public.notification_type OWNER TO postgres;

--
-- Name: payroll_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.payroll_status AS ENUM (
    'draft',
    'pending_approval',
    'approved',
    'paid'
);


ALTER TYPE public.payroll_status OWNER TO postgres;

--
-- Name: position_level; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.position_level AS ENUM (
    'intern',
    'fresher',
    'junior',
    'middle',
    'senior',
    'manager',
    'director'
);


ALTER TYPE public.position_level OWNER TO postgres;

--
-- Name: request_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.request_status AS ENUM (
    'pending',
    'approved',
    'rejected'
);


ALTER TYPE public.request_status OWNER TO postgres;

--
-- Name: user_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_status AS ENUM (
    'active',
    'locked'
);


ALTER TYPE public.user_status OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ai_alerts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ai_alerts (
    id integer NOT NULL,
    alert_type character varying(50) NOT NULL,
    risk_level character varying(20),
    message text NOT NULL,
    status character varying(20) DEFAULT 'PENDING'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    employee_id uuid NOT NULL
);


ALTER TABLE public.ai_alerts OWNER TO postgres;

--
-- Name: ai_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ai_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ai_alerts_id_seq OWNER TO postgres;

--
-- Name: ai_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ai_alerts_id_seq OWNED BY public.ai_alerts.id;


--
-- Name: attendance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attendance (
    id bigint NOT NULL,
    employee_id uuid,
    work_location_id integer,
    attendance_date date NOT NULL,
    check_in_time timestamp with time zone,
    check_out_time timestamp with time zone,
    check_in_latitude numeric(10,6),
    check_in_longitude numeric(10,6),
    check_out_latitude numeric(10,6),
    check_out_longitude numeric(10,6),
    device_ip character varying(50),
    status public.attendance_status,
    total_work_hours numeric(5,2) DEFAULT 0,
    payroll_id uuid,
    check_out_note text
);


ALTER TABLE public.attendance OWNER TO postgres;

--
-- Name: attendance_explanation_request; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attendance_explanation_request (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employee_id uuid NOT NULL,
    attendance_date date NOT NULL,
    explanation_type public.explanation_type NOT NULL,
    proposed_check_in time without time zone,
    proposed_check_out time without time zone,
    reason text NOT NULL,
    attachment_url character varying(500),
    approver_id uuid,
    status public.request_status DEFAULT 'pending'::public.request_status,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    reject_reason text
);


ALTER TABLE public.attendance_explanation_request OWNER TO postgres;

--
-- Name: attendance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.attendance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.attendance_id_seq OWNER TO postgres;

--
-- Name: attendance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.attendance_id_seq OWNED BY public.attendance.id;


--
-- Name: branch; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.branch (
    id integer NOT NULL,
    branch_code character varying(50) NOT NULL,
    branch_name character varying(255) NOT NULL,
    address character varying(500),
    allowed_ips text[],
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    province character varying(100),
    hotline character varying(50),
    email character varying(255),
    description text
);


ALTER TABLE public.branch OWNER TO postgres;

--
-- Name: branch_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.branch_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.branch_id_seq OWNER TO postgres;

--
-- Name: branch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.branch_id_seq OWNED BY public.branch.id;


--
-- Name: contract; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contract (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    contract_number character varying(100) NOT NULL,
    employee_id uuid,
    contract_type public.contract_type NOT NULL,
    start_date date NOT NULL,
    end_date date,
    base_salary numeric(15,2) NOT NULL,
    allowances jsonb,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.contract OWNER TO postgres;

--
-- Name: department; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.department (
    id integer NOT NULL,
    department_code character varying(50) NOT NULL,
    department_name character varying(255) NOT NULL,
    branch_id integer,
    manager_id uuid,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    description character varying(100)
);


ALTER TABLE public.department OWNER TO postgres;

--
-- Name: department_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.department_id_seq OWNER TO postgres;

--
-- Name: department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.department_id_seq OWNED BY public.department.id;


--
-- Name: employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employee_code character varying(50) NOT NULL,
    full_name character varying(255) NOT NULL,
    personal_email character varying(255),
    work_email character varying(255),
    phone_number character varying(20),
    date_of_birth date,
    identity_card_number character varying(20),
    gender boolean,
    bank_account_number character varying(50),
    avatar_url character varying(500),
    position_id integer,
    direct_manager_id uuid,
    join_date date DEFAULT CURRENT_DATE NOT NULL,
    status public.employee_status DEFAULT 'active'::public.employee_status,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    address text,
    bank_name character varying(100)
);


ALTER TABLE public.employee OWNER TO postgres;

--
-- Name: hr_decision; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hr_decision (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    decision_number character varying(100) NOT NULL,
    employee_id uuid,
    decision_type public.decision_type NOT NULL,
    form public.decision_form NOT NULL,
    amount numeric(15,2) DEFAULT 0,
    reason text NOT NULL,
    issue_date date NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    issuer_id uuid,
    payroll_id uuid,
    attachment_url character varying(255)
);


ALTER TABLE public.hr_decision OWNER TO postgres;

--
-- Name: leave_request; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.leave_request (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employee_id uuid,
    leave_type public.leave_type NOT NULL,
    start_datetime timestamp with time zone NOT NULL,
    end_datetime timestamp with time zone NOT NULL,
    reason text,
    approver_id uuid,
    status public.request_status DEFAULT 'pending'::public.request_status,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    attachment text,
    updated_at timestamp with time zone,
    reject_reason text
);


ALTER TABLE public.leave_request OWNER TO postgres;

--
-- Name: location_assignment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.location_assignment (
    id bigint NOT NULL,
    employee_id uuid,
    work_location_id integer NOT NULL,
    assigned_date date,
    is_temporary boolean DEFAULT false,
    status public.request_status DEFAULT 'approved'::public.request_status,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    branch_id integer,
    department_id integer,
    end_date date,
    CONSTRAINT check_single_target CHECK ((((((branch_id IS NOT NULL))::integer + ((department_id IS NOT NULL))::integer) + ((employee_id IS NOT NULL))::integer) = 1))
);


ALTER TABLE public.location_assignment OWNER TO postgres;

--
-- Name: location_assignment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.location_assignment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.location_assignment_id_seq OWNER TO postgres;

--
-- Name: location_assignment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.location_assignment_id_seq OWNED BY public.location_assignment.id;


--
-- Name: notification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sender_id uuid,
    title character varying(255) NOT NULL,
    content text NOT NULL,
    notification_type public.notification_type DEFAULT 'info'::public.notification_type,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    target character varying(255) DEFAULT 'Tất cả nhân viên'::character varying,
    "desc" character varying(255),
    status character varying(50) DEFAULT 'Đã gửi'::character varying,
    target_department_id integer,
    target_employee_id uuid
);


ALTER TABLE public.notification OWNER TO postgres;

--
-- Name: notification_recipient; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_recipient (
    id bigint NOT NULL,
    notification_id uuid,
    employee_id uuid,
    is_read boolean DEFAULT false,
    read_at timestamp with time zone
);


ALTER TABLE public.notification_recipient OWNER TO postgres;

--
-- Name: notification_recipient_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notification_recipient_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notification_recipient_id_seq OWNER TO postgres;

--
-- Name: notification_recipient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notification_recipient_id_seq OWNED BY public.notification_recipient.id;


--
-- Name: overtime_request; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.overtime_request (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employee_id uuid,
    payroll_id uuid,
    ot_date date NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    reason text NOT NULL,
    approver_id uuid,
    status public.request_status DEFAULT 'pending'::public.request_status,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone,
    reject_reason text
);


ALTER TABLE public.overtime_request OWNER TO postgres;

--
-- Name: payroll; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payroll (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employee_id uuid,
    month_year character varying(10) NOT NULL,
    base_salary_snapshot numeric(15,2) NOT NULL,
    total_work_days numeric(5,2) DEFAULT 0,
    total_allowance numeric(15,2) DEFAULT 0,
    total_deduction numeric(15,2) DEFAULT 0,
    net_salary numeric(15,2) NOT NULL,
    status public.payroll_status DEFAULT 'draft'::public.payroll_status,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.payroll OWNER TO postgres;

--
-- Name: position; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."position" (
    id integer NOT NULL,
    position_code character varying(50) NOT NULL,
    position_name character varying(255) NOT NULL,
    department_id integer,
    level public.position_level NOT NULL,
    base_salary_min numeric(15,2) DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public."position" OWNER TO postgres;

--
-- Name: position_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.position_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.position_id_seq OWNER TO postgres;

--
-- Name: position_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.position_id_seq OWNED BY public."position".id;


--
-- Name: system_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.system_config (
    config_key character varying(50) NOT NULL,
    config_value character varying(255) NOT NULL,
    description text,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.system_config OWNER TO postgres;

--
-- Name: user_account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_account (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employee_id uuid,
    username character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role_code character varying(50) NOT NULL,
    status public.user_status DEFAULT 'active'::public.user_status,
    last_login timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    require_pass_change boolean DEFAULT false,
    expo_push_token character varying(255)
);


ALTER TABLE public.user_account OWNER TO postgres;

--
-- Name: work_location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_location (
    id integer NOT NULL,
    location_name character varying(255) NOT NULL,
    location_type public.location_type NOT NULL,
    latitude numeric(10,6) NOT NULL,
    longitude numeric(10,6) NOT NULL,
    radius_meters integer DEFAULT 100,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_active boolean DEFAULT true,
    branch_id integer,
    CONSTRAINT work_location_latitude_check CHECK (((latitude >= ('-90'::integer)::numeric) AND (latitude <= (90)::numeric))),
    CONSTRAINT work_location_longitude_check CHECK (((longitude >= ('-180'::integer)::numeric) AND (longitude <= (180)::numeric))),
    CONSTRAINT work_location_radius_meters_check CHECK ((radius_meters > 0))
);


ALTER TABLE public.work_location OWNER TO postgres;

--
-- Name: work_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.work_location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.work_location_id_seq OWNER TO postgres;

--
-- Name: work_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.work_location_id_seq OWNED BY public.work_location.id;


--
-- Name: ai_alerts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_alerts ALTER COLUMN id SET DEFAULT nextval('public.ai_alerts_id_seq'::regclass);


--
-- Name: attendance id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance ALTER COLUMN id SET DEFAULT nextval('public.attendance_id_seq'::regclass);


--
-- Name: branch id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branch ALTER COLUMN id SET DEFAULT nextval('public.branch_id_seq'::regclass);


--
-- Name: department id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department ALTER COLUMN id SET DEFAULT nextval('public.department_id_seq'::regclass);


--
-- Name: location_assignment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location_assignment ALTER COLUMN id SET DEFAULT nextval('public.location_assignment_id_seq'::regclass);


--
-- Name: notification_recipient id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_recipient ALTER COLUMN id SET DEFAULT nextval('public.notification_recipient_id_seq'::regclass);


--
-- Name: position id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."position" ALTER COLUMN id SET DEFAULT nextval('public.position_id_seq'::regclass);


--
-- Name: work_location id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_location ALTER COLUMN id SET DEFAULT nextval('public.work_location_id_seq'::regclass);


--
-- Data for Name: ai_alerts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ai_alerts (id, alert_type, risk_level, message, status, created_at, updated_at, employee_id) FROM stdin;
\.


--
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance (id, employee_id, work_location_id, attendance_date, check_in_time, check_out_time, check_in_latitude, check_in_longitude, check_out_latitude, check_out_longitude, device_ip, status, total_work_hours, payroll_id, check_out_note) FROM stdin;
\.


--
-- Data for Name: attendance_explanation_request; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance_explanation_request (id, employee_id, attendance_date, explanation_type, proposed_check_in, proposed_check_out, reason, attachment_url, approver_id, status, created_at, updated_at, reject_reason) FROM stdin;
\.


--
-- Data for Name: branch; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.branch (id, branch_code, branch_name, address, allowed_ips, is_active, created_at, province, hotline, email, description) FROM stdin;
1	HO-DN	Tru so chinh - Da Nang	36 Bach Dang, Hai Chau, Da Nang	\N	t	2026-06-01 01:37:09.860405+07	Da Nang	02363.123.456	danang@vinalpha.vn	\N
2	CN-HN	Chi nhanh Ha Noi	Toa nha Keangnam, Pham Hung, Nam Tu Liem	\N	t	2026-06-01 01:37:09.860405+07	Ha Noi	02462.123.456	hanoi@vinalpha.vn	\N
3	CN-HCM	Chi nhanh Ho Chi Minh	Landmark 81, Vinhomes Central Park, Q.BT	\N	t	2026-06-01 01:37:09.860405+07	TP.HCM	02862.123.456	hcm@vinalpha.vn	\N
4	CN-HUE	Chi nhanh Hue	23 Le Loi, Vinh Ninh, TP. Hue	\N	t	2026-06-01 01:37:09.860405+07	Thua Thien Hue	02342.123.456	hue@vinalpha.vn	\N
5	CN-QNI	Chi nhanh Quang Ngai	125 Hung Vuong, TP. Quang Ngai	\N	t	2026-06-01 01:37:09.860405+07	Quang Ngai	02552.123.456	quangngai@vinalpha.vn	\N
\.


--
-- Data for Name: contract; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contract (id, contract_number, employee_id, contract_type, start_date, end_date, base_salary, allowances, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: department; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.department (id, department_code, department_name, branch_id, manager_id, is_active, created_at, description) FROM stdin;
\.


--
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee (id, employee_code, full_name, personal_email, work_email, phone_number, date_of_birth, identity_card_number, gender, bank_account_number, avatar_url, position_id, direct_manager_id, join_date, status, created_at, updated_at, address, bank_name) FROM stdin;
a3e1f44b-7267-4f64-b178-aaf9697b0860	EMP-465026	Lê Thị Thúy Trang	\N	thuytrang.admin@vinalpha.vn	0901000001	\N	\N	\N	\N	\N	\N	\N	2026-06-03	active	2026-06-03 22:40:05.616888+07	2026-06-03 22:40:05.616888+07	\N	\N
10eebddd-a873-4abe-831f-229e784688ac	EMP-842416	Lê Thúy Trang	\N	thuytrang.ceo@vinalpha.vn	0901000002	\N	\N	\N	\N	\N	\N	\N	2026-06-03	active	2026-06-03 22:40:05.635201+07	2026-06-03 22:40:05.635201+07	\N	\N
5b3cb901-53e5-42a8-b6b7-5958647193b2	EMP-993231	Nguyễn Văn Hùng	\N	hung.manager@vinalpha.vn	0902000001	\N	\N	\N	\N	\N	\N	\N	2026-06-03	active	2026-06-03 22:40:05.637493+07	2026-06-03 22:40:05.637493+07	\N	\N
95bbd224-da85-4fbe-ac66-4021905e4876	EMP-647056	Trần Thị Hồng	\N	hong.manager@vinalpha.vn	0902000002	\N	\N	\N	\N	\N	\N	\N	2026-06-03	active	2026-06-03 22:40:05.639837+07	2026-06-03 22:40:05.639837+07	\N	\N
2624638a-c7b2-4ef2-9134-f1868581f9a7	EMP-891027	Phan Thị Bảo Châu	\N	baochau.manager@vinalpha.vn	0902000003	\N	\N	\N	\N	\N	\N	\N	2026-06-03	active	2026-06-03 22:40:05.641703+07	2026-06-03 22:40:05.641703+07	\N	\N
1a1055dc-d8bc-4024-b851-4752b629d453	EMP-875370	Võ Thị Bích	\N	bich.nv@vinalpha.vn	0903000001	\N	\N	\N	\N	\N	\N	\N	2026-06-03	active	2026-06-03 22:40:05.643621+07	2026-06-03 22:40:05.643621+07	\N	\N
45d35f49-e3ed-4efc-9d42-08c3490787b8	EMP-970177	Nguyễn Đức Anh	\N	ducanh.nv@vinalpha.vn	0903000002	\N	\N	\N	\N	\N	\N	\N	2026-06-03	active	2026-06-03 22:40:05.645437+07	2026-06-03 22:40:05.645437+07	\N	\N
4798b42d-e145-4fab-9c59-f764d743ad42	EMP-716264	Trần Thị Lan Anh	\N	lananh.nv@vinalpha.vn	0903000003	\N	\N	\N	\N	\N	\N	\N	2026-06-03	active	2026-06-03 22:40:05.647615+07	2026-06-03 22:40:05.647615+07	\N	\N
3a673eb6-9621-4ec2-b981-ec7808c40be1	EMP-646483	Lê Minh Tuấn	\N	minhtuan.nv@vinalpha.vn	0903000004	\N	\N	\N	\N	\N	\N	\N	2026-06-03	active	2026-06-03 22:40:05.649094+07	2026-06-03 22:40:05.649094+07	\N	\N
f61489ba-36ce-49e9-afa8-c3a2a93e2fd4	EMP-237304	Phạm Thị Mỹ Linh	\N	mylinh.nv@vinalpha.vn	0903000005	\N	\N	\N	\N	\N	\N	\N	2026-06-03	active	2026-06-03 22:40:05.651289+07	2026-06-03 22:40:05.651289+07	\N	\N
b0251cba-1ba2-419a-8e83-edba59e1a3e7	EMP-833754	Bùi Thanh Tùng	\N	thanhtung.nv@vinalpha.vn	0903000006	\N	\N	\N	\N	\N	\N	\N	2026-06-03	active	2026-06-03 22:40:05.653128+07	2026-06-03 22:40:05.653128+07	\N	\N
bc48e7e6-a686-42ad-84b7-d1a420ad566c	EMP-237817	Lý Văn Nam	\N	vannam.nv@vinalpha.vn	0903000007	\N	\N	\N	\N	\N	\N	\N	2026-06-03	active	2026-06-03 22:40:05.654659+07	2026-06-03 22:40:05.654659+07	\N	\N
3e39dbbb-692b-43f6-802f-c45360280135	EMP-973129	Đinh Văn Phúc	\N	vanphuc.nv@vinalpha.vn	0903000008	\N	\N	\N	\N	\N	\N	\N	2026-06-03	active	2026-06-03 22:40:05.655992+07	2026-06-03 22:40:05.655992+07	\N	\N
d2e06785-75d6-4c9f-ad81-d0d3bf6e9333	EMP-511626	Vũ Thị Thu Trang	\N	thutrang.nv@vinalpha.vn	0903000009	\N	\N	\N	\N	\N	\N	\N	2026-06-03	active	2026-06-03 22:40:05.657368+07	2026-06-03 22:40:05.657368+07	\N	\N
a93e2fa2-0cc1-43da-a17c-5fd97040f385	EMP-368432	Hoàng Thị Ngọc Bích	\N	ngocbich.nv@vinalpha.vn	0903000010	\N	\N	\N	\N	\N	\N	\N	2026-06-03	active	2026-06-03 22:40:05.658905+07	2026-06-03 22:40:05.658905+07	\N	\N
\.


--
-- Data for Name: hr_decision; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hr_decision (id, decision_number, employee_id, decision_type, form, amount, reason, issue_date, created_at, issuer_id, payroll_id, attachment_url) FROM stdin;
\.


--
-- Data for Name: leave_request; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.leave_request (id, employee_id, leave_type, start_datetime, end_datetime, reason, approver_id, status, created_at, attachment, updated_at, reject_reason) FROM stdin;
\.


--
-- Data for Name: location_assignment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.location_assignment (id, employee_id, work_location_id, assigned_date, is_temporary, status, created_at, branch_id, department_id, end_date) FROM stdin;
\.


--
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification (id, sender_id, title, content, notification_type, created_at, target, "desc", status, target_department_id, target_employee_id) FROM stdin;
\.


--
-- Data for Name: notification_recipient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification_recipient (id, notification_id, employee_id, is_read, read_at) FROM stdin;
\.


--
-- Data for Name: overtime_request; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.overtime_request (id, employee_id, payroll_id, ot_date, start_time, end_time, reason, approver_id, status, created_at, updated_at, reject_reason) FROM stdin;
\.


--
-- Data for Name: payroll; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payroll (id, employee_id, month_year, base_salary_snapshot, total_work_days, total_allowance, total_deduction, net_salary, status, created_at) FROM stdin;
\.


--
-- Data for Name: position; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."position" (id, position_code, position_name, department_id, level, base_salary_min, created_at) FROM stdin;
\.


--
-- Data for Name: system_config; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.system_config (config_key, config_value, description, updated_at) FROM stdin;
DEFAULT_CHECKIN_TIME	07:30	Gio bat dau ca	2026-06-01 01:37:34.865683+07
DEFAULT_CHECKOUT_TIME	17:00	Gio ket thuc ca	2026-06-01 01:37:34.865683+07
LUNCH_BREAK_START	11:30	Bat dau nghi trua	2026-06-01 01:37:34.865683+07
LUNCH_BREAK_END	13:00	Ket thuc nghi trua	2026-06-01 01:37:34.865683+07
\.


--
-- Data for Name: user_account; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_account (id, employee_id, username, password_hash, role_code, status, last_login, created_at, require_pass_change, expo_push_token) FROM stdin;
0c1587d6-e0bc-4934-b25c-98fdf18d9fde	a3e1f44b-7267-4f64-b178-aaf9697b0860	lethithuytrang	$2b$10$M96B/KDa.aIMyhpfMA9DO.n58t/hPp8Dw9lmqKu6UM8Qyi2jB9O3G	admin	active	\N	2026-06-03 22:40:05.627248+07	f	\N
3b4a02fc-cc2f-4137-aa19-ff39ca73a211	10eebddd-a873-4abe-831f-229e784688ac	lethuytrang	$2b$10$M96B/KDa.aIMyhpfMA9DO.n58t/hPp8Dw9lmqKu6UM8Qyi2jB9O3G	director	active	\N	2026-06-03 22:40:05.636372+07	f	\N
e020d37b-d87a-47ba-9242-f1ae955ad035	5b3cb901-53e5-42a8-b6b7-5958647193b2	nguyenvanhung	$2b$10$M96B/KDa.aIMyhpfMA9DO.n58t/hPp8Dw9lmqKu6UM8Qyi2jB9O3G	manager	active	\N	2026-06-03 22:40:05.638345+07	f	\N
31eeb774-41fd-4e46-810d-303c7d194b60	95bbd224-da85-4fbe-ac66-4021905e4876	tranthihong	$2b$10$M96B/KDa.aIMyhpfMA9DO.n58t/hPp8Dw9lmqKu6UM8Qyi2jB9O3G	manager	active	\N	2026-06-03 22:40:05.640667+07	f	\N
dccc9eed-ed4a-44b7-90b8-bb0323a62bd9	2624638a-c7b2-4ef2-9134-f1868581f9a7	phanbaochau	$2b$10$M96B/KDa.aIMyhpfMA9DO.n58t/hPp8Dw9lmqKu6UM8Qyi2jB9O3G	manager	active	\N	2026-06-03 22:40:05.642521+07	f	\N
2787bc35-497a-4e78-9986-9cf461f7f75a	1a1055dc-d8bc-4024-b851-4752b629d453	vothibich	$2b$10$M96B/KDa.aIMyhpfMA9DO.n58t/hPp8Dw9lmqKu6UM8Qyi2jB9O3G	employee	active	\N	2026-06-03 22:40:05.644421+07	f	\N
bd9c0238-47a5-4ae0-958f-3542f0761013	45d35f49-e3ed-4efc-9d42-08c3490787b8	nguyenducanh	$2b$10$M96B/KDa.aIMyhpfMA9DO.n58t/hPp8Dw9lmqKu6UM8Qyi2jB9O3G	employee	active	\N	2026-06-03 22:40:05.646096+07	f	\N
1c8206af-fcd7-43c2-83fa-00d689bc60bd	4798b42d-e145-4fab-9c59-f764d743ad42	tranthilanhanh	$2b$10$M96B/KDa.aIMyhpfMA9DO.n58t/hPp8Dw9lmqKu6UM8Qyi2jB9O3G	employee	active	\N	2026-06-03 22:40:05.648302+07	f	\N
593070dc-425f-48aa-a849-43b46fca1e8e	3a673eb6-9621-4ec2-b981-ec7808c40be1	leminhtuan	$2b$10$M96B/KDa.aIMyhpfMA9DO.n58t/hPp8Dw9lmqKu6UM8Qyi2jB9O3G	employee	active	\N	2026-06-03 22:40:05.650055+07	f	\N
f6601674-434e-4874-97eb-297a66e6b525	f61489ba-36ce-49e9-afa8-c3a2a93e2fd4	phamthimylinh	$2b$10$M96B/KDa.aIMyhpfMA9DO.n58t/hPp8Dw9lmqKu6UM8Qyi2jB9O3G	employee	active	\N	2026-06-03 22:40:05.652402+07	f	\N
db46c519-a4a8-45fd-9d04-c78b64b52a3e	b0251cba-1ba2-419a-8e83-edba59e1a3e7	buithanhung	$2b$10$M96B/KDa.aIMyhpfMA9DO.n58t/hPp8Dw9lmqKu6UM8Qyi2jB9O3G	employee	active	\N	2026-06-03 22:40:05.653819+07	f	\N
701e5c16-698c-4c1c-990b-4322509956d5	bc48e7e6-a686-42ad-84b7-d1a420ad566c	lyvannam	$2b$10$M96B/KDa.aIMyhpfMA9DO.n58t/hPp8Dw9lmqKu6UM8Qyi2jB9O3G	employee	active	\N	2026-06-03 22:40:05.655303+07	f	\N
0a959d70-b25a-4865-a8f2-eb6e6a3677ca	3e39dbbb-692b-43f6-802f-c45360280135	dinhvanphuc	$2b$10$M96B/KDa.aIMyhpfMA9DO.n58t/hPp8Dw9lmqKu6UM8Qyi2jB9O3G	employee	active	\N	2026-06-03 22:40:05.656685+07	f	\N
f24c785f-e93f-44db-8203-801b106bdbb7	d2e06785-75d6-4c9f-ad81-d0d3bf6e9333	vuthithurang	$2b$10$M96B/KDa.aIMyhpfMA9DO.n58t/hPp8Dw9lmqKu6UM8Qyi2jB9O3G	employee	active	\N	2026-06-03 22:40:05.657923+07	f	\N
d59757a9-476b-4a91-9a81-55dc16eaaecd	a93e2fa2-0cc1-43da-a17c-5fd97040f385	hoangthingocbich	$2b$10$M96B/KDa.aIMyhpfMA9DO.n58t/hPp8Dw9lmqKu6UM8Qyi2jB9O3G	employee	active	\N	2026-06-03 22:40:05.660283+07	f	\N
\.


--
-- Data for Name: work_location; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work_location (id, location_name, location_type, latitude, longitude, radius_meters, created_at, is_active, branch_id) FROM stdin;
1	Tru so chinh Da Nang	branch	16.066500	108.221800	300	2026-06-01 01:39:47.245195+07	t	1
2	Chi nhanh Ha Noi	branch	21.028300	105.834000	300	2026-06-01 01:39:47.245195+07	t	2
3	Chi nhanh Ho Chi Minh	branch	10.795300	106.721800	300	2026-06-01 01:39:47.245195+07	t	3
4	Chi nhanh Hue	branch	16.463300	107.597600	300	2026-06-01 01:39:47.245195+07	t	4
5	Chi nhanh Quang Ngai	branch	15.119600	108.800700	300	2026-06-01 01:39:47.245195+07	t	5
\.


--
-- Name: ai_alerts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ai_alerts_id_seq', 1, false);


--
-- Name: attendance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.attendance_id_seq', 1, false);


--
-- Name: branch_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.branch_id_seq', 10, true);


--
-- Name: department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.department_id_seq', 1, false);


--
-- Name: location_assignment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.location_assignment_id_seq', 1, false);


--
-- Name: notification_recipient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notification_recipient_id_seq', 1, false);


--
-- Name: position_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.position_id_seq', 1, false);


--
-- Name: work_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.work_location_id_seq', 10, true);


--
-- Name: ai_alerts ai_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_alerts
    ADD CONSTRAINT ai_alerts_pkey PRIMARY KEY (id);


--
-- Name: attendance attendance_employee_id_attendance_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_employee_id_attendance_date_key UNIQUE (employee_id, attendance_date);


--
-- Name: attendance_explanation_request attendance_explanation_request_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance_explanation_request
    ADD CONSTRAINT attendance_explanation_request_pkey PRIMARY KEY (id);


--
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (id);


--
-- Name: branch branch_branch_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_branch_code_key UNIQUE (branch_code);


--
-- Name: branch branch_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_pkey PRIMARY KEY (id);


--
-- Name: contract contract_contract_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contract
    ADD CONSTRAINT contract_contract_number_key UNIQUE (contract_number);


--
-- Name: contract contract_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contract
    ADD CONSTRAINT contract_pkey PRIMARY KEY (id);


--
-- Name: department department_department_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_department_code_key UNIQUE (department_code);


--
-- Name: department department_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_pkey PRIMARY KEY (id);


--
-- Name: employee employee_employee_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_employee_code_key UNIQUE (employee_code);


--
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (id);


--
-- Name: employee employee_work_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_work_email_key UNIQUE (work_email);


--
-- Name: hr_decision hr_decision_decision_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_decision
    ADD CONSTRAINT hr_decision_decision_number_key UNIQUE (decision_number);


--
-- Name: hr_decision hr_decision_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_decision
    ADD CONSTRAINT hr_decision_pkey PRIMARY KEY (id);


--
-- Name: leave_request leave_request_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leave_request
    ADD CONSTRAINT leave_request_pkey PRIMARY KEY (id);


--
-- Name: location_assignment location_assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location_assignment
    ADD CONSTRAINT location_assignment_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: notification_recipient notification_recipient_notification_id_employee_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_recipient
    ADD CONSTRAINT notification_recipient_notification_id_employee_id_key UNIQUE (notification_id, employee_id);


--
-- Name: notification_recipient notification_recipient_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_recipient
    ADD CONSTRAINT notification_recipient_pkey PRIMARY KEY (id);


--
-- Name: overtime_request overtime_request_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.overtime_request
    ADD CONSTRAINT overtime_request_pkey PRIMARY KEY (id);


--
-- Name: payroll payroll_employee_id_month_year_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll
    ADD CONSTRAINT payroll_employee_id_month_year_key UNIQUE (employee_id, month_year);


--
-- Name: payroll payroll_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll
    ADD CONSTRAINT payroll_pkey PRIMARY KEY (id);


--
-- Name: position position_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."position"
    ADD CONSTRAINT position_pkey PRIMARY KEY (id);


--
-- Name: position position_position_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."position"
    ADD CONSTRAINT position_position_code_key UNIQUE (position_code);


--
-- Name: system_config system_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_config
    ADD CONSTRAINT system_config_pkey PRIMARY KEY (config_key);


--
-- Name: user_account user_account_employee_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT user_account_employee_id_key UNIQUE (employee_id);


--
-- Name: user_account user_account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT user_account_pkey PRIMARY KEY (id);


--
-- Name: user_account user_account_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT user_account_username_key UNIQUE (username);


--
-- Name: work_location work_location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_location
    ADD CONSTRAINT work_location_pkey PRIMARY KEY (id);


--
-- Name: idx_att_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_att_date ON public.attendance USING btree (attendance_date);


--
-- Name: idx_att_payroll; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_att_payroll ON public.attendance USING btree (payroll_id);


--
-- Name: idx_decision_issuer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_decision_issuer ON public.hr_decision USING btree (issuer_id);


--
-- Name: idx_decision_payroll; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_decision_payroll ON public.hr_decision USING btree (payroll_id);


--
-- Name: idx_emp_work_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_emp_work_email ON public.employee USING btree (work_email);


--
-- Name: idx_explanation_emp_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_explanation_emp_date ON public.attendance_explanation_request USING btree (employee_id, attendance_date);


--
-- Name: idx_explanation_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_explanation_status ON public.attendance_explanation_request USING btree (status);


--
-- Name: idx_loc_assignment; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_loc_assignment ON public.location_assignment USING btree (employee_id, assigned_date);


--
-- Name: idx_notif_unread; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notif_unread ON public.notification_recipient USING btree (employee_id) WHERE (is_read = false);


--
-- Name: idx_ot_payroll; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ot_payroll ON public.overtime_request USING btree (payroll_id);


--
-- Name: idx_payroll_period; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payroll_period ON public.payroll USING btree (month_year);


--
-- Name: attendance attendance_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(id) ON DELETE RESTRICT;


--
-- Name: attendance attendance_payroll_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_payroll_id_fkey FOREIGN KEY (payroll_id) REFERENCES public.payroll(id) ON DELETE SET NULL;


--
-- Name: attendance attendance_work_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_work_location_id_fkey FOREIGN KEY (work_location_id) REFERENCES public.work_location(id) ON DELETE SET NULL;


--
-- Name: contract contract_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contract
    ADD CONSTRAINT contract_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(id) ON DELETE RESTRICT;


--
-- Name: department department_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch(id) ON DELETE SET NULL;


--
-- Name: employee employee_direct_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_direct_manager_id_fkey FOREIGN KEY (direct_manager_id) REFERENCES public.employee(id) ON DELETE SET NULL;


--
-- Name: employee employee_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_position_id_fkey FOREIGN KEY (position_id) REFERENCES public."position"(id) ON DELETE SET NULL;


--
-- Name: department fk_dept_manager; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT fk_dept_manager FOREIGN KEY (manager_id) REFERENCES public.employee(id) ON DELETE SET NULL;


--
-- Name: ai_alerts fk_employee_ai; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_alerts
    ADD CONSTRAINT fk_employee_ai FOREIGN KEY (employee_id) REFERENCES public.employee(id) ON DELETE CASCADE;


--
-- Name: attendance_explanation_request fk_explanation_approver; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance_explanation_request
    ADD CONSTRAINT fk_explanation_approver FOREIGN KEY (approver_id) REFERENCES public.employee(id) ON DELETE SET NULL;


--
-- Name: attendance_explanation_request fk_explanation_employee; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance_explanation_request
    ADD CONSTRAINT fk_explanation_employee FOREIGN KEY (employee_id) REFERENCES public.employee(id) ON DELETE CASCADE;


--
-- Name: hr_decision hr_decision_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_decision
    ADD CONSTRAINT hr_decision_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(id) ON DELETE RESTRICT;


--
-- Name: hr_decision hr_decision_issuer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_decision
    ADD CONSTRAINT hr_decision_issuer_id_fkey FOREIGN KEY (issuer_id) REFERENCES public.employee(id) ON DELETE SET NULL;


--
-- Name: hr_decision hr_decision_payroll_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hr_decision
    ADD CONSTRAINT hr_decision_payroll_id_fkey FOREIGN KEY (payroll_id) REFERENCES public.payroll(id) ON DELETE SET NULL;


--
-- Name: leave_request leave_request_approver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leave_request
    ADD CONSTRAINT leave_request_approver_id_fkey FOREIGN KEY (approver_id) REFERENCES public.employee(id) ON DELETE RESTRICT;


--
-- Name: leave_request leave_request_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leave_request
    ADD CONSTRAINT leave_request_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(id) ON DELETE RESTRICT;


--
-- Name: location_assignment location_assignment_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location_assignment
    ADD CONSTRAINT location_assignment_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch(id) ON DELETE CASCADE;


--
-- Name: location_assignment location_assignment_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location_assignment
    ADD CONSTRAINT location_assignment_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(id) ON DELETE CASCADE;


--
-- Name: location_assignment location_assignment_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location_assignment
    ADD CONSTRAINT location_assignment_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(id) ON DELETE CASCADE;


--
-- Name: location_assignment location_assignment_work_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location_assignment
    ADD CONSTRAINT location_assignment_work_location_id_fkey FOREIGN KEY (work_location_id) REFERENCES public.work_location(id) ON DELETE CASCADE;


--
-- Name: notification_recipient notification_recipient_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_recipient
    ADD CONSTRAINT notification_recipient_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(id) ON DELETE CASCADE;


--
-- Name: notification_recipient notification_recipient_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_recipient
    ADD CONSTRAINT notification_recipient_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.notification(id) ON DELETE CASCADE;


--
-- Name: notification notification_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.employee(id) ON DELETE SET NULL;


--
-- Name: notification notification_target_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_target_department_id_fkey FOREIGN KEY (target_department_id) REFERENCES public.department(id) ON DELETE SET NULL;


--
-- Name: notification notification_target_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_target_employee_id_fkey FOREIGN KEY (target_employee_id) REFERENCES public.employee(id) ON DELETE SET NULL;


--
-- Name: overtime_request overtime_request_approver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.overtime_request
    ADD CONSTRAINT overtime_request_approver_id_fkey FOREIGN KEY (approver_id) REFERENCES public.employee(id) ON DELETE SET NULL;


--
-- Name: overtime_request overtime_request_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.overtime_request
    ADD CONSTRAINT overtime_request_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(id) ON DELETE RESTRICT;


--
-- Name: overtime_request overtime_request_payroll_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.overtime_request
    ADD CONSTRAINT overtime_request_payroll_id_fkey FOREIGN KEY (payroll_id) REFERENCES public.payroll(id) ON DELETE SET NULL;


--
-- Name: payroll payroll_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll
    ADD CONSTRAINT payroll_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(id) ON DELETE RESTRICT;


--
-- Name: position position_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."position"
    ADD CONSTRAINT position_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(id) ON DELETE CASCADE;


--
-- Name: user_account user_account_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT user_account_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(id) ON DELETE CASCADE;


--
-- Name: work_location work_location_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_location
    ADD CONSTRAINT work_location_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict j3PMBASTTGuG3GR7uTgACEPi0JKlm3ahCRGefz23MDJ1hUicwIdeqZpn7fp0aSX

