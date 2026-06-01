--
-- PostgreSQL database dump
--

\restrict f7o0hGTTe7WzKOpahCUEoTsMFye7FJxEGFEgdg5XyZPa6XkgTjSKu0Qz6iSjspm

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

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
317	TURNOVER_RISK	LOW	{"summary":"Nhân viên Test đã có mặt đầy đủ trong suốt tháng 5/2026, không có vắng mặt, trễ hay về sớm. Tuy nhiên, nhân viên chưa nhận được bất kỳ khen thưởng nào và cũng không có kỷ luật.","recommendations":["Tạo cơ hội để nhân viên tham gia các dự án thực tế","Cải thiện giao tiếp với nhân viên về mục tiêu công việc và giá trị cống hiến của họ"],"risk_score":25,"analysis":{"key_concerns":["Nhân viên chưa có kinh nghiệm làm việc thực tế"],"positive_signals":[],"behavior_pattern":"Đã thể hiện sự chuyên nghiệp cao trong thời gian thử việc, nhưng cần thêm động lực để tăng cường hiệu suất và cảm thấy giá trị của công việc."},"retention_strategy":[{"action":"Tạo cơ hội cho nhân viên tham gia các dự án thực tế","priority":"HIGH","timeline":"1 tuần"}],"suggested_action":{"type":"monitor","reason":"Để theo dõi sự tiến bộ và xác định liệu có cần thêm hỗ trợ hay không."},"last_stats":{"pastWorkingDays":7,"presentCount":7,"totalWorkHours":56,"otHours":0,"absentCount":0,"lateCount":0,"earlyLeaveCount":0,"approvedLeaveCount":0,"disciplineCount":0,"rewardCount":0,"gpsFraudCount":0}}	PENDING	2026-05-08 08:31:28.692	2026-05-08 08:31:28.692	043bffa9-79f6-49fc-b77e-bfeeabff040e
318	TURNOVER_RISK	LOW	{"summary":"Nhân viên Châu Ngọc Hội có mặt đầy đủ trong tháng 5/2026, không có dấu hiệu về trễ hay về sớm. Tuy nhiên, do nhân viên này mới tham gia công ty chỉ được 1 năm, nên rủi ro nghỉ việc vẫn ở mức thấp.","recommendations":["Tạo cơ hội cho nhân viên tham gia các khóa đào tạo để phát triển kỹ năng chuyên môn.","Điều tra thêm về nguyên nhân nếu có bất kỳ dấu hiệu nào về không hài lòng tại nơi làm việc."],"risk_score":20,"analysis":{"key_concerns":["Không có kỷ luật hoặc khen thưởng trong tháng."],"positive_signals":["Nhân viên có mặt đầy đủ trong tất cả các ngày làm việc."],"behavior_pattern":"Duy trì công việc ổn định, không có dấu hiệu về trễ hay về sớm. Tuy nhiên, nhân viên mới nên cần thêm thời gian để hòa nhập và thể hiện năng lực."},"retention_strategy":[{"action":"Giao thêm dự án nhỏ để tăng cường trách nhiệm","priority":"MEDIUM","timeline":"1 tuần"}],"suggested_action":{"type":"monitor","reason":"Tiếp tục theo dõi sự tiến triển của nhân viên trong thời gian tới."},"last_stats":{"pastWorkingDays":7,"presentCount":7,"totalWorkHours":56,"otHours":0,"absentCount":0,"lateCount":0,"earlyLeaveCount":0,"approvedLeaveCount":0,"disciplineCount":0,"rewardCount":0,"gpsFraudCount":0}}	PENDING	2026-05-08 08:32:21.896	2026-05-08 08:32:21.896	80966e2b-89e4-49b1-9948-57d226a9f363
323	TURNOVER_RISK	LOW	{"summary":"Lê Lập Trình Viên đã chứng tỏ tinh thần cống hiến vượt bậc và tính kỷ luật cực cao trong tháng 05/2026. Anh không đi trễ, không về sớm, và không nghỉ phép không lý do. Đồng thời, anh đã đóng góp tổng cộng 13.5 giờ tăng ca (OT) để hỗ trợ các dự án quan trọng của công ty. Đây là một nhân sự cốt cán có mức độ gắn kết cao và xứng đáng được khen thưởng đặc biệt.","recommendations":["Đề xuất khen thưởng bằng tiền mặt trị giá 1,000,000 VND và vinh danh Nhân viên Xuất sắc Tháng.","Cân nhắc điều chỉnh lương hoặc lộ trình thăng tiến sớm để giữ chân nhân tài.","HR tổ chức gặp mặt để ghi nhận sự cống hiến và tiếp thêm động lực cho đội ngũ."],"risk_score":15,"analysis":{"key_concerns":[],"positive_signals":["Chuyên cần tuyệt đối 17/17 ngày công","Số giờ OT cống hiến cao: 13.5 giờ","Không đi trễ, không về sớm, không vi phạm GPS"],"behavior_pattern":"Ổn định, cống hiến cao và cam kết tuyệt đối với mục tiêu chung."},"retention_strategy":[{"action":"Vinh danh thành tích và khen thưởng tài chính trong kỳ họp tới","priority":"HIGH","timeline":"Trong 1 tuần"}],"suggested_action":{"type":"reward","reason":"Đạt thành tích xuất sắc về số giờ làm và OT, giữ vững kỷ luật 100%."},"last_stats":{"pastWorkingDays":17,"presentCount":17,"totalWorkHours":149.5,"otHours":13.5,"absentCount":0,"lateCount":0,"earlyLeaveCount":0,"approvedLeaveCount":0,"disciplineCount":0,"rewardCount":0,"gpsFraudCount":0}}	PENDING	2026-05-20 13:54:54.445139	2026-05-20 13:54:54.445139	cccccccc-cccc-cccc-cccc-cccccccccccc
324	TURNOVER_RISK	HIGH	{"summary":"Trần Thị Quản Lý có dấu hiệu sụt giảm động lực làm việc nghiêm trọng trong tháng này. Trong tổng số 17 ngày làm việc, cô đi trễ 3 lần và về sớm 2 lần (tổng cộng 5 lần vi phạm kỷ luật lao động). Rủi ro nghỉ việc của nhân viên này được đánh giá ở mức cao do sự suy giảm tính cam kết.","recommendations":["Quản lý trực tiếp cần có cuộc trao đổi 1-1 khẩn cấp để tìm hiểu nguyên nhân (sức khỏe, gia đình hay bất mãn công việc).","Nhắc nhở về quy chế chấm công và nội quy lao động của công ty.","Tạm thời giám sát sát sao hiệu suất công việc và hỗ trợ khi cần thiết."],"risk_score":82,"analysis":{"key_concerns":["Đi trễ 3 lần gây ảnh hưởng đến giờ bắt đầu làm việc chung","Về sớm 2 lần phản ánh thái độ thiếu tập trung và giảm nhiệt huyết","Tổng cộng 5 lần vi phạm kỷ luật chuyên cần"],"positive_signals":["Vẫn đi làm đầy đủ các ngày công chuẩn"],"behavior_pattern":"Đi làm đầy đủ nhưng không tuân thủ giờ giấc, có dấu hiệu mệt mỏi hoặc xao nhãng nhiệm vụ."},"retention_strategy":[{"action":"Tổ chức gặp mặt trực tiếp trao đổi và hỗ trợ giải quyết khó khăn cá nhân","priority":"HIGH","timeline":"Trong 3 ngày"}],"suggested_action":{"type":"meeting","reason":"Gặp mặt riêng để nắm bắt tình hình tư tưởng và có biện pháp chấn chỉnh kịp thời."},"last_stats":{"pastWorkingDays":17,"presentCount":17,"totalWorkHours":132.8,"otHours":0,"absentCount":0,"lateCount":3,"earlyLeaveCount":2,"approvedLeaveCount":0,"disciplineCount":0,"rewardCount":0,"gpsFraudCount":0}}	PENDING	2026-05-20 13:54:54.455921	2026-05-20 13:54:54.455921	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
320	TURNOVER_RISK	LOW	{"summary":"Nhân viên Abc đã có mặt đầy đủ trong suốt 7 ngày làm việc, không có sự trễ hoặc về sớm. Tuy nhiên, nhân viên chưa nhận được bất kỳ khen thưởng nào và cũng không có kỷ luật. Điều này cho thấy rằng nhân viên đang ổn định nhưng cần thêm động lực để tăng hiệu suất.","recommendations":["Tạo ra các mục tiêu cụ thể cho nhân viên để hướng dẫn họ cải thiện hiệu suất.","Xây dựng một hệ thống khen thưởng phù hợp để khuyến khích sự nỗ lực của nhân viên."],"risk_score":25,"analysis":{"key_concerns":["Không có sự trễ hoặc về sớm, đồng nghĩa với việc quản lý thời gian tốt."],"positive_signals":["100% mặt đúng giờ trong suốt 7 ngày làm việc."],"behavior_pattern":"Nhân viên Abc đang thể hiện sự chuyên nghiệp và kỷ luật cao trong công việc."},"retention_strategy":[{"action":"Tạo cơ hội để nhân viên nhận khen thưởng.","priority":"MEDIUM","timeline":"1 tuần"}],"suggested_action":{"type":"reward","reason":"Để tăng động lực và giữ chân nhân viên."},"last_stats":{"pastWorkingDays":7,"presentCount":7,"totalWorkHours":56,"otHours":0,"absentCount":0,"lateCount":0,"earlyLeaveCount":0,"approvedLeaveCount":0,"disciplineCount":0,"rewardCount":0,"gpsFraudCount":0}}	PENDING	2026-05-08 08:34:00.049	2026-05-08 08:34:00.049	aa77dd9a-ce37-41f8-80f3-80d14c825ec5
321	TURNOVER_RISK	LOW	{"summary":"Nhân viên Testlanthu2 đã có mặt đầy đủ trong suốt tháng 5/2026, không có kỷ luật hoặc khen thưởng. Tuy nhiên, nhân viên này chưa thể hiện các hành vi tích cực như tham gia overtime hay nhận được sự khen ngợi.","recommendations":["Tạo ra một lộ trình phát triển rõ ràng cho nhân viên thực tập này.","Cung cấp cơ hội tham gia các dự án hoặc công việc mới để kích thích động lực làm việc."],"risk_score":20,"analysis":{"key_concerns":["Không có dấu hiệu tích cực về sự nỗ lực công việc."],"positive_signals":[],"behavior_pattern":"Nhân viên Testlanthu2 đã làm việc ổn định nhưng chưa thể hiện sự cam kết mạnh mẽ với công việc."},"retention_strategy":[{"action":"Phát triển kỹ năng và tạo cơ hội thăng tiến","priority":"HIGH","timeline":"1 tuần"}],"suggested_action":{"type":"monitor","reason":"Để theo dõi sự phát triển của nhân viên trong thời gian tới."},"last_stats":{"pastWorkingDays":7,"presentCount":7,"totalWorkHours":56,"otHours":0,"absentCount":0,"lateCount":0,"earlyLeaveCount":0,"approvedLeaveCount":0,"disciplineCount":0,"rewardCount":0,"gpsFraudCount":0}}	PENDING	2026-05-08 08:34:46.561	2026-05-08 08:34:46.561	d2fb703d-ac4c-4c38-b814-875fedacfedd
325	TURNOVER_RISK	HIGH	{"summary":"Hệ thống phát hiện Ngô Ngọc Hồi có hành vi gian lận chấm công GPS lặp lại 3 lần trong tháng 05/2026. Nhân viên thực hiện check-in tại các tọa độ nằm ngoài bán kính cho phép của văn phòng (cách xa hơn 10km). Đây là hành vi vi phạm kỷ luật lao động nghiêm trọng và có rủi ro cao về tính chính trực.","recommendations":["HR lập biên bản làm việc và yêu cầu giải trình bằng văn bản về các ngày chấm công sai vị trí.","Hủy kết quả chấm công của các ngày vi phạm và trừ lương tương ứng nếu không có lý do chính đáng.","Chuyển thông tin cho Ban Giám đốc xem xét hình thức kỷ luật cảnh cáo trước toàn công ty."],"risk_score":95,"analysis":{"key_concerns":["Gian lận GPS 3 lần vào các ngày 5, 12, và 19 tháng 5 năm 2026","Khoảng cách check-in sai lệch hơn 10km so với địa điểm làm việc quy định","Vi phạm nguyên tắc trung thực và cam kết lao động"],"positive_signals":[],"behavior_pattern":"Cố tình chấm công hộ hoặc chấm công từ xa không có mặt tại nơi làm việc."},"retention_strategy":[{"action":"Triệu tập làm việc chính thức và đình chỉ tạm thời kết quả chấm công","priority":"URGENT","timeline":"Trong 1 ngày"}],"suggested_action":{"type":"discipline","reason":"Gian lận định vị GPS khi chấm công lặp lại nhiều lần."},"last_stats":{"pastWorkingDays":17,"presentCount":17,"totalWorkHours":136,"otHours":0,"absentCount":0,"lateCount":0,"earlyLeaveCount":0,"approvedLeaveCount":0,"disciplineCount":0,"rewardCount":0,"gpsFraudCount":3}}	PENDING	2026-05-20 13:54:54.456823	2026-05-20 13:54:54.456823	11111111-1111-1111-1111-111111111111
322	TURNOVER_RISK	HIGH	{"last_stats":{"absentCount":4,"lateCount":7,"gpsFraudCount":1,"otHours":0,"presentCount":15,"earlyLeaveCount":3,"totalWorkHours":120},"summary":"Nhân viên có thái độ làm việc giảm sút nghiêm trọng, thường xuyên đi trễ và vắng mặt không phép. Đặc biệt có phát hiện gian lận vị trí.","recommendations":[{"priority":"Urgent","strategy":"Tiến hành kỷ luật cảnh cáo và mời họp 1-1","reason":"Phát hiện 1 lần gian lận GPS, 4 ngày vắng không phép và 7 lần đi trễ trong tháng"}]}	PENDING	2026-05-08 11:02:17.434	2026-05-08 11:02:17.434	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
313	TURNOVER_RISK	LOW	{"summary":"Nhân viên Châu Ngọc Hội đã có mặt đầy đủ trong suốt 7 ngày làm việc, không có dấu hiệu về trễ muộn hoặc vắng mặt. Tuy nhiên, nhân viên chưa nhận được bất kỳ khen thưởng nào và cũng không có kỷ luật.","recommendations":["Nâng cao cơ chế khen thưởng để tạo động lực cho nhân viên.","Tổ chức các cuộc họp định kỳ để đánh giá hiệu suất công việc của nhân viên"],"risk_score":0,"analysis":{"key_concerns":["Nhân viên chưa có kinh nghiệm tích cực từ phía công ty như khen thưởng."],"positive_signals":[],"behavior_pattern":"Duy trì sự chuyên nghiệp cao với mức độ hiện diện đầy đủ trong suốt thời gian quan sát."},"retention_strategy":[{"action":"Tạo cơ hội cho nhân viên nhận được khen thưởng và đánh giá tích cực.","priority":"HIGH","timeline":"1 tuần"}],"suggested_action":{"type":"reward","reason":"Để khuyến khích sự chuyên nghiệp và tăng động lực làm việc."},"last_stats":{"pastWorkingDays":7,"presentCount":7,"totalWorkHours":56,"otHours":0,"absentCount":0,"lateCount":0,"earlyLeaveCount":0,"approvedLeaveCount":0,"disciplineCount":0,"rewardCount":0,"gpsFraudCount":0}}	PENDING	2026-05-08 08:28:25.055	2026-05-08 08:28:25.055	8f631fe8-88aa-49aa-b5da-e855e1be4d2b
314	TURNOVER_RISK	HIGH	{"last_stats":{"absentCount":4,"lateCount":5,"gpsFraudCount":1,"otHours":0,"presentCount":15,"earlyLeaveCount":2,"disciplineCount":1},"summary":"Nhân viên có dấu hiệu chống đối, vi phạm kỷ luật nghiêm trọng với nhiều lần đi trễ, nghỉ không phép và có hành vi gian lận vị trí chấm công. Nguy cơ nghỉ việc cực kỳ cao.","recommendations":[{"priority":"Urgent","strategy":"Lập biên bản kỷ luật và xem xét chấm dứt hợp đồng","reason":"Vi phạm nghiêm trọng: Gian lận GPS 1 lần, nghỉ vô kỷ luật 4 ngày, đi trễ 5 lần"}]}	PENDING	2026-05-08 08:29:16.524	2026-05-08 11:04:13.534	d582164b-8e56-478f-b485-6678ca75b43b
315	TURNOVER_RISK	LOW	{"summary":"Nhân viên Ngô Đăng Khoa đã có mặt đầy đủ trong 7 ngày làm việc, không có kỷ luật hay khen thưởng. Tuy nhiên, do thâm niên còn ngắn (1 năm), rủi ro nghỉ việc vẫn ở mức thấp.","recommendations":["Tiếp tục đánh giá hiệu suất định kỳ","Tạo cơ hội cho nhân viên tham gia các khóa đào tạo kỹ năng"],"risk_score":10,"analysis":{"key_concerns":[],"positive_signals":["Công tác đầy đủ","Không có kỷ luật"],"behavior_pattern":"Nhân viên hiện tại đang làm việc ổn định và tuân thủ quy định công ty."},"retention_strategy":[{"action":"Tiếp tục đánh giá hiệu suất","priority":"MEDIUM","timeline":"1 tuần"}],"suggested_action":{"type":"monitor","reason":"Để theo dõi sự tiến triển trong công việc và khả năng phát triển của nhân viên."},"last_stats":{"pastWorkingDays":7,"presentCount":7,"totalWorkHours":56,"otHours":0,"absentCount":0,"lateCount":0,"earlyLeaveCount":0,"approvedLeaveCount":0,"disciplineCount":0,"rewardCount":0,"gpsFraudCount":0}}	PENDING	2026-05-08 08:29:59.053	2026-05-08 08:29:59.053	9c80270b-9f4b-4878-85d2-37bc36ae4ceb
\.


