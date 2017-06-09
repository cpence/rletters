SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admin_administrators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE admin_administrators (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: admin_administrators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_administrators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_administrators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_administrators_id_seq OWNED BY admin_administrators.id;


--
-- Name: admin_benchmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE admin_benchmarks (
    id integer NOT NULL,
    job character varying,
    size integer,
    "time" double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admin_benchmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_benchmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_benchmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_benchmarks_id_seq OWNED BY admin_benchmarks.id;


--
-- Name: admin_feature_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE admin_feature_flags (
    id integer NOT NULL,
    var character varying NOT NULL,
    value text,
    thing_id integer,
    thing_type character varying(30),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admin_feature_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_feature_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_feature_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_feature_flags_id_seq OWNED BY admin_feature_flags.id;


--
-- Name: admin_markdown_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE admin_markdown_pages (
    id integer NOT NULL,
    name character varying(255),
    content text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: admin_markdown_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_markdown_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_markdown_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_markdown_pages_id_seq OWNED BY admin_markdown_pages.id;


--
-- Name: admin_uploaded_asset_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE admin_uploaded_asset_files (
    id integer NOT NULL,
    admin_uploaded_asset_id integer,
    style character varying(255),
    file_contents bytea
);


--
-- Name: admin_uploaded_asset_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_uploaded_asset_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_uploaded_asset_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_uploaded_asset_files_id_seq OWNED BY admin_uploaded_asset_files.id;


--
-- Name: admin_uploaded_assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE admin_uploaded_assets (
    id integer NOT NULL,
    name character varying(255),
    file_file_name character varying(255),
    file_content_type character varying(255),
    file_file_size integer,
    file_updated_at timestamp without time zone,
    file_fingerprint character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: admin_uploaded_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_uploaded_assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_uploaded_assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_uploaded_assets_id_seq OWNED BY admin_uploaded_assets.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: datasets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE datasets (
    id integer NOT NULL,
    name character varying(255),
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    "fetch" boolean DEFAULT false,
    document_count integer DEFAULT 0
);


--
-- Name: datasets_file_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE datasets_file_results (
    id integer NOT NULL,
    datasets_file_id integer,
    style character varying,
    file_contents bytea
);


--
-- Name: datasets_file_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE datasets_file_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datasets_file_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE datasets_file_results_id_seq OWNED BY datasets_file_results.id;


--
-- Name: datasets_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE datasets_files (
    id integer NOT NULL,
    description character varying,
    short_description character varying,
    task_id integer,
    result_file_name character varying,
    result_content_type character varying,
    result_file_size integer,
    result_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    downloadable boolean DEFAULT false
);


--
-- Name: datasets_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE datasets_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datasets_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE datasets_files_id_seq OWNED BY datasets_files.id;


--
-- Name: datasets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE datasets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datasets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE datasets_id_seq OWNED BY datasets.id;


--
-- Name: datasets_queries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE datasets_queries (
    id integer NOT NULL,
    dataset_id integer,
    q character varying,
    fq character varying,
    def_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: datasets_queries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE datasets_queries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datasets_queries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE datasets_queries_id_seq OWNED BY datasets_queries.id;


--
-- Name: datasets_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE datasets_tasks (
    id integer NOT NULL,
    name character varying(255),
    finished_at timestamp without time zone,
    dataset_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    failed boolean DEFAULT false,
    job_type character varying(255),
    progress double precision,
    progress_message character varying,
    last_progress timestamp without time zone,
    job_id character varying
);


--
-- Name: datasets_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE datasets_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datasets_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE datasets_tasks_id_seq OWNED BY datasets_tasks.id;


--
-- Name: documents_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE documents_categories (
    id integer NOT NULL,
    parent_id integer,
    sort_order integer,
    name character varying(255),
    journals text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: documents_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE documents_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE documents_categories_id_seq OWNED BY documents_categories.id;


--
-- Name: documents_category_hierarchies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE documents_category_hierarchies (
    ancestor_id integer NOT NULL,
    descendant_id integer NOT NULL,
    generations integer NOT NULL
);


--
-- Name: documents_stop_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE documents_stop_lists (
    id integer NOT NULL,
    language character varying(255),
    list text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: documents_stop_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE documents_stop_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_stop_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE documents_stop_lists_id_seq OWNED BY documents_stop_lists.id;


--
-- Name: que_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE que_jobs (
    priority smallint DEFAULT 100 NOT NULL,
    run_at timestamp with time zone DEFAULT now() NOT NULL,
    job_id bigint NOT NULL,
    job_class text NOT NULL,
    args json DEFAULT '[]'::json NOT NULL,
    error_count integer DEFAULT 0 NOT NULL,
    last_error text,
    queue text DEFAULT ''::text NOT NULL
);


--
-- Name: TABLE que_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE que_jobs IS '3';


--
-- Name: que_jobs_job_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE que_jobs_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: que_jobs_job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE que_jobs_job_id_seq OWNED BY que_jobs.job_id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    language character varying(255) DEFAULT 'en'::character varying,
    timezone character varying(255) DEFAULT 'Eastern Time (US & Canada)'::character varying,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    csl_style_id integer,
    workflow_active boolean DEFAULT false,
    workflow_class character varying(255),
    workflow_datasets text[] DEFAULT '{}'::text[]
);


--
-- Name: users_csl_styles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users_csl_styles (
    id integer NOT NULL,
    name character varying(255),
    style text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: users_csl_styles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_csl_styles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_csl_styles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_csl_styles_id_seq OWNED BY users_csl_styles.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: users_libraries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users_libraries (
    id integer NOT NULL,
    name character varying(255),
    url character varying(255),
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: users_libraries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_libraries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_libraries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_libraries_id_seq OWNED BY users_libraries.id;


--
-- Name: admin_administrators id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_administrators ALTER COLUMN id SET DEFAULT nextval('admin_administrators_id_seq'::regclass);


--
-- Name: admin_benchmarks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_benchmarks ALTER COLUMN id SET DEFAULT nextval('admin_benchmarks_id_seq'::regclass);


--
-- Name: admin_feature_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_feature_flags ALTER COLUMN id SET DEFAULT nextval('admin_feature_flags_id_seq'::regclass);


--
-- Name: admin_markdown_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_markdown_pages ALTER COLUMN id SET DEFAULT nextval('admin_markdown_pages_id_seq'::regclass);


--
-- Name: admin_uploaded_asset_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_uploaded_asset_files ALTER COLUMN id SET DEFAULT nextval('admin_uploaded_asset_files_id_seq'::regclass);


--
-- Name: admin_uploaded_assets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_uploaded_assets ALTER COLUMN id SET DEFAULT nextval('admin_uploaded_assets_id_seq'::regclass);


--
-- Name: datasets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets ALTER COLUMN id SET DEFAULT nextval('datasets_id_seq'::regclass);


--
-- Name: datasets_file_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets_file_results ALTER COLUMN id SET DEFAULT nextval('datasets_file_results_id_seq'::regclass);


--
-- Name: datasets_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets_files ALTER COLUMN id SET DEFAULT nextval('datasets_files_id_seq'::regclass);


--
-- Name: datasets_queries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets_queries ALTER COLUMN id SET DEFAULT nextval('datasets_queries_id_seq'::regclass);


--
-- Name: datasets_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets_tasks ALTER COLUMN id SET DEFAULT nextval('datasets_tasks_id_seq'::regclass);


--
-- Name: documents_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents_categories ALTER COLUMN id SET DEFAULT nextval('documents_categories_id_seq'::regclass);


--
-- Name: documents_stop_lists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents_stop_lists ALTER COLUMN id SET DEFAULT nextval('documents_stop_lists_id_seq'::regclass);


--
-- Name: que_jobs job_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY que_jobs ALTER COLUMN job_id SET DEFAULT nextval('que_jobs_job_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: users_csl_styles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_csl_styles ALTER COLUMN id SET DEFAULT nextval('users_csl_styles_id_seq'::regclass);


--
-- Name: users_libraries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_libraries ALTER COLUMN id SET DEFAULT nextval('users_libraries_id_seq'::regclass);


--
-- Name: admin_administrators admin_administrators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_administrators
    ADD CONSTRAINT admin_administrators_pkey PRIMARY KEY (id);


--
-- Name: admin_benchmarks admin_benchmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_benchmarks
    ADD CONSTRAINT admin_benchmarks_pkey PRIMARY KEY (id);


--
-- Name: admin_feature_flags admin_feature_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_feature_flags
    ADD CONSTRAINT admin_feature_flags_pkey PRIMARY KEY (id);


--
-- Name: admin_markdown_pages admin_markdown_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_markdown_pages
    ADD CONSTRAINT admin_markdown_pages_pkey PRIMARY KEY (id);


--
-- Name: admin_uploaded_asset_files admin_uploaded_asset_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_uploaded_asset_files
    ADD CONSTRAINT admin_uploaded_asset_files_pkey PRIMARY KEY (id);


--
-- Name: admin_uploaded_assets admin_uploaded_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_uploaded_assets
    ADD CONSTRAINT admin_uploaded_assets_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: datasets_file_results datasets_file_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets_file_results
    ADD CONSTRAINT datasets_file_results_pkey PRIMARY KEY (id);


--
-- Name: datasets_files datasets_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets_files
    ADD CONSTRAINT datasets_files_pkey PRIMARY KEY (id);


--
-- Name: datasets datasets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets
    ADD CONSTRAINT datasets_pkey PRIMARY KEY (id);


--
-- Name: datasets_queries datasets_queries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets_queries
    ADD CONSTRAINT datasets_queries_pkey PRIMARY KEY (id);


--
-- Name: datasets_tasks datasets_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets_tasks
    ADD CONSTRAINT datasets_tasks_pkey PRIMARY KEY (id);


--
-- Name: documents_categories documents_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents_categories
    ADD CONSTRAINT documents_categories_pkey PRIMARY KEY (id);


--
-- Name: documents_stop_lists documents_stop_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents_stop_lists
    ADD CONSTRAINT documents_stop_lists_pkey PRIMARY KEY (id);


--
-- Name: que_jobs que_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY que_jobs
    ADD CONSTRAINT que_jobs_pkey PRIMARY KEY (queue, priority, run_at, job_id);


--
-- Name: users_csl_styles users_csl_styles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_csl_styles
    ADD CONSTRAINT users_csl_styles_pkey PRIMARY KEY (id);


--
-- Name: users_libraries users_libraries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_libraries
    ADD CONSTRAINT users_libraries_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: documents_category_anc_desc_udx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX documents_category_anc_desc_udx ON documents_category_hierarchies USING btree (ancestor_id, descendant_id, generations);


--
-- Name: documents_category_desc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX documents_category_desc_idx ON documents_category_hierarchies USING btree (descendant_id);


--
-- Name: index_admin_administrators_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_administrators_on_email ON admin_administrators USING btree (email);


--
-- Name: index_admin_administrators_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_administrators_on_reset_password_token ON admin_administrators USING btree (reset_password_token);


--
-- Name: index_admin_feature_flags_on_thing_type_and_thing_id_and_var; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_feature_flags_on_thing_type_and_thing_id_and_var ON admin_feature_flags USING btree (thing_type, thing_id, var);


--
-- Name: index_datasets_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datasets_on_user_id ON datasets USING btree (user_id);


--
-- Name: index_datasets_tasks_on_dataset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_datasets_tasks_on_dataset_id ON datasets_tasks USING btree (dataset_id);


--
-- Name: index_users_libraries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_libraries_on_user_id ON users_libraries USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: datasets_tasks datasets_analysis_tasks_dataset_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets_tasks
    ADD CONSTRAINT datasets_analysis_tasks_dataset_id_fk FOREIGN KEY (dataset_id) REFERENCES datasets(id);


--
-- Name: datasets datasets_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets
    ADD CONSTRAINT datasets_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: documents_categories documents_categories_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents_categories
    ADD CONSTRAINT documents_categories_parent_id_fk FOREIGN KEY (parent_id) REFERENCES documents_categories(id);


--
-- Name: documents_category_hierarchies documents_category_hierarchies_ancestor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents_category_hierarchies
    ADD CONSTRAINT documents_category_hierarchies_ancestor_id_fk FOREIGN KEY (ancestor_id) REFERENCES documents_categories(id);


--
-- Name: documents_category_hierarchies documents_category_hierarchies_descendant_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents_category_hierarchies
    ADD CONSTRAINT documents_category_hierarchies_descendant_id_fk FOREIGN KEY (descendant_id) REFERENCES documents_categories(id);


--
-- Name: users_libraries users_libraries_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_libraries
    ADD CONSTRAINT users_libraries_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20110908133632'),
('20110908232625'),
('20110916203031'),
('20110928165308'),
('20110929135437'),
('20111001233930'),
('20111018003510'),
('20111024225019'),
('20111122135408'),
('20111205172114'),
('20111205185208'),
('20111206000437'),
('20120105150524'),
('20120123202818'),
('20120124192349'),
('20121207143836'),
('20130109194840'),
('20130109194902'),
('20130109194903'),
('20130109223820'),
('20130110034148'),
('20130112012448'),
('20130112042432'),
('20130112162822'),
('20130311180722'),
('20130731220528'),
('20130731222054'),
('20130801021934'),
('20130801202821'),
('20130806005057'),
('20130917194623'),
('20130917195215'),
('20130917195220'),
('20130917195527'),
('20130920174611'),
('20131017161525'),
('20131022151607'),
('20131031130451'),
('20131031190215'),
('20131105202034'),
('20131110162848'),
('20131110184843'),
('20131110210646'),
('20131110214442'),
('20131112153938'),
('20131114011634'),
('20131114044009'),
('20131117181239'),
('20131117182828'),
('20131122160941'),
('20131204171642'),
('20131224154209'),
('20140523162748'),
('20150321205255'),
('20150704144210'),
('20150704153023'),
('20150712153313'),
('20150713141304'),
('20150908203553'),
('20150908210220'),
('20150918225229'),
('20151005170502'),
('20151118043212'),
('20151119181057'),
('20151120145451'),
('20151204013427'),
('20160126134222');


