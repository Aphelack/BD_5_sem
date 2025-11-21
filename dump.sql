--
-- PostgreSQL database dump
--

\restrict wyDpbHDegVe7aCXlB2C0vpoE5tnmnM8FY9DnzEKb4NGO9EQVtuMWzecHlfIvyoR

-- Dumped from database version 15.2
-- Dumped by pg_dump version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

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
-- Name: homeflip; Type: SCHEMA; Schema: -; Owner: user
--

CREATE SCHEMA homeflip;


ALTER SCHEMA homeflip OWNER TO "user";

--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: get_user_privileges(text); Type: FUNCTION; Schema: homeflip; Owner: user
--

CREATE FUNCTION homeflip.get_user_privileges(p_user_id text) RETURNS TABLE(privilege_name text, privilege_description text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT p.name, p.description
    FROM homeflip.users u
    JOIN homeflip.roles r ON u.role_id = r.id
    JOIN homeflip.role_privileges rp ON r.id = rp.role_id
    JOIN homeflip.privileges p ON rp.privilege_id = p.id
    WHERE u.id = p_user_id;
END;
$$;


ALTER FUNCTION homeflip.get_user_privileges(p_user_id text) OWNER TO "user";

--
-- Name: user_has_privilege(text, text); Type: FUNCTION; Schema: homeflip; Owner: user
--

CREATE FUNCTION homeflip.user_has_privilege(p_user_id text, p_privilege_name text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM homeflip.users u
        JOIN homeflip.roles r ON u.role_id = r.id
        JOIN homeflip.role_privileges rp ON r.id = rp.role_id
        JOIN homeflip.privileges p ON rp.privilege_id = p.id
        WHERE u.id = p_user_id AND p.name = p_privilege_name
    );
END;
$$;


ALTER FUNCTION homeflip.user_has_privilege(p_user_id text, p_privilege_name text) OWNER TO "user";

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: user
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO "user";

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accommodation_amenity; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.accommodation_amenity (
    accommodation_id uuid NOT NULL,
    amenity_id uuid NOT NULL
);


ALTER TABLE homeflip.accommodation_amenity OWNER TO "user";

--
-- Name: accommodation_booked_periods; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.accommodation_booked_periods (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    accommodation_id uuid NOT NULL,
    exchange_offer_id uuid NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL,
    is_valid_period boolean DEFAULT false,
    CONSTRAINT check_booked_period_valid CHECK ((end_date > start_date))
);


ALTER TABLE homeflip.accommodation_booked_periods OWNER TO "user";

--
-- Name: accommodation_details; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.accommodation_details (
    accommodation_id uuid NOT NULL,
    type_id uuid NOT NULL,
    floor integer,
    has_elevator boolean DEFAULT false,
    area_sqm integer,
    bedrooms integer,
    max_guests integer,
    pets_allowed boolean DEFAULT false,
    children_allowed boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_area_positive CHECK (((area_sqm IS NULL) OR (area_sqm > 0))),
    CONSTRAINT check_area_reasonable CHECK (((area_sqm IS NULL) OR (area_sqm <= 10000))),
    CONSTRAINT check_bedrooms_positive CHECK (((bedrooms IS NULL) OR (bedrooms >= 0))),
    CONSTRAINT check_floor_reasonable CHECK (((floor IS NULL) OR ((floor >= '-5'::integer) AND (floor <= 200)))),
    CONSTRAINT check_max_guests_positive CHECK (((max_guests IS NULL) OR (max_guests > 0)))
);


ALTER TABLE homeflip.accommodation_details OWNER TO "user";

--
-- Name: TABLE accommodation_details; Type: COMMENT; Schema: homeflip; Owner: user
--

COMMENT ON TABLE homeflip.accommodation_details IS 'Single source of truth for accommodation characteristics and details';


--
-- Name: accommodation_photos; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.accommodation_photos (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    accommodation_id uuid NOT NULL,
    url text NOT NULL,
    is_primary boolean DEFAULT false
);


ALTER TABLE homeflip.accommodation_photos OWNER TO "user";

--
-- Name: accommodation_posted_periods; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.accommodation_posted_periods (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    accommodation_id uuid NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL,
    CONSTRAINT check_posted_period_future CHECK ((start_date >= CURRENT_DATE)),
    CONSTRAINT check_posted_period_valid CHECK ((end_date > start_date))
);


ALTER TABLE homeflip.accommodation_posted_periods OWNER TO "user";

--
-- Name: accommodation_statuses; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.accommodation_statuses (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_status_code_length CHECK (((length(code) >= 2) AND (length(code) <= 20))),
    CONSTRAINT check_status_name_length CHECK (((length(name) >= 2) AND (length(name) <= 50)))
);


ALTER TABLE homeflip.accommodation_statuses OWNER TO "user";

--
-- Name: accommodation_types; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.accommodation_types (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_type_description_length CHECK (((description IS NULL) OR ((length(description) >= 5) AND (length(description) <= 500)))),
    CONSTRAINT check_type_name_length CHECK (((length(name) >= 2) AND (length(name) <= 50)))
);


ALTER TABLE homeflip.accommodation_types OWNER TO "user";

--
-- Name: accommodations; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.accommodations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    owner_id uuid NOT NULL,
    telegram text NOT NULL,
    description text NOT NULL,
    status_id uuid NOT NULL,
    address_id uuid NOT NULL,
    CONSTRAINT check_description_length CHECK (((length(description) >= 10) AND (length(description) <= 5000))),
    CONSTRAINT check_telegram_format CHECK ((telegram ~ '^@[a-zA-Z0-9_]{5,32}$'::text))
);