--
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance (id, employee_id, work_location_id, attendance_date, check_in_time, check_out_time, check_in_latitude, check_in_longitude, check_out_latitude, check_out_longitude, device_ip, status, total_work_hours, payroll_id, check_out_note) FROM stdin;
1	cccccccc-cccc-cccc-cccc-cccccccccccc	2	2026-03-19	2026-03-19 08:00:00+07	2026-03-19 17:00:00+07	16.067780	108.220830	\N	\N	\N	late	8.00	\N	\N
5	cccccccc-cccc-cccc-cccc-cccccccccccc	\N	2026-03-31	2026-03-31 08:00:00+07	\N	\N	\N	\N	\N	\N	late	0.00	\N	\N
6	80966e2b-89e4-49b1-9948-57d226a9f363	\N	2026-03-31	2026-03-31 08:30:00+07	\N	\N	\N	\N	\N	\N	late	0.00	\N	\N
7	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	\N	2026-03-31	2026-03-31 07:50:00+07	\N	\N	\N	\N	\N	\N	late	0.00	\N	\N
370	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	12	2026-04-02	2026-04-02 07:30:00+07	2026-04-02 15:30:00+07	16.075324	108.222990	16.075324	108.222990	\N	late_early_leave	6.50	\N	\N
371	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	12	2026-04-02	2026-04-02 07:55:00+07	2026-04-02 15:30:00+07	16.075324	108.222990	16.075324	108.222990	\N	late_early_leave	6.50	\N	\N
372	d582164b-8e56-478f-b485-6678ca75b43b	12	2026-04-02	2026-04-02 07:55:00+07	2026-04-02 15:30:00+07	16.075324	108.222990	16.075324	108.222990	\N	late_early_leave	6.50	\N	\N
373	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	12	2026-04-07	2026-04-07 07:55:00+07	2026-04-07 15:30:00+07	16.075324	108.222990	16.075324	108.222990	\N	late_early_leave	6.50	\N	\N
374	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	12	2026-04-07	2026-04-07 07:55:00+07	2026-04-07 15:30:00+07	16.075324	108.222990	16.075324	108.222990	\N	late_early_leave	6.50	\N	\N
375	d582164b-8e56-478f-b485-6678ca75b43b	12	2026-04-07	2026-04-07 07:55:00+07	2026-04-07 15:30:00+07	16.075324	108.222990	16.075324	108.222990	\N	late_early_leave	6.50	\N	\N
376	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	12	2026-04-09	2026-04-09 07:55:00+07	2026-04-09 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
377	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	12	2026-04-09	2026-04-09 07:55:00+07	2026-04-09 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
378	d582164b-8e56-478f-b485-6678ca75b43b	12	2026-04-09	2026-04-09 07:55:00+07	2026-04-09 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
379	e68efa7c-f2cd-4c12-8510-aab7a7350070	12	2026-04-01	2026-04-01 07:55:00+07	2026-04-01 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
380	22222222-2222-2222-2222-222222222222	12	2026-04-01	2026-04-01 07:55:00+07	2026-04-01 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
381	80966e2b-89e4-49b1-9948-57d226a9f363	12	2026-04-01	2026-04-01 07:55:00+07	2026-04-01 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
382	e68efa7c-f2cd-4c12-8510-aab7a7350070	12	2026-04-02	2026-04-02 07:55:00+07	2026-04-02 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
383	22222222-2222-2222-2222-222222222222	12	2026-04-02	2026-04-02 07:55:00+07	2026-04-02 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
384	80966e2b-89e4-49b1-9948-57d226a9f363	12	2026-04-02	2026-04-02 07:55:00+07	2026-04-02 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
385	e68efa7c-f2cd-4c12-8510-aab7a7350070	12	2026-04-09	2026-04-09 08:20:00+07	2026-04-09 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	7.67	\N	\N
386	22222222-2222-2222-2222-222222222222	12	2026-04-09	2026-04-09 08:20:00+07	2026-04-09 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	7.67	\N	\N
387	80966e2b-89e4-49b1-9948-57d226a9f363	12	2026-04-09	2026-04-09 08:20:00+07	2026-04-09 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	7.67	\N	\N
550	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-13	2026-05-13 07:25:00+07	2026-05-13 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
389	11111111-1111-1111-1111-111111111111	14	2026-05-05	2026-05-05 07:26:00+07	2026-05-05 17:02:00+07	16.158924	108.274210	16.158924	108.274210	192.168.1.156	on_time	8.00	\N	\N
458	11111111-1111-1111-1111-111111111111	14	2026-05-06	2026-05-06 07:26:00+07	2026-05-06 17:02:00+07	16.058924	108.174210	16.058924	108.174210	socket:geofence	on_time	8.00	\N	\N
513	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-25	2026-05-25 07:30:00+07	2026-05-25 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
539	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-14	2026-05-14 07:25:00+07	2026-05-14 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
561	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-06	2026-05-06 07:25:00+07	2026-05-06 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
516	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-23	2026-05-23 07:30:00+07	2026-05-23 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
540	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-26	2026-05-26 07:30:00+07	2026-05-26 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
542	22222222-2222-2222-2222-222222222222	14	2026-05-23	2026-05-23 07:30:00+07	2026-05-23 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
546	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-26	2026-05-26 07:30:00+07	2026-05-26 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
547	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-25	2026-05-25 07:30:00+07	2026-05-25 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
548	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-30	2026-05-30 07:30:00+07	2026-05-30 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
551	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-30	2026-05-30 07:30:00+07	2026-05-30 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
552	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-23	2026-05-23 07:30:00+07	2026-05-23 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
553	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-26	2026-05-26 07:30:00+07	2026-05-26 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
555	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-22	2026-05-22 07:30:00+07	2026-05-22 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
559	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-25	2026-05-25 07:30:00+07	2026-05-25 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
543	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-07	2026-05-07 07:25:00+07	2026-05-07 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
556	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-08	2026-05-08 07:25:00+07	2026-05-08 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
563	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-16	2026-05-16 07:25:00+07	2026-05-16 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
560	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-07	2026-05-07 07:25:00+07	2026-05-07 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
549	22222222-2222-2222-2222-222222222222	14	2026-05-14	2026-05-14 07:25:00+07	2026-05-14 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
554	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-07	2026-05-07 07:25:00+07	2026-05-07 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
457	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-06	2026-05-06 07:25:00+07	2026-05-06 17:05:00+07	16.058924	108.174210	16.058924	108.174210	127.0.0.1	on_time	8.00	\N	\N
514	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-13	2026-05-13 07:25:00+07	2026-05-13 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
541	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-13	2026-05-13 07:20:00+07	2026-05-13 16:15:00+07	16.058924	108.174210	16.058924	108.174210	\N	early_leave	7.25	\N	\N
515	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-14	2026-05-14 07:24:00+07	2026-05-14 17:04:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
562	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-09	2026-05-09 07:25:00+07	2026-05-09 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
545	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-12	2026-05-12 07:25:00+07	2026-05-12 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
388	11111111-1111-1111-1111-111111111111	14	2026-05-01	2026-05-01 07:26:00+07	2026-05-01 17:02:00+07	16.058924	108.174210	16.058924	108.174210	127.0.0.1	on_time	8.00	\N	\N
544	11111111-1111-1111-1111-111111111111	14	2026-05-14	2026-05-14 07:26:00+07	2026-05-14 17:02:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
558	11111111-1111-1111-1111-111111111111	14	2026-05-20	2026-05-20 07:26:00+07	2026-05-20 17:02:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
811	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-01	2026-05-01 07:25:00+07	2026-05-01 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
812	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-02	2026-05-02 07:25:00+07	2026-05-02 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
813	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-04	2026-05-04 07:25:00+07	2026-05-04 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
814	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-05	2026-05-05 07:25:00+07	2026-05-05 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
815	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-06	2026-05-06 07:25:00+07	2026-05-06 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
816	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-07	2026-05-07 07:25:00+07	2026-05-07 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
600	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-19	2026-05-19 07:25:00+07	2026-05-19 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
603	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-11	2026-05-11 07:25:00+07	2026-05-11 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
519	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-22	2026-05-22 07:30:00+07	2026-05-22 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
564	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-23	2026-05-23 07:30:00+07	2026-05-23 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
566	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-22	2026-05-22 07:30:00+07	2026-05-22 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
568	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-26	2026-05-26 07:30:00+07	2026-05-26 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
569	22222222-2222-2222-2222-222222222222	14	2026-05-25	2026-05-25 07:30:00+07	2026-05-25 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
570	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-29	2026-05-29 07:30:00+07	2026-05-29 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
574	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-23	2026-05-23 07:30:00+07	2026-05-23 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
575	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-30	2026-05-30 07:30:00+07	2026-05-30 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
577	11111111-1111-1111-1111-111111111111	14	2026-05-25	2026-05-25 07:30:00+07	2026-05-25 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
578	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-21	2026-05-21 07:30:00+07	2026-05-21 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
579	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-23	2026-05-23 07:30:00+07	2026-05-23 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
583	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-22	2026-05-22 07:30:00+07	2026-05-22 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
584	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-21	2026-05-21 07:30:00+07	2026-05-21 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
587	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-28	2026-05-28 07:30:00+07	2026-05-28 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
589	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-22	2026-05-22 07:30:00+07	2026-05-22 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
594	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-21	2026-05-21 07:30:00+07	2026-05-21 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
596	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-28	2026-05-28 07:30:00+07	2026-05-28 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
598	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-25	2026-05-25 07:30:00+07	2026-05-25 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
599	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-29	2026-05-29 07:30:00+07	2026-05-29 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
605	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-29	2026-05-29 07:30:00+07	2026-05-29 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
609	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-27	2026-05-27 07:30:00+07	2026-05-27 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
611	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-28	2026-05-28 07:30:00+07	2026-05-28 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
615	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-22	2026-05-22 07:30:00+07	2026-05-22 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
590	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-06	2026-05-06 07:25:00+07	2026-05-06 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
592	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-20	2026-05-20 07:25:00+07	2026-05-20 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
585	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-09	2026-05-09 07:25:00+07	2026-05-09 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
581	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-12	2026-05-12 07:25:00+07	2026-05-12 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
613	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-15	2026-05-15 07:25:00+07	2026-05-15 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
595	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-13	2026-05-13 07:25:00+07	2026-05-13 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
614	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-14	2026-05-14 07:25:00+07	2026-05-14 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
518	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-09	2026-05-09 07:25:00+07	2026-05-09 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
606	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-19	2026-05-19 07:25:00+07	2026-05-19 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
580	22222222-2222-2222-2222-222222222222	14	2026-05-13	2026-05-13 07:25:00+07	2026-05-13 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
617	22222222-2222-2222-2222-222222222222	14	2026-05-16	2026-05-16 07:25:00+07	2026-05-16 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
567	22222222-2222-2222-2222-222222222222	14	2026-05-20	2026-05-20 07:25:00+07	2026-05-20 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
608	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-11	2026-05-11 07:25:00+07	2026-05-11 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
517	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-12	2026-05-12 07:25:00+07	2026-05-12 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
610	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-08	2026-05-08 07:25:00+07	2026-05-08 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
582	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-14	2026-05-14 07:25:00+07	2026-05-14 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
607	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-16	2026-05-16 07:25:00+07	2026-05-16 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
586	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-06	2026-05-06 07:25:00+07	2026-05-06 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
591	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-09	2026-05-09 07:25:00+07	2026-05-09 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
571	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-12	2026-05-12 07:25:00+07	2026-05-12 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
616	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-15	2026-05-15 07:25:00+07	2026-05-15 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
604	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-08	2026-05-08 07:25:00+07	2026-05-08 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
565	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-13	2026-05-13 07:25:00+07	2026-05-13 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
593	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-14	2026-05-14 07:25:00+07	2026-05-14 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
597	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-16	2026-05-16 07:25:00+07	2026-05-16 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
576	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-20	2026-05-20 07:25:00+07	2026-05-20 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
601	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-15	2026-05-15 07:25:00+07	2026-05-15 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
573	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-11	2026-05-11 07:25:00+07	2026-05-11 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
588	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-19	2026-05-19 07:25:00+07	2026-05-19 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
618	11111111-1111-1111-1111-111111111111	14	2026-05-08	2026-05-08 07:26:00+07	2026-05-08 17:02:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
572	11111111-1111-1111-1111-111111111111	14	2026-05-13	2026-05-13 07:26:00+07	2026-05-13 17:02:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
817	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-08	2026-05-08 07:25:00+07	2026-05-08 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
818	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-09	2026-05-09 07:25:00+07	2026-05-09 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
819	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-11	2026-05-11 07:25:00+07	2026-05-11 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
619	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-23	2026-05-23 07:30:00+07	2026-05-23 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
621	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-27	2026-05-27 07:30:00+07	2026-05-27 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
626	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-27	2026-05-27 07:30:00+07	2026-05-27 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
631	22222222-2222-2222-2222-222222222222	14	2026-05-27	2026-05-27 07:30:00+07	2026-05-27 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
633	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-29	2026-05-29 07:30:00+07	2026-05-29 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
637	11111111-1111-1111-1111-111111111111	14	2026-05-27	2026-05-27 07:30:00+07	2026-05-27 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
638	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-23	2026-05-23 07:30:00+07	2026-05-23 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
640	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-29	2026-05-29 07:30:00+07	2026-05-29 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
642	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-28	2026-05-28 07:30:00+07	2026-05-28 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
643	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-26	2026-05-26 07:30:00+07	2026-05-26 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
645	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-30	2026-05-30 07:30:00+07	2026-05-30 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
647	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-28	2026-05-28 07:30:00+07	2026-05-28 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
648	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-22	2026-05-22 07:30:00+07	2026-05-22 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
653	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-29	2026-05-29 07:30:00+07	2026-05-29 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
657	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-27	2026-05-27 07:30:00+07	2026-05-27 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
658	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-28	2026-05-28 07:30:00+07	2026-05-28 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
662	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-29	2026-05-29 07:30:00+07	2026-05-29 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
665	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-27	2026-05-27 07:30:00+07	2026-05-27 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
666	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-28	2026-05-28 07:30:00+07	2026-05-28 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
669	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-21	2026-05-21 07:30:00+07	2026-05-21 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
671	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-21	2026-05-21 07:30:00+07	2026-05-21 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
674	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-30	2026-05-30 07:30:00+07	2026-05-30 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
676	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-28	2026-05-28 07:30:00+07	2026-05-28 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
677	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-26	2026-05-26 07:30:00+07	2026-05-26 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
632	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-07	2026-05-07 07:25:00+07	2026-05-07 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
641	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-08	2026-05-08 07:25:00+07	2026-05-08 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
634	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-16	2026-05-16 07:25:00+07	2026-05-16 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
453	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-05	2026-05-05 07:25:00+07	2026-05-05 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
655	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-06	2026-05-06 07:25:00+07	2026-05-06 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
659	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-09	2026-05-09 07:25:00+07	2026-05-09 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
664	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-12	2026-05-12 07:25:00+07	2026-05-12 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
622	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-20	2026-05-20 07:25:00+07	2026-05-20 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
678	22222222-2222-2222-2222-222222222222	14	2026-05-06	2026-05-06 07:25:00+07	2026-05-06 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
623	22222222-2222-2222-2222-222222222222	14	2026-05-08	2026-05-08 07:25:00+07	2026-05-08 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
672	22222222-2222-2222-2222-222222222222	14	2026-05-09	2026-05-09 07:25:00+07	2026-05-09 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
646	22222222-2222-2222-2222-222222222222	14	2026-05-15	2026-05-15 07:25:00+07	2026-05-15 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
663	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-15	2026-05-15 07:25:00+07	2026-05-15 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
635	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-11	2026-05-11 07:22:00+07	2026-05-11 19:15:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	10.25	\N	\N
644	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-19	2026-05-19 07:22:00+07	2026-05-19 17:03:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
656	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-11	2026-05-11 07:25:00+07	2026-05-11 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
668	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-19	2026-05-19 07:25:00+07	2026-05-19 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
628	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-08	2026-05-08 07:25:00+07	2026-05-08 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
636	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-16	2026-05-16 07:25:00+07	2026-05-16 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
651	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-15	2026-05-15 07:25:00+07	2026-05-15 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
630	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-11	2026-05-11 07:25:00+07	2026-05-11 16:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	early_leave	7.00	\N	\N
649	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-19	2026-05-19 07:24:00+07	2026-05-19 17:04:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
654	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-08	2026-05-08 07:25:00+07	2026-05-08 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
661	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-16	2026-05-16 07:25:00+07	2026-05-16 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
673	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-20	2026-05-20 07:25:00+07	2026-05-20 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
627	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-07	2026-05-07 07:25:00+07	2026-05-07 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
675	11111111-1111-1111-1111-111111111111	14	2026-05-09	2026-05-09 07:26:00+07	2026-05-09 17:02:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
650	11111111-1111-1111-1111-111111111111	14	2026-05-15	2026-05-15 07:26:00+07	2026-05-15 17:02:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
624	11111111-1111-1111-1111-111111111111	14	2026-05-16	2026-05-16 07:26:00+07	2026-05-16 17:02:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
670	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-19	2026-05-19 07:25:00+07	2026-05-19 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
667	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-11	2026-05-11 07:25:00+07	2026-05-11 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
660	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-19	2026-05-19 07:25:00+07	2026-05-19 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
679	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-21	2026-05-21 07:30:00+07	2026-05-21 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
684	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-25	2026-05-25 07:30:00+07	2026-05-25 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
685	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-30	2026-05-30 07:30:00+07	2026-05-30 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
686	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-25	2026-05-25 07:30:00+07	2026-05-25 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
687	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-29	2026-05-29 07:30:00+07	2026-05-29 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
692	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-26	2026-05-26 07:30:00+07	2026-05-26 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
693	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-23	2026-05-23 07:30:00+07	2026-05-23 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
694	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-21	2026-05-21 07:30:00+07	2026-05-21 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
698	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-27	2026-05-27 07:30:00+07	2026-05-27 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
701	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-22	2026-05-22 07:30:00+07	2026-05-22 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
702	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-21	2026-05-21 07:30:00+07	2026-05-21 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
704	11111111-1111-1111-1111-111111111111	14	2026-05-26	2026-05-26 07:30:00+07	2026-05-26 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
706	11111111-1111-1111-1111-111111111111	14	2026-05-30	2026-05-30 07:30:00+07	2026-05-30 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
707	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-22	2026-05-22 07:30:00+07	2026-05-22 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
709	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-23	2026-05-23 07:30:00+07	2026-05-23 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
710	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-25	2026-05-25 07:30:00+07	2026-05-25 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
712	22222222-2222-2222-2222-222222222222	14	2026-05-26	2026-05-26 07:30:00+07	2026-05-26 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
714	22222222-2222-2222-2222-222222222222	14	2026-05-30	2026-05-30 07:30:00+07	2026-05-30 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
719	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-21	2026-05-21 07:30:00+07	2026-05-21 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
723	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-23	2026-05-23 07:30:00+07	2026-05-23 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
724	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-30	2026-05-30 07:30:00+07	2026-05-30 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
726	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-23	2026-05-23 07:30:00+07	2026-05-23 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
729	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-26	2026-05-26 07:30:00+07	2026-05-26 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
731	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-27	2026-05-27 07:30:00+07	2026-05-27 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
733	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-22	2026-05-22 07:30:00+07	2026-05-22 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
735	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-21	2026-05-21 07:30:00+07	2026-05-21 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
739	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-30	2026-05-30 07:30:00+07	2026-05-30 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
690	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-13	2026-05-13 07:25:00+07	2026-05-13 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
717	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-14	2026-05-14 07:25:00+07	2026-05-14 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
697	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-20	2026-05-20 07:25:00+07	2026-05-20 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
716	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-15	2026-05-15 07:25:00+07	2026-05-15 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
737	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-14	2026-05-14 07:25:00+07	2026-05-14 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
718	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-20	2026-05-20 07:25:00+07	2026-05-20 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
727	22222222-2222-2222-2222-222222222222	14	2026-05-07	2026-05-07 07:25:00+07	2026-05-07 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
689	22222222-2222-2222-2222-222222222222	14	2026-05-12	2026-05-12 07:25:00+07	2026-05-12 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
730	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-14	2026-05-14 07:25:00+07	2026-05-14 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
738	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-20	2026-05-20 07:25:00+07	2026-05-20 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
696	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-09	2026-05-09 07:25:00+07	2026-05-09 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
715	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-12	2026-05-12 07:25:00+07	2026-05-12 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
736	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-06	2026-05-06 07:22:00+07	2026-05-06 17:03:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
680	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-07	2026-05-07 07:22:00+07	2026-05-07 19:15:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	10.25	\N	\N
721	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-12	2026-05-12 07:22:00+07	2026-05-12 19:15:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	10.25	\N	\N
713	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-07	2026-05-07 07:25:00+07	2026-05-07 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
683	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-13	2026-05-13 07:25:00+07	2026-05-13 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
703	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-14	2026-05-14 07:25:00+07	2026-05-14 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
695	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-20	2026-05-20 07:25:00+07	2026-05-20 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
711	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-06	2026-05-06 07:25:00+07	2026-05-06 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
705	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-09	2026-05-09 07:25:00+07	2026-05-09 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
699	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-12	2026-05-12 07:25:00+07	2026-05-12 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
688	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-07	2026-05-07 07:24:00+07	2026-05-07 17:04:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
734	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-09	2026-05-09 07:24:00+07	2026-05-09 17:04:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
725	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-12	2026-05-12 07:24:00+07	2026-05-12 17:04:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
708	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-13	2026-05-13 07:25:00+07	2026-05-13 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
682	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-14	2026-05-14 07:25:00+07	2026-05-14 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
728	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-08	2026-05-08 07:25:00+07	2026-05-08 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
722	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-16	2026-05-16 07:25:00+07	2026-05-16 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
681	11111111-1111-1111-1111-111111111111	14	2026-05-12	2026-05-12 07:26:00+07	2026-05-12 17:02:00+07	16.158924	108.274210	16.158924	108.274210	\N	on_time	8.00	\N	\N
691	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-11	2026-05-11 07:25:00+07	2026-05-11 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
700	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-07	2026-05-07 07:25:00+07	2026-05-07 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
356	cccccccc-cccc-cccc-cccc-cccccccccccc	12	2026-04-29	2026-04-29 07:50:00+07	2026-04-29 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
357	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	12	2026-04-29	2026-04-29 07:50:00+07	2026-04-29 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
359	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	12	2026-04-01	2026-04-01 08:45:00+07	2026-04-01 17:00:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	7.25	\N	\N
360	d582164b-8e56-478f-b485-6678ca75b43b	12	2026-04-01	2026-04-01 08:45:00+07	2026-04-01 17:00:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	7.25	\N	\N
361	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	12	2026-04-06	2026-04-06 08:45:00+07	2026-04-06 17:00:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	7.25	\N	\N
362	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	12	2026-04-06	2026-04-06 08:45:00+07	2026-04-06 17:00:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	7.25	\N	\N
363	d582164b-8e56-478f-b485-6678ca75b43b	12	2026-04-06	2026-04-06 08:45:00+07	2026-04-06 17:00:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	7.25	\N	\N
364	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	12	2026-04-13	2026-04-13 08:45:00+07	2026-04-13 17:00:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	7.25	\N	\N
365	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	12	2026-04-13	2026-04-13 08:45:00+07	2026-04-13 17:00:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	7.25	\N	\N
366	d582164b-8e56-478f-b485-6678ca75b43b	12	2026-04-13	2026-04-13 08:45:00+07	2026-04-13 17:00:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	7.25	\N	\N
367	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	12	2026-04-20	2026-04-20 08:45:00+07	2026-04-20 17:00:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	7.25	\N	\N
368	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	12	2026-04-20	2026-04-20 08:45:00+07	2026-04-20 17:00:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	7.25	\N	\N
369	d582164b-8e56-478f-b485-6678ca75b43b	12	2026-04-20	2026-04-20 08:45:00+07	2026-04-20 17:00:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	7.25	\N	\N
520	11111111-1111-1111-1111-111111111111	14	2026-05-22	2026-05-22 07:30:00+07	2026-05-22 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
535	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-20	2026-05-20 07:25:00+07	2026-05-20 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
522	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-30	2026-05-30 07:30:00+07	2026-05-30 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
523	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-26	2026-05-26 07:30:00+07	2026-05-26 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
524	22222222-2222-2222-2222-222222222222	14	2026-05-22	2026-05-22 07:30:00+07	2026-05-22 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
820	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-12	2026-05-12 07:25:00+07	2026-05-12 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
526	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-21	2026-05-21 07:30:00+07	2026-05-21 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
821	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-13	2026-05-13 07:25:00+07	2026-05-13 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
822	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-14	2026-05-14 07:25:00+07	2026-05-14 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
529	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-25	2026-05-25 07:30:00+07	2026-05-25 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
823	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-15	2026-05-15 07:25:00+07	2026-05-15 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
824	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-16	2026-05-16 07:25:00+07	2026-05-16 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
826	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-19	2026-05-19 07:25:00+07	2026-05-19 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
533	11111111-1111-1111-1111-111111111111	14	2026-05-23	2026-05-23 07:30:00+07	2026-05-23 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
534	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-27	2026-05-27 07:30:00+07	2026-05-27 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
536	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-25	2026-05-25 07:30:00+07	2026-05-25 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
537	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-30	2026-05-30 07:30:00+07	2026-05-30 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
827	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-20	2026-05-20 07:25:00+07	2026-05-20 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
828	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-21	2026-05-21 07:30:00+07	2026-05-21 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
829	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-22	2026-05-22 07:30:00+07	2026-05-22 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
830	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-23	2026-05-23 07:30:00+07	2026-05-23 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
831	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-25	2026-05-25 07:30:00+07	2026-05-25 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
832	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-26	2026-05-26 07:30:00+07	2026-05-26 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
833	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-27	2026-05-27 07:30:00+07	2026-05-27 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
834	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-28	2026-05-28 07:30:00+07	2026-05-28 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
835	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-29	2026-05-29 07:30:00+07	2026-05-29 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
836	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-30	2026-05-30 07:30:00+07	2026-05-30 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
531	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-13	2026-05-13 07:22:00+07	2026-05-13 17:03:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
525	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-20	2026-05-20 07:25:00+07	2026-05-20 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
528	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-07	2026-05-07 07:25:00+07	2026-05-07 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
521	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-15	2026-05-15 07:25:00+07	2026-05-15 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
530	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-08	2026-05-08 07:25:00+07	2026-05-08 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
538	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-16	2026-05-16 07:25:00+07	2026-05-16 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
527	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-14	2026-05-14 07:25:00+07	2026-05-14 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
742	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-26	2026-05-26 07:30:00+07	2026-05-26 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
744	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-22	2026-05-22 07:30:00+07	2026-05-22 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
745	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-26	2026-05-26 07:30:00+07	2026-05-26 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
747	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-30	2026-05-30 07:30:00+07	2026-05-30 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
749	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-23	2026-05-23 07:30:00+07	2026-05-23 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
750	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-25	2026-05-25 07:30:00+07	2026-05-25 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
751	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-26	2026-05-26 07:30:00+07	2026-05-26 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
752	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-28	2026-05-28 07:30:00+07	2026-05-28 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
757	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-30	2026-05-30 07:30:00+07	2026-05-30 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
759	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-22	2026-05-22 07:30:00+07	2026-05-22 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
761	22222222-2222-2222-2222-222222222222	14	2026-05-21	2026-05-21 07:30:00+07	2026-05-21 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
766	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-29	2026-05-29 07:30:00+07	2026-05-29 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
767	11111111-1111-1111-1111-111111111111	14	2026-05-21	2026-05-21 07:30:00+07	2026-05-21 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
768	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-25	2026-05-25 07:30:00+07	2026-05-25 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
770	22222222-2222-2222-2222-222222222222	14	2026-05-28	2026-05-28 07:30:00+07	2026-05-28 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
773	11111111-1111-1111-1111-111111111111	14	2026-05-28	2026-05-28 07:30:00+07	2026-05-28 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
778	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-27	2026-05-27 07:30:00+07	2026-05-27 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
779	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-25	2026-05-25 07:30:00+07	2026-05-25 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
780	22222222-2222-2222-2222-222222222222	14	2026-05-29	2026-05-29 07:30:00+07	2026-05-29 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
784	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-27	2026-05-27 07:30:00+07	2026-05-27 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
785	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-21	2026-05-21 07:30:00+07	2026-05-21 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
786	11111111-1111-1111-1111-111111111111	14	2026-05-29	2026-05-29 07:30:00+07	2026-05-29 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
787	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-29	2026-05-29 07:30:00+07	2026-05-29 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
791	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-27	2026-05-27 07:30:00+07	2026-05-27 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
792	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-28	2026-05-28 07:30:00+07	2026-05-28 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
788	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-07	2026-05-07 07:25:00+07	2026-05-07 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
762	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-11	2026-05-11 07:25:00+07	2026-05-11 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
748	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-19	2026-05-19 07:25:00+07	2026-05-19 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
793	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-08	2026-05-08 07:25:00+07	2026-05-08 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
758	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-13	2026-05-13 07:25:00+07	2026-05-13 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
797	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-16	2026-05-16 07:25:00+07	2026-05-16 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
777	22222222-2222-2222-2222-222222222222	14	2026-05-11	2026-05-11 07:25:00+07	2026-05-11 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
774	22222222-2222-2222-2222-222222222222	14	2026-05-19	2026-05-19 07:25:00+07	2026-05-19 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
452	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-05	2026-05-05 07:25:00+07	2026-05-05 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
753	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-13	2026-05-13 07:25:00+07	2026-05-13 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
755	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-07	2026-05-07 07:25:00+07	2026-05-07 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
795	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-19	2026-05-19 07:25:00+07	2026-05-19 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
740	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-09	2026-05-09 07:22:00+07	2026-05-09 17:03:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
776	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-15	2026-05-15 07:22:00+07	2026-05-15 17:03:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
763	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-06	2026-05-06 07:25:00+07	2026-05-06 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
760	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-09	2026-05-09 07:25:00+07	2026-05-09 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
756	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-12	2026-05-12 07:25:00+07	2026-05-12 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
789	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-15	2026-05-15 07:25:00+07	2026-05-15 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
451	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-05	2026-05-05 07:25:00+07	2026-05-05 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
765	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-07	2026-05-07 07:25:00+07	2026-05-07 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
794	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-11	2026-05-11 07:25:00+07	2026-05-11 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
743	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-06	2026-05-06 08:30:00+07	2026-05-06 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	late	7.00	\N	\N
772	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-15	2026-05-15 07:24:00+07	2026-05-15 17:04:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
783	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-13	2026-05-13 07:25:00+07	2026-05-13 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
796	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-20	2026-05-20 07:25:00+07	2026-05-20 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
782	11111111-1111-1111-1111-111111111111	14	2026-05-11	2026-05-11 07:26:00+07	2026-05-11 17:02:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
769	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-06	2026-05-06 07:25:00+07	2026-05-06 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
775	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-09	2026-05-09 07:25:00+07	2026-05-09 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
781	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-12	2026-05-12 07:25:00+07	2026-05-12 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
741	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-15	2026-05-15 07:25:00+07	2026-05-15 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
754	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-06	2026-05-06 07:25:00+07	2026-05-06 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
746	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-09	2026-05-09 07:25:00+07	2026-05-09 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
764	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-12	2026-05-12 07:25:00+07	2026-05-12 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
798	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-15	2026-05-15 07:25:00+07	2026-05-15 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
799	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-30	2026-05-30 07:30:00+07	2026-05-30 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
800	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-29	2026-05-29 07:30:00+07	2026-05-29 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
397	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-01	2026-05-01 07:25:00+07	2026-05-01 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
334	11111111-1111-1111-1111-111111111111	12	2026-04-01	2026-04-01 07:50:00+07	2026-04-01 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
335	cccccccc-cccc-cccc-cccc-cccccccccccc	12	2026-04-01	2026-04-01 07:50:00+07	2026-04-01 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
336	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	12	2026-04-01	2026-04-01 07:50:00+07	2026-04-01 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
337	11111111-1111-1111-1111-111111111111	12	2026-04-02	2026-04-02 07:50:00+07	2026-04-02 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
338	cccccccc-cccc-cccc-cccc-cccccccccccc	12	2026-04-02	2026-04-02 07:50:00+07	2026-04-02 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
339	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	12	2026-04-02	2026-04-02 07:50:00+07	2026-04-02 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
340	11111111-1111-1111-1111-111111111111	12	2026-04-03	2026-04-03 07:50:00+07	2026-04-03 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
341	cccccccc-cccc-cccc-cccc-cccccccccccc	12	2026-04-03	2026-04-03 07:50:00+07	2026-04-03 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
342	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	12	2026-04-03	2026-04-03 07:50:00+07	2026-04-03 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
343	11111111-1111-1111-1111-111111111111	12	2026-04-06	2026-04-06 07:50:00+07	2026-04-06 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
344	cccccccc-cccc-cccc-cccc-cccccccccccc	12	2026-04-06	2026-04-06 07:50:00+07	2026-04-06 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
345	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	12	2026-04-06	2026-04-06 07:50:00+07	2026-04-06 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
346	11111111-1111-1111-1111-111111111111	12	2026-04-07	2026-04-07 07:50:00+07	2026-04-07 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
347	cccccccc-cccc-cccc-cccc-cccccccccccc	12	2026-04-07	2026-04-07 07:50:00+07	2026-04-07 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
348	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	12	2026-04-07	2026-04-07 07:50:00+07	2026-04-07 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
349	11111111-1111-1111-1111-111111111111	12	2026-04-08	2026-04-08 07:50:00+07	2026-04-08 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
802	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-27	2026-05-27 07:30:00+07	2026-05-27 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
804	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-26	2026-05-26 07:30:00+07	2026-05-26 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
805	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-28	2026-05-28 07:30:00+07	2026-05-28 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
350	cccccccc-cccc-cccc-cccc-cccccccccccc	12	2026-04-08	2026-04-08 07:50:00+07	2026-04-08 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
351	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	12	2026-04-08	2026-04-08 07:50:00+07	2026-04-08 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
352	11111111-1111-1111-1111-111111111111	12	2026-04-28	2026-04-28 07:50:00+07	2026-04-28 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
353	cccccccc-cccc-cccc-cccc-cccccccccccc	12	2026-04-28	2026-04-28 07:50:00+07	2026-04-28 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
354	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	12	2026-04-28	2026-04-28 07:50:00+07	2026-04-28 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
355	11111111-1111-1111-1111-111111111111	12	2026-04-29	2026-04-29 07:50:00+07	2026-04-29 17:05:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	8.00	\N	\N
413	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-02	2026-05-02 07:25:00+07	2026-05-02 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
405	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-01	2026-05-01 07:25:00+07	2026-05-01 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
399	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-01	2026-05-01 07:25:00+07	2026-05-01 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
415	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-02	2026-05-02 07:25:00+07	2026-05-02 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
392	22222222-2222-2222-2222-222222222222	14	2026-05-01	2026-05-01 07:25:00+07	2026-05-01 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
408	22222222-2222-2222-2222-222222222222	14	2026-05-02	2026-05-02 07:25:00+07	2026-05-02 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
404	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-01	2026-05-01 07:25:00+07	2026-05-01 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
809	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-08	2026-05-08 07:25:00+07	2026-05-08 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
803	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-16	2026-05-16 07:25:00+07	2026-05-16 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
416	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-02	2026-05-02 07:25:00+07	2026-05-02 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
801	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-11	2026-05-11 07:25:00+07	2026-05-11 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
401	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-01	2026-05-01 07:22:00+07	2026-05-01 17:03:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
417	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-02	2026-05-02 07:22:00+07	2026-05-02 17:03:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
394	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-01	2026-05-01 07:25:00+07	2026-05-01 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
410	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-02	2026-05-02 07:25:00+07	2026-05-02 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
403	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-01	2026-05-01 07:25:00+07	2026-05-01 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
395	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-01	2026-05-01 07:25:00+07	2026-05-01 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
411	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-02	2026-05-02 07:25:00+07	2026-05-02 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
806	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-19	2026-05-19 07:25:00+07	2026-05-19 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
398	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-01	2026-05-01 07:24:00+07	2026-05-01 17:04:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
414	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-02	2026-05-02 07:24:00+07	2026-05-02 17:04:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
390	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-01	2026-05-01 07:25:00+07	2026-05-01 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
406	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-02	2026-05-02 07:25:00+07	2026-05-02 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
393	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-01	2026-05-01 07:25:00+07	2026-05-01 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
409	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-02	2026-05-02 07:25:00+07	2026-05-02 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
808	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-14	2026-05-14 07:25:00+07	2026-05-14 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
407	11111111-1111-1111-1111-111111111111	14	2026-05-02	2026-05-02 07:26:00+07	2026-05-02 17:02:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
396	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-01	2026-05-01 07:25:00+07	2026-05-01 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
412	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-02	2026-05-02 07:25:00+07	2026-05-02 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
402	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-01	2026-05-01 07:25:00+07	2026-05-01 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
850	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-18	2026-05-18 07:25:00+07	2026-05-18 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
851	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-18	2026-05-18 07:25:00+07	2026-05-18 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
852	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-18	2026-05-18 07:25:00+07	2026-05-18 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
853	22222222-2222-2222-2222-222222222222	14	2026-05-18	2026-05-18 07:25:00+07	2026-05-18 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
854	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-18	2026-05-18 07:25:00+07	2026-05-18 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
400	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-01	2026-05-01 07:25:00+07	2026-05-01 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
855	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-18	2026-05-18 07:22:00+07	2026-05-18 17:03:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
856	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-18	2026-05-18 07:25:00+07	2026-05-18 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
857	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-18	2026-05-18 07:25:00+07	2026-05-18 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
858	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-18	2026-05-18 07:24:00+07	2026-05-18 17:04:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
859	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-18	2026-05-18 07:25:00+07	2026-05-18 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
860	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-18	2026-05-18 07:25:00+07	2026-05-18 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
720	11111111-1111-1111-1111-111111111111	14	2026-05-07	2026-05-07 07:26:00+07	2026-05-07 17:02:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
846	11111111-1111-1111-1111-111111111111	14	2026-05-18	2026-05-18 07:26:00+07	2026-05-18 17:02:00+07	16.058924	108.174210	16.058924	108.174210	127.0.0.1	on_time	8.00	\N	\N
861	11111111-1111-1111-1111-111111111111	14	2026-05-19	2026-05-19 07:26:00+07	2026-05-19 17:02:00+07	16.158924	108.274210	16.158924	108.274210	\N	on_time	8.00	\N	\N
862	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-18	2026-05-18 07:25:00+07	2026-05-18 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
863	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-18	2026-05-18 07:25:00+07	2026-05-18 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
864	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	14	2026-05-18	2026-05-18 07:25:00+07	2026-05-18 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
448	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-05	2026-05-05 07:25:00+07	2026-05-05 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
848	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-18	2026-05-18 07:25:00+07	2026-05-18 17:05:00+07	16.058924	108.174210	16.058924	108.174210	127.0.0.1	on_time	8.00	\N	\N
838	11111111-1111-1111-1111-111111111111	\N	2026-04-30	2026-04-30 07:30:00+07	\N	\N	\N	\N	\N	\N	on_time	0.00	\N	\N
849	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-18	2026-05-18 07:25:00+07	2026-05-18 17:05:00+07	16.058924	108.174210	16.058924	108.174210	192.168.0.112	on_time	8.00	\N	\N
358	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	12	2026-04-01	2026-04-01 07:30:00+07	2026-04-01 17:00:00+07	16.075324	108.222990	16.075324	108.222990	\N	late	7.25	\N	\N
429	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-04	2026-05-04 07:25:00+07	2026-05-04 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
421	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-02	2026-05-02 07:25:00+07	2026-05-02 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
431	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-04	2026-05-04 07:25:00+07	2026-05-04 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
424	22222222-2222-2222-2222-222222222222	14	2026-05-04	2026-05-04 07:25:00+07	2026-05-04 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
420	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-02	2026-05-02 07:25:00+07	2026-05-02 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
426	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-04	2026-05-04 07:25:00+07	2026-05-04 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
419	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-02	2026-05-02 07:25:00+07	2026-05-02 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
427	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-04	2026-05-04 07:25:00+07	2026-05-04 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
430	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-04	2026-05-04 08:15:00+07	2026-05-04 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	late	7.25	\N	\N
422	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-04	2026-05-04 07:25:00+07	2026-05-04 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
425	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-04	2026-05-04 07:25:00+07	2026-05-04 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
423	11111111-1111-1111-1111-111111111111	14	2026-05-04	2026-05-04 07:26:00+07	2026-05-04 17:02:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
428	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-04	2026-05-04 07:25:00+07	2026-05-04 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
418	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-02	2026-05-02 07:25:00+07	2026-05-02 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
460	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-22	2026-05-22 07:30:00+07	2026-05-22 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
463	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-27	2026-05-27 07:30:00+07	2026-05-27 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
464	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-30	2026-05-30 07:30:00+07	2026-05-30 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
467	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-29	2026-05-29 07:30:00+07	2026-05-29 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
469	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-26	2026-05-26 07:30:00+07	2026-05-26 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
473	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-23	2026-05-23 07:30:00+07	2026-05-23 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
476	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-28	2026-05-28 07:30:00+07	2026-05-28 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
478	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-27	2026-05-27 07:30:00+07	2026-05-27 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
481	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-29	2026-05-29 07:30:00+07	2026-05-29 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
490	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-25	2026-05-25 07:30:00+07	2026-05-25 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
492	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-29	2026-05-29 07:30:00+07	2026-05-29 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
495	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-28	2026-05-28 07:30:00+07	2026-05-28 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
496	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-28	2026-05-28 07:30:00+07	2026-05-28 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
499	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-21	2026-05-21 07:30:00+07	2026-05-21 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
502	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-25	2026-05-25 07:30:00+07	2026-05-25 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
445	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-05	2026-05-05 07:25:00+07	2026-05-05 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
485	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-11	2026-05-11 07:25:00+07	2026-05-11 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
498	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	14	2026-05-19	2026-05-19 07:25:00+07	2026-05-19 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
437	e68efa7c-f2cd-4c12-8510-aab7a7350070	14	2026-05-04	2026-05-04 07:25:00+07	2026-05-04 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
447	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-05	2026-05-05 07:25:00+07	2026-05-05 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
500	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-12	2026-05-12 07:25:00+07	2026-05-12 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
465	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-15	2026-05-15 07:25:00+07	2026-05-15 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
440	22222222-2222-2222-2222-222222222222	14	2026-05-05	2026-05-05 07:25:00+07	2026-05-05 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
436	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-04	2026-05-04 07:25:00+07	2026-05-04 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
501	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-09	2026-05-09 07:25:00+07	2026-05-09 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
471	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-15	2026-05-15 07:25:00+07	2026-05-15 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
432	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-04	2026-05-04 07:25:00+07	2026-05-04 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
433	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-04	2026-05-04 07:22:00+07	2026-05-04 19:15:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	10.25	\N	\N
449	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-05	2026-05-05 07:22:00+07	2026-05-05 19:15:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	10.25	\N	\N
480	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-08	2026-05-08 07:22:00+07	2026-05-08 19:15:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	10.25	\N	\N
487	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-16	2026-05-16 07:22:00+07	2026-05-16 17:03:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
442	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-05	2026-05-05 07:25:00+07	2026-05-05 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
468	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-08	2026-05-08 07:25:00+07	2026-05-08 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
462	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	14	2026-05-16	2026-05-16 07:25:00+07	2026-05-16 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
435	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-04	2026-05-04 07:25:00+07	2026-05-04 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
488	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-11	2026-05-11 07:25:00+07	2026-05-11 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
493	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-19	2026-05-19 07:25:00+07	2026-05-19 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
443	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-05	2026-05-05 07:25:00+07	2026-05-05 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
446	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-05	2026-05-05 07:24:00+07	2026-05-05 17:04:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
489	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-08	2026-05-08 08:10:00+07	2026-05-08 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	late	7.33	\N	\N
483	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-16	2026-05-16 07:24:00+07	2026-05-16 17:04:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
438	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-05	2026-05-05 07:25:00+07	2026-05-05 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
466	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-11	2026-05-11 07:25:00+07	2026-05-11 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
475	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-19	2026-05-19 07:25:00+07	2026-05-19 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
441	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-05	2026-05-05 07:25:00+07	2026-05-05 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
497	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-06	2026-05-06 07:25:00+07	2026-05-06 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
494	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-09	2026-05-09 07:25:00+07	2026-05-09 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
491	80966e2b-89e4-49b1-9948-57d226a9f363	14	2026-05-12	2026-05-12 07:25:00+07	2026-05-12 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
444	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-05	2026-05-05 07:25:00+07	2026-05-05 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
482	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-13	2026-05-13 07:25:00+07	2026-05-13 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
461	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-14	2026-05-14 07:25:00+07	2026-05-14 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
472	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	14	2026-05-20	2026-05-20 07:25:00+07	2026-05-20 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
434	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-04	2026-05-04 07:25:00+07	2026-05-04 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
450	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-05	2026-05-05 07:25:00+07	2026-05-05 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
479	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-08	2026-05-08 07:25:00+07	2026-05-08 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
474	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-16	2026-05-16 07:25:00+07	2026-05-16 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
504	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	14	2026-05-23	2026-05-23 07:30:00+07	2026-05-23 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
508	c9cb540f-f9ab-42f2-925f-6eeca1396aee	14	2026-05-22	2026-05-22 07:30:00+07	2026-05-22 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
509	d582164b-8e56-478f-b485-6678ca75b43b	14	2026-05-21	2026-05-21 07:30:00+07	2026-05-21 17:00:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
512	be7a0a5c-8f11-4e3c-86c4-3271863339e7	14	2026-05-06	2026-05-06 07:25:00+07	2026-05-06 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
505	dddddddd-dddd-dddd-dddd-dddddddddddd	14	2026-05-06	2026-05-06 07:25:00+07	2026-05-06 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
510	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-14	2026-05-14 07:22:00+07	2026-05-14 17:03:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
503	cccccccc-cccc-cccc-cccc-cccccccccccc	14	2026-05-20	2026-05-20 07:22:00+07	2026-05-20 17:03:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
507	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	14	2026-05-20	2026-05-20 07:24:00+07	2026-05-20 17:04:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
511	043bffa9-79f6-49fc-b77e-bfeeabff040e	14	2026-05-07	2026-05-07 07:25:00+07	2026-05-07 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
506	d2fb703d-ac4c-4c38-b814-875fedacfedd	14	2026-05-13	2026-05-13 07:25:00+07	2026-05-13 17:05:00+07	16.058924	108.174210	16.058924	108.174210	\N	on_time	8.00	\N	\N
\.


