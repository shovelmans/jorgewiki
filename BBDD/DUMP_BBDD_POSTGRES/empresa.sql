--
-- PostgreSQL database dump
--

\restrict pqWr5HmMIzoNZQOxNPlFswdp5Pmilo4BfMr488rvdZXtTHyWqde25z37M3G9LU0

-- Dumped from database version 16.13 (Debian 16.13-1.pgdg13+1)
-- Dumped by pg_dump version 16.13 (Debian 16.13-1.pgdg13+1)

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
-- Name: rrhh; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA rrhh;


ALTER SCHEMA rrhh OWNER TO postgres;

--
-- Name: ventas; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA ventas;


ALTER SCHEMA ventas OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: empleados; Type: TABLE; Schema: rrhh; Owner: postgres
--

CREATE TABLE rrhh.empleados (
    id integer NOT NULL,
    nombre text,
    puesto text
);


ALTER TABLE rrhh.empleados OWNER TO postgres;

--
-- Name: empleados_id_seq; Type: SEQUENCE; Schema: rrhh; Owner: postgres
--

CREATE SEQUENCE rrhh.empleados_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE rrhh.empleados_id_seq OWNER TO postgres;

--
-- Name: empleados_id_seq; Type: SEQUENCE OWNED BY; Schema: rrhh; Owner: postgres
--

ALTER SEQUENCE rrhh.empleados_id_seq OWNED BY rrhh.empleados.id;


--
-- Name: clientes; Type: TABLE; Schema: ventas; Owner: postgres
--

CREATE TABLE ventas.clientes (
    id integer NOT NULL,
    nombre text,
    ciudad text
);


ALTER TABLE ventas.clientes OWNER TO postgres;

--
-- Name: clientes_id_seq; Type: SEQUENCE; Schema: ventas; Owner: postgres
--

CREATE SEQUENCE ventas.clientes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ventas.clientes_id_seq OWNER TO postgres;

--
-- Name: clientes_id_seq; Type: SEQUENCE OWNED BY; Schema: ventas; Owner: postgres
--

ALTER SEQUENCE ventas.clientes_id_seq OWNED BY ventas.clientes.id;


--
-- Name: empleados id; Type: DEFAULT; Schema: rrhh; Owner: postgres
--

ALTER TABLE ONLY rrhh.empleados ALTER COLUMN id SET DEFAULT nextval('rrhh.empleados_id_seq'::regclass);


--
-- Name: clientes id; Type: DEFAULT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY ventas.clientes ALTER COLUMN id SET DEFAULT nextval('ventas.clientes_id_seq'::regclass);


--
-- Data for Name: empleados; Type: TABLE DATA; Schema: rrhh; Owner: postgres
--

COPY rrhh.empleados (id, nombre, puesto) FROM stdin;
1	Carlos	DevOps
2	Lucia	DBA
\.


--
-- Data for Name: clientes; Type: TABLE DATA; Schema: ventas; Owner: postgres
--

COPY ventas.clientes (id, nombre, ciudad) FROM stdin;
1	Jorge	Madrid
2	Ana	Sevilla
3	Luis	Valencia
\.


--
-- Name: empleados_id_seq; Type: SEQUENCE SET; Schema: rrhh; Owner: postgres
--

SELECT pg_catalog.setval('rrhh.empleados_id_seq', 2, true);


--
-- Name: clientes_id_seq; Type: SEQUENCE SET; Schema: ventas; Owner: postgres
--

SELECT pg_catalog.setval('ventas.clientes_id_seq', 3, true);


--
-- Name: empleados empleados_pkey; Type: CONSTRAINT; Schema: rrhh; Owner: postgres
--

ALTER TABLE ONLY rrhh.empleados
    ADD CONSTRAINT empleados_pkey PRIMARY KEY (id);


--
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: ventas; Owner: postgres
--

ALTER TABLE ONLY ventas.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id);


--
-- Name: SCHEMA rrhh; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA rrhh TO reportuser;


--
-- Name: SCHEMA ventas; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA ventas TO appuser;


--
-- Name: TABLE empleados; Type: ACL; Schema: rrhh; Owner: postgres
--

GRANT SELECT ON TABLE rrhh.empleados TO reportuser;


--
-- Name: TABLE clientes; Type: ACL; Schema: ventas; Owner: postgres
--

GRANT SELECT ON TABLE ventas.clientes TO appuser;


--
-- PostgreSQL database dump complete
--

\unrestrict pqWr5HmMIzoNZQOxNPlFswdp5Pmilo4BfMr488rvdZXtTHyWqde25z37M3G9LU0

