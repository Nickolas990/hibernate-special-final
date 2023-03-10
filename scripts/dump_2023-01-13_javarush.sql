--
-- PostgreSQL database dump
--

-- Dumped from database version 15.0 (Debian 15.0-1.pgdg110+1)
-- Dumped by pg_dump version 15.0 (Debian 15.0-1.pgdg110+1)

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

ALTER TABLE ONLY public.user_notepad DROP CONSTRAINT user_notepad_user_id_fk;
ALTER TABLE ONLY public.user_notepad DROP CONSTRAINT user_notepad_notepad_id_fk;
ALTER TABLE ONLY public.team_user DROP CONSTRAINT user__fk;
ALTER TABLE ONLY public.team_user DROP CONSTRAINT team_user_team_id_fk;
ALTER TABLE ONLY public.post DROP CONSTRAINT post_post_id_fk;
ALTER TABLE ONLY public.post DROP CONSTRAINT post_note_id_fk2;
ALTER TABLE ONLY public.post DROP CONSTRAINT post_note_id_fk;
ALTER TABLE ONLY public.note DROP CONSTRAINT note_notepad_id_fk;
DROP TRIGGER sync_lastupdate ON public.note;
DROP TRIGGER filter_content ON public.post;
DROP TRIGGER encrypt_insert ON public."user";
DROP TRIGGER delete_users_noutepads ON public.user_notepad;
DROP TRIGGER author_history ON public.user_notepad;
DROP TRIGGER action_log ON public.post;
DROP TRIGGER action_log ON public.note;
ALTER TABLE ONLY public."user" DROP CONSTRAINT user_pk2;
ALTER TABLE ONLY public."user" DROP CONSTRAINT user_pk;
ALTER TABLE ONLY public.user_notepad DROP CONSTRAINT user_notepad_pk;
ALTER TABLE ONLY public.team_user DROP CONSTRAINT team_user_pk;
ALTER TABLE ONLY public.post DROP CONSTRAINT post_pk2;
ALTER TABLE ONLY public.post DROP CONSTRAINT post_pk;
ALTER TABLE ONLY public.notepad DROP CONSTRAINT notepad_pk;
ALTER TABLE ONLY public.note DROP CONSTRAINT note_pk;
ALTER TABLE ONLY public.log_table DROP CONSTRAINT log_table_pk;
ALTER TABLE ONLY public.log_author DROP CONSTRAINT log_author_pk;
ALTER TABLE ONLY public.team DROP CONSTRAINT "Team_pk2";
ALTER TABLE ONLY public.team DROP CONSTRAINT "Team_pk";
ALTER TABLE public.note ALTER COLUMN id DROP DEFAULT;
DROP TABLE public.user_notepad;
DROP TABLE public."user";
DROP TABLE public.team_user;
DROP TABLE public.post;
DROP TABLE public.notepad;
DROP SEQUENCE public.note_id_seq;
DROP TABLE public.note;
DROP TABLE public.log_table;
DROP TABLE public.log_author;
DROP TABLE public.team;
DROP FUNCTION public.sync_lastupdate();
DROP FUNCTION public.log_author_changing();
DROP FUNCTION public.log_actions();
DROP FUNCTION public.hash_update_tg();
DROP FUNCTION public.encrypt_password();
DROP FUNCTION public.delete_notepad();
DROP FUNCTION public.content_filter();
DROP TYPE public.type_of_post;
DROP TYPE public.program_language;
DROP TYPE public.cover_color;
DROP EXTENSION pgcrypto;
--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: cover_color; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cover_color AS ENUM (
    'black',
    'white',
    'blue',
    'red',
    'green'
);


ALTER TYPE public.cover_color OWNER TO postgres;

--
-- Name: program_language; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.program_language AS ENUM (
    'SQL',
    'Java',
    'C++',
    'Shell'
);


ALTER TYPE public.program_language OWNER TO postgres;

--
-- Name: type_of_post; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.type_of_post AS ENUM (
    'Text',
    'Code',
    'Title',
    'Quote',
    'File',
    'Picture',
    'YouTUBE Video',
    'Note'
);


ALTER TYPE public.type_of_post OWNER TO postgres;

