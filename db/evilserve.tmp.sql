--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: powerdns; Type: SCHEMA; Schema: -; Owner: evilserve
--

CREATE SCHEMA powerdns;


ALTER SCHEMA powerdns OWNER TO evilserve;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pgsql
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: pgsql
--

CREATE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO pgsql;

SET search_path = powerdns, pg_catalog;

--
-- Name: domain_type; Type: TYPE; Schema: powerdns; Owner: evilserve
--

CREATE TYPE domain_type AS ENUM (
    'NATIVE',
    'MASTER',
    'SLAVE',
    'SUPERSLAVE'
);


ALTER TYPE powerdns.domain_type OWNER TO evilserve;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: domains; Type: TABLE; Schema: powerdns; Owner: evilserve; Tablespace: 
--

CREATE TABLE domains (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    master character varying(255) DEFAULT NULL::character varying,
    last_check integer,
    type domain_type NOT NULL,
    notified_serial integer,
    account character varying(40) DEFAULT NULL::character varying
);


ALTER TABLE powerdns.domains OWNER TO evilserve;

--
-- Name: record_type; Type: TYPE; Schema: powerdns; Owner: evilserve
--

CREATE TYPE record_type AS ENUM (
    'A',
    'AAAA',
    'AFSDB',
    'CERT',
    'CNAME',
    'DNSKEY',
    'DS',
    'HINFO',
    'KEY',
    'LOC',
    'MX',
    'NAPTR',
    'NS',
    'NSEC',
    'PTR',
    'RP',
    'RRSIG',
    'SOA',
    'SPF',
    'SSHFP',
    'SRV',
    'TXT'
);


ALTER TYPE powerdns.record_type OWNER TO evilserve;

--
-- Name: records; Type: TABLE; Schema: powerdns; Owner: evilserve; Tablespace: 
--

CREATE TABLE records (
    id bigint NOT NULL,
    domain_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    type record_type NOT NULL,
    content character varying(255) NOT NULL,
    ttl integer,
    prio integer,
    change_date integer,
    ref_id bigint
);


ALTER TABLE powerdns.records OWNER TO evilserve;

SET search_path = public, pg_catalog;

--
-- Name: dns_resource_types; Type: TABLE; Schema: public; Owner: evilserve; Tablespace: 
--

CREATE TABLE dns_resource_types (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description text
);


ALTER TABLE public.dns_resource_types OWNER TO evilserve;

--
-- Name: dns_resources; Type: TABLE; Schema: public; Owner: evilserve; Tablespace: 
--

CREATE TABLE dns_resources (
    id bigint NOT NULL,
    dns_zone_id bigint NOT NULL,
    dns_resource_type_id bigint NOT NULL,
    name character varying(64) NOT NULL,
    data character varying(255) NOT NULL,
    aux integer,
    ttl integer
);


ALTER TABLE public.dns_resources OWNER TO evilserve;

--
-- Name: dns_zones; Type: TABLE; Schema: public; Owner: evilserve; Tablespace: 
--

CREATE TABLE dns_zones (
    id bigint NOT NULL,
    origin character varying(255) NOT NULL,
    ns character varying(255) NOT NULL,
    mbox character varying(255) NOT NULL,
    serial bigint DEFAULT 1::bigint NOT NULL,
    refresh integer DEFAULT 10800 NOT NULL,
    retry integer DEFAULT 3600 NOT NULL,
    expire integer DEFAULT 604800 NOT NULL,
    ttl integer DEFAULT 3600 NOT NULL
);


ALTER TABLE public.dns_zones OWNER TO evilserve;

--
-- Name: concat_hosts_func(text, text); Type: FUNCTION; Schema: public; Owner: evilserve
--

CREATE FUNCTION concat_hosts_func(text, text) RETURNS text
    AS $_$
  DECLARE
  BEGIN
    IF ($1 = '' OR $1 IS NULL) THEN
      RETURN $2;
    END IF;
    RETURN ($1 || '.' || $2);
  END;
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION public.concat_hosts_func(text, text) OWNER TO evilserve;

--
-- Name: dns_resources_increment_dns_zones_serial_func(); Type: FUNCTION; Schema: public; Owner: evilserve
--

CREATE FUNCTION dns_resources_increment_dns_zones_serial_func() RETURNS trigger
    AS $$
  DECLARE
  BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
      UPDATE dns_zones SET serial=serial+1 WHERE id=NEW.dns_zone_id;
      RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
      UPDATE dns_zones SET serial=serial+1 WHERE id=OLD.dns_zone_id;
      RETURN OLD;
    END IF;
    RETURN NULL;
  END
$$
    LANGUAGE plpgsql;


ALTER FUNCTION public.dns_resources_increment_dns_zones_serial_func() OWNER TO evilserve;

--
-- Name: dns_resources_powerdns_func(); Type: FUNCTION; Schema: public; Owner: evilserve
--

CREATE FUNCTION dns_resources_powerdns_func() RETURNS trigger
    AS $$
  DECLARE
    origin_l VARCHAR(255);
-- PostgreSQL 8.3
    type_l powerdns.RECORD_TYPE;
-- PostgreSQL 8.2
--     type_l VARCHAR(5);
    ttl_l INT4;
  BEGIN
    IF (TG_OP = 'DELETE') THEN
      DELETE FROM powerdns.records WHERE ref_id=OLD.id;
      RETURN OLD;
    END IF;

    IF (NEW.ttl IS NULL) THEN
      SELECT ttl INTO ttl_l FROM dns_zones WHERE id=NEW.dns_zone_id;
    ELSE
      ttl_l := NEW.ttl;
    END IF;

    IF (TG_OP = 'INSERT') THEN
      SELECT origin INTO origin_l FROM dns_zones WHERE id=NEW.dns_zone_id;
      SELECT name INTO type_l FROM dns_resource_types WHERE id=NEW.dns_resource_type_id;
      INSERT INTO powerdns.records (domain_id, name, type, content, ttl, prio, ref_id) VALUES
        (NEW.dns_zone_id, concat_hosts_func(NEW.name, origin_l), type_l,
         NEW.data, ttl_l, NEW.aux, NEW.id);
      RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
      SELECT origin INTO origin_l FROM dns_zones WHERE id=NEW.dns_zone_id;
      SELECT name INTO type_l FROM dns_resource_types WHERE id=NEW.dns_resource_type_id;
      UPDATE powerdns.records SET domain_id=NEW.dns_zone_id,
        name=concat_hosts_func(NEW.name, origin_l), type=type_l,
        content=NEW.data, ttl=ttl_l, prio=NEW.aux WHERE ref_id=NEW.id;
      RETURN NEW;
    END IF;
    RETURN NULL;
  END