--
-- Data for Name: attendance_explanation_request; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance_explanation_request (id, employee_id, attendance_date, explanation_type, proposed_check_in, proposed_check_out, reason, attachment_url, approver_id, status, created_at, updated_at, reject_reason) FROM stdin;
71fc5cab-2199-446d-9ae8-49f0ec0f004f	11111111-1111-1111-1111-111111111111	2026-04-20	forgot_checkin	17:00:00	17:00:00	Quên chấm công	\N	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	approved	2026-04-20 16:01:06.235287+07	2026-04-20 16:01:06.235287+07	\N
b6632f9c-2b18-4722-9bdb-ed5418a16d7d	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	2026-04-02	late_arrival	09:00:00	\N	dddđ	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee	approved	2026-04-21 16:23:47.109076+07	2026-04-21 16:24:23.460251+07	\N
fd94779b-6390-42a9-beb5-f604cdac1d57	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	2026-04-02	late_arrival	09:00:00	\N	dddđ	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee	approved	2026-04-21 16:23:04.184265+07	2026-05-05 11:25:30.463551+07	\N
6b472c8c-caed-4a35-9734-700c6d8f2a51	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	2026-04-01	late_arrival	08:00:00	\N	quên chấm công	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee	approved	2026-04-21 16:22:44.58091+07	2026-05-05 11:25:45.03871+07	\N
2189e6ef-2fbe-4cbb-a6e8-a8d37abb0982	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	2026-04-01	late_arrival	\N	\N	quên chấm công	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee	rejected	2026-04-21 16:22:12.229123+07	2026-05-05 11:32:38.817372+07	ngu
a8440f6a-97ea-4915-a56e-f4565d640389	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	2026-04-01	late_arrival	\N	\N	quên chấm công	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee	approved	2026-04-21 16:21:46.410318+07	2026-05-05 11:32:40.889981+07	\N
4c51ce6e-92a4-43a3-86b5-c3ee32a41a86	c9cb540f-f9ab-42f2-925f-6eeca1396aee	2026-05-05	forgot_checkin	07:00:00	17:00:00	quên chấm công	\N	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	approved	2026-05-06 10:00:47.992343+07	2026-05-06 10:00:47.992343+07	\N
b95f623c-91b1-4f45-bba1-604e932ee4a1	11111111-1111-1111-1111-111111111111	2026-04-30	forgot_checkin	07:00:00	17:00:00	quên chấm công	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee	approved	2026-05-06 09:52:59.895697+07	2026-05-06 15:37:35.850724+07	\N
14f310c2-680f-49d5-8e07-731368c80856	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	2026-04-01	late_arrival	\N	\N	quên chấm công	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee	approved	2026-04-21 16:21:46.251167+07	2026-05-06 15:37:35.891791+07	\N
bca625d0-3cb1-4ca3-ac77-54dddfb551fe	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	2026-04-01	late_arrival	\N	\N	quên chấm công	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee	approved	2026-04-21 16:21:46.073857+07	2026-05-06 15:37:35.897817+07	\N
f0d2eac9-391b-4326-8254-0f790c2ce89c	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	2026-04-01	late_arrival	\N	\N	quên chấm công	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee	approved	2026-04-21 16:21:45.261915+07	2026-05-06 15:37:38.728788+07	\N
29939e26-64d8-412c-9d79-a5982ae53aaf	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	2026-04-01	late_arrival	\N	\N	quên chấm công	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee	approved	2026-04-21 16:21:45.920327+07	2026-05-06 15:37:38.724891+07	\N
7a2346d5-bcd1-4e40-9576-0c85048ba0ed	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	2026-04-01	late_arrival	\N	\N	quên chấm công	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee	approved	2026-04-21 16:21:45.749124+07	2026-05-06 15:37:38.72628+07	\N
60ca5878-0c78-4b14-908a-63318881f3dd	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	2026-04-01	late_arrival	\N	\N	quên chấm công	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee	approved	2026-04-21 16:21:43.900134+07	2026-05-06 15:37:38.746672+07	\N
7b464dcc-6ef7-45ea-b614-b0926b7d7123	11111111-1111-1111-1111-111111111111	2026-05-17	forgot_checkin	07:55:00	18:55:00	quên chấm công	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee	rejected	2026-05-18 16:55:53.420639+07	2026-05-18 16:56:11.945782+07	hôm qua không đi làm
74f8cba5-bdca-439b-8c76-251ab733c092	11111111-1111-1111-1111-111111111111	2026-05-16	forgot_checkout	08:21:00	19:23:00	Còn quản lý thì chọn được	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee	approved	2026-05-18 17:22:44.094758+07	2026-05-18 17:23:11.968621+07	\N
e5851346-8bfc-4798-a7d1-e08a26e4bbf4	11111111-1111-1111-1111-111111111111	2026-05-16	forgot_checkin	07:23:00	17:24:00	sửa lỗi	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee	pending	2026-05-18 17:25:05.140062+07	2026-05-18 17:25:05.140062+07	\N
04ea4cff-f563-47a6-bf92-cb263804672a	c9cb540f-f9ab-42f2-925f-6eeca1396aee	2026-05-16	forgot_checkin	07:46:00	17:43:00	quên chấm công ra	\N	e68efa7c-f2cd-4c12-8510-aab7a7350070	approved	2026-05-18 17:44:03.960814+07	2026-05-18 17:44:03.960814+07	\N
\.