ALTER TABLE homeflip.accommodations OWNER TO "user";

--
-- Name: addresses; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.addresses (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    street_address text NOT NULL,
    postal_code text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    city_id uuid NOT NULL,
    CONSTRAINT check_postal_code_format CHECK (((postal_code IS NULL) OR ((length(postal_code) >= 3) AND (length(postal_code) <= 20)))),
    CONSTRAINT check_street_address_length CHECK (((length(street_address) >= 5) AND (length(street_address) <= 500)))
);


ALTER TABLE homeflip.addresses OWNER TO "user";

--
-- Name: TABLE addresses; Type: COMMENT; Schema: homeflip; Owner: user
--

COMMENT ON TABLE homeflip.addresses IS 'Unified address entity containing all address information for accommodations';


--
-- Name: COLUMN addresses.street_address; Type: COMMENT; Schema: homeflip; Owner: user
--

COMMENT ON COLUMN homeflip.addresses.street_address IS 'Complete street address including building number and street name';


--
-- Name: COLUMN addresses.postal_code; Type: COMMENT; Schema: homeflip; Owner: user
--

COMMENT ON COLUMN homeflip.addresses.postal_code IS 'Optional postal or ZIP code for additional location precision';


--
-- Name: amenities; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.amenities (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    short_name text NOT NULL,
    CONSTRAINT check_amenity_name_length CHECK (((length(short_name) >= 2) AND (length(short_name) <= 50)))
);


ALTER TABLE homeflip.amenities OWNER TO "user";

--
-- Name: cities; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.cities (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    country_id uuid NOT NULL,
    region text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_city_name_length CHECK (((length(name) >= 2) AND (length(name) <= 100))),
    CONSTRAINT check_region_length CHECK (((region IS NULL) OR ((length(region) >= 2) AND (length(region) <= 100))))
);


ALTER TABLE homeflip.cities OWNER TO "user";

--
-- Name: countries; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.countries (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    iso_code text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_country_name_length CHECK (((length(name) >= 2) AND (length(name) <= 100))),
    CONSTRAINT check_iso_code_format CHECK (((length(iso_code) = 2) AND (iso_code ~ '^[A-Z]{2}$'::text)))
);


ALTER TABLE homeflip.countries OWNER TO "user";

--
-- Name: exchange_offer_statuses; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.exchange_offer_statuses (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_offer_status_code_length CHECK (((length(code) >= 2) AND (length(code) <= 20))),
    CONSTRAINT check_offer_status_name_length CHECK (((length(name) >= 2) AND (length(name) <= 50)))
);


ALTER TABLE homeflip.exchange_offer_statuses OWNER TO "user";

--
-- Name: exchange_offers; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.exchange_offers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    target_accommodation_id uuid NOT NULL,
    from_user_id uuid NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL,
    status_id uuid NOT NULL,
    CONSTRAINT check_exchange_period_valid CHECK ((end_date > start_date))
);


ALTER TABLE homeflip.exchange_offers OWNER TO "user";

--
-- Name: privileges; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.privileges (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_privilege_description_length CHECK (((length(description) >= 5) AND (length(description) <= 500))),
    CONSTRAINT check_privilege_name_length CHECK (((length(name) >= 2) AND (length(name) <= 50)))
);


ALTER TABLE homeflip.privileges OWNER TO "user";

