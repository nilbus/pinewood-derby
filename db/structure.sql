--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: contestants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contestants (
    id integer NOT NULL,
    name character varying(255),
    retired boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: contestants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contestants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contestants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contestants_id_seq OWNED BY contestants.id;


--
-- Name: heats; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE heats (
    id integer NOT NULL,
    sequence integer,
    status character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: heats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE heats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE heats_id_seq OWNED BY heats.id;


--
-- Name: runs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE runs (
    id integer NOT NULL,
    contestant_id integer,
    heat_id integer,
    "time" numeric,
    lane integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE runs_id_seq OWNED BY runs.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: single_values; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE single_values (
    id integer NOT NULL,
    value hstore,
    type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: single_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE single_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: single_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE single_values_id_seq OWNED BY single_values.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contestants ALTER COLUMN id SET DEFAULT nextval('contestants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY heats ALTER COLUMN id SET DEFAULT nextval('heats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY runs ALTER COLUMN id SET DEFAULT nextval('runs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY single_values ALTER COLUMN id SET DEFAULT nextval('single_values_id_seq'::regclass);


--
-- Name: contestants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contestants
    ADD CONSTRAINT contestants_pkey PRIMARY KEY (id);


--
-- Name: heats_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY heats
    ADD CONSTRAINT heats_pkey PRIMARY KEY (id);


--
-- Name: runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY runs
    ADD CONSTRAINT runs_pkey PRIMARY KEY (id);


--
-- Name: single_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY single_values
    ADD CONSTRAINT single_values_pkey PRIMARY KEY (id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20130105124714');

INSERT INTO schema_migrations (version) VALUES ('20130105213045');

INSERT INTO schema_migrations (version) VALUES ('20130105213224');

INSERT INTO schema_migrations (version) VALUES ('20130109190716');

INSERT INTO schema_migrations (version) VALUES ('20130109190837');