--
-- Data for Name: branch; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.branch (id, branch_code, branch_name, address, allowed_ips, is_active, created_at, province, hotline, email, description) FROM stdin;
1	HN01	Hội sở Hà Nội	123 Cầu Giấy, Hà Nội	{192.168.1.1,113.190.233.1}	t	2026-03-19 08:39:12.006185+07	\N	\N	\N	\N
6	HN02	Chi nhánh Hà Nội	Tòa nhà Lotte, Liễu Giai, Ba Đình	\N	t	2026-03-26 14:44:48.012089+07	\N	\N	\N	\N
7	HCM02	Chi nhánh Hồ Chí Minh	Landmark 81, Vinhomes Central Park, Bình Thạnh	\N	t	2026-03-26 14:44:48.012089+07	\N	\N	\N	\N
2	DN01	Chi nhánh Đà Nẵng	456 Lê Duẩn, Đà Nẵng	{}	t	2026-03-19 08:39:12.006185+07	\N	\N	\N	\N
3	CN_3864	Đá và Ong	136 Tôn Đức Thắng	{}	t	2026-03-21 14:00:05.585715+07	\N	\N	\N	\N
12	BR-1775465936504	Văn Phòng Khoa CNTT	03 Quang Trung	{}	t	2026-04-06 15:58:56.511757+07	\N	\N	\N	\N
\.


--
-- Data for Name: contract; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contract (id, contract_number, employee_id, contract_type, start_date, end_date, base_salary, allowances, is_active, created_at, updated_at) FROM stdin;
cf44639f-e958-4a39-b901-8c379b975839	HD-2024-04	dddddddd-dddd-dddd-dddd-dddddddddddd	indefinite	2024-03-01	\N	25000000.00	\N	t	2026-03-19 08:39:12.006185+07	2026-04-17 07:54:52.831095
6ad9b1dc-0f96-4826-a217-b10a2183819e	HD-2024-01	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	fixed_1y	2024-01-01	2026-03-29	50000000.00	[]	t	2026-03-19 08:39:12.006185+07	2026-04-17 07:54:52.831095
156c3b9a-51d2-4e18-a47c-9d6bf68d1c21	HD-2026-3587	22222222-2222-2222-2222-222222222222	indefinite	2026-03-28	\N	0.00	[]	t	2026-03-28 13:51:42.228833+07	2026-04-17 07:54:52.831095
3c21611a-a584-4025-97b9-f1a50082d861	HD-2026-6938	22222222-2222-2222-2222-222222222222	probation	2026-03-28	\N	0.00	[]	t	2026-03-28 13:52:12.250222+07	2026-04-17 07:54:52.831095
c36b5a7a-8ef3-4a1d-8ed3-1ac39dbc3feb	HD-2024-02	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	fixed_3y	2024-02-01	\N	0.00	[{"name": "hhhhh", "amount": 1213}, {"name": "jj", "amount": 0}]	t	2026-03-19 08:39:12.006185+07	2026-04-17 07:54:52.831095
2be6ca4e-c73b-47f2-a60d-03be0aa963fe	HD-2026-1963	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	fixed_3y	2026-03-30	2026-04-18	20000000.00	[]	f	2026-03-30 15:28:08.149232+07	2026-04-17 07:56:06.668286
b649e3e5-ba9e-44e4-82b6-3e6385030ec6	HD-EMP-953560-2026	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	fixed_3y	2026-04-18	2026-04-21	20000000.00	[]	t	2026-04-17 14:56:06.668286+07	2026-04-17 07:56:06.668286
1ec97060-6258-4682-87ec-ae036e9f35ec	HD-2026-7093	11111111-1111-1111-1111-111111111111	fixed_1y	2026-04-20	2027-04-19	45000000.00	[]	t	2026-04-20 16:11:04.392884+07	2026-04-20 09:11:04.392884
4cc326b6-6c19-4e3a-a468-d6d960620760	HD-2026-4940	80966e2b-89e4-49b1-9948-57d226a9f363	probation	2026-04-21	2026-06-20	12000000.00	[]	t	2026-04-21 14:22:16.134282+07	2026-04-21 07:22:16.134282
50486489-31df-4268-8721-9cd5c867b358	HD-2026-2483	c9cb540f-f9ab-42f2-925f-6eeca1396aee	probation	2026-04-21	2026-06-20	20000000.00	[]	t	2026-04-21 14:22:27.420546+07	2026-04-21 07:22:27.420546
04657344-f37a-4f97-af7d-10cdc547f84c	HD-2026-2630	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	probation	2026-04-21	2026-06-20	12000000.00	[]	t	2026-04-21 14:22:35.73037+07	2026-04-21 07:22:35.73037
d4130ecc-4654-495e-a13a-6bd617e27d24	HD-2026-1357	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	probation	2026-05-06	2026-07-06	8000000.00	\N	t	2026-05-06 10:23:50.21425+07	2026-05-06 03:23:50.21425
fd21681f-abda-4282-ae29-18f8873bdba1	HD-2026-7744	043bffa9-79f6-49fc-b77e-bfeeabff040e	fixed_1y	2026-05-06	2027-05-06	4000000.00	\N	t	2026-05-06 11:22:45.17386+07	2026-05-06 04:22:45.17386
be84dbf9-4deb-4b94-ac31-e9a80898056c	HD-2026-7234	d582164b-8e56-478f-b485-6678ca75b43b	fixed_1y	2026-05-06	2027-05-06	12000000.00	\N	t	2026-05-06 11:22:45.17386+07	2026-05-06 04:22:45.17386
f754dfc7-e57d-4739-a30c-9418aacc547f	HD-2026-1667	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	fixed_1y	2026-05-06	2027-05-06	28000000.00	\N	t	2026-05-06 11:22:45.17386+07	2026-05-06 04:22:45.17386
85dc7585-5dd5-44eb-bf02-891479d84d4f	HD-2026-7229	e68efa7c-f2cd-4c12-8510-aab7a7350070	fixed_1y	2026-05-06	2027-05-06	50000000.00	\N	t	2026-05-06 11:22:45.17386+07	2026-05-06 04:22:45.17386
112375d1-7e6e-42fa-8438-74f21a289762	HD-2026-4833	be7a0a5c-8f11-4e3c-86c4-3271863339e7	fixed_1y	2026-05-06	2027-05-06	50000000.00	\N	t	2026-05-06 11:22:45.17386+07	2026-05-06 04:22:45.17386
7de54f43-0a9d-449f-839b-18f3b243c0e3	HD-2026-7081	d2fb703d-ac4c-4c38-b814-875fedacfedd	fixed_1y	2026-05-06	2027-05-06	4000000.00	\N	t	2026-05-06 11:22:45.17386+07	2026-05-06 04:22:45.17386
9275169b-d603-4e5b-bc26-5b05b2aac725	HD-2026-4529	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	fixed_1y	2026-05-06	2027-05-06	12000000.00	\N	t	2026-05-06 11:22:45.17386+07	2026-05-06 04:22:45.17386
704204bb-15ac-4b65-89aa-4491280a8575	HD-2024-03	cccccccc-cccc-cccc-cccc-cccccccccccc	fixed_1y	2024-06-15	2025-06-14	12000000.00	[]	t	2026-03-19 08:39:12.006185+07	2026-04-17 07:54:52.831095
41596280-03e0-4fec-bfab-1f9e62b573cb	HD-2026-5408	80966e2b-89e4-49b1-9948-57d226a9f363	probation	2026-04-21	2026-05-06	12000000.00	[]	f	2026-04-21 14:22:47.54223+07	2026-05-20 13:36:56.467533
ca159f1d-0df5-4675-a9b5-c6c00d16cac2	HD-80966e2b-89e4-49b1-9948-57d226a9f363-1779284216467	80966e2b-89e4-49b1-9948-57d226a9f363	probation	2026-05-06	2026-07-05	12000000.00	{"lunch": 0, "travel": 0}	t	2026-05-20 20:36:56.467533+07	2026-05-20 13:36:56.467533
\.


--
-- Data for Name: department; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.department (id, department_code, department_name, branch_id, manager_id, is_active, created_at, description) FROM stdin;
5	PB_1774845033808	Phòng Chứng Khoán	2	\N	t	2026-03-30 11:30:33.842298+07	Phòng này để thổi nến
1	BOD	Ban Giám Đốc	3	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	t	2026-03-19 08:39:12.006185+07	
3	IT	Phòng Công nghệ Thông tin	12	c9cb540f-f9ab-42f2-925f-6eeca1396aee	t	2026-03-19 08:39:12.006185+07	
\.


--
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee (id, employee_code, full_name, personal_email, work_email, phone_number, date_of_birth, identity_card_number, gender, bank_account_number, avatar_url, position_id, direct_manager_id, join_date, status, created_at, updated_at, address, bank_name) FROM stdin;
aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	EMP-001	Nguyễn Văn Giám Đốc	bod@gmail.com	ceo@congty.com	0901000001	\N	\N	t	\N	\N	1	\N	2026-03-19	active	2026-03-19 08:39:12.006185+07	2026-03-19 08:39:12.006185+07	\N	\N
e68efa7c-f2cd-4c12-8510-aab7a7350070	EMP-616081	Admin 1	\N	ngochoinct@gmail.com	\N	\N	\N	\N	\N	\N	1	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	2026-04-21	active	2026-04-21 09:48:09.551805+07	2026-04-21 09:48:09.551805+07	\N	\N
be7a0a5c-8f11-4e3c-86c4-3271863339e7	EMP-447021	QuanLy1	\N	\N	\N	\N	\N	\N	\N	\N	1	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	2026-04-21	active	2026-04-21 09:49:51.548508+07	2026-04-21 09:49:51.548508+07	\N	\N
22222222-2222-2222-2222-222222222222	ADM-001	Administrator - Ngô Ngọc Hồi	ngochoivts6a@gmail.com	admin.hoi@congty.com	0909123456	\N	\N	t	\N	\N	1	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	2026-03-19	active	2026-03-19 15:51:26.380878+07	2026-03-19 15:51:26.380878+07	\N	\N
dddddddd-dddd-dddd-dddd-dddddddddddd	EMP-004	Phạm Quản Trị Hệ Thống	sys@gmail.com	admin@congty.com	0901000004	\N	\N	t	\N	\N	1	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	2026-03-19	active	2026-03-19 08:39:12.006185+07	2026-03-19 08:39:12.006185+07	\N	\N
c9cb540f-f9ab-42f2-925f-6eeca1396aee	EMP-643467	test123	\N	\N	\N	\N	\N	\N	\N	\N	11	\N	2026-04-21	active	2026-04-21 11:15:54.134466+07	2026-04-21 11:15:54.134466+07	\N	\N
cccccccc-cccc-cccc-cccc-cccccccccccc	EMP-003	Lê Lập Trình Viên	dev@gmail.com	employee@congty.com	0901000003	\N	\N	t	\N	\N	3	c9cb540f-f9ab-42f2-925f-6eeca1396aee	2026-03-19	active	2026-03-19 08:39:12.006185+07	2026-03-19 08:39:12.006185+07	\N	\N
8f631fe8-88aa-49aa-b5da-e855e1be4d2b	EMP-753170	Châu Ngọc Hội	\N	thanhlantt@gmail.com	\N	\N	\N	\N	\N	\N	3	c9cb540f-f9ab-42f2-925f-6eeca1396aee	2026-04-06	active	2026-04-06 15:49:59.906586+07	2026-04-06 15:49:59.906586+07	\N	\N
d582164b-8e56-478f-b485-6678ca75b43b	NV-2026-6753	Lê Trường Giang	zenblack991@gmail.com	zenwhite991@gmail.com	0866478997	2026-03-12	0451245944	t	63210000824482	\N	3	c9cb540f-f9ab-42f2-925f-6eeca1396aee	2026-03-30	active	2026-03-30 15:20:37.396729+07	2026-03-30 15:20:37.396729+07	Krông Pak	ABC
9c80270b-9f4b-4878-85d2-37bc36ae4ceb	EMP-953560	Ngô Đăng Khoa	ndkkhoa10c10@gmail.com	ndkkhoa10c10@gmail.com	\N	\N	\N	\N	\N	\N	3	c9cb540f-f9ab-42f2-925f-6eeca1396aee	2026-03-20	active	2026-03-20 16:50:01.464245+07	2026-03-20 16:50:01.464245+07	\N	\N
bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	EMP-002	Trần Thị Quản Lý	hr@gmail.com	manager@congty.com	0901000002	\N	\N	f	\N	\N	3	c9cb540f-f9ab-42f2-925f-6eeca1396aee	2026-03-19	active	2026-03-19 08:39:12.006185+07	2026-03-19 08:39:12.006185+07	\N	\N
043bffa9-79f6-49fc-b77e-bfeeabff040e	EMP-658915	Test	\N	\N	\N	\N	\N	\N	\N	\N	20	c9cb540f-f9ab-42f2-925f-6eeca1396aee	2026-04-21	active	2026-04-21 15:26:58.579+07	2026-04-21 15:26:58.579+07	\N	\N
80966e2b-89e4-49b1-9948-57d226a9f363	NV-2026-5938	Châu Ngọc Hội	chaungochoi@dtu.edu.vn	chaungochoi@dtu.edu.vn	0866478997	2026-03-18	066204008905	t	63210000824482	\N	3	c9cb540f-f9ab-42f2-925f-6eeca1396aee	2026-03-30	active	2026-03-30 12:43:56.990304+07	2026-03-30 12:43:56.990304+07	Krông Pak	BIDV
11111111-1111-1111-1111-111111111111	EMP-005	Ngô Ngọc Hồi	ngochoinct@gmail.com	ngochoinct@congty.com	0909999888	2004-12-14	066204008905	t	63210000824482	avatars/1777011632720-482217912_1156504539276338_5551604339889888936_n.jpg	3	c9cb540f-f9ab-42f2-925f-6eeca1396aee	2026-03-19	active	2026-03-19 13:17:41.860411+07	2026-04-24 13:20:32.771+07	15 Trần Đình Nam	BIDV
aa77dd9a-ce37-41f8-80f3-80d14c825ec5	EMP-274225	Abc	\N	ngochoivts6a@gmail.com	\N	\N	\N	\N	\N	\N	18	c9cb540f-f9ab-42f2-925f-6eeca1396aee	2026-04-21	active	2026-04-21 15:44:56.527+07	2026-04-21 15:44:56.527+07	\N	\N
d2fb703d-ac4c-4c38-b814-875fedacfedd	EMP-569617	Testlanthu2	\N	\N	\N	\N	\N	\N	\N	\N	20	c9cb540f-f9ab-42f2-925f-6eeca1396aee	2026-04-21	active	2026-04-21 15:28:09.14+07	2026-04-21 15:28:09.14+07	\N	\N
8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	EMP-1357	Ngô Ngọc Hội	\N	ngochoi1357@congty.com		\N	\N	\N	\N	\N	12	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	2026-05-06	active	2026-05-06 10:23:50.21425+07	2026-05-07 09:11:25.856+07	\N	\N
\.