--
-- Name: reviews_on_accommodations; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.reviews_on_accommodations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    author_id uuid NOT NULL,
    accommodation_id uuid NOT NULL,
    comment text NOT NULL,
    rating integer NOT NULL,
    CONSTRAINT check_review_comment_length CHECK (((length(comment) >= 10) AND (length(comment) <= 2000))),
    CONSTRAINT reviews_on_accommodations_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE homeflip.reviews_on_accommodations OWNER TO "user";

--
-- Name: role_privileges; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.role_privileges (
    role_id uuid NOT NULL,
    privilege_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE homeflip.role_privileges OWNER TO "user";

--
-- Name: roles; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.roles (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_role_description_length CHECK (((length(description) >= 5) AND (length(description) <= 500))),
    CONSTRAINT check_role_name_length CHECK (((length(name) >= 2) AND (length(name) <= 50)))
);


ALTER TABLE homeflip.roles OWNER TO "user";

--
-- Name: users; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    yandex_id text NOT NULL,
    email text NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    phone_number text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    has_approved_accommodation boolean DEFAULT false,
    role_id uuid,
    CONSTRAINT check_email_format CHECK ((email ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'::text)),
    CONSTRAINT check_first_name_length CHECK (((length(first_name) >= 2) AND (length(first_name) <= 50))),
    CONSTRAINT check_last_name_length CHECK (((length(last_name) >= 2) AND (length(last_name) <= 50))),
    CONSTRAINT check_phone_length CHECK (((length(phone_number) >= 7) AND (length(phone_number) <= 20)))
);


ALTER TABLE homeflip.users OWNER TO "user";

--
-- Name: user_privileges; Type: VIEW; Schema: homeflip; Owner: user
--

CREATE VIEW homeflip.user_privileges AS
 SELECT u.id AS user_id,
    u.email,
    r.name AS role_name,
    p.name AS privilege_name,
    p.description AS privilege_description
   FROM (((homeflip.users u
     LEFT JOIN homeflip.roles r ON ((u.role_id = r.id)))
     LEFT JOIN homeflip.role_privileges rp ON ((r.id = rp.role_id)))
     LEFT JOIN homeflip.privileges p ON ((rp.privilege_id = p.id)));


ALTER VIEW homeflip.user_privileges OWNER TO "user";

--
-- Name: whitelist_emails; Type: TABLE; Schema: homeflip; Owner: user
--

CREATE TABLE homeflip.whitelist_emails (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email text NOT NULL,
    CONSTRAINT check_whitelist_email_format CHECK ((email ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'::text))
);


ALTER TABLE homeflip.whitelist_emails OWNER TO "user";

--
-- Name: u_clients; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.u_clients (
    hostname text NOT NULL,
    updated timestamp with time zone NOT NULL,
    max_connections integer NOT NULL,
    cur_user text
);


ALTER TABLE public.u_clients OWNER TO "user";

--
-- Name: accommodation_amenity accommodation_amenity_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_amenity
    ADD CONSTRAINT accommodation_amenity_pkey PRIMARY KEY (accommodation_id, amenity_id);


--
-- Name: accommodation_booked_periods accommodation_booked_periods_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_booked_periods
    ADD CONSTRAINT accommodation_booked_periods_pkey PRIMARY KEY (id);


--
-- Name: accommodation_details accommodation_details_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_details
    ADD CONSTRAINT accommodation_details_pkey PRIMARY KEY (accommodation_id);


--
-- Name: accommodation_photos accommodation_photos_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_photos
    ADD CONSTRAINT accommodation_photos_pkey PRIMARY KEY (id);


--
-- Name: accommodation_posted_periods accommodation_posted_periods_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_posted_periods
    ADD CONSTRAINT accommodation_posted_periods_pkey PRIMARY KEY (id);


--
-- Name: accommodation_statuses accommodation_statuses_code_key; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_statuses
    ADD CONSTRAINT accommodation_statuses_code_key UNIQUE (code);


--
-- Name: accommodation_statuses accommodation_statuses_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_statuses
    ADD CONSTRAINT accommodation_statuses_pkey PRIMARY KEY (id);


--
-- Name: accommodation_types accommodation_types_name_key; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_types
    ADD CONSTRAINT accommodation_types_name_key UNIQUE (name);


--
-- Name: accommodation_types accommodation_types_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_types
    ADD CONSTRAINT accommodation_types_pkey PRIMARY KEY (id);


--
-- Name: accommodations accommodations_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodations
    ADD CONSTRAINT accommodations_pkey PRIMARY KEY (id);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: amenities amenities_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.amenities
    ADD CONSTRAINT amenities_pkey PRIMARY KEY (id);


--
-- Name: cities cities_name_country_id_key; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.cities
    ADD CONSTRAINT cities_name_country_id_key UNIQUE (name, country_id);


--
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- Name: countries countries_iso_code_key; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.countries
    ADD CONSTRAINT countries_iso_code_key UNIQUE (iso_code);


--
-- Name: countries countries_name_key; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.countries
    ADD CONSTRAINT countries_name_key UNIQUE (name);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: exchange_offer_statuses exchange_offer_statuses_code_key; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.exchange_offer_statuses
    ADD CONSTRAINT exchange_offer_statuses_code_key UNIQUE (code);


--
-- Name: exchange_offer_statuses exchange_offer_statuses_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.exchange_offer_statuses
    ADD CONSTRAINT exchange_offer_statuses_pkey PRIMARY KEY (id);


--
-- Name: exchange_offers exchange_offers_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.exchange_offers
    ADD CONSTRAINT exchange_offers_pkey PRIMARY KEY (id);


--
-- Name: accommodation_booked_periods prevent_overlapping_booked_periods; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_booked_periods
    ADD CONSTRAINT prevent_overlapping_booked_periods EXCLUDE USING gist (accommodation_id WITH =, tstzrange(start_date, end_date, '[]'::text) WITH &&);


--
-- Name: CONSTRAINT prevent_overlapping_booked_periods ON accommodation_booked_periods; Type: COMMENT; Schema: homeflip; Owner: user
--

COMMENT ON CONSTRAINT prevent_overlapping_booked_periods ON homeflip.accommodation_booked_periods IS 'Prevents booking the same accommodation for overlapping time periods';


--
-- Name: accommodation_posted_periods prevent_overlapping_posted_periods; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_posted_periods
    ADD CONSTRAINT prevent_overlapping_posted_periods EXCLUDE USING gist (accommodation_id WITH =, tstzrange(start_date, end_date, '[]'::text) WITH &&);


--
-- Name: CONSTRAINT prevent_overlapping_posted_periods ON accommodation_posted_periods; Type: COMMENT; Schema: homeflip; Owner: user
--

COMMENT ON CONSTRAINT prevent_overlapping_posted_periods ON homeflip.accommodation_posted_periods IS 'Prevents posting the same accommodation for overlapping time periods';


--
-- Name: privileges privileges_name_key; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.privileges
    ADD CONSTRAINT privileges_name_key UNIQUE (name);


--
-- Name: privileges privileges_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.privileges
    ADD CONSTRAINT privileges_pkey PRIMARY KEY (id);


--
-- Name: reviews_on_accommodations reviews_on_accommodations_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.reviews_on_accommodations
    ADD CONSTRAINT reviews_on_accommodations_pkey PRIMARY KEY (id);


--
-- Name: role_privileges role_privileges_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.role_privileges
    ADD CONSTRAINT role_privileges_pkey PRIMARY KEY (role_id, privilege_id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_yandex_id_key; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.users
    ADD CONSTRAINT users_yandex_id_key UNIQUE (yandex_id);


--
-- Name: whitelist_emails whitelist_emails_email_key; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.whitelist_emails
    ADD CONSTRAINT whitelist_emails_email_key UNIQUE (email);


--
-- Name: whitelist_emails whitelist_emails_pkey; Type: CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.whitelist_emails
    ADD CONSTRAINT whitelist_emails_pkey PRIMARY KEY (id);


--
-- Name: u_clients u_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.u_clients
    ADD CONSTRAINT u_clients_pkey PRIMARY KEY (hostname);


--
-- Name: idx_accommodation_amenity_amenity_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_accommodation_amenity_amenity_id ON homeflip.accommodation_amenity USING btree (amenity_id);


--
-- Name: idx_accommodation_booked_periods_accommodation_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_accommodation_booked_periods_accommodation_id ON homeflip.accommodation_booked_periods USING btree (accommodation_id);


--
-- Name: idx_accommodation_booked_periods_exchange_offer_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_accommodation_booked_periods_exchange_offer_id ON homeflip.accommodation_booked_periods USING btree (exchange_offer_id);


--
-- Name: idx_accommodation_details_type_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_accommodation_details_type_id ON homeflip.accommodation_details USING btree (type_id);


--
-- Name: idx_accommodation_photos_accommodation_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_accommodation_photos_accommodation_id ON homeflip.accommodation_photos USING btree (accommodation_id);


--
-- Name: idx_accommodation_posted_periods_accommodation_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_accommodation_posted_periods_accommodation_id ON homeflip.accommodation_posted_periods USING btree (accommodation_id);


--
-- Name: idx_accommodation_statuses_code; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_accommodation_statuses_code ON homeflip.accommodation_statuses USING btree (code);


--
-- Name: idx_accommodation_types_name; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_accommodation_types_name ON homeflip.accommodation_types USING btree (name);


--
-- Name: idx_accommodations_address_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_accommodations_address_id ON homeflip.accommodations USING btree (address_id);


--
-- Name: idx_accommodations_owner_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_accommodations_owner_id ON homeflip.accommodations USING btree (owner_id);


--
-- Name: idx_accommodations_status_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_accommodations_status_id ON homeflip.accommodations USING btree (status_id);


--
-- Name: idx_addresses_city_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_addresses_city_id ON homeflip.addresses USING btree (city_id);


--
-- Name: idx_booked_periods_dates; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_booked_periods_dates ON homeflip.accommodation_booked_periods USING btree (start_date, end_date);


--
-- Name: idx_cities_country_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_cities_country_id ON homeflip.cities USING btree (country_id);


--
-- Name: idx_cities_name; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_cities_name ON homeflip.cities USING btree (name);


--
-- Name: idx_cities_name_country; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_cities_name_country ON homeflip.cities USING btree (name, country_id);


--
-- Name: idx_countries_iso_code; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_countries_iso_code ON homeflip.countries USING btree (iso_code);


--
-- Name: idx_countries_name; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_countries_name ON homeflip.countries USING btree (name);


--
-- Name: idx_exchange_offer_statuses_code; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_exchange_offer_statuses_code ON homeflip.exchange_offer_statuses USING btree (code);


--
-- Name: idx_exchange_offers_from_user_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_exchange_offers_from_user_id ON homeflip.exchange_offers USING btree (from_user_id);


--
-- Name: idx_exchange_offers_status_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_exchange_offers_status_id ON homeflip.exchange_offers USING btree (status_id);


--
-- Name: idx_exchange_offers_target_accommodation_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_exchange_offers_target_accommodation_id ON homeflip.exchange_offers USING btree (target_accommodation_id);


--
-- Name: idx_posted_periods_dates; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_posted_periods_dates ON homeflip.accommodation_posted_periods USING btree (start_date, end_date);


--
-- Name: idx_reviews_accommodation_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_reviews_accommodation_id ON homeflip.reviews_on_accommodations USING btree (accommodation_id);


--
-- Name: idx_reviews_author_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_reviews_author_id ON homeflip.reviews_on_accommodations USING btree (author_id);


--
-- Name: idx_role_privileges_privilege_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_role_privileges_privilege_id ON homeflip.role_privileges USING btree (privilege_id);


--
-- Name: idx_users_role_id; Type: INDEX; Schema: homeflip; Owner: user
--

CREATE INDEX idx_users_role_id ON homeflip.users USING btree (role_id);


--
-- Name: accommodation_details update_accommodation_details_updated_at; Type: TRIGGER; Schema: homeflip; Owner: user
--

CREATE TRIGGER update_accommodation_details_updated_at BEFORE UPDATE ON homeflip.accommodation_details FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: addresses update_addresses_updated_at; Type: TRIGGER; Schema: homeflip; Owner: user
--

CREATE TRIGGER update_addresses_updated_at BEFORE UPDATE ON homeflip.addresses FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: accommodation_amenity accommodation_amenity_accommodation_id_fkey; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_amenity
    ADD CONSTRAINT accommodation_amenity_accommodation_id_fkey FOREIGN KEY (accommodation_id) REFERENCES homeflip.accommodations(id);


--
-- Name: accommodation_amenity accommodation_amenity_amenity_id_fkey; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_amenity
    ADD CONSTRAINT accommodation_amenity_amenity_id_fkey FOREIGN KEY (amenity_id) REFERENCES homeflip.amenities(id);


--
-- Name: accommodation_booked_periods accommodation_booked_periods_accommodation_id_fkey; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_booked_periods
    ADD CONSTRAINT accommodation_booked_periods_accommodation_id_fkey FOREIGN KEY (accommodation_id) REFERENCES homeflip.accommodations(id);


--
-- Name: accommodation_booked_periods accommodation_booked_periods_exchange_offer_id_fkey; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_booked_periods
    ADD CONSTRAINT accommodation_booked_periods_exchange_offer_id_fkey FOREIGN KEY (exchange_offer_id) REFERENCES homeflip.exchange_offers(id);


--
-- Name: accommodation_details accommodation_details_accommodation_id_fkey; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_details
    ADD CONSTRAINT accommodation_details_accommodation_id_fkey FOREIGN KEY (accommodation_id) REFERENCES homeflip.accommodations(id) ON DELETE CASCADE;


--
-- Name: accommodation_details accommodation_details_type_id_fkey; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_details
    ADD CONSTRAINT accommodation_details_type_id_fkey FOREIGN KEY (type_id) REFERENCES homeflip.accommodation_types(id);


--
-- Name: accommodation_photos accommodation_photos_accommodation_id_fkey; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_photos
    ADD CONSTRAINT accommodation_photos_accommodation_id_fkey FOREIGN KEY (accommodation_id) REFERENCES homeflip.accommodations(id);


--
-- Name: accommodation_posted_periods accommodation_posted_periods_accommodation_id_fkey; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodation_posted_periods
    ADD CONSTRAINT accommodation_posted_periods_accommodation_id_fkey FOREIGN KEY (accommodation_id) REFERENCES homeflip.accommodations(id);


--
-- Name: accommodations accommodations_owner_id_fkey; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodations
    ADD CONSTRAINT accommodations_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES homeflip.users(id);


--
-- Name: addresses addresses_city_id_fkey; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.addresses
    ADD CONSTRAINT addresses_city_id_fkey FOREIGN KEY (city_id) REFERENCES homeflip.cities(id);


--
-- Name: cities cities_country_id_fkey; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.cities
    ADD CONSTRAINT cities_country_id_fkey FOREIGN KEY (country_id) REFERENCES homeflip.countries(id);


--
-- Name: exchange_offers exchange_offers_from_user_id_fkey; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.exchange_offers
    ADD CONSTRAINT exchange_offers_from_user_id_fkey FOREIGN KEY (from_user_id) REFERENCES homeflip.users(id);


--
-- Name: exchange_offers exchange_offers_target_accommodation_id_fkey; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.exchange_offers
    ADD CONSTRAINT exchange_offers_target_accommodation_id_fkey FOREIGN KEY (target_accommodation_id) REFERENCES homeflip.accommodations(id);


--
-- Name: accommodations fk_accommodations_address; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodations
    ADD CONSTRAINT fk_accommodations_address FOREIGN KEY (address_id) REFERENCES homeflip.addresses(id);


--
-- Name: accommodations fk_accommodations_status; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.accommodations
    ADD CONSTRAINT fk_accommodations_status FOREIGN KEY (status_id) REFERENCES homeflip.accommodation_statuses(id);


--
-- Name: exchange_offers fk_exchange_offers_status; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.exchange_offers
    ADD CONSTRAINT fk_exchange_offers_status FOREIGN KEY (status_id) REFERENCES homeflip.exchange_offer_statuses(id);


--
-- Name: users fk_user_role; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.users
    ADD CONSTRAINT fk_user_role FOREIGN KEY (role_id) REFERENCES homeflip.roles(id);


--
-- Name: reviews_on_accommodations reviews_on_accommodations_accommodation_id_fkey; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.reviews_on_accommodations
    ADD CONSTRAINT reviews_on_accommodations_accommodation_id_fkey FOREIGN KEY (accommodation_id) REFERENCES homeflip.accommodations(id);


--
-- Name: reviews_on_accommodations reviews_on_accommodations_author_id_fkey; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.reviews_on_accommodations
    ADD CONSTRAINT reviews_on_accommodations_author_id_fkey FOREIGN KEY (author_id) REFERENCES homeflip.users(id);


--
-- Name: role_privileges role_privileges_privilege_id_fkey; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.role_privileges
    ADD CONSTRAINT role_privileges_privilege_id_fkey FOREIGN KEY (privilege_id) REFERENCES homeflip.privileges(id) ON DELETE CASCADE;


--
-- Name: role_privileges role_privileges_role_id_fkey; Type: FK CONSTRAINT; Schema: homeflip; Owner: user
--

ALTER TABLE ONLY homeflip.role_privileges
    ADD CONSTRAINT role_privileges_role_id_fkey FOREIGN KEY (role_id) REFERENCES homeflip.roles(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict wyDpbHDegVe7aCXlB2C0vpoE5tnmnM8FY9DnzEKb4NGO9EQVtuMWzecHlfIvyoR