$$
    LANGUAGE plpgsql;


ALTER FUNCTION public.dns_resources_powerdns_func() OWNER TO evilserve;

--
-- Name: dns_zones_powerdns_func(); Type: FUNCTION; Schema: public; Owner: evilserve
--

CREATE FUNCTION dns_zones_powerdns_func() RETURNS trigger
    AS $$
  DECLARE
  BEGIN
    IF (TG_OP = 'INSERT') THEN
      INSERT INTO powerdns.domains (id, name, type) VALUES (NEW.id, NEW.origin, 'MASTER');
      INSERT INTO powerdns.records (domain_id, name, type, content, ttl) VALUES (NEW.id, NEW.origin, 'SOA',
        (NEW.ns || ' ' || NEW.mbox || ' ' || NEW.serial || ' ' || NEW.refresh || ' ' ||
        NEW.retry || ' ' || NEW.expire || ' ' || NEW.ttl), NEW.ttl);
      RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
      IF (NEW.origin <> OLD.origin) THEN
        UPDATE powerdns.domains SET name=NEW.origin WHERE id=NEW.id;
        UPDATE powerdns.records SET name=NEW.origin WHERE domain_id=NEW.id AND type='SOA';
      END IF;

      IF (NEW.ns <> OLD.ns OR
          NEW.mbox <> OLD.mbox OR
          NEW.serial <> OLD.serial OR
          NEW.refresh <> OLD.refresh OR
          NEW.retry <> OLD.retry OR
          NEW.expire <> OLD.expire OR
          NEW.ttl <> OLD.ttl) THEN
        UPDATE powerdns.records SET content=(NEW.ns || ' ' ||
            NEW.mbox || ' ' || NEW.serial || ' ' || NEW.refresh || ' ' ||
            NEW.retry || ' ' || NEW.expire || ' ' || NEW.ttl),
            ttl=NEW.ttl
          WHERE domain_id=NEW.id AND type='SOA';
      END IF;
      RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
      DELETE FROM powerdns.domains WHERE id=OLD.id;
      RETURN OLD;
    END IF;
    RETURN NULL;
  END
$$
    LANGUAGE plpgsql;


ALTER FUNCTION public.dns_zones_powerdns_func() OWNER TO evilserve;

--
-- Name: dns_zones_update_increment_serial_func(); Type: FUNCTION; Schema: public; Owner: evilserve
--

CREATE FUNCTION dns_zones_update_increment_serial_func() RETURNS trigger
    AS $$
  DECLARE
  BEGIN
    IF (NEW.serial <= OLD.serial) THEN
      NEW.serial := OLD.serial + 1;
    END IF;
    RETURN NEW;
  END
$$
    LANGUAGE plpgsql;


ALTER FUNCTION public.dns_zones_update_increment_serial_func() OWNER TO evilserve;

SET search_path = powerdns, pg_catalog;

--
-- Name: records_id_seq; Type: SEQUENCE; Schema: powerdns; Owner: evilserve
--

CREATE SEQUENCE records_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE powerdns.records_id_seq OWNER TO evilserve;

--
-- Name: records_id_seq; Type: SEQUENCE OWNED BY; Schema: powerdns; Owner: evilserve
--

ALTER SEQUENCE records_id_seq OWNED BY records.id;


--
-- Name: records_id_seq; Type: SEQUENCE SET; Schema: powerdns; Owner: evilserve
--

SELECT pg_catalog.setval('records_id_seq', 195, true);


SET search_path = public, pg_catalog;

--
-- Name: dns_resource_types_id_seq; Type: SEQUENCE; Schema: public; Owner: evilserve
--

CREATE SEQUENCE dns_resource_types_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.dns_resource_types_id_seq OWNER TO evilserve;

--
-- Name: dns_resource_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: evilserve
--

ALTER SEQUENCE dns_resource_types_id_seq OWNED BY dns_resource_types.id;


--
-- Name: dns_resource_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: evilserve
--

SELECT pg_catalog.setval('dns_resource_types_id_seq', 9, true);


--
-- Name: dns_resources_id_seq; Type: SEQUENCE; Schema: public; Owner: evilserve
--

CREATE SEQUENCE dns_resources_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.dns_resources_id_seq OWNER TO evilserve;

--
-- Name: dns_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: evilserve
--

ALTER SEQUENCE dns_resources_id_seq OWNED BY dns_resources.id;


--
-- Name: dns_resources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: evilserve
--

SELECT pg_catalog.setval('dns_resources_id_seq', 175, true);


--
-- Name: dns_zones_id_seq; Type: SEQUENCE; Schema: public; Owner: evilserve
--

CREATE SEQUENCE dns_zones_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.dns_zones_id_seq OWNER TO evilserve;

--
-- Name: dns_zones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: evilserve
--

ALTER SEQUENCE dns_zones_id_seq OWNED BY dns_zones.id;


--
-- Name: dns_zones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: evilserve
--

SELECT pg_catalog.setval('dns_zones_id_seq', 39, true);


SET search_path = powerdns, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: powerdns; Owner: evilserve
--