--
-- Data for Name: hr_decision; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hr_decision (id, decision_number, employee_id, decision_type, form, amount, reason, issue_date, created_at, issuer_id, payroll_id, attachment_url) FROM stdin;
fa091320-0bbd-4155-ac5e-cea8efbe15d5	QD-KT-202604-003	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	reward	money	1000000.00	Nhân viên xuất sắc tháng 03/2026	2026-04-02	2026-04-02 09:00:00+07	\N	cf98b759-1a9c-4c4c-971a-34ad0408598a	\N
60f011c3-3ab2-48a6-907b-bf1e49a5f6ba	QĐ-2026-005	d582164b-8e56-478f-b485-6678ca75b43b	discipline	money	200000.00	Không nộp báo cáo công việc cuối tuần	2026-03-25	2026-04-04 08:48:49.683876+07	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	81b84d9e-1077-44ee-abcc-fc1ca0922724	\N
87472e97-7e3d-4bb5-a5d9-2f057f5f4a06	QĐ-2026-004	80966e2b-89e4-49b1-9948-57d226a9f363	reward	money	5000000.00	Thưởng vượt tiến độ dự án Đồ án Tốt nghiệp xuất sắc	2026-03-20	2026-04-04 08:48:49.683876+07	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	10c1927e-ffcf-4530-ba48-0688ea2ce82e	\N
01e33546-d7e3-4272-b0e0-d4f23b28279a	QD-KT-202604-002	cccccccc-cccc-cccc-cccc-cccccccccccc	reward	money	1000000.00	Nhân viên xuất sắc tháng 03/2026	2026-04-02	2026-04-02 09:00:00+07	\N	1cb1bc2a-2f9b-4e1b-a388-2d7e0820e63a	\N
cf13bc68-c7dd-44a4-ba9e-9a712379da38	QD-KL-202604-003	d582164b-8e56-478f-b485-6678ca75b43b	discipline	warning	0.00	Vi phạm nội quy giờ giấc nghiêm trọng	2026-04-28	2026-04-28 15:00:00+07	\N	dc8d2064-c6f3-4ca1-9c5a-a8354fdc7599	\N
bf6c990f-8525-4821-846a-25b9a41ec167	QD-KL-202604-002	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	discipline	warning	0.00	Vi phạm nội quy giờ giấc nghiêm trọng	2026-04-28	2026-04-28 15:00:00+07	\N	cfe9e954-7f46-417a-b76e-6876a0419801	\N
e279e885-2ab6-4393-aa79-3516482fca30	QD-KL-202604-001	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	discipline	warning	0.00	Vi phạm nội quy giờ giấc nghiêm trọng	2026-04-28	2026-04-28 15:00:00+07	\N	d8e6016a-e697-411a-b65c-c222a0b03f1f	\N
d1f76f5e-6b94-4abd-b240-98a9aa4f2731	QD-KT-202604-001	11111111-1111-1111-1111-111111111111	reward	money	1000000.00	Nhân viên xuất sắc tháng 03/2026	2026-04-02	2026-04-02 09:00:00+07	\N	b08d94c9-3672-4f6f-8961-9dc15a7bbdc9	\N
88dc631a-1e58-4173-9841-6d1f2c532b78	QĐ-2026-003	cccccccc-cccc-cccc-cccc-cccccccccccc	discipline	warning	0.00	Cảnh cáo vi phạm quy định bảo mật hệ thống máy chủ	2026-03-15	2026-04-04 08:48:49.683876+07	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	6b2ee5f6-ba8c-4ecf-bf50-37c71d01c9f2	\N
cd71c638-b5bb-40bf-bc40-cdb90fd866a1	QĐ-2026-001	11111111-1111-1111-1111-111111111111	reward	money	2000000.00	Thưởng nhân viên xuất sắc tháng 2/2026	2026-03-05	2026-04-04 08:48:49.683876+07	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	70466f04-1642-47d3-b69b-d9b50e9bf8eb	\N
\.


--
-- Data for Name: leave_request; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.leave_request (id, employee_id, leave_type, start_datetime, end_datetime, reason, approver_id, status, created_at, attachment, updated_at, reject_reason) FROM stdin;
a61243b2-f724-4f12-8c0a-299b716e1b17	cccccccc-cccc-cccc-cccc-cccccccccccc	annual	2026-03-20 00:00:00+07	2026-03-21 00:00:00+07	Xin nghỉ về quê	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	approved	2026-03-19 08:39:12.006185+07	\N	\N	\N
70506398-8e9d-4a13-9ccd-37272b3a538d	11111111-1111-1111-1111-111111111111	annual	2026-04-21 07:00:00+07	2026-04-22 07:00:00+07	Nghĩ phép năm	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	approved	2026-04-20 15:59:59.692979+07	\N	\N	\N
eb24893f-8c77-47e6-8b7e-7352461a411c	11111111-1111-1111-1111-111111111111	annual	2026-04-11 07:00:00+07	2026-04-11 07:00:00+07	Nghĩ về đám giỗ	22222222-2222-2222-2222-222222222222	approved	2026-04-11 08:00:00.428998+07	\N	\N	\N
2a4e78eb-7b7b-45b0-9ab6-6fa0208dc36f	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	annual	2026-04-22 07:00:00+07	2026-04-23 07:00:00+07	abc	dddddddd-dddd-dddd-dddd-dddddddddddd	approved	2026-04-21 09:21:14.509875+07	\N	\N	\N
b97ce623-f55a-4c08-a8fe-d584f6e9d0f2	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	annual	2026-04-24 07:00:00+07	2026-04-25 07:00:00+07	nghĩ phép năm	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	approved	2026-04-24 09:25:36.049931+07	\N	\N	\N
6ec5bfbb-4f51-45ae-8a0d-6afec2d8148e	c9cb540f-f9ab-42f2-925f-6eeca1396aee	annual	2026-04-24 07:00:00+07	2026-04-24 07:00:00+07	test\r\n	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	approved	2026-04-24 10:12:42.086666+07	\N	\N	\N
2c954640-ddd8-4d7e-8bb9-b0eeaaf0483b	c9cb540f-f9ab-42f2-925f-6eeca1396aee	annual	2026-05-05 07:00:00+07	2026-05-05 07:00:00+07	nghĩ ốm	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	approved	2026-05-05 09:18:44.00647+07	\N	\N	\N
72143c38-23c7-4544-9b23-f403aebc66c1	11111111-1111-1111-1111-111111111111	annual	2026-05-21 07:00:00+07	2026-05-21 07:00:00+07	test	c9cb540f-f9ab-42f2-925f-6eeca1396aee	rejected	2026-05-05 11:39:14.453892+07	\N	2026-05-05 11:39:35.686065+07	không hợp lý
b9469095-74a4-4669-8beb-d7186ed1aa7e	11111111-1111-1111-1111-111111111111	sick	2026-05-06 07:00:00+07	2026-05-07 07:00:00+07	nghĩ ốm	c9cb540f-f9ab-42f2-925f-6eeca1396aee	rejected	2026-05-05 11:24:44.131763+07	\N	2026-05-05 11:25:15.108427+07	không được
f5d822d6-e271-4ed2-9bf4-35c01a282c12	11111111-1111-1111-1111-111111111111	annual	2026-05-05 07:00:00+07	2026-05-06 06:59:59+07	Nghĩ	c9cb540f-f9ab-42f2-925f-6eeca1396aee	rejected	2026-05-05 08:09:05.757474+07	\N	2026-05-05 11:25:23.262656+07	không được
9e4b5a48-c835-489d-8e73-c189be8188fc	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	annual	2026-04-24 07:00:00+07	2026-04-24 07:00:00+07	test	c9cb540f-f9ab-42f2-925f-6eeca1396aee	rejected	2026-04-24 10:12:04.863325+07	\N	2026-05-05 11:25:28.479073+07	không được
335380da-cd2f-41f5-a1be-a594fddc6f0e	c9cb540f-f9ab-42f2-925f-6eeca1396aee	annual	2026-05-14 07:00:00+07	2026-05-14 07:00:00+07	xin nghĩ	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	rejected	2026-05-05 15:09:16.207276+07	\N	\N	không được
ad534b26-b079-4da8-9fa0-0d02bc8d930c	c9cb540f-f9ab-42f2-925f-6eeca1396aee	bereavement	2026-05-06 07:00:00+07	2026-05-06 07:00:00+07	nghĩ tang	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	approved	2026-05-06 09:54:51.166763+07	\N	\N	\N
b604ec9f-ff08-4317-b844-f7043f7661f3	c9cb540f-f9ab-42f2-925f-6eeca1396aee	annual	2026-05-07 07:00:00+07	2026-05-07 07:00:00+07	test	dddddddd-dddd-dddd-dddd-dddddddddddd	pending	2026-05-06 15:36:08.605483+07	\N	\N	\N
9ee3744e-1e86-4486-914a-108381e6c15f	c9cb540f-f9ab-42f2-925f-6eeca1396aee	annual	2026-05-08 07:00:00+07	2026-05-09 07:00:00+07	adasa	e68efa7c-f2cd-4c12-8510-aab7a7350070	approved	2026-05-07 10:18:07.144973+07	\N	\N	\N
67bf9955-8ac4-4c0d-bef8-93e616665124	11111111-1111-1111-1111-111111111111	sick	2026-05-09 07:00:00+07	2026-05-09 07:00:00+07	bị ốm	c9cb540f-f9ab-42f2-925f-6eeca1396aee	rejected	2026-05-09 14:08:20.131149+07	\N	2026-05-18 18:16:50.186447+07	không được
\.


--
-- Data for Name: location_assignment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.location_assignment (id, employee_id, work_location_id, assigned_date, is_temporary, status, created_at, branch_id, department_id, end_date) FROM stdin;
7	11111111-1111-1111-1111-111111111111	16	2026-05-19	f	approved	2026-05-19 14:22:50.438657+07	\N	\N	\N
\.