--
-- Name: content_filter(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.content_filter() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    exp_note_id integer;


BEGIN
    IF tg_op = 'INSERT' OR tg_op = 'UPDATE' THEN
        IF NEW.type IN ('Text', 'Title', 'Quote') AND NEW.content IS NULL THEN
            RAISE EXCEPTION 'Content can not be NULL for this type of post';
        end if;
        IF NEW.type IN ('Code') AND NEW.programing_language IS NULL THEN
            RAISE EXCEPTION 'Program language can not be null for Code type';
        ELSEIF NEW.type IN ('File', 'Picture', 'YouTUBE Video', 'Note') AND NEW.link IS NULL THEN
            RAISE EXCEPTION 'Reference can not be NULL for this type of post';
        ELSEIF NEW.type IN ('Note') THEN
            IF new.note_id IS NULL THEN
                RAISE EXCEPTION 'For this type of post note_id can not be null';
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.content_filter() OWNER TO postgres;

--
-- Name: delete_notepad(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_notepad() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

    BEGIN

        DELETE from notepad where id = OLD.notepad_id;

    end;

$$;


ALTER FUNCTION public.delete_notepad() OWNER TO postgres;

--
-- Name: encrypt_password(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.encrypt_password() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

 NEW.password := crypt(NEW.password, 'sha1');  -- or some other function?

 RETURN NEW;

END

$$;


ALTER FUNCTION public.encrypt_password() OWNER TO postgres;

--
-- Name: hash_update_tg(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.hash_update_tg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

IF tg_op = 'INSERT' OR tg_op = 'UPDATE' THEN

NEW.password = digest(NEW.password, 'sha1');

RETURN NEW;

END IF;

END;

$$;


ALTER FUNCTION public.hash_update_tg() OWNER TO postgres;

--
-- Name: log_actions(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_actions() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        INSERT INTO log_table (action, target, time_of_changes) VALUES (TG_OP, tg_table_name, current_timestamp);
    end;
    $$;


ALTER FUNCTION public.log_actions() OWNER TO postgres;

--
-- Name: log_author_changing(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_author_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

    BEGIN

        INSERT INTO log_author (action, target, time_of_changes) VALUES (TG_OP, tg_table_name);

    end;

    $$;


ALTER FUNCTION public.log_author_changing() OWNER TO postgres;

--
-- Name: sync_lastupdate(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sync_lastupdate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    IF tg_op = 'UPDATE' THEN

    NEW.last_update = NOW();

    RETURN NEW;

    END IF;

END;

$$;


ALTER FUNCTION public.sync_lastupdate() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team (
    id integer NOT NULL,
    team_name character varying(20) NOT NULL
);


ALTER TABLE public.team OWNER TO postgres;

--
-- Name: Team_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.team ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Team_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: log_author; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log_author (
    id integer NOT NULL,
    "user" character varying(50) DEFAULT CURRENT_USER NOT NULL,
    action character varying(10) NOT NULL,
    target character varying(50),
    time_of_changes timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.log_author OWNER TO postgres;

--
-- Name: log_author_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.log_author ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.log_author_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: log_table; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log_table (
    id integer NOT NULL,
    "user" character varying(255) DEFAULT CURRENT_USER NOT NULL,
    action character varying(10) NOT NULL,
    target character varying(255),
    time_of_changes timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.log_table OWNER TO postgres;

--
-- Name: log_table_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.log_table ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.log_table_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: note; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.note (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    creation_date date DEFAULT now() NOT NULL,
    last_update date,
    notepad_id integer
);


ALTER TABLE public.note OWNER TO postgres;

--
-- Name: note_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.note_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.note_id_seq OWNER TO postgres;

--
-- Name: note_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.note_id_seq OWNED BY public.note.id;


--
-- Name: notepad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notepad (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    creation_date date DEFAULT CURRENT_DATE,
    cover public.cover_color DEFAULT 'black'::public.cover_color,
    CONSTRAINT date_check CHECK (((creation_date = CURRENT_DATE) OR (creation_date < CURRENT_DATE)))
);


ALTER TABLE public.notepad OWNER TO postgres;

--
-- Name: post; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post (
    id integer NOT NULL,
    type public.type_of_post NOT NULL,
    content text,
    programing_language public.program_language,
    link character varying(255),
    order_number integer,
    note_id integer NOT NULL,
    post_id integer,
    reference_note integer,
    CONSTRAINT check_url CHECK (((link)::text ~ 'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,255}\.[a-z]{2,9}\y([-a-zA-Z0-9@:%_\+.~#?&//=]*)$'::text)),
    CONSTRAINT order_check CHECK ((order_number > 0))
);


ALTER TABLE public.post OWNER TO postgres;

--
-- Name: post_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.post ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.post_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: team_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team_user (
    team_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.team_user OWNER TO postgres;

--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    id integer NOT NULL,
    name character varying(15) NOT NULL,
    surname character varying(30) NOT NULL,
    email character varying(50) NOT NULL,
    date_of_birth date NOT NULL,
    password text NOT NULL,
    CONSTRAINT correct_age CHECK ((date_of_birth < (CURRENT_DATE - '16 years'::interval year))),
    CONSTRAINT correct_email CHECK (((email)::text ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$'::text))
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- Name: COLUMN "user".date_of_birth; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."user".date_of_birth IS 'Users under 16 years old are not allowed';


--
-- Name: COLUMN "user".password; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."user".password IS 'encrypted password';


--
-- Name: CONSTRAINT correct_age ON "user"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON CONSTRAINT correct_age ON public."user" IS 'Users under 16 years old are not allowed';


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."user" ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_notepad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_notepad (
    user_id integer NOT NULL,
    notepad_id integer NOT NULL
);


ALTER TABLE public.user_notepad OWNER TO postgres;

--
-- Name: note id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.note ALTER COLUMN id SET DEFAULT nextval('public.note_id_seq'::regclass);


--
-- Data for Name: log_author; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log_author (id, "user", action, target, time_of_changes) FROM stdin;
\.


--
-- Data for Name: log_table; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log_table (id, "user", action, target, time_of_changes) FROM stdin;
\.


--
-- Data for Name: note; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.note (id, title, creation_date, last_update, notepad_id) FROM stdin;
\.


--
-- Data for Name: notepad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notepad (id, title, creation_date, cover) FROM stdin;
\.


--
-- Data for Name: post; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post (id, type, content, programing_language, link, order_number, note_id, post_id, reference_note) FROM stdin;
\.


--
-- Data for Name: team; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.team (id, team_name) FROM stdin;
1	Antares
\.


--
-- Data for Name: team_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.team_user (team_id, user_id) FROM stdin;
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (id, name, surname, email, date_of_birth, password) FROM stdin;
\.


--
-- Data for Name: user_notepad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_notepad (user_id, notepad_id) FROM stdin;
\.


--
-- Name: Team_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Team_id_seq"', 1, true);


--
-- Name: log_author_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_author_id_seq', 1, false);


--
-- Name: log_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_table_id_seq', 1, false);


--
-- Name: note_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.note_id_seq', 1, true);


--
-- Name: post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.post_id_seq', 6, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_id_seq', 6, true);


--
-- Name: team Team_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT "Team_pk" PRIMARY KEY (id);


--
-- Name: team Team_pk2; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT "Team_pk2" UNIQUE (team_name);


--
-- Name: log_author log_author_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_author
    ADD CONSTRAINT log_author_pk PRIMARY KEY (id);


--
-- Name: log_table log_table_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_table
    ADD CONSTRAINT log_table_pk PRIMARY KEY (id);


--
-- Name: note note_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.note
    ADD CONSTRAINT note_pk PRIMARY KEY (id);


--
-- Name: notepad notepad_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notepad
    ADD CONSTRAINT notepad_pk PRIMARY KEY (id);


--
-- Name: post post_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_pk PRIMARY KEY (id);


--
-- Name: post post_pk2; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_pk2 UNIQUE (note_id, order_number);


--
-- Name: team_user team_user_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_user
    ADD CONSTRAINT team_user_pk PRIMARY KEY (team_id, user_id);


--
-- Name: user_notepad user_notepad_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_notepad
    ADD CONSTRAINT user_notepad_pk PRIMARY KEY (user_id, notepad_id);


--
-- Name: user user_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pk PRIMARY KEY (id);


--
-- Name: user user_pk2; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pk2 UNIQUE (email);


--
-- Name: note action_log; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER action_log AFTER INSERT OR DELETE OR UPDATE ON public.note FOR EACH ROW EXECUTE FUNCTION public.log_actions();


--
-- Name: post action_log; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER action_log AFTER INSERT OR DELETE OR UPDATE ON public.post FOR EACH ROW EXECUTE FUNCTION public.log_actions();


--
-- Name: user_notepad author_history; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER author_history AFTER INSERT OR DELETE OR UPDATE ON public.user_notepad FOR EACH ROW EXECUTE FUNCTION public.log_author_changing();


--
-- Name: user_notepad delete_users_noutepads; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER delete_users_noutepads BEFORE DELETE ON public.user_notepad FOR EACH ROW EXECUTE FUNCTION public.delete_notepad();


--
-- Name: user encrypt_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER encrypt_insert BEFORE INSERT OR UPDATE ON public."user" FOR EACH ROW EXECUTE FUNCTION public.hash_update_tg();


--
-- Name: post filter_content; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER filter_content BEFORE INSERT OR UPDATE ON public.post FOR EACH ROW EXECUTE FUNCTION public.content_filter();


--
-- Name: note sync_lastupdate; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER sync_lastupdate BEFORE UPDATE ON public.note FOR EACH ROW EXECUTE FUNCTION public.sync_lastupdate();


--
-- Name: note note_notepad_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.note
    ADD CONSTRAINT note_notepad_id_fk FOREIGN KEY (notepad_id) REFERENCES public.notepad(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post post_note_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_note_id_fk FOREIGN KEY (note_id) REFERENCES public.note(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post post_note_id_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_note_id_fk2 FOREIGN KEY (reference_note) REFERENCES public.note(id);


--
-- Name: post post_post_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_post_id_fk FOREIGN KEY (post_id) REFERENCES public.post(id);


--
-- Name: team_user team_user_team_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_user
    ADD CONSTRAINT team_user_team_id_fk FOREIGN KEY (team_id) REFERENCES public.team(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: team_user user__fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_user
    ADD CONSTRAINT user__fk FOREIGN KEY (user_id) REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_notepad user_notepad_notepad_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_notepad
    ADD CONSTRAINT user_notepad_notepad_id_fk FOREIGN KEY (notepad_id) REFERENCES public.notepad(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: user_notepad user_notepad_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_notepad
    ADD CONSTRAINT user_notepad_user_id_fk FOREIGN KEY (user_id) REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