ALTER TABLE records ALTER COLUMN id SET DEFAULT nextval('records_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: evilserve
--

ALTER TABLE dns_resource_types ALTER COLUMN id SET DEFAULT nextval('dns_resource_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: evilserve
--

ALTER TABLE dns_resources ALTER COLUMN id SET DEFAULT nextval('dns_resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: evilserve
--

ALTER TABLE dns_zones ALTER COLUMN id SET DEFAULT nextval('dns_zones_id_seq'::regclass);


SET search_path = powerdns, pg_catalog;

--
-- Data for Name: domains; Type: TABLE DATA; Schema: powerdns; Owner: evilserve
--

COPY domains (id, name, master, last_check, type, notified_serial, account) FROM stdin;
2	thesjg.com	\N	\N	MASTER	6	\N
3	thesjg.net	\N	\N	MASTER	6	\N
4	thesjg.org	\N	\N	MASTER	6	\N
5	mindlessracing.com	\N	\N	MASTER	6	\N
6	mindlessracing.net	\N	\N	MASTER	6	\N
7	mindlessracing.org	\N	\N	MASTER	6	\N
8	bitbum.com	\N	\N	MASTER	6	\N
9	bitbum.net	\N	\N	MASTER	6	\N
10	bitbum.org	\N	\N	MASTER	6	\N
12	ftmeaderemount.com	\N	\N	MASTER	7	\N
1	evilcode.net	\N	\N	MASTER	23	\N
11	flixn.com	\N	\N	MASTER	39	\N
14	kaneda.net	\N	\N	MASTER	11	\N
27	durandall.org	\N	\N	MASTER	11	\N
28	k-osh.com	\N	\N	MASTER	8	\N
29	randallbattlesdirk.com	\N	\N	MASTER	7	\N
26	developink.com	\N	\N	MASTER	13	\N
13	evilprojects.net	\N	\N	MASTER	13	\N
30	randallcreasey.com	\N	\N	MASTER	21	\N
25	infernalhosting.net	\N	\N	MASTER	78	\N
\.


--
-- Data for Name: records; Type: TABLE DATA; Schema: powerdns; Owner: evilserve
--

COPY records (id, domain_id, name, type, content, ttl, prio, change_date, ref_id) FROM stdin;
37	7	mindlessracing.org	A	72.232.239.133	3600	\N	\N	30
54	10	bitbum.org	NS	ns0.evilcode.net	3600	\N	\N	44
4	1	ns0.evilcode.net	A	72.232.239.131	3600	\N	\N	3
38	7	*.mindlessracing.org	A	72.232.239.133	3600	\N	\N	31
5	1	ns1.evilcode.net	A	72.232.228.26	3600	\N	\N	4
75	13	evilprojects.net	SOA	ns.evilcode.net dns.evilcode.net 13 300 300 1200 300	300	\N	\N	\N
39	7	mindlessracing.org	NS	ns0.evilcode.net	3600	\N	\N	32
7	1	evilcode.net	MX	mail.evilcode.net	3600	1	\N	6
8	1	evilcode.net	NS	ns0.evilcode.net	3600	\N	\N	7
40	7	mindlessracing.org	NS	ns1.evilcode.net	3600	\N	\N	33
9	1	evilcode.net	NS	ns1.evilcode.net	3600	\N	\N	8
12	2	thesjg.com	A	72.232.239.133	3600	\N	\N	10
55	10	bitbum.org	NS	ns1.evilcode.net	3600	\N	\N	45
13	2	*.thesjg.com	A	72.232.239.133	3600	\N	\N	11
42	8	bitbum.com	A	72.232.239.133	3600	\N	\N	34
14	2	thesjg.com	NS	ns0.evilcode.net	3600	\N	\N	12
15	2	thesjg.com	NS	ns1.evilcode.net	3600	\N	\N	13
17	3	thesjg.net	A	72.232.239.133	3600	\N	\N	14
43	8	*.bitbum.com	A	72.232.239.133	3600	\N	\N	35
18	3	*.thesjg.net	A	72.232.239.133	3600	\N	\N	15
63	11	flixn.com	NS	ns1.evilcode.net	3600	\N	\N	52
19	3	thesjg.net	NS	ns0.evilcode.net	3600	\N	\N	16
20	3	thesjg.net	NS	ns1.evilcode.net	3600	\N	\N	17
44	8	bitbum.com	NS	ns0.evilcode.net	3600	\N	\N	36
22	4	thesjg.org	A	72.232.239.133	3600	\N	\N	18
23	4	*.thesjg.org	A	72.232.239.133	3600	\N	\N	19
45	8	bitbum.com	NS	ns1.evilcode.net	3600	\N	\N	37
24	4	thesjg.org	NS	ns0.evilcode.net	3600	\N	\N	20
25	4	thesjg.org	NS	ns1.evilcode.net	3600	\N	\N	21
27	5	mindlessracing.com	A	72.232.239.133	3600	\N	\N	22
28	5	*.mindlessracing.com	A	72.232.239.133	3600	\N	\N	23
47	9	bitbum.net	A	72.232.239.133	3600	\N	\N	38
29	5	mindlessracing.com	NS	ns0.evilcode.net	3600	\N	\N	24
30	5	mindlessracing.com	NS	ns1.evilcode.net	3600	\N	\N	25
11	2	thesjg.com	SOA	ns.evilcode.net dns.evilcode.net 6 10800 3600 604800 3600	3600	\N	\N	\N
32	6	mindlessracing.net	A	72.232.239.133	3600	\N	\N	26
48	9	*.bitbum.net	A	72.232.239.133	3600	\N	\N	39
33	6	*.mindlessracing.net	A	72.232.239.133	3600	\N	\N	27
34	6	mindlessracing.net	NS	ns0.evilcode.net	3600	\N	\N	28
68	12	ftmeaderemount.com	NS	ns0.evilcode.net	3600	\N	\N	56
35	6	mindlessracing.net	NS	ns1.evilcode.net	3600	\N	\N	29
49	9	bitbum.net	NS	ns0.evilcode.net	3600	\N	\N	40
50	9	bitbum.net	NS	ns1.evilcode.net	3600	\N	\N	41
64	11	flixn.com	MX	smtp15.msoutlookonline.net	3600	1	\N	53
52	10	bitbum.org	A	72.232.239.133	3600	\N	\N	42
53	10	*.bitbum.org	A	72.232.239.133	3600	\N	\N	43
59	11	fms01.flixn.com	A	72.232.239.130	3600	\N	\N	48
16	3	thesjg.net	SOA	ns.evilcode.net dns.evilcode.net 6 10800 3600 604800 3600	3600	\N	\N	\N
60	11	fms02.flixn.com	A	72.232.228.26	3600	\N	\N	49
58	11	*.flixn.com	A	72.232.239.133	300	\N	\N	47
61	11	media.flixn.com	A	72.232.228.26	3600	\N	\N	50
69	12	ftmeaderemount.com	NS	ns1.evilcode.net	3600	\N	\N	57
62	11	flixn.com	NS	ns0.evilcode.net	3600	\N	\N	51
21	4	thesjg.org	SOA	ns.evilcode.net dns.evilcode.net 6 10800 3600 604800 3600	3600	\N	\N	\N
26	5	mindlessracing.com	SOA	ns.evilcode.net dns.evilcode.net 6 10800 3600 604800 3600	3600	\N	\N	\N
31	6	mindlessracing.net	SOA	ns.evilcode.net dns.evilcode.net 6 10800 3600 604800 3600	3600	\N	\N	\N
36	7	mindlessracing.org	SOA	ns.evilcode.net dns.evilcode.net 6 10800 3600 604800 3600	3600	\N	\N	\N
41	8	bitbum.com	SOA	ns.evilcode.net dns.evilcode.net 6 10800 3600 604800 3600	3600	\N	\N	\N
46	9	bitbum.net	SOA	ns.evilcode.net dns.evilcode.net 6 10800 3600 604800 3600	3600	\N	\N	\N
51	10	bitbum.org	SOA	ns.evilcode.net dns.evilcode.net 6 10800 3600 604800 3600	3600	\N	\N	\N
71	1	aurora.evilcode.net	A	67.15.197.7	3600	\N	\N	59
72	1	hawthorne.evilcode.net	A	72.232.228.26	3600	\N	\N	60
73	1	brio.evilcode.net	A	209.40.201.62	3600	\N	\N	61
74	1	catalyst.evilcode.net	A	72.232.239.130	3600	\N	\N	62
66	12	ftmeaderemount.com	A	72.232.239.133	3600	\N	\N	54
76	13	evilprojects.net	A	72.232.239.132	300	0	\N	63
6	1	mail.evilcode.net	A	72.232.239.131	3600	\N	\N	5
77	13	*.evilprojects.net	A	72.232.239.132	300	0	\N	64
78	13	evilprojects.net	NS	ns0.evilcode.net	300	0	\N	65
79	13	evilprojects.net	NS	ns1.evilcode.net	300	0	\N	66
80	13	mail.evilprojects.net	CNAME	mail.evilcode.net	300	0	\N	67
81	13	evilprojects.net	MX	mail.evilcode.net	300	0	\N	68
82	1	svn.evilcode.net	A	72.232.239.130	3600	\N	\N	69
83	13	www.evilprojects.net	A	72.232.239.133	300	0	\N	70
95	30	randallcreasey.com	SOA	ns1.infernalhosting.net dns.infernalhosting.net 21 10800 3600 604800 3600	3600	\N	\N	\N
107	28	k-osh.com	NS	ns0.evilcode.net.	300	0	\N	87
119	27	durandall.org	NS	ns1.evilcode.net.	300	0	\N	99
108	28	k-osh.com	NS	ns1.evilcode.net.	300	0	\N	88
57	11	flixn.com	A	72.232.239.133	300	\N	\N	46
109	28	k-osh.com	MX	mail.infernalhosting.net.	300	0	\N	89
120	27	durandall.org	NS	ns0.evilcode.net.	300	0	\N	100
84	11	admin.flixn.com	A	72.232.239.133	300	\N	\N	71
85	11	widgets.flixn.com	A	72.232.239.133	300	\N	\N	72
86	13	flixn.evilprojects.net	A	72.232.239.133	300	\N	\N	73
65	12	ftmeaderemount.com	SOA	ns.evilcode.net dns.evilcode.net 7 10800 3600 604800 3600	3600	\N	\N	\N
67	12	*.ftmeaderemount.com	A	72.232.239.133	3600	\N	\N	55
70	11	mint.flixn.com	A	72.232.239.133	300	\N	\N	58
2	1	evilcode.net	A	72.232.239.133	3600	\N	\N	1
1	1	evilcode.net	SOA	ns.evilcode.net dns.evilcode.net 23 10800 3600 604800 3600	3600	\N	\N	\N
3	1	*.evilcode.net	A	72.232.239.133	3600	\N	\N	2
110	28	mail.k-osh.com	CNAME	mail.infernalhosting.net.	300	0	\N	90
87	11	ecard.flixn.com	A	72.232.239.133	300	\N	\N	74
56	11	flixn.com	SOA	ns.evilcode.net dns.evilcode.net 39 300 300 1200 300	300	\N	\N	\N
88	11	ecards.flixn.com	A	72.232.239.133	300	\N	\N	75
97	30	randallcreasey.com	NS	ns0.evilcode.net.	300	0	\N	77
98	30	randallcreasey.com	NS	ns1.evilcode.net.	300	0	\N	78
112	28	www.k-osh.com	CNAME	k-osh.com.	300	0	\N	92
99	30	randallcreasey.com	MX	mail.infernalhosting.net.	300	0	\N	79
121	26	www.developink.com	CNAME	developink.myshopify.com.	300	0	\N	101
100	30	mail.randallcreasey.com	CNAME	mail.infernalhosting.net.	300	0	\N	80
101	30	www.randallcreasey.com	CNAME	randallcreasey.com.	300	0	\N	81
113	27	durandall.org	MX	mail.infernalhosting.net.	300	0	\N	93
130	26	sql.developink.com	A	67.15.197.7	300	0	\N	110
103	29	randallbattlesdirk.com	MX	mail.randallbattlesdirk.com.	300	0	\N	83
114	27	mail.durandall.org	CNAME	mail.infernalhosting.net.	300	0	\N	94
104	29	www.randallbattlesdirk.com	CNAME	randallbattlesdirk.com.	300	0	\N	84
122	26	developink.com	MX	mail.infernalhosting.net.	300	0	\N	102
105	29	db.randallbattlesdirk.com	A	67.15.197.7	300	0	\N	85
106	29	mail.randallbattlesdirk.com	CNAME	mail.infernalhosting.net.	300	0	\N	86
115	27	www.durandall.org	CNAME	durandall.org.	300	0	\N	95
127	26	developink.com	NS	ns0.evilcode.net.	300	0	\N	107
116	27	dev.durandall.org	CNAME	durandall.org.	300	0	\N	96
123	26	mail.developink.com	CNAME	mail.infernalhosting.net.	300	0	\N	103
128	26	shop.developink.com	CNAME	developink.myshopify.com.	300	0	\N	108
131	14	kaneda.net	MX	mail.kaneda.net.	300	0	\N	111
125	26	developink.com	NS	ns1.evilcode.net.	300	0	\N	105
133	14	mail.kaneda.net	CNAME	mail.infernalhosting.net.	300	0	\N	113
129	26	dev.developink.com	CNAME	developink.com.	300	0	\N	109
89	14	kaneda.net	SOA	ns1.infernalhosting.net dns.infernalhosting.net 11 10800 3600 604800 3600	3600	\N	\N	\N
132	14	stats.kaneda.net	CNAME	web01.infernalhosting.net.	300	0	\N	112
134	14	ns.kaneda.net	CNAME	ns1.infernalhosting.net.	300	0	\N	114
135	14	kaneda.net	A	72.232.239.132	300	0	\N	115
136	14	kaneda.net	NS	ns0.evilcode.net.	300	0	\N	116
137	14	www.kaneda.net	CNAME	kaneda.net.	300	0	\N	117
138	14	db.kaneda.net	CNAME	db01.infernalhosting.net.	300	0	\N	118
139	14	xml.kaneda.net	CNAME	kaneda.net.	300	0	\N	119
140	14	feed.kaneda.net	CNAME	kaneda.net.	300	0	\N	120
141	25	infernalhosting.net	MX	mail.infernalhosting.net.	300	0	\N	121
142	25	media.infernalhosting.net	CNAME	infernalhosting.net.	300	0	\N	122
143	25	rails01.infernalhosting.net	A	72.232.239.132	300	0	\N	123
144	25	web01.infernalhosting.net	A	72.232.239.133	300	0	\N	124
145	25	db01.infernalhosting.net	A	10.0.3.1	300	0	\N	125
146	25	mdb01.infernalhosting.net	A	10.0.0.2	300	0	\N	126
147	25	infernalhosting.net	A	72.232.239.132	300	0	\N	127
151	25	irc.infernalhosting.net	CNAME	irc.evilcode.net.	300	0	\N	131
154	25	ns.infernalhosting.net	CNAME	ns1.infernalhosting.net.	300	0	\N	134
157	25	old.infernalhosting.net	CNAME	infernalhosting.net.	300	0	\N	137
158	25	services.irc.infernalhosting.net	A	70.168.96.168	300	0	\N	138
159	25	sql.infernalhosting.net	A	67.15.197.7	300	0	\N	139
160	25	www.infernalhosting.net	CNAME	infernalhosting.net.	300	0	\N	140
161	25	dev.admin.infernalhosting.net	CNAME	infernalhosting.net.	300	0	\N	141
162	25	dev.infernalhosting.net	CNAME	rails01.infernalhosting.net.	300	0	\N	142
163	25	cacti.infernalhosting.net	CNAME	web01.infernalhosting.net.	300	0	\N	143
96	30	randallcreasey.com	A	72.232.239.133	300	0	\N	76
94	29	randallbattlesdirk.com	SOA	ns1.infernalhosting.net dns.infernalhosting.net 7 10800 3600 604800 3600	3600	\N	\N	\N
102	29	randallbattlesdirk.com	A	72.232.239.133	300	0	\N	82
93	28	k-osh.com	SOA	ns1.infernalhosting.net dns.infernalhosting.net 8 10800 3600 604800 3600	3600	\N	\N	\N
111	28	k-osh.com	A	72.232.239.133	300	0	\N	91
117	27	durandall.org	A	72.232.239.133	300	0	\N	97
92	27	durandall.org	SOA	ns1.infernalhosting.net dns.infernalhosting.net 11 10800 3600 604800 3600	3600	\N	\N	\N
118	27	mysql.durandall.org	A	72.232.239.133	300	0	\N	98
124	26	mysql.developink.com	A	72.232.239.133	300	0	\N	104
91	26	developink.com	SOA	ns1.infernalhosting.net dns.infernalhosting.net 13 10800 3600 604800 3600	3600	\N	\N	\N
126	26	developink.com	A	72.232.239.133	300	0	\N	106
150	25	webmail.infernalhosting.net	A	72.232.239.133	300	0	\N	130
153	25	mysql.infernalhosting.net	A	72.232.239.133	300	0	\N	133
152	25	mail.infernalhosting.net	A	72.232.239.131	300	0	\N	132
164	25	infernalhosting.net	MX	mail.infernalhosting.net.	300	0	\N	144
170	25	infernalhosting.net	A	72.232.239.132	300	0	\N	150
155	25	ns1.infernalhosting.net	A	72.232.228.26	300	0	\N	135
148	25	infernalhosting.net	NS	ns0.infernalhosting.net	300	0	\N	128
149	25	infernalhosting.net	NS	ns1.infernalhosting.net	300	0	\N	129
193	13	flixnsvn.evilprojects.net	A	72.232.239.132	300	\N	\N	173
194	13	hacks.evilprojects.net	A	72.232.239.132	300	\N	\N	174
195	25	ns0.infernalhosting.net	A	72.232.239.131	300	0	\N	175
90	25	infernalhosting.net	SOA	ns1.infernalhosting.net dns.infernalhosting.net 78 10800 3600 604800 3600	3600	\N	\N	\N
\.


SET search_path = public, pg_catalog;

--
-- Data for Name: dns_resource_types; Type: TABLE DATA; Schema: public; Owner: evilserve
--

COPY dns_resource_types (id, name, description) FROM stdin;
1	A	
2	AAAA	
3	CNAME	
4	HINFO	
5	MX	
6	NS	
7	PTR	
8	SRV	
9	TXT	
\.


--
-- Data for Name: dns_resources; Type: TABLE DATA; Schema: public; Owner: evilserve
--

COPY dns_resources (id, dns_zone_id, dns_resource_type_id, name, data, aux, ttl) FROM stdin;
3	1	1	ns0	72.232.239.131	\N	\N
4	1	1	ns1	72.232.228.26	\N	\N
6	1	5		mail.evilcode.net	1	\N
7	1	6		ns0.evilcode.net	\N	\N
8	1	6		ns1.evilcode.net	\N	\N
10	2	1		72.232.239.133	\N	\N
11	2	1	*	72.232.239.133	\N	\N
12	2	6		ns0.evilcode.net	\N	\N
13	2	6		ns1.evilcode.net	\N	\N
14	3	1		72.232.239.133	\N	\N
15	3	1	*	72.232.239.133	\N	\N
16	3	6		ns0.evilcode.net	\N	\N
17	3	6		ns1.evilcode.net	\N	\N
18	4	1		72.232.239.133	\N	\N
19	4	1	*	72.232.239.133	\N	\N
20	4	6		ns0.evilcode.net	\N	\N
21	4	6		ns1.evilcode.net	\N	\N
22	5	1		72.232.239.133	\N	\N
23	5	1	*	72.232.239.133	\N	\N
24	5	6		ns0.evilcode.net	\N	\N
25	5	6		ns1.evilcode.net	\N	\N
26	6	1		72.232.239.133	\N	\N
27	6	1	*	72.232.239.133	\N	\N
28	6	6		ns0.evilcode.net	\N	\N
29	6	6		ns1.evilcode.net	\N	\N
30	7	1		72.232.239.133	\N	\N
31	7	1	*	72.232.239.133	\N	\N
32	7	6		ns0.evilcode.net	\N	\N
33	7	6		ns1.evilcode.net	\N	\N
34	8	1		72.232.239.133	\N	\N
35	8	1	*	72.232.239.133	\N	\N
36	8	6		ns0.evilcode.net	\N	\N
37	8	6		ns1.evilcode.net	\N	\N
38	9	1		72.232.239.133	\N	\N
39	9	1	*	72.232.239.133	\N	\N
40	9	6		ns0.evilcode.net	\N	\N
41	9	6		ns1.evilcode.net	\N	\N
42	10	1		72.232.239.133	\N	\N
43	10	1	*	72.232.239.133	\N	\N
44	10	6		ns0.evilcode.net	\N	\N
45	10	6		ns1.evilcode.net	\N	\N
48	11	1	fms01	72.232.239.130	\N	\N
49	11	1	fms02	72.232.228.26	\N	\N
50	11	1	media	72.232.228.26	\N	\N
51	11	6		ns0.evilcode.net	\N	\N
52	11	6		ns1.evilcode.net	\N	\N
53	11	5		smtp15.msoutlookonline.net	1	\N
54	12	1		72.232.239.133	\N	\N
55	12	1	*	72.232.239.133	\N	\N
58	11	1	mint	72.232.239.133	\N	\N
1	1	1		72.232.239.133	\N	\N
2	1	1	*	72.232.239.133	\N	\N
56	12	6		ns0.evilcode.net	\N	\N
57	12	6		ns1.evilcode.net	\N	\N
76	30	1		72.232.239.133	0	300
82	29	1		72.232.239.133	0	300
59	1	1	aurora	67.15.197.7	\N	\N
60	1	1	hawthorne	72.232.228.26	\N	\N
61	1	1	brio	209.40.201.62	\N	\N
62	1	1	catalyst	72.232.239.130	\N	\N
63	13	1		72.232.239.132	0	300
64	13	1	*	72.232.239.132	0	300
65	13	6		ns0.evilcode.net	0	300
66	13	6		ns1.evilcode.net	0	300
67	13	3	mail	mail.evilcode.net	0	300
68	13	5		mail.evilcode.net	0	300
69	1	1	svn	72.232.239.130	\N	\N
70	13	1	www	72.232.239.133	0	300
74	11	1	ecard	72.232.239.133	\N	300
75	11	1	ecards	72.232.239.133	\N	300
77	30	6		ns0.evilcode.net.	0	300
78	30	6		ns1.evilcode.net.	0	300
79	30	5		mail.infernalhosting.net.	0	300
80	30	3	mail	mail.infernalhosting.net.	0	300
81	30	3	www	randallcreasey.com.	0	300
83	29	5		mail.randallbattlesdirk.com.	0	300
46	11	1		72.232.239.133	\N	300
47	11	1	*	72.232.239.133	\N	300
84	29	3	www	randallbattlesdirk.com.	0	300
85	29	1	db	67.15.197.7	0	300
71	11	1	admin	72.232.239.133	\N	300
72	11	1	widgets	72.232.239.133	\N	300
73	13	1	flixn	72.232.239.133	\N	300
5	1	1	mail	72.232.239.131	\N	\N
86	29	3	mail	mail.infernalhosting.net.	0	300
87	28	6		ns0.evilcode.net.	0	300
88	28	6		ns1.evilcode.net.	0	300
89	28	5		mail.infernalhosting.net.	0	300
90	28	3	mail	mail.infernalhosting.net.	0	300
92	28	3	www	k-osh.com.	0	300
93	27	5		mail.infernalhosting.net.	0	300
94	27	3	mail	mail.infernalhosting.net.	0	300
95	27	3	www	durandall.org.	0	300
96	27	3	dev	durandall.org.	0	300
99	27	6		ns1.evilcode.net.	0	300
100	27	6		ns0.evilcode.net.	0	300
101	26	3	www	developink.myshopify.com.	0	300
91	28	1		72.232.239.133	0	300
97	27	1		72.232.239.133	0	300
98	27	1	mysql	72.232.239.133	0	300
102	26	5		mail.infernalhosting.net.	0	300
103	26	3	mail	mail.infernalhosting.net.	0	300
105	26	6		ns1.evilcode.net.	0	300
107	26	6		ns0.evilcode.net.	0	300
108	26	3	shop	developink.myshopify.com.	0	300
109	26	3	dev	developink.com.	0	300
110	26	1	sql	67.15.197.7	0	300
111	14	5		mail.kaneda.net.	0	300
112	14	3	stats	web01.infernalhosting.net.	0	300
113	14	3	mail	mail.infernalhosting.net.	0	300
114	14	3	ns	ns1.infernalhosting.net.	0	300
115	14	1		72.232.239.132	0	300
116	14	6		ns0.evilcode.net.	0	300
117	14	3	www	kaneda.net.	0	300
118	14	3	db	db01.infernalhosting.net.	0	300
119	14	3	xml	kaneda.net.	0	300
120	14	3	feed	kaneda.net.	0	300
121	25	5		mail.infernalhosting.net.	0	300
122	25	3	media	infernalhosting.net.	0	300
123	25	1	rails01	72.232.239.132	0	300
124	25	1	web01	72.232.239.133	0	300
125	25	1	db01	10.0.3.1	0	300
126	25	1	mdb01	10.0.0.2	0	300
127	25	1		72.232.239.132	0	300
131	25	3	irc	irc.evilcode.net.	0	300
134	25	3	ns	ns1.infernalhosting.net.	0	300
137	25	3	old	infernalhosting.net.	0	300
138	25	1	services.irc	70.168.96.168	0	300
139	25	1	sql	67.15.197.7	0	300
140	25	3	www	infernalhosting.net.	0	300
141	25	3	dev.admin	infernalhosting.net.	0	300
142	25	3	dev	rails01.infernalhosting.net.	0	300
143	25	3	cacti	web01.infernalhosting.net.	0	300
104	26	1	mysql	72.232.239.133	0	300
106	26	1		72.232.239.133	0	300
130	25	1	webmail	72.232.239.133	0	300
133	25	1	mysql	72.232.239.133	0	300
132	25	1	mail	72.232.239.131	0	300
144	25	5		mail.infernalhosting.net.	0	300
150	25	1		72.232.239.132	0	300
173	13	1	flixnsvn	72.232.239.132	\N	300
174	13	1	hacks	72.232.239.132	\N	300
175	25	1	ns0	72.232.239.131	0	300
135	25	1	ns1	72.232.228.26	0	300
128	25	6		ns0.infernalhosting.net	0	300
129	25	6		ns1.infernalhosting.net	0	300
\.


--
-- Data for Name: dns_zones; Type: TABLE DATA; Schema: public; Owner: evilserve
--

COPY dns_zones (id, origin, ns, mbox, serial, refresh, retry, expire, ttl) FROM stdin;
2	thesjg.com	ns.evilcode.net	dns.evilcode.net	6	10800	3600	604800	3600
3	thesjg.net	ns.evilcode.net	dns.evilcode.net	6	10800	3600	604800	3600
4	thesjg.org	ns.evilcode.net	dns.evilcode.net	6	10800	3600	604800	3600
12	ftmeaderemount.com	ns.evilcode.net	dns.evilcode.net	7	10800	3600	604800	3600
5	mindlessracing.com	ns.evilcode.net	dns.evilcode.net	6	10800	3600	604800	3600
6	mindlessracing.net	ns.evilcode.net	dns.evilcode.net	6	10800	3600	604800	3600
7	mindlessracing.org	ns.evilcode.net	dns.evilcode.net	6	10800	3600	604800	3600
8	bitbum.com	ns.evilcode.net	dns.evilcode.net	6	10800	3600	604800	3600
9	bitbum.net	ns.evilcode.net	dns.evilcode.net	6	10800	3600	604800	3600
10	bitbum.org	ns.evilcode.net	dns.evilcode.net	6	10800	3600	604800	3600
1	evilcode.net	ns.evilcode.net	dns.evilcode.net	23	10800	3600	604800	3600
13	evilprojects.net	ns.evilcode.net	dns.evilcode.net	13	300	300	1200	300
11	flixn.com	ns.evilcode.net	dns.evilcode.net	39	300	300	1200	300
30	randallcreasey.com	ns1.infernalhosting.net	dns.infernalhosting.net	21	10800	3600	604800	3600
29	randallbattlesdirk.com	ns1.infernalhosting.net	dns.infernalhosting.net	7	10800	3600	604800	3600
28	k-osh.com	ns1.infernalhosting.net	dns.infernalhosting.net	8	10800	3600	604800	3600
25	infernalhosting.net	ns1.infernalhosting.net	dns.infernalhosting.net	78	10800	3600	604800	3600
27	durandall.org	ns1.infernalhosting.net	dns.infernalhosting.net	11	10800	3600	604800	3600
26	developink.com	ns1.infernalhosting.net	dns.infernalhosting.net	13	10800	3600	604800	3600
14	kaneda.net	ns1.infernalhosting.net	dns.infernalhosting.net	11	10800	3600	604800	3600
\.


SET search_path = powerdns, pg_catalog;

--
-- Name: domains_name_key; Type: CONSTRAINT; Schema: powerdns; Owner: evilserve; Tablespace: 
--

ALTER TABLE ONLY domains
    ADD CONSTRAINT domains_name_key UNIQUE (name);


--
-- Name: domains_pkey; Type: CONSTRAINT; Schema: powerdns; Owner: evilserve; Tablespace: 
--

ALTER TABLE ONLY domains
    ADD CONSTRAINT domains_pkey PRIMARY KEY (id);


--
-- Name: records_pkey; Type: CONSTRAINT; Schema: powerdns; Owner: evilserve; Tablespace: 
--

ALTER TABLE ONLY records
    ADD CONSTRAINT records_pkey PRIMARY KEY (id);


SET search_path = public, pg_catalog;

--
-- Name: dns_resource_types_pkey; Type: CONSTRAINT; Schema: public; Owner: evilserve; Tablespace: 
--

ALTER TABLE ONLY dns_resource_types
    ADD CONSTRAINT dns_resource_types_pkey PRIMARY KEY (id);


--
-- Name: dns_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: evilserve; Tablespace: 
--

ALTER TABLE ONLY dns_resources
    ADD CONSTRAINT dns_resources_pkey PRIMARY KEY (id);


--
-- Name: dns_zones_origin_key; Type: CONSTRAINT; Schema: public; Owner: evilserve; Tablespace: 
--

ALTER TABLE ONLY dns_zones
    ADD CONSTRAINT dns_zones_origin_key UNIQUE (origin);


--
-- Name: dns_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: evilserve; Tablespace: 
--

ALTER TABLE ONLY dns_zones
    ADD CONSTRAINT dns_zones_pkey PRIMARY KEY (id);


SET search_path = powerdns, pg_catalog;

--
-- Name: records_domain_id_index; Type: INDEX; Schema: powerdns; Owner: evilserve; Tablespace: 
--

CREATE INDEX records_domain_id_index ON records USING btree (domain_id);


--
-- Name: records_name_index; Type: INDEX; Schema: powerdns; Owner: evilserve; Tablespace: 
--

CREATE INDEX records_name_index ON records USING btree (name);


--
-- Name: records_name_type_index; Type: INDEX; Schema: powerdns; Owner: evilserve; Tablespace: 
--

CREATE INDEX records_name_type_index ON records USING btree (name, type);


SET search_path = public, pg_catalog;

--
-- Name: dns_resources_increment_dns_zones_serial_trigger; Type: TRIGGER; Schema: public; Owner: evilserve
--

CREATE TRIGGER dns_resources_increment_dns_zones_serial_trigger
    AFTER INSERT OR DELETE OR UPDATE ON dns_resources
    FOR EACH ROW
    EXECUTE PROCEDURE dns_resources_increment_dns_zones_serial_func();


--
-- Name: dns_resources_powerdns_trigger; Type: TRIGGER; Schema: public; Owner: evilserve
--

CREATE TRIGGER dns_resources_powerdns_trigger
    AFTER INSERT OR DELETE OR UPDATE ON dns_resources
    FOR EACH ROW
    EXECUTE PROCEDURE dns_resources_powerdns_func();


--
-- Name: dns_zones_powerdns_trigger; Type: TRIGGER; Schema: public; Owner: evilserve
--

CREATE TRIGGER dns_zones_powerdns_trigger
    AFTER INSERT OR DELETE OR UPDATE ON dns_zones
    FOR EACH ROW
    EXECUTE PROCEDURE dns_zones_powerdns_func();


--
-- Name: dns_zones_update_increment_serial_trigger; Type: TRIGGER; Schema: public; Owner: evilserve
--

CREATE TRIGGER dns_zones_update_increment_serial_trigger
    BEFORE UPDATE ON dns_zones
    FOR EACH ROW
    EXECUTE PROCEDURE dns_zones_update_increment_serial_func();


SET search_path = powerdns, pg_catalog;

--
-- Name: records_domain_id_fkey; Type: FK CONSTRAINT; Schema: powerdns; Owner: evilserve
--

ALTER TABLE ONLY records
    ADD CONSTRAINT records_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE;


SET search_path = public, pg_catalog;

--
-- Name: dns_resources_dns_resource_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: evilserve
--

ALTER TABLE ONLY dns_resources
    ADD CONSTRAINT dns_resources_dns_resource_type_id_fkey FOREIGN KEY (dns_resource_type_id) REFERENCES dns_resource_types(id);


--
-- Name: dns_resources_dns_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: evilserve
--

ALTER TABLE ONLY dns_resources
    ADD CONSTRAINT dns_resources_dns_zone_id_fkey FOREIGN KEY (dns_zone_id) REFERENCES dns_zones(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: powerdns; Type: ACL; Schema: -; Owner: evilserve
--

REVOKE ALL ON SCHEMA powerdns FROM PUBLIC;
REVOKE ALL ON SCHEMA powerdns FROM evilserve;
GRANT ALL ON SCHEMA powerdns TO evilserve;
GRANT ALL ON SCHEMA powerdns TO powerdns;


--
-- Name: public; Type: ACL; Schema: -; Owner: pgsql
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM pgsql;
GRANT ALL ON SCHEMA public TO pgsql;
GRANT ALL ON SCHEMA public TO PUBLIC;


SET search_path = powerdns, pg_catalog;

--
-- Name: domains; Type: ACL; Schema: powerdns; Owner: evilserve
--

REVOKE ALL ON TABLE domains FROM PUBLIC;
REVOKE ALL ON TABLE domains FROM evilserve;
GRANT ALL ON TABLE domains TO evilserve;
GRANT ALL ON TABLE domains TO powerdns;


--
-- Name: records; Type: ACL; Schema: powerdns; Owner: evilserve
--

REVOKE ALL ON TABLE records FROM PUBLIC;
REVOKE ALL ON TABLE records FROM evilserve;
GRANT ALL ON TABLE records TO evilserve;
GRANT ALL ON TABLE records TO powerdns;


--
-- Name: records_id_seq; Type: ACL; Schema: powerdns; Owner: evilserve
--

REVOKE ALL ON SEQUENCE records_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE records_id_seq FROM evilserve;
GRANT ALL ON SEQUENCE records_id_seq TO evilserve;
GRANT ALL ON SEQUENCE records_id_seq TO powerdns;


--
-- PostgreSQL database dump complete
--