--
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification (id, sender_id, title, content, notification_type, created_at, target, "desc", status, target_department_id, target_employee_id) FROM stdin;
5de62bc2-e6a3-482c-8849-aa67f7f4ecaf	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	Heloo	Test	info	2026-03-30 11:29:02.962515+07	Cá nhân	Test...	Đã gửi	1	22222222-2222-2222-2222-222222222222
96e08a80-b7cf-4a92-b668-74389d8bb595	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	Hôm Nay	Tôi Xong sprint1	info	2026-03-30 15:29:52.764956+07	Phòng ban	Tôi Xong sprint1...	Đã gửi	1	\N
5ca62fff-31ce-48f6-8755-63eca0640992	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	Hôm nay	Xong sprint 1	info	2026-03-30 15:30:55.792264+07	Phòng ban	Xong sprint 1...	Đã gửi	3	\N
7f85d0f5-0f4a-41c3-88e2-112be65a3d5d	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	Hôm nay	Cảnh báo	warning	2026-03-30 15:31:12.622513+07	Phòng ban	Cảnh báo...	Đã gửi	3	\N
206fd4e9-07b9-489e-8cfd-59e0e0611f84	\N	🎉 Quyết định Khen thưởng: QĐ-26-006	\n        <p>Phòng Nhân sự vừa ban hành một Quyết định hành chính đối với bạn.</p>\n        <ul>\n          <li><strong>Hình thức:</strong> money</li>\n          <li><strong>Lý do:</strong> Hoàn thành deadline trước thời hạn</li>\n          <li><strong>Hiệu lực từ:</strong> 4/4/2026</li>\n        </ul>\n      	info	2026-04-04 09:49:27.486036+07	Cá nhân	Quyết định số QĐ-26-006	Đã gửi	\N	11111111-1111-1111-1111-111111111111
7b00278d-cacd-4264-a888-098f4ae201db	\N	🎉 Quyết định Khen thưởng: QĐ-26-007	\n        <p>Phòng Nhân sự vừa ban hành một Quyết định hành chính đối với bạn.</p>\n        <ul>\n          <li><strong>Hình thức:</strong> money</li>\n          <li><strong>Lý do:</strong> Hoàn thành deadline trước hạn</li>\n          <li><strong>Hiệu lực từ:</strong> 4/4/2026</li>\n        </ul>\n      	info	2026-04-04 09:50:19.985884+07	Cá nhân	Quyết định số QĐ-26-007	Đã gửi	\N	11111111-1111-1111-1111-111111111111
f07516a7-268d-402d-ab5b-98f83abd4b96	\N	🎉 Quyết định Khen thưởng: QĐ-26-008	<p>Phòng Nhân sự vừa ban hành Quyết định đối với bạn.</p><ul><li>Hình thức: money</li><li>Lý do: Hoàn thành deadline trước hạn</li></ul>	info	2026-04-04 09:59:46.756087+07	Cá nhân	Quyết định số QĐ-26-008	Đã gửi	\N	11111111-1111-1111-1111-111111111111
fe77c8d7-2d0e-4240-b6ff-e06f935e553a	\N	🎉 Quyết định Khen thưởng: QĐ-26-009	<p>Phòng Nhân sự vừa ban hành Quyết định đối với bạn.</p><ul><li>Hình thức: money</li><li>Lý do: test</li></ul>	info	2026-04-04 10:04:23.644382+07	Cá nhân	Quyết định số QĐ-26-009	Đã gửi	\N	11111111-1111-1111-1111-111111111111
6225b184-1e42-4e79-93e3-e06bfa70d6fa	\N	🎉 Quyết định Khen thưởng: QĐ-26-010	<p>Phòng Nhân sự vừa ban hành Quyết định đối với bạn.</p><ul><li>Hình thức: money</li><li>Lý do: Test hệ thống</li></ul>	info	2026-04-04 10:08:15.89944+07	Cá nhân	Quyết định số QĐ-26-010	Đã gửi	\N	11111111-1111-1111-1111-111111111111
c1f7bb0e-7948-4e7f-ad46-b6604fabce5c	\N	🎉 Quyết định Khen thưởng: QĐ-26-011	<p>Phòng Nhân sự vừa ban hành Quyết định đối với bạn.</p><ul><li>Hình thức: gift</li><li>Lý do: test</li></ul>	info	2026-04-04 10:10:26.887991+07	Cá nhân	Quyết định số QĐ-26-011	Đã gửi	\N	11111111-1111-1111-1111-111111111111
0e4aad83-d5b0-421c-87d8-b49a0d2a5f5d	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	🎉 Quyết định Khen thưởng: QĐ-26-013	<p>Phòng Nhân sự vừa ban hành Quyết định đối với bạn.</p><ul><li>Hình thức: money</li><li>Lý do: test</li></ul>	warning	2026-04-04 10:21:20.778863+07	Cá nhân	Phòng Nhân sự vừa ban hành Quyết định đối với bạn.Hình thức:...	Đã chỉnh sửa	3	9c80270b-9f4b-4878-85d2-37bc36ae4ceb
f208661c-8737-4089-b40c-8d3c09e31820	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	🎉 Quyết định Khen thưởng: QĐ-26-012	<p>Phòng Nhân sự vừa ban hành Quyết định đối với bạn.</p><ul><li>Hình thức: money</li><li>Lý do: Test</li></ul>	info	2026-04-04 10:19:22.681341+07	Phòng ban	Phòng Nhân sự vừa ban hành Quyết định đối với bạn.Hình thức:...	Đã chỉnh sửa	3	\N
cb5579cf-953e-4ccd-b50a-fc7c3fe4cffc	\N	🎉 Quyết định Khen thưởng: QĐ-26-014	<p>Phòng Nhân sự vừa ban hành Quyết định đối với bạn.</p><ul><li>Hình thức: money</li><li>Lý do: Khen thưởng test</li></ul>	info	2026-04-06 16:27:20.923558+07	Cá nhân	Quyết định số QĐ-26-014	Đã gửi	\N	11111111-1111-1111-1111-111111111111
4fe32482-421b-4160-b624-34a580a28048	\N	⚠️ Quyết định Kỷ luật: QĐ-26-015	<p>Phòng Nhân sự vừa ban hành Quyết định đối với bạn.</p><ul><li>Hình thức: warning</li><li>Lý do: Đi trể quá nhiều lần</li></ul>	warning	2026-04-06 16:32:09.341042+07	Cá nhân	Quyết định số QĐ-26-015	Đã gửi	\N	11111111-1111-1111-1111-111111111111
1baa97a7-19ab-4c0e-acec-d7dcaa72ed47	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	test	123	info	2026-04-16 14:48:43.318418+07	Toàn công ty	123...	Đã gửi	\N	\N
1198d82d-f0a5-49ee-84df-5b135d60b6e3	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	dsadas	asddsa	info	2026-04-16 14:49:21.741283+07	Toàn công ty	asddsa...	Đã gửi	\N	\N
13f9287e-c297-4c8f-a139-375e64823b0f	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	ad	ad	info	2026-04-16 14:49:43.867372+07	Toàn công ty	ad...	Đã gửi	\N	\N
7919236c-7ef4-4cd8-a169-98f0d86d0b06	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	1	1232	info	2026-04-20 09:32:49.239854+07	Toàn công ty	1232...	Đã gửi	\N	\N
6b94beca-026b-4a23-b318-92774d87a989	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	1	123	info	2026-04-20 09:32:59.300338+07	Toàn công ty	123...	Đã gửi	\N	\N
17039cfe-d6d6-408c-b0ce-b9afe4e4b3a4	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	🎉 Quyết định Khen thưởng: QĐ-26-016	\n            <p><strong style="color:#166534">Chúc mừng bạn!</strong> Phòng Nhân sự đã ban hành quyết định khen thưởng.</p>\n            <div style="margin:10px 0;padding:10px 12px;border:1px solid #bbf7d0;background:#f0fdf4;border-radius:10px;">\n              <p style="margin:0;font-weight:700;color:#166534;">Số tiền thưởng: 200.000 VNĐ</p>\n            </div>\n            <ul>\n              <li><strong>Hình thức:</strong> money</li>\n              <li><strong>Lý do:</strong> hi</li>\n            </ul>\n          	info	2026-04-20 13:55:33.96625+07	Cá nhân	Quyết định số QĐ-26-016	Đã gửi	\N	11111111-1111-1111-1111-111111111111
baaf0654-5f4b-4749-9150-40c98103ab9c	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	test phong ban	Tết rồi anh em ơi	warning	2026-03-30 11:31:19.441756+07	Phòng ban	Tết rồi anh em ơi...	Đã gửi	\N	\N
eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee	dddddddd-dddd-dddd-dddd-dddddddddddd	Chào mừng hệ thống GPS mới	Hệ thống chấm công GPS đã chính thức đi vào hoạt động.	system_info	2026-03-19 08:39:12.006185+07	Tất cả nhân viên	\N	Đã gửi	\N	\N
8d715161-a24a-4d39-80ee-da28612300b0	\N	Nghỉ phép năm bị từ chối	Nghỉ phép năm của bạn cho thời gian 07:00 24/4/26 - 07:00 24/4/26 đã bị từ chối. Lý do: test. Lý do từ chối: Không có lý do chi tiết	system_warning	2026-05-05 11:25:28.479073+07	Cá nhân	Yêu cầu của bạn đã bị quản lý từ chối.	Đã gửi	\N	9c80270b-9f4b-4878-85d2-37bc36ae4ceb
fed5b5f2-d628-4a3a-a9b6-52c216c72ffc	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	Cảnh báo chuyên cần: Trần Thị Quản Lý	\n      <p>Chào Trần Thị Quản Lý,</p>\n      <p>Hệ thống ghi nhận trong tháng này bạn có vi phạm về giờ giấc chấm công.</p>\n      <ul>\n        <li>Mã nhân viên: EMP-002</li>\n        <li>Phòng ban: Phòng Nhân sự</li>\n        <li>Số lần đi trễ: 3</li>\n        <li>Tổng thời gian đi trễ: 4 giờ 18 phút</li>\n      </ul>\n      <p>Vui lòng kiểm tra lại lịch làm việc và chủ động cải thiện trong các ngày tới.</p>\n    	warning	2026-04-17 14:58:31.383507+07	Cá nhân	\n      Chào Trần Thị Quản Lý,\n      Hệ thống ghi nhận trong ...	Đã gửi	\N	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
515863ad-2db9-4a6c-8062-2d9b6a43321c	\N	Bảng lương 04-2026 bị từ chối	\n        <p><strong style="color:#b91c1c">Bảng lương tháng 04-2026 của bạn chưa được duyệt.</strong></p>\n        <p>Vui lòng kiểm tra lại thông tin bảng lương hoặc liên hệ bộ phận phụ trách để được hỗ trợ.</p>\n      	system_warning	2026-04-20 16:10:01.393365+07	Cá nhân	Giám đốc đã từ chối bảng lương của bạn.	Đã gửi	\N	11111111-1111-1111-1111-111111111111
5e249ffc-2b17-47e2-aefc-847bc2a7c96f	\N	Bảng lương 04-2026 bị từ chối	\n        <p><strong style="color:#b91c1c">Bảng lương tháng 04-2026 của bạn chưa được duyệt.</strong></p>\n        <p>Vui lòng kiểm tra lại thông tin bảng lương hoặc liên hệ bộ phận phụ trách để được hỗ trợ.</p>\n      	system_warning	2026-04-21 09:12:52.015607+07	Cá nhân	Giám đốc đã từ chối bảng lương của bạn.	Đã gửi	\N	cccccccc-cccc-cccc-cccc-cccccccccccc
46f2facd-b119-433c-b7e8-e574008fc5a7	\N	Bảng lương 04-2026 bị từ chối	\n        <p><strong style="color:#b91c1c">Bảng lương tháng 04-2026 của bạn chưa được duyệt.</strong></p>\n        <p>Vui lòng kiểm tra lại thông tin bảng lương hoặc liên hệ bộ phận phụ trách để được hỗ trợ.</p>\n      	system_warning	2026-04-21 09:12:53.376014+07	Cá nhân	Giám đốc đã từ chối bảng lương của bạn.	Đã gửi	\N	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
007a6c69-ac5f-40f6-9f7d-551b66365992	\N	Nghỉ ốm bị từ chối	Nghỉ ốm của bạn cho thời gian 07:00 6/5/26 - 07:00 7/5/26 đã bị từ chối. Lý do: nghĩ ốm. Lý do từ chối: Không có lý do chi tiết	system_warning	2026-05-05 11:25:15.108427+07	Cá nhân	Yêu cầu của bạn đã bị quản lý từ chối.	Đã gửi	\N	11111111-1111-1111-1111-111111111111
5420a8c4-a49e-4054-9595-4d5633c3c3e2	\N	Nghỉ phép năm bị từ chối	Nghỉ phép năm của bạn cho thời gian 07:00 5/5/26 - 06:59 6/5/26 đã bị từ chối. Lý do: Nghĩ. Lý do từ chối: Không có lý do chi tiết	system_warning	2026-05-05 11:25:23.262656+07	Cá nhân	Yêu cầu của bạn đã bị quản lý từ chối.	Đã gửi	\N	11111111-1111-1111-1111-111111111111
0c088a73-cc07-46af-9414-34d513c5f903	\N	Nghỉ phép năm bị từ chối	Nghỉ phép năm của bạn cho thời gian 07:00 21/5/26 - 07:00 21/5/26 đã bị từ chối. Lý do từ chối: không hợp lý.	system_warning	2026-05-05 11:39:35.686065+07	Cá nhân	Yêu cầu của bạn đã bị quản lý từ chối: không hợp lý	Đã gửi	\N	11111111-1111-1111-1111-111111111111
979ed852-c97f-40e5-879e-0c2ef4cf1bbb	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	Đơn phép bị từ chối	\n      <p style="margin:0 0 8px;"><strong style="color:#b91c1c;font-size:18px;">Đơn phép của bạn đã bị từ chối.</strong></p>\n      <div style="margin:10px 0;padding:12px 14px;border:1px solid #fecaca;background:#fef2f2;border-radius:12px;">\n        <p style="margin:0 0 8px;"><strong>Thời gian:</strong> 07:00 14/5/26 - 07:00 14/5/26</p>\n        <p style="margin:0;"><strong>Lý do trong đơn:</strong> xin nghĩ</p>\n      <p style="margin:0;color:#b91c1c;"><strong>Lý do từ chối:</strong> Không có lý do chi tiết</p></div>\n    	system_warning	2026-05-05 15:09:42.952087+07	Cá nhân	Yêu cầu của bạn đã bị Giám đốc từ chối.	Đã gửi	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee
e9997743-f104-4209-8362-01f7f186dc22	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	Đơn tăng ca bị từ chối	\n      <p style="margin:0 0 8px;"><strong style="color:#b91c1c;font-size:18px;">Đơn tăng ca của bạn đã bị từ chối.</strong></p>\n      <div style="margin:10px 0;padding:12px 14px;border:1px solid #fecaca;background:#fef2f2;border-radius:12px;">\n        <p style="margin:0 0 8px;"><strong>Thời gian:</strong> 6/5/26 17:00 - 19:00</p>\n        <p style="margin:0;"><strong>Lý do trong đơn:</strong> tăng ca xử lý việc</p>\n      <p style="margin:0;color:#b91c1c;"><strong>Lý do từ chối:</strong> Không có lý do chi tiết</p></div>\n    	system_warning	2026-05-05 15:19:05.251793+07	Cá nhân	Yêu cầu của bạn đã bị Giám đốc từ chối.	Đã gửi	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee
e39390ba-08b7-40c7-9d8d-97f9d268e2aa	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	Đơn giải trình đã được duyệt	\n      <p style="margin:0 0 8px;"><strong style="color:#065f46;font-size:18px;">Đơn giải trình của bạn đã được chấp thuận.</strong></p>\n      <div style="margin:10px 0;padding:12px 14px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:12px;">\n        <p style="margin:0 0 8px;"><strong>Thời gian:</strong> 20/4/26 07:37 - 17:00</p>\n        <p style="margin:0;"><strong>Lý do trong đơn:</strong> Quên chấm công</p>\n      </div>\n    	system_info	2026-04-20 16:07:01.759405+07	Cá nhân	Yêu cầu của bạn đã được Giám đốc phê duyệt.	Đã gửi	\N	11111111-1111-1111-1111-111111111111
05fab4cd-6d63-4a1b-b6fa-21f832009729	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	Đơn phép đã được duyệt	\n      <p style="margin:0 0 8px;"><strong style="color:#065f46;font-size:18px;">Đơn phép của bạn đã được chấp thuận.</strong></p>\n      <div style="margin:10px 0;padding:12px 14px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:12px;">\n        <p style="margin:0 0 8px;"><strong>Thời gian:</strong> 07:00 21/4/26 - 07:00 22/4/26</p>\n        <p style="margin:0;"><strong>Lý do trong đơn:</strong> Nghĩ phép năm</p>\n      </div>\n    	system_info	2026-04-20 16:07:16.697498+07	Cá nhân	Yêu cầu của bạn đã được Giám đốc phê duyệt.	Đã gửi	\N	11111111-1111-1111-1111-111111111111
daa716d9-6b18-4877-b97b-3464732bfdf6	22222222-2222-2222-2222-222222222222	Đơn phép đã được duyệt	\n      <p style="margin:0 0 8px;"><strong style="color:#065f46;font-size:18px;">Đơn phép của bạn đã được chấp thuận.</strong></p>\n      <div style="margin:10px 0;padding:12px 14px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:12px;">\n        <p style="margin:0 0 8px;"><strong>Thời gian:</strong> 07:00 11/4/26 - 07:00 11/4/26</p>\n        <p style="margin:0;"><strong>Lý do trong đơn:</strong> Nghĩ về đám giỗ</p>\n      </div>\n    	system_info	2026-04-20 16:07:17.203536+07	Cá nhân	Yêu cầu của bạn đã được Giám đốc phê duyệt.	Đã gửi	\N	11111111-1111-1111-1111-111111111111
461e9468-f785-4817-9240-9ae6ef41d31d	\N	Đơn giải trình đã được duyệt	Đơn giải trình của bạn cho thời gian 07:00 30/4/26 đã được phê duyệt.	system_info	2026-05-06 15:37:35.850724+07	Cá nhân	Yêu cầu của bạn đã được quản lý phê duyệt.	Đã gửi	\N	11111111-1111-1111-1111-111111111111
71349826-eec9-4f21-ae92-3cd4d8c14af7	\N	Bảng lương 04-2026 đã được duyệt	\n        <p><strong style="color:#065f46">Bảng lương tháng 04-2026 của bạn đã được Giám đốc duyệt.</strong></p>\n        <div style="margin:10px 0;padding:10px 12px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:10px;">\n          <p style="margin:0;"><strong>Thực nhận:</strong> 3.583.307,69 VNĐ</p>\n          <p style="margin:8px 0 0;"><strong>Tổng khấu trừ:</strong> 4.725.000 VNĐ</p>\n        </div>\n      	system_info	2026-04-20 16:12:33.487837+07	Cá nhân	Giám đốc đã duyệt bảng lương của bạn.	Đã gửi	\N	11111111-1111-1111-1111-111111111111
f9b9a11a-12d6-4006-9fee-1e74042e7902	dddddddd-dddd-dddd-dddd-dddddddddddd	Đơn phép đã được duyệt	\n      <p style="margin:0 0 8px;"><strong style="color:#065f46;font-size:18px;">Đơn phép của bạn đã được chấp thuận.</strong></p>\n      <div style="margin:10px 0;padding:12px 14px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:12px;">\n        <p style="margin:0 0 8px;"><strong>Thời gian:</strong> 07:00 22/4/26 - 07:00 23/4/26</p>\n        <p style="margin:0;"><strong>Lý do trong đơn:</strong> abc</p>\n      </div>\n    	system_info	2026-04-21 12:58:53.479746+07	Cá nhân	Yêu cầu của bạn đã được Giám đốc phê duyệt.	Đã gửi	\N	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
e878d5e7-8424-4cd0-adcf-f7512873504d	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	Đơn phép đã được duyệt	\n      <p style="margin:0 0 8px;"><strong style="color:#065f46;font-size:18px;">Đơn phép của bạn đã được chấp thuận.</strong></p>\n      <div style="margin:10px 0;padding:12px 14px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:12px;">\n        <p style="margin:0 0 8px;"><strong>Thời gian:</strong> 07:00 24/4/26 - 07:00 25/4/26</p>\n        <p style="margin:0;"><strong>Lý do trong đơn:</strong> nghĩ phép năm</p>\n      </div>\n    	system_info	2026-04-24 09:32:31.845948+07	Cá nhân	Yêu cầu của bạn đã được Giám đốc phê duyệt.	Đã gửi	\N	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
f2e67cb8-4217-4235-8e8c-9bb82150a566	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	Đơn phép đã được duyệt	\n      <p style="margin:0 0 8px;"><strong style="color:#065f46;font-size:18px;">Đơn phép của bạn đã được chấp thuận.</strong></p>\n      <div style="margin:10px 0;padding:12px 14px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:12px;">\n        <p style="margin:0 0 8px;"><strong>Thời gian:</strong> 07:00 24/4/26 - 07:00 24/4/26</p>\n        <p style="margin:0;"><strong>Lý do trong đơn:</strong> test\r\n</p>\n      </div>\n    	system_info	2026-04-28 12:22:28.094913+07	Cá nhân	Yêu cầu của bạn đã được Giám đốc phê duyệt.	Đã gửi	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee
17878bac-2270-4c16-8c4c-618f2e9fae57	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	Đơn phép đã được duyệt	\n      <p style="margin:0 0 8px;"><strong style="color:#065f46;font-size:18px;">Đơn phép của bạn đã được chấp thuận.</strong></p>\n      <div style="margin:10px 0;padding:12px 14px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:12px;">\n        <p style="margin:0 0 8px;"><strong>Thời gian:</strong> 07:00 5/5/26 - 07:00 5/5/26</p>\n        <p style="margin:0;"><strong>Lý do trong đơn:</strong> nghĩ ốm</p>\n      </div>\n    	system_info	2026-05-05 09:19:06.480797+07	Cá nhân	Yêu cầu của bạn đã được Giám đốc phê duyệt.	Đã gửi	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee
17006267-140b-4b4b-8cbe-c245b40d3e1c	\N	Bảng lương 05-2026 đã được duyệt	\n        <p><strong style="color:#065f46">Bảng lương tháng 05-2026 của bạn đã được Giám đốc duyệt.</strong></p>\n        <div style="margin:10px 0;padding:10px 12px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:10px;">\n          <p style="margin:0;"><strong>Thực nhận:</strong> 17.900.000 VNĐ</p>\n          <p style="margin:8px 0 0;"><strong>Tổng khấu trừ:</strong> 2.100.000 VNĐ</p>\n        </div>\n      	system_info	2026-05-06 11:26:02.419457+07	Cá nhân	Giám đốc đã duyệt bảng lương của bạn.	Đã gửi	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee
80f8a6fe-23f9-4f02-87aa-9cf62584fdf2	\N	Bảng lương 05-2026 đã được duyệt	\n        <p><strong style="color:#065f46">Bảng lương tháng 05-2026 của bạn đã được Giám đốc duyệt.</strong></p>\n        <div style="margin:10px 0;padding:10px 12px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:10px;">\n          <p style="margin:0;"><strong>Thực nhận:</strong> 10.740.000 VNĐ</p>\n          <p style="margin:8px 0 0;"><strong>Tổng khấu trừ:</strong> 1.260.000 VNĐ</p>\n        </div>\n      	system_info	2026-05-06 11:26:02.419457+07	Cá nhân	Giám đốc đã duyệt bảng lương của bạn.	Đã gửi	\N	cccccccc-cccc-cccc-cccc-cccccccccccc
b5668a21-7c00-4a4c-a2da-7c9f25518ec6	\N	Bảng lương 05-2026 đã được duyệt	\n        <p><strong style="color:#065f46">Bảng lương tháng 05-2026 của bạn đã được Giám đốc duyệt.</strong></p>\n        <div style="margin:10px 0;padding:10px 12px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:10px;">\n          <p style="margin:0;"><strong>Thực nhận:</strong> 10.740.000 VNĐ</p>\n          <p style="margin:8px 0 0;"><strong>Tổng khấu trừ:</strong> 1.260.000 VNĐ</p>\n        </div>\n      	system_info	2026-05-06 11:26:02.419457+07	Cá nhân	Giám đốc đã duyệt bảng lương của bạn.	Đã gửi	\N	8f631fe8-88aa-49aa-b5da-e855e1be4d2b
6985de0f-ed73-4d4c-9a31-dbf3b68875f6	\N	Bảng lương 05-2026 đã được duyệt	\n        <p><strong style="color:#065f46">Bảng lương tháng 05-2026 của bạn đã được Giám đốc duyệt.</strong></p>\n        <div style="margin:10px 0;padding:10px 12px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:10px;">\n          <p style="margin:0;"><strong>Thực nhận:</strong> 10.740.000 VNĐ</p>\n          <p style="margin:8px 0 0;"><strong>Tổng khấu trừ:</strong> 1.260.000 VNĐ</p>\n        </div>\n      	system_info	2026-05-06 11:26:02.419457+07	Cá nhân	Giám đốc đã duyệt bảng lương của bạn.	Đã gửi	\N	d582164b-8e56-478f-b485-6678ca75b43b
004cdaef-aa37-4e71-9251-bef125f84ca6	\N	Bảng lương 05-2026 đã được duyệt	\n        <p><strong style="color:#065f46">Bảng lương tháng 05-2026 của bạn đã được Giám đốc duyệt.</strong></p>\n        <div style="margin:10px 0;padding:10px 12px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:10px;">\n          <p style="margin:0;"><strong>Thực nhận:</strong> 17.900.000 VNĐ</p>\n          <p style="margin:8px 0 0;"><strong>Tổng khấu trừ:</strong> 2.100.000 VNĐ</p>\n        </div>\n      	system_info	2026-05-06 11:26:02.419457+07	Cá nhân	Giám đốc đã duyệt bảng lương của bạn.	Đã gửi	\N	9c80270b-9f4b-4878-85d2-37bc36ae4ceb
a9b980d4-5227-4cd4-8e13-0dffd197ef4c	\N	Bảng lương 05-2026 đã được duyệt	\n        <p><strong style="color:#065f46">Bảng lương tháng 05-2026 của bạn đã được Giám đốc duyệt.</strong></p>\n        <div style="margin:10px 0;padding:10px 12px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:10px;">\n          <p style="margin:0;"><strong>Thực nhận:</strong> 10.740.000 VNĐ</p>\n          <p style="margin:8px 0 0;"><strong>Tổng khấu trừ:</strong> 1.260.000 VNĐ</p>\n        </div>\n      	system_info	2026-05-06 11:26:02.419457+07	Cá nhân	Giám đốc đã duyệt bảng lương của bạn.	Đã gửi	\N	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
84676b8b-9ddc-4ffc-9398-a6e932af66eb	\N	Bảng lương 05-2026 đã được duyệt	\n        <p><strong style="color:#065f46">Bảng lương tháng 05-2026 của bạn đã được Giám đốc duyệt.</strong></p>\n        <div style="margin:10px 0;padding:10px 12px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:10px;">\n          <p style="margin:0;"><strong>Thực nhận:</strong> 3.580.000 VNĐ</p>\n          <p style="margin:8px 0 0;"><strong>Tổng khấu trừ:</strong> 420.000 VNĐ</p>\n        </div>\n      	system_info	2026-05-06 11:26:02.419457+07	Cá nhân	Giám đốc đã duyệt bảng lương của bạn.	Đã gửi	\N	043bffa9-79f6-49fc-b77e-bfeeabff040e
0f596663-f1e6-4417-b9c4-6c67f5a61160	\N	Bảng lương 05-2026 đã được duyệt	\n        <p><strong style="color:#065f46">Bảng lương tháng 05-2026 của bạn đã được Giám đốc duyệt.</strong></p>\n        <div style="margin:10px 0;padding:10px 12px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:10px;">\n          <p style="margin:0;"><strong>Thực nhận:</strong> 10.740.000 VNĐ</p>\n          <p style="margin:8px 0 0;"><strong>Tổng khấu trừ:</strong> 1.260.000 VNĐ</p>\n        </div>\n      	system_info	2026-05-06 11:26:02.419457+07	Cá nhân	Giám đốc đã duyệt bảng lương của bạn.	Đã gửi	\N	80966e2b-89e4-49b1-9948-57d226a9f363
f33a96d8-c8c9-4248-9ee8-d11ab62bfbd0	\N	Bảng lương 05-2026 đã được duyệt	\n        <p><strong style="color:#065f46">Bảng lương tháng 05-2026 của bạn đã được Giám đốc duyệt.</strong></p>\n        <div style="margin:10px 0;padding:10px 12px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:10px;">\n          <p style="margin:0;"><strong>Thực nhận:</strong> 40.275.000 VNĐ</p>\n          <p style="margin:8px 0 0;"><strong>Tổng khấu trừ:</strong> 4.725.000 VNĐ</p>\n        </div>\n      	system_info	2026-05-06 11:26:02.419457+07	Cá nhân	Giám đốc đã duyệt bảng lương của bạn.	Đã gửi	\N	11111111-1111-1111-1111-111111111111
b76dcbd6-f7e0-4d11-833b-914cc60346e8	\N	Bảng lương 05-2026 đã được duyệt	\n        <p><strong style="color:#065f46">Bảng lương tháng 05-2026 của bạn đã được Giám đốc duyệt.</strong></p>\n        <div style="margin:10px 0;padding:10px 12px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:10px;">\n          <p style="margin:0;"><strong>Thực nhận:</strong> 25.060.000 VNĐ</p>\n          <p style="margin:8px 0 0;"><strong>Tổng khấu trừ:</strong> 2.940.000 VNĐ</p>\n        </div>\n      	system_info	2026-05-06 11:26:02.419457+07	Cá nhân	Giám đốc đã duyệt bảng lương của bạn.	Đã gửi	\N	aa77dd9a-ce37-41f8-80f3-80d14c825ec5
492dc9b0-c981-46b2-9b87-8c21cd7037fa	\N	Bảng lương 05-2026 đã được duyệt	\n        <p><strong style="color:#065f46">Bảng lương tháng 05-2026 của bạn đã được Giám đốc duyệt.</strong></p>\n        <div style="margin:10px 0;padding:10px 12px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:10px;">\n          <p style="margin:0;"><strong>Thực nhận:</strong> 3.580.000 VNĐ</p>\n          <p style="margin:8px 0 0;"><strong>Tổng khấu trừ:</strong> 420.000 VNĐ</p>\n        </div>\n      	system_info	2026-05-06 11:26:02.419457+07	Cá nhân	Giám đốc đã duyệt bảng lương của bạn.	Đã gửi	\N	d2fb703d-ac4c-4c38-b814-875fedacfedd
5b6634a8-887f-42ca-a45e-ec0313a639db	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	Đơn giải trình đã được duyệt	\n      <p style="margin:0 0 8px;"><strong style="color:#065f46;font-size:18px;">Đơn giải trình của bạn đã được chấp thuận.</strong></p>\n      <div style="margin:10px 0;padding:12px 14px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:12px;">\n        <p style="margin:0 0 8px;"><strong>Thời gian:</strong> 5/5/26 07:00 - 17:00</p>\n        <p style="margin:0;"><strong>Lý do trong đơn:</strong> quên chấm công</p>\n      </div>\n    	system_info	2026-05-06 11:26:08.107889+07	Cá nhân	Yêu cầu của bạn đã được Giám đốc phê duyệt.	Đã gửi	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee
55dfa8da-2983-4fe5-ae90-6320f1373a07	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	Đơn phép đã được duyệt	\n      <p style="margin:0 0 8px;"><strong style="color:#065f46;font-size:18px;">Đơn phép của bạn đã được chấp thuận.</strong></p>\n      <div style="margin:10px 0;padding:12px 14px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:12px;">\n        <p style="margin:0 0 8px;"><strong>Thời gian:</strong> 07:00 6/5/26 - 07:00 6/5/26</p>\n        <p style="margin:0;"><strong>Lý do trong đơn:</strong> nghĩ tang</p>\n      </div>\n    	system_info	2026-05-06 11:26:08.107889+07	Cá nhân	Yêu cầu của bạn đã được Giám đốc phê duyệt.	Đã gửi	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee
27d50454-ce37-48b9-94c0-e0e040ce1ff4	\N	Đơn giải trình đã được duyệt	Đơn giải trình của bạn cho thời gian 07:00 1/4/26 đã được phê duyệt.	system_info	2026-05-06 15:37:35.891791+07	Cá nhân	Yêu cầu của bạn đã được quản lý phê duyệt.	Đã gửi	\N	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
a0ae385e-7a5a-45e0-b52c-d03f9b6f275f	\N	Đơn giải trình đã được duyệt	Đơn giải trình của bạn cho thời gian 07:00 1/4/26 đã được phê duyệt.	system_info	2026-05-06 15:37:35.897817+07	Cá nhân	Yêu cầu của bạn đã được quản lý phê duyệt.	Đã gửi	\N	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
8fa8b520-0fb8-455a-adc2-686b1833bbec	\N	Đơn giải trình đã được duyệt	Đơn giải trình của bạn cho thời gian 07:00 1/4/26 đã được phê duyệt.	system_info	2026-05-06 15:37:38.728788+07	Cá nhân	Yêu cầu của bạn đã được quản lý phê duyệt.	Đã gửi	\N	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
7f266de3-f1ae-4bbc-ba4d-97d918e6e157	\N	Đơn giải trình đã được duyệt	Đơn giải trình của bạn cho thời gian 07:00 1/4/26 đã được phê duyệt.	system_info	2026-05-06 15:37:38.724891+07	Cá nhân	Yêu cầu của bạn đã được quản lý phê duyệt.	Đã gửi	\N	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
7175c413-6601-4ff3-b53d-7867187f55ee	\N	Đơn giải trình đã được duyệt	Đơn giải trình của bạn cho thời gian 07:00 1/4/26 đã được phê duyệt.	system_info	2026-05-06 15:37:38.72628+07	Cá nhân	Yêu cầu của bạn đã được quản lý phê duyệt.	Đã gửi	\N	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
7c1de199-abad-4994-9ca2-fd6dca91add8	\N	Đơn giải trình đã được duyệt	Đơn giải trình của bạn cho thời gian 07:00 1/4/26 đã được phê duyệt.	system_info	2026-05-06 15:37:38.746672+07	Cá nhân	Yêu cầu của bạn đã được quản lý phê duyệt.	Đã gửi	\N	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
99aca571-fe6d-45bd-8e8b-b899c7dd6730	e68efa7c-f2cd-4c12-8510-aab7a7350070	Đơn phép đã được duyệt	\n      <p style="margin:0 0 8px;"><strong style="color:#065f46;font-size:18px;">Đơn phép của bạn đã được chấp thuận.</strong></p>\n      <div style="margin:10px 0;padding:12px 14px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:12px;">\n        <p style="margin:0 0 8px;"><strong>Thời gian:</strong> 07:00 8/5/26 - 07:00 9/5/26</p>\n        <p style="margin:0;"><strong>Lý do trong đơn:</strong> adasa</p>\n      </div>\n    	system_info	2026-05-07 10:18:36.699438+07	Cá nhân	Yêu cầu của bạn đã được Giám đốc phê duyệt.	Đã gửi	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee
8b5ab722-51ed-49db-a874-e628145e55d8	\N	Đơn tăng ca bị từ chối	\n      <p style="margin:0 0 8px;"><strong style="color:#b91c1c;font-size:18px;">Đơn tăng ca của bạn đã bị quản lý từ chối.</strong></p>\n      <div style="margin:10px 0;padding:12px 14px;border:1px solid #fecaca;background:#fef2f2;border-radius:12px;">\n        <p style="margin:0 0 8px;"><strong>Thời gian:</strong> 07:00 19/5/26 17:21:00-20:21:00</p>\n        <p style="margin:0;color:#b91c1c;"><strong>Lý do từ chối:</strong> không hợp lý</p>\n      </div>\n    	system_warning	2026-05-18 16:22:20.210977+07	Cá nhân	Yêu cầu của bạn đã bị quản lý từ chối: không hợp lý	Đã gửi	\N	11111111-1111-1111-1111-111111111111
07f3e912-f17c-4ab7-994c-05d9f4aaccc1	\N	Đơn giải trình bị từ chối	\n      <p style="margin:0 0 8px;"><strong style="color:#b91c1c;font-size:18px;">Đơn giải trình của bạn đã bị quản lý từ chối.</strong></p>\n      <div style="margin:10px 0;padding:12px 14px;border:1px solid #fecaca;background:#fef2f2;border-radius:12px;">\n        <p style="margin:0 0 8px;"><strong>Thời gian:</strong> 07:00 17/5/26</p>\n        <p style="margin:0;color:#b91c1c;"><strong>Lý do từ chối:</strong> hôm qua không đi làm</p>\n      </div>\n    	system_warning	2026-05-18 16:56:11.945782+07	Cá nhân	Yêu cầu của bạn đã bị quản lý từ chối: hôm qua không đi làm	Đã gửi	\N	11111111-1111-1111-1111-111111111111
2dd68124-cc9c-4a46-94a1-878869780356	\N	Đơn giải trình đã được duyệt	\n      <p style="margin:0 0 8px;"><strong style="color:#065f46;font-size:18px;">Đơn giải trình của bạn đã được quản lý phê duyệt.</strong></p>\n      <div style="margin:10px 0;padding:12px 14px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:12px;">\n        <p style="margin:0;"><strong>Thời gian:</strong> 07:00 16/5/26</p>\n      </div>\n    	system_info	2026-05-18 17:23:11.968621+07	Cá nhân	Yêu cầu của bạn đã được quản lý phê duyệt.	Đã gửi	\N	11111111-1111-1111-1111-111111111111
0585ed75-987e-4a90-9302-4e265e943c82	e68efa7c-f2cd-4c12-8510-aab7a7350070	Đơn giải trình đã được duyệt	\n      <p style="margin:0 0 8px;"><strong style="color:#065f46;font-size:18px;">Đơn giải trình của bạn đã được chấp thuận.</strong></p>\n      <div style="margin:10px 0;padding:12px 14px;border:1px solid #a7f3d0;background:#ecfdf5;border-radius:12px;">\n        <p style="margin:0 0 8px;"><strong>Thời gian:</strong> 16/5/26 07:46 - 17:43</p>\n        <p style="margin:0;"><strong>Lý do trong đơn:</strong> quên chấm công ra</p>\n      </div>\n    	info	2026-05-18 17:44:17.94812+07	Cá nhân	Yêu cầu của bạn đã được Giám đốc phê duyệt.	Đã gửi	\N	c9cb540f-f9ab-42f2-925f-6eeca1396aee
30fb4b85-4f3c-4423-83b3-df6a8304ee89	\N	Nghỉ ốm bị từ chối	\n      <p style="margin:0 0 8px;"><strong style="color:#b91c1c;font-size:18px;">Nghỉ ốm của bạn đã bị quản lý từ chối.</strong></p>\n      <div style="margin:10px 0;padding:12px 14px;border:1px solid #fecaca;background:#fef2f2;border-radius:12px;">\n        <p style="margin:0 0 8px;"><strong>Thời gian:</strong> 07:00 9/5/26 - 07:00 9/5/26</p>\n        <p style="margin:0;color:#b91c1c;"><strong>Lý do từ chối:</strong> Không có lý do chi tiết</p>\n      </div>\n    	system_warning	2026-05-18 18:16:50.186447+07	Cá nhân	Yêu cầu của bạn đã bị quản lý từ chối.	Đã gửi	\N	11111111-1111-1111-1111-111111111111
\.


--
-- Data for Name: notification_recipient; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification_recipient (id, notification_id, employee_id, is_read, read_at) FROM stdin;
1	eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee	cccccccc-cccc-cccc-cccc-cccccccccccc	f	\N
2	5de62bc2-e6a3-482c-8849-aa67f7f4ecaf	22222222-2222-2222-2222-222222222222	t	2026-03-30 11:29:13.794426+07
7	5ca62fff-31ce-48f6-8755-63eca0640992	cccccccc-cccc-cccc-cccc-cccccccccccc	f	\N
9	5ca62fff-31ce-48f6-8755-63eca0640992	80966e2b-89e4-49b1-9948-57d226a9f363	f	\N
12	7f85d0f5-0f4a-41c3-88e2-112be65a3d5d	cccccccc-cccc-cccc-cccc-cccccccccccc	f	\N
14	7f85d0f5-0f4a-41c3-88e2-112be65a3d5d	80966e2b-89e4-49b1-9948-57d226a9f363	f	\N
10	5ca62fff-31ce-48f6-8755-63eca0640992	d582164b-8e56-478f-b485-6678ca75b43b	t	2026-03-30 15:31:44.117989+07
15	7f85d0f5-0f4a-41c3-88e2-112be65a3d5d	d582164b-8e56-478f-b485-6678ca75b43b	t	2026-03-30 15:32:15.763466+07
4	96e08a80-b7cf-4a92-b668-74389d8bb595	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	t	2026-04-02 08:08:58.909799+07
16	7f85d0f5-0f4a-41c3-88e2-112be65a3d5d	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	t	2026-04-02 08:32:29.157461+07
3	baaf0654-5f4b-4749-9150-40c98103ab9c	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	t	2026-04-02 16:22:49.038027+07
20	fe77c8d7-2d0e-4240-b6ff-e06f935e553a	11111111-1111-1111-1111-111111111111	t	2026-04-06 08:05:16.913841+07
22	c1f7bb0e-7948-4e7f-ad46-b6604fabce5c	11111111-1111-1111-1111-111111111111	t	2026-04-06 08:05:23.021074+07
6	96e08a80-b7cf-4a92-b668-74389d8bb595	22222222-2222-2222-2222-222222222222	t	2026-04-06 08:06:49.986244+07
8	5ca62fff-31ce-48f6-8755-63eca0640992	11111111-1111-1111-1111-111111111111	t	2026-04-06 08:24:11.917515+07
13	7f85d0f5-0f4a-41c3-88e2-112be65a3d5d	11111111-1111-1111-1111-111111111111	t	2026-04-06 08:24:11.917515+07
17	206fd4e9-07b9-489e-8cfd-59e0e0611f84	11111111-1111-1111-1111-111111111111	t	2026-04-06 08:24:11.917515+07
18	7b00278d-cacd-4264-a888-098f4ae201db	11111111-1111-1111-1111-111111111111	t	2026-04-06 08:24:11.917515+07
19	f07516a7-268d-402d-ab5b-98f83abd4b96	11111111-1111-1111-1111-111111111111	t	2026-04-06 08:24:11.917515+07
21	6225b184-1e42-4e79-93e3-e06bfa70d6fa	11111111-1111-1111-1111-111111111111	t	2026-04-06 08:24:11.917515+07
26	f208661c-8737-4089-b40c-8d3c09e31820	cccccccc-cccc-cccc-cccc-cccccccccccc	f	\N
28	f208661c-8737-4089-b40c-8d3c09e31820	80966e2b-89e4-49b1-9948-57d226a9f363	f	\N
29	f208661c-8737-4089-b40c-8d3c09e31820	d582164b-8e56-478f-b485-6678ca75b43b	f	\N
30	f208661c-8737-4089-b40c-8d3c09e31820	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	t	2026-04-06 15:55:30.815058+07
25	0e4aad83-d5b0-421c-87d8-b49a0d2a5f5d	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	t	2026-04-06 15:55:33.914616+07
31	cb5579cf-953e-4ccd-b50a-fc7c3fe4cffc	11111111-1111-1111-1111-111111111111	t	2026-04-06 16:28:47.175126+07
32	4fe32482-421b-4160-b624-34a580a28048	11111111-1111-1111-1111-111111111111	t	2026-04-06 16:32:25.213344+07
27	f208661c-8737-4089-b40c-8d3c09e31820	11111111-1111-1111-1111-111111111111	t	2026-04-07 10:06:07.546204+07
11	5ca62fff-31ce-48f6-8755-63eca0640992	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	t	2026-04-07 14:02:32.105971+07
34	1baa97a7-19ab-4c0e-acec-d7dcaa72ed47	cccccccc-cccc-cccc-cccc-cccccccccccc	f	\N
39	1baa97a7-19ab-4c0e-acec-d7dcaa72ed47	80966e2b-89e4-49b1-9948-57d226a9f363	f	\N
40	1baa97a7-19ab-4c0e-acec-d7dcaa72ed47	d582164b-8e56-478f-b485-6678ca75b43b	f	\N
41	1baa97a7-19ab-4c0e-acec-d7dcaa72ed47	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	f	\N
42	1baa97a7-19ab-4c0e-acec-d7dcaa72ed47	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	f	\N
43	1baa97a7-19ab-4c0e-acec-d7dcaa72ed47	dddddddd-dddd-dddd-dddd-dddddddddddd	f	\N
45	1198d82d-f0a5-49ee-84df-5b135d60b6e3	cccccccc-cccc-cccc-cccc-cccccccccccc	f	\N
50	1198d82d-f0a5-49ee-84df-5b135d60b6e3	80966e2b-89e4-49b1-9948-57d226a9f363	f	\N
51	1198d82d-f0a5-49ee-84df-5b135d60b6e3	d582164b-8e56-478f-b485-6678ca75b43b	f	\N
52	1198d82d-f0a5-49ee-84df-5b135d60b6e3	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	f	\N
53	1198d82d-f0a5-49ee-84df-5b135d60b6e3	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	f	\N
54	1198d82d-f0a5-49ee-84df-5b135d60b6e3	dddddddd-dddd-dddd-dddd-dddddddddddd	f	\N
56	13f9287e-c297-4c8f-a139-375e64823b0f	cccccccc-cccc-cccc-cccc-cccccccccccc	f	\N
61	13f9287e-c297-4c8f-a139-375e64823b0f	80966e2b-89e4-49b1-9948-57d226a9f363	f	\N
62	13f9287e-c297-4c8f-a139-375e64823b0f	d582164b-8e56-478f-b485-6678ca75b43b	f	\N
63	13f9287e-c297-4c8f-a139-375e64823b0f	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	f	\N
64	13f9287e-c297-4c8f-a139-375e64823b0f	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	f	\N
65	13f9287e-c297-4c8f-a139-375e64823b0f	dddddddd-dddd-dddd-dddd-dddddddddddd	f	\N
55	13f9287e-c297-4c8f-a139-375e64823b0f	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	t	2026-04-17 10:47:46.852875+07
44	1198d82d-f0a5-49ee-84df-5b135d60b6e3	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	t	2026-04-17 10:47:49.000003+07
33	1baa97a7-19ab-4c0e-acec-d7dcaa72ed47	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	t	2026-04-17 10:47:50.886853+07
66	fed5b5f2-d628-4a3a-a9b6-52c216c72ffc	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	t	2026-04-17 14:58:44.873935+07
35	1baa97a7-19ab-4c0e-acec-d7dcaa72ed47	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	t	2026-04-20 09:09:41.341841+07
46	1198d82d-f0a5-49ee-84df-5b135d60b6e3	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	t	2026-04-20 09:09:41.341841+07
57	13f9287e-c297-4c8f-a139-375e64823b0f	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	t	2026-04-20 09:09:41.341841+07
68	7919236c-7ef4-4cd8-a169-98f0d86d0b06	cccccccc-cccc-cccc-cccc-cccccccccccc	f	\N
69	7919236c-7ef4-4cd8-a169-98f0d86d0b06	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	f	\N
73	7919236c-7ef4-4cd8-a169-98f0d86d0b06	80966e2b-89e4-49b1-9948-57d226a9f363	f	\N
74	7919236c-7ef4-4cd8-a169-98f0d86d0b06	d582164b-8e56-478f-b485-6678ca75b43b	f	\N
75	7919236c-7ef4-4cd8-a169-98f0d86d0b06	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	f	\N
76	7919236c-7ef4-4cd8-a169-98f0d86d0b06	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	f	\N
77	7919236c-7ef4-4cd8-a169-98f0d86d0b06	dddddddd-dddd-dddd-dddd-dddddddddddd	f	\N
79	6b94beca-026b-4a23-b318-92774d87a989	cccccccc-cccc-cccc-cccc-cccccccccccc	f	\N
80	6b94beca-026b-4a23-b318-92774d87a989	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	f	\N
84	6b94beca-026b-4a23-b318-92774d87a989	80966e2b-89e4-49b1-9948-57d226a9f363	f	\N
85	6b94beca-026b-4a23-b318-92774d87a989	d582164b-8e56-478f-b485-6678ca75b43b	f	\N
86	6b94beca-026b-4a23-b318-92774d87a989	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	f	\N
87	6b94beca-026b-4a23-b318-92774d87a989	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	f	\N
88	6b94beca-026b-4a23-b318-92774d87a989	dddddddd-dddd-dddd-dddd-dddddddddddd	f	\N
95	5e249ffc-2b17-47e2-aefc-847bc2a7c96f	cccccccc-cccc-cccc-cccc-cccccccccccc	f	\N
96	46f2facd-b119-433c-b7e8-e574008fc5a7	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	f	\N
97	f9b9a11a-12d6-4006-9fee-1e74042e7902	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	f	\N
83	6b94beca-026b-4a23-b318-92774d87a989	22222222-2222-2222-2222-222222222222	t	2026-04-21 13:22:51.508061+07
72	7919236c-7ef4-4cd8-a169-98f0d86d0b06	22222222-2222-2222-2222-222222222222	t	2026-04-21 13:22:54.353771+07
60	13f9287e-c297-4c8f-a139-375e64823b0f	22222222-2222-2222-2222-222222222222	t	2026-04-21 13:22:57.255547+07
49	1198d82d-f0a5-49ee-84df-5b135d60b6e3	22222222-2222-2222-2222-222222222222	t	2026-04-21 13:22:59.5575+07
38	1baa97a7-19ab-4c0e-acec-d7dcaa72ed47	22222222-2222-2222-2222-222222222222	t	2026-04-21 13:23:01.958503+07
78	6b94beca-026b-4a23-b318-92774d87a989	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	t	2026-04-24 08:06:27.079323+07
67	7919236c-7ef4-4cd8-a169-98f0d86d0b06	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	t	2026-04-24 08:06:29.525912+07
98	e878d5e7-8424-4cd0-adcf-f7512873504d	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	f	\N
37	1baa97a7-19ab-4c0e-acec-d7dcaa72ed47	11111111-1111-1111-1111-111111111111	t	2026-05-05 10:31:14.220142+07
48	1198d82d-f0a5-49ee-84df-5b135d60b6e3	11111111-1111-1111-1111-111111111111	t	2026-05-05 10:31:14.220142+07
59	13f9287e-c297-4c8f-a139-375e64823b0f	11111111-1111-1111-1111-111111111111	t	2026-05-05 10:31:14.220142+07
71	7919236c-7ef4-4cd8-a169-98f0d86d0b06	11111111-1111-1111-1111-111111111111	t	2026-05-05 10:31:14.220142+07
82	6b94beca-026b-4a23-b318-92774d87a989	11111111-1111-1111-1111-111111111111	t	2026-05-05 10:31:14.220142+07
89	17039cfe-d6d6-408c-b0ce-b9afe4e4b3a4	11111111-1111-1111-1111-111111111111	t	2026-05-05 10:31:14.220142+07
90	e39390ba-08b7-40c7-9d8d-97f9d268e2aa	11111111-1111-1111-1111-111111111111	t	2026-05-05 10:31:14.220142+07
91	05fab4cd-6d63-4a1b-b6fa-21f832009729	11111111-1111-1111-1111-111111111111	t	2026-05-05 10:31:14.220142+07
100	17878bac-2270-4c16-8c4c-618f2e9fae57	c9cb540f-f9ab-42f2-925f-6eeca1396aee	t	2026-05-05 14:36:52.379507+07
99	f2e67cb8-4217-4235-8e8c-9bb82150a566	c9cb540f-f9ab-42f2-925f-6eeca1396aee	t	2026-05-05 15:07:52.539449+07
92	daa716d9-6b18-4877-b97b-3464732bfdf6	11111111-1111-1111-1111-111111111111	t	2026-05-05 10:31:14.220142+07
93	515863ad-2db9-4a6c-8062-2d9b6a43321c	11111111-1111-1111-1111-111111111111	t	2026-05-05 10:31:14.220142+07
94	71349826-eec9-4f21-ae92-3cd4d8c14af7	11111111-1111-1111-1111-111111111111	t	2026-05-05 10:31:14.220142+07
106	8d715161-a24a-4d39-80ee-da28612300b0	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	f	\N
103	5420a8c4-a49e-4054-9595-4d5633c3c3e2	11111111-1111-1111-1111-111111111111	t	2026-05-05 11:33:14.102546+07
101	007a6c69-ac5f-40f6-9f7d-551b66365992	11111111-1111-1111-1111-111111111111	t	2026-05-05 11:33:30.191996+07
107	0c088a73-cc07-46af-9414-34d513c5f903	11111111-1111-1111-1111-111111111111	t	2026-05-05 11:39:50.364357+07
108	979ed852-c97f-40e5-879e-0c2ef4cf1bbb	c9cb540f-f9ab-42f2-925f-6eeca1396aee	t	2026-05-05 15:09:49.347678+07
109	e9997743-f104-4209-8362-01f7f186dc22	c9cb540f-f9ab-42f2-925f-6eeca1396aee	t	2026-05-05 15:19:12.336659+07
111	80f8a6fe-23f9-4f02-87aa-9cf62584fdf2	cccccccc-cccc-cccc-cccc-cccccccccccc	f	\N
112	b5668a21-7c00-4a4c-a2da-7c9f25518ec6	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	f	\N
114	004cdaef-aa37-4e71-9251-bef125f84ca6	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	f	\N
115	a9b980d4-5227-4cd4-8e13-0dffd197ef4c	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	f	\N
116	84676b8b-9ddc-4ffc-9398-a6e932af66eb	043bffa9-79f6-49fc-b77e-bfeeabff040e	f	\N
117	0f596663-f1e6-4417-b9c4-6c67f5a61160	80966e2b-89e4-49b1-9948-57d226a9f363	f	\N
119	b76dcbd6-f7e0-4d11-833b-914cc60346e8	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	f	\N
120	492dc9b0-c981-46b2-9b87-8c21cd7037fa	d2fb703d-ac4c-4c38-b814-875fedacfedd	f	\N
118	f33a96d8-c8c9-4248-9ee8-d11ab62bfbd0	11111111-1111-1111-1111-111111111111	t	2026-05-06 14:54:12.257455+07
122	55dfa8da-2983-4fe5-ae90-6320f1373a07	c9cb540f-f9ab-42f2-925f-6eeca1396aee	t	2026-05-06 15:35:26.28862+07
124	27d50454-ce37-48b9-94c0-e0e040ce1ff4	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	f	\N
125	a0ae385e-7a5a-45e0-b52c-d03f9b6f275f	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	f	\N
126	8fa8b520-0fb8-455a-adc2-686b1833bbec	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	f	\N
127	7f266de3-f1ae-4bbc-ba4d-97d918e6e157	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	f	\N
128	7175c413-6601-4ff3-b53d-7867187f55ee	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	f	\N
129	7c1de199-abad-4994-9ca2-fd6dca91add8	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	f	\N
113	6985de0f-ed73-4d4c-9a31-dbf3b68875f6	d582164b-8e56-478f-b485-6678ca75b43b	t	2026-05-06 16:00:09.307464+07
123	461e9468-f785-4817-9240-9ae6ef41d31d	11111111-1111-1111-1111-111111111111	t	2026-05-08 09:54:27.942211+07
130	99aca571-fe6d-45bd-8e8b-b899c7dd6730	c9cb540f-f9ab-42f2-925f-6eeca1396aee	t	2026-05-18 16:12:46.759389+07
121	5b6634a8-887f-42ca-a45e-ec0313a639db	c9cb540f-f9ab-42f2-925f-6eeca1396aee	t	2026-05-18 16:12:50.734345+07
110	17006267-140b-4b4b-8cbe-c245b40d3e1c	c9cb540f-f9ab-42f2-925f-6eeca1396aee	t	2026-05-18 16:12:54.238092+07
134	0585ed75-987e-4a90-9302-4e265e943c82	c9cb540f-f9ab-42f2-925f-6eeca1396aee	f	\N
141	30fb4b85-4f3c-4423-83b3-df6a8304ee89	11111111-1111-1111-1111-111111111111	t	2026-05-18 18:17:10.986458+07
131	8b5ab722-51ed-49db-a874-e628145e55d8	11111111-1111-1111-1111-111111111111	t	2026-05-20 22:13:57.446504+07
132	07f3e912-f17c-4ab7-994c-05d9f4aaccc1	11111111-1111-1111-1111-111111111111	t	2026-05-20 22:13:57.446504+07
133	2dd68124-cc9c-4a46-94a1-878869780356	11111111-1111-1111-1111-111111111111	t	2026-05-20 22:13:57.446504+07
\.


--
-- Data for Name: overtime_request; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.overtime_request (id, employee_id, payroll_id, ot_date, start_time, end_time, reason, approver_id, status, created_at, updated_at, reject_reason) FROM stdin;
30567dbf-3abc-4d64-9412-93fbc89f1608	c9cb540f-f9ab-42f2-925f-6eeca1396aee	\N	2026-05-06	17:00:00	19:00:00	tăng ca xử lý việc	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	rejected	2026-05-05 15:18:51.119162+07	\N	không được
7eea0e53-b0b5-4f82-b325-f63e1526586d	11111111-1111-1111-1111-111111111111	\N	2026-05-19	17:21:00	20:21:00	sửa lỗi	c9cb540f-f9ab-42f2-925f-6eeca1396aee	rejected	2026-05-18 16:21:56.225844+07	2026-05-18 16:22:20.210977+07	không hợp lý
\.


--
-- Data for Name: payroll; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payroll (id, employee_id, month_year, base_salary_snapshot, total_work_days, total_allowance, total_deduction, net_salary, status, created_at) FROM stdin;
2053b713-f153-4bad-ac90-39cb4512e660	be7a0a5c-8f11-4e3c-86c4-3271863339e7	03-2026	0.00	0.00	0.00	0.00	0.00	draft	2026-04-21 11:04:29.348074+07
cf98b759-1a9c-4c4c-971a-34ad0408598a	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	04-2026	50000000.00	8.00	1000000.00	5250000.00	11134615.38	approved	2026-04-14 08:45:23.572545+07
b79ccb14-2184-4396-8dbb-10d0c7dfc7d9	d2fb703d-ac4c-4c38-b814-875fedacfedd	03-2026	0.00	0.00	0.00	0.00	0.00	draft	2026-04-21 16:19:24.900012+07
67fa6888-0474-48a2-85ba-7c3dbf56f734	22222222-2222-2222-2222-222222222222	03-2026	0.00	0.00	0.00	0.00	0.00	draft	2026-04-17 08:31:39.345075+07
a1ce4588-137b-4575-8eba-c5c4a8f2fa6c	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	05-2026	50000000.00	25.00	0.00	5250000.00	42826923.08	draft	2026-05-05 09:12:37.130972+07
4a7375aa-41d8-425b-ad4f-e344e3505043	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	03-2026	0.00	0.00	0.00	0.00	0.00	draft	2026-04-21 16:19:24.900012+07
f9825713-4ff9-4dbe-baa1-cfe2502b16b4	e68efa7c-f2cd-4c12-8510-aab7a7350070	04-2026	50000000.00	2.96	0.00	5250000.00	442307.69	draft	2026-04-21 11:04:29.347349+07
01497e33-2672-48b7-a579-36d17cac7553	e68efa7c-f2cd-4c12-8510-aab7a7350070	05-2026	50000000.00	25.00	0.00	5250000.00	42826923.08	draft	2026-05-05 09:12:37.130972+07
50c77488-c521-4746-a0ce-56c1fedfc020	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	04-2026	12000000.00	0.00	0.00	1260000.00	-1260000.00	draft	2026-04-16 07:55:22.571123+07
70466f04-1642-47d3-b69b-d9b50e9bf8eb	11111111-1111-1111-1111-111111111111	03-2026	45000000.00	0.00	2000000.00	4725000.00	-2725000.00	draft	2026-04-17 08:31:39.345075+07
6b2ee5f6-ba8c-4ecf-bf50-37c71d01c9f2	cccccccc-cccc-cccc-cccc-cccccccccccc	03-2026	0.00	1.00	0.00	0.00	0.00	approved	2026-03-19 08:39:12.006185+07
47853e5b-79ef-4841-8552-acf9c92fb5b6	dddddddd-dddd-dddd-dddd-dddddddddddd	03-2026	25000000.00	0.00	0.00	2625000.00	-2625000.00	draft	2026-04-17 08:31:39.345075+07
dc8d2064-c6f3-4ca1-9c5a-a8354fdc7599	d582164b-8e56-478f-b485-6678ca75b43b	04-2026	12000000.00	6.26	0.00	1260000.00	1629230.77	draft	2026-04-16 07:55:22.571123+07
cfe9e954-7f46-417a-b76e-6876a0419801	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	04-2026	20000000.00	6.26	0.00	2100000.00	2715384.62	draft	2026-04-14 08:45:23.572545+07
ea3ad6be-a9f7-46d8-919f-dcd37860daa7	be7a0a5c-8f11-4e3c-86c4-3271863339e7	04-2026	50000000.00	0.00	0.00	5250000.00	-5250000.00	draft	2026-04-21 11:04:29.347349+07
d8e6016a-e697-411a-b65c-c222a0b03f1f	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	04-2026	12000000.00	6.26	0.00	1260000.00	1629230.77	draft	2026-04-14 08:45:23.572545+07
ff37b520-40ab-4af3-884d-4ec829e30d6d	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	03-2026	0.00	0.00	0.00	0.00	0.00	draft	2026-04-17 08:31:39.345075+07
f6c5fd8e-17c5-4569-b2c3-fc5e61303fb6	be7a0a5c-8f11-4e3c-86c4-3271863339e7	05-2026	50000000.00	25.00	0.00	5250000.00	42826923.08	draft	2026-05-05 09:12:37.130972+07
81b84d9e-1077-44ee-abcc-fc1ca0922724	d582164b-8e56-478f-b485-6678ca75b43b	03-2026	0.00	0.00	0.00	200000.00	-200000.00	draft	2026-04-17 08:31:39.345075+07
d13cdf56-4f66-447b-a7ef-12e83fe7358e	043bffa9-79f6-49fc-b77e-bfeeabff040e	04-2026	4000000.00	0.00	0.00	420000.00	-420000.00	draft	2026-04-21 16:19:24.896268+07
a980879c-e7fe-40e1-ba87-b1972de1b71f	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	03-2026	20000000.00	0.00	0.00	2100000.00	-2100000.00	draft	2026-04-17 08:31:39.345075+07
03f99fdc-7c45-41f9-a446-baf0715836ad	80966e2b-89e4-49b1-9948-57d226a9f363	04-2026	12000000.00	2.96	0.00	1260000.00	106153.85	draft	2026-04-16 07:55:22.571123+07
c44c24d1-95e7-4e46-8658-7a1bb99f9090	c9cb540f-f9ab-42f2-925f-6eeca1396aee	03-2026	20000000.00	0.00	0.00	2100000.00	-2100000.00	draft	2026-04-21 11:16:41.607252+07
52e96f4c-a463-44ac-b00f-998c78646907	22222222-2222-2222-2222-222222222222	04-2026	0.00	2.96	0.00	0.00	0.00	approved	2026-04-14 08:45:23.572545+07
484b1bb0-4e14-4629-b8db-61f0342af926	22222222-2222-2222-2222-222222222222	05-2026	0.00	25.00	0.00	0.00	0.00	draft	2026-05-05 09:12:37.130972+07
5d894c84-a2a7-4752-b2d7-6c9e399f9d0c	dddddddd-dddd-dddd-dddd-dddddddddddd	04-2026	25000000.00	0.00	0.00	2625000.00	-2625000.00	approved	2026-04-14 08:45:23.572545+07
d46b095f-6de3-4462-9c2d-8a4f496da696	dddddddd-dddd-dddd-dddd-dddddddddddd	05-2026	25000000.00	25.00	0.00	2625000.00	21413461.54	draft	2026-05-05 09:12:37.130972+07
ed358f16-31ee-4201-8b4c-404aa20ec832	d2fb703d-ac4c-4c38-b814-875fedacfedd	04-2026	4000000.00	0.00	0.00	420000.00	-420000.00	draft	2026-04-21 16:19:24.896268+07
72907a65-319a-4f80-b11d-d0b7aa02cffb	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	03-2026	12000000.00	0.00	0.00	1260000.00	-1260000.00	draft	2026-04-17 08:31:39.345075+07
10c1927e-ffcf-4530-ba48-0688ea2ce82e	80966e2b-89e4-49b1-9948-57d226a9f363	03-2026	12000000.00	0.00	5000000.00	1260000.00	3740000.00	draft	2026-04-17 08:31:39.345075+07
cf2d8506-ea42-444b-98c1-15693eb8d6bb	043bffa9-79f6-49fc-b77e-bfeeabff040e	03-2026	0.00	0.00	0.00	0.00	0.00	draft	2026-04-21 16:19:24.900012+07
f536e09d-9b9f-4a9e-b68d-6c55f8a674d6	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	03-2026	50000000.00	0.00	0.00	5250000.00	-5250000.00	draft	2026-04-17 08:31:39.345075+07
6897d122-286f-437f-b81d-ea7a46dae65f	e68efa7c-f2cd-4c12-8510-aab7a7350070	03-2026	0.00	0.00	0.00	0.00	0.00	draft	2026-04-21 11:04:29.348074+07
9a577090-e429-4e59-a942-11f9ac40c2c3	c9cb540f-f9ab-42f2-925f-6eeca1396aee	04-2026	20000000.00	0.00	0.00	2100000.00	-2100000.00	draft	2026-04-21 11:16:41.606473+07
1cb1bc2a-2f9b-4e1b-a388-2d7e0820e63a	cccccccc-cccc-cccc-cccc-cccccccccccc	04-2026	12000000.00	8.00	1000000.00	1260000.00	3432307.69	draft	2026-04-14 08:45:23.572545+07
12be361d-92b1-48be-8d11-8498305872ea	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	04-2026	8000000.00	0.00	0.00	840000.00	-840000.00	draft	2026-05-06 13:40:09.628387+07
ea845723-d2b2-4a59-ade9-af34bc27446c	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	05-2026	8000000.00	25.00	0.00	840000.00	6852307.69	draft	2026-05-06 10:45:33.970501+07
b08d94c9-3672-4f6f-8961-9dc15a7bbdc9	11111111-1111-1111-1111-111111111111	04-2026	45000000.00	8.00	1000000.00	4725000.00	10121153.85	approved	2026-04-16 07:55:22.571123+07
92e2e024-7641-46b5-8d5d-e7c16ef4df60	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	04-2026	28000000.00	0.00	0.00	2940000.00	-2940000.00	draft	2026-04-21 16:19:24.896268+07
\.


--
-- Data for Name: position; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."position" (id, position_code, position_name, department_id, level, base_salary_min, created_at) FROM stdin;
1	CEO	Giám đốc Điều hành	1	director	50000000.00	2026-03-19 08:39:12.006185+07
3	IT_DEV	Lập trình viên Backend	3	junior	12000000.00	2026-03-19 08:39:12.006185+07
11	IT_Leader	Trưởng Phòng CNTT	3	manager	20000000.00	2026-04-21 09:58:07.449255+07
12	CFO	Giám đốc Tài chính	1	director	45000000.00	2026-04-21 10:11:49.992796+07
13	COO	Giám đốc Vận hành	1	director	40000000.00	2026-04-21 10:11:49.992796+07
17	IT_FE	Lập trình viên Frontend	3	junior	12000000.00	2026-04-21 10:11:49.992796+07
18	IT_SENIOR	Lập trình viên Fullstack	3	senior	28000000.00	2026-04-21 10:11:49.992796+07
19	IT_QA	Chuyên viên Kiểm thử (QA/QC)	3	middle	15000000.00	2026-04-21 10:11:49.992796+07
20	IT_INTERN	Thực tập sinh IT	3	intern	4000000.00	2026-04-21 10:11:49.992796+07
21	STOCK_MGR	Trưởng phòng Chứng khoán	5	manager	35000000.00	2026-04-21 10:11:49.992796+07
22	STOCK_SENIOR	Chuyên viên Phân tích Cao cấp	5	senior	25000000.00	2026-04-21 10:11:49.992796+07
23	STOCK_BROKER	Môi giới Chứng khoán	5	middle	15000000.00	2026-04-21 10:11:49.992796+07
24	STOCK_FRESHER	Nhân viên Chứng khoán mới	5	fresher	8000000.00	2026-04-21 10:11:49.992796+07
\.


--
-- Data for Name: system_config; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.system_config (config_key, config_value, description, updated_at) FROM stdin;
DEFAULT_WORK_HOURS	8	Số giờ làm việc tiêu chuẩn trong ngày (tiếng)	2026-03-19 08:39:12.006185+07
DEFAULT_LATE_TOLERANCE	15	Số phút đi muộn tối đa cho phép	2026-03-19 08:39:12.006185+07
WIFI_CHECK_ENABLED	true	Bật/Tắt tính năng check IP Wifi khi chấm công	2026-03-19 08:39:12.006185+07
DEFAULT_CHECKIN_TIME	07:30	Giờ bắt đầu ca làm việc mặc định	2026-05-06 10:54:04.341614+07
DEFAULT_CHECKOUT_TIME	17:00	Giờ kết thúc ca làm việc mặc định	2026-05-06 10:54:04.341614+07
LUNCH_BREAK_START	11:30	Giờ bắt đầu nghỉ trưa	2026-05-06 10:54:04.341614+07
LUNCH_BREAK_END	13:00	Giờ kết thúc nghỉ trưa	2026-05-06 10:54:04.341614+07
\.


--
-- Data for Name: user_account; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_account (id, employee_id, username, password_hash, role_code, status, last_login, created_at, require_pass_change, expo_push_token) FROM stdin;
97de6952-ef1e-49a5-a81c-c1a3fe166290	8de11a73-8f6a-4b7f-bc42-1e7e32d73a7e	ngochoi1357	$2a$06$byibCtNnzN19yeFRH4PssuUL3t1R4Spca1PGI42zQES6lsiLRIRH6	EMPLOYEE	active	\N	2026-05-06 10:23:50.21425+07	f	\N
a4dada9a-d1d6-466a-b1e2-842d5a210cb4	bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb	manager@gmail.com	$2a$06$k1YDUZUC5UQEhIEYswWNTOLF3kDt/c9a4TnSfD/aFNr3ONdtO0iG2	MANAGER	active	\N	2026-03-19 08:39:12.006185+07	f	\N
b6b614e5-ac64-45af-b3c3-9f9dd1c1de56	aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa	director@gmail.com	$2a$06$dS1yCOxXwi.ILBDRCDucOeixjDWc1QoaRNo9UmUDjhmBAcDWjB9b2	DIRECTOR	active	\N	2026-03-19 08:39:12.006185+07	f	\N
5b4f1bd5-e5c5-4516-bbec-1f246b3e219a	be7a0a5c-8f11-4e3c-86c4-3271863339e7	QuanLy1	$2a$06$cyJAsEUgmmSPryCF9PT3Q.rLtiBSarZlAxnMzSyGngu5cszK8ENa.	MANAGER	active	\N	2026-04-21 09:49:51.548508+07	f	\N
853c0252-050a-44d3-b2e1-0250f3a546ae	22222222-2222-2222-2222-222222222222	ngochoivts6a@gmail.com	$2a$06$9COdOvB2h32fwaiLrR.OBO.xtEtRlqko1jGmP95k9WkDseOL7uKbi	ADMIN	active	\N	2026-03-19 15:51:26.380878+07	f	\N
2f7358df-672a-42e6-b72d-1c2d31433b06	c9cb540f-f9ab-42f2-925f-6eeca1396aee	test123	$2a$06$CGIqiL7RMYfSQM51Usw0EebrvJvPP4kEVyNhiTjwZU9SQ3OsgpeY2	MANAGER	active	\N	2026-04-21 11:15:54.134466+07	f	\N
ed8572b5-7373-47db-b716-0c2bb12638e8	043bffa9-79f6-49fc-b77e-bfeeabff040e	Test2	$2b$10$zqdS8WXDXSITL/3nZ97/IOqfZLXi1F6IPgneDvqxpO2MLvGtNiaDK	EMPLOYEE	active	\N	2026-04-21 15:26:58.57627+07	f	\N
17541ccc-8a55-41ec-93d2-dcdf2e7afa4d	d2fb703d-ac4c-4c38-b814-875fedacfedd	Test234	$2b$10$0KBrpJ1zDa5v3ckYMAtwK.p26JBQBBR60bLiPD3PeoFTyCM5mFV4S	EMPLOYEE	active	\N	2026-04-21 15:28:09.141015+07	f	\N
fcfbe266-b193-4fc9-a940-48094730361c	aa77dd9a-ce37-41f8-80f3-80d14c825ec5	Test132456	$2a$06$CpmVytye9s19CZwcWKk6YuEeCQrMxfsl4sSVhletAZvTJqsN0uWCC	EMPLOYEE	active	\N	2026-04-21 15:57:45.552887+07	f	\N
e5ccb6ac-6a61-40ba-9203-e015c9911a1b	80966e2b-89e4-49b1-9948-57d226a9f363	chaungochoi@dtu.edu.vn	$2b$10$d6wwS6730p3bTkMiIs9qweyKbzHxJILmeEm/vOSlpAvZ.RSEmDoO6	EMPLOYEE	active	\N	2026-03-30 12:43:56.990304+07	t	\N
e6579cc2-b821-42bc-818c-f6b80663eecb	d582164b-8e56-478f-b485-6678ca75b43b	zenblack991@gmail.com	$2a$06$b.mxo/s1GVJWTlXD12UliuBoZv.DC33YS4xGW8cT9G1O.WZuVC7K.	EMPLOYEE	active	\N	2026-03-30 15:20:37.396729+07	f	\N
b548f7bd-64af-4349-ad31-170636e85446	8f631fe8-88aa-49aa-b5da-e855e1be4d2b	thanhlantt@gmail.com	$2a$06$8unxQp6YbOaHUuKhCcsmT.160N4fe.ozfiwcxgjwb0tsoDpF47Iui	EMPLOYEE	active	\N	2026-04-06 15:49:59.906586+07	t	\N
826390f2-9eb6-4160-bea3-f68cd8dda120	9c80270b-9f4b-4878-85d2-37bc36ae4ceb	ndkkhoa10c10@gmail.com	$2a$06$3BBE/n20W9uQ4wKN/PdBLue3a66jEFSYxkXmlc21ZNQDLFlJfxuEK	EMPLOYEE	active	\N	2026-03-20 16:50:01.464245+07	f	ExponentPushToken[4xg3M1Jue4GH5itgsoYh7J]
132b1962-9108-4ae6-910a-3ab6d951c14f	11111111-1111-1111-1111-111111111111	ngochoinct@gmail.com	$2a$06$W47cLHufIeF4UbHKwbVOgeW3KDNDeN6yc7mibjbylEroil9bbf2RK	EMPLOYEE	active	\N	2026-03-19 13:17:41.860411+07	f	ExponentPushToken[4xg3M1Jue4GH5itgsoYh7J]
83b0986f-7d8a-4bc5-98e5-d9bf1d1e84a5	cccccccc-cccc-cccc-cccc-cccccccccccc	employee	$2a$06$l0UWNr9Jv/cW/lLp4O9/a.qI/K7aRNbycsU0dJzuMdzjKpiYTulry	EMPLOYEE	active	\N	2026-03-19 08:39:12.006185+07	f	\N
\.


--
-- Data for Name: work_location; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work_location (id, location_name, location_type, latitude, longitude, radius_meters, created_at, is_active, branch_id) FROM stdin;
3	Kho vận Cảng Tiên Sa	client_site	16.120760	108.214470	300	2026-03-19 08:39:12.006185+07	t	\N
1	Trụ sở chính Hà Nội	branch	21.028511	105.804817	2	2026-03-19 08:39:12.006185+07	t	1
2	Chi nhánh Đà Nẵng	branch	16.067780	108.220830	50	2026-03-19 08:39:12.006185+07	t	2
12	Văn Phòng Khoan CNTT	branch	16.075324	108.222990	100	2026-04-06 15:58:56.511757+07	t	12
16	Trạm 247	branch	16.071683	108.173559	50	2026-04-07 13:35:04.857177+07	t	12
17	Khu vực mới	branch	16.044413	108.179338	50	2026-04-11 15:39:23.357647+07	t	12
14	Minh Trần Holding	branch	16.058924	108.174210	50	2026-04-07 09:27:43.357623+07	t	12
\.


--
-- Name: ai_alerts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ai_alerts_id_seq', 325, true);


--
-- Name: attendance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.attendance_id_seq', 864, true);


--
-- Name: branch_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.branch_id_seq', 15, true);


--
-- Name: department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.department_id_seq', 5, true);


--
-- Name: location_assignment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.location_assignment_id_seq', 7, true);


--
-- Name: notification_recipient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notification_recipient_id_seq', 141, true);


--
-- Name: position_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.position_id_seq', 24, true);


--
-- Name: work_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.work_location_id_seq', 18, true);


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

\unrestrict f7o0hGTTe7WzKOpahCUEoTsMFye7FJxEGFEgdg5XyZPa6XkgTjSKu0Qz6iSjspm

