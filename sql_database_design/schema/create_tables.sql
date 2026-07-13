-- This script create the structure for the database in postgreSQL.
BEGIN;


CREATE TABLE IF NOT EXISTS public.sales_transaction
(
    transaction_id bigint NOT NULL,
    transaction_date date NOT NULL,
    transaction_time time without time zone NOT NULL,
    outlet_id integer,
    staff_id integer,
    customer_id integer,
    PRIMARY KEY (transaction_id)
);

CREATE TABLE IF NOT EXISTS public.product
(
    product_id integer NOT NULL,
    product_name character varying(50) NOT NULL,
    description text,
    price numeric(10, 2) NOT NULL,
    product_type_id integer,
    PRIMARY KEY (product_id)
);

CREATE TABLE IF NOT EXISTS public.customer
(
    customer_id integer NOT NULL,
    customer_name character varying(30) NOT NULL,
    customer_email character varying(50) NOT NULL,
    customer_since date,
    card_number character varying(25),
    birthdate date NOT NULL,
    gender character(1),
    PRIMARY KEY (customer_id)
);

CREATE TABLE IF NOT EXISTS public.sales_outlet
(
    outlet_id integer NOT NULL,
    outlet_type character varying(30) NOT NULL,
    address text NOT NULL,
    city character varying(30) NOT NULL,
    telephone character varying(20) NOT NULL,
    postal_code character varying(10) NOT NULL,
    manager character varying(30) NOT NULL,
    PRIMARY KEY (outlet_id)
);

CREATE TABLE IF NOT EXISTS public.staff
(
    staff_id integer NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    "position" character varying(40) NOT NULL,
    start_date date NOT NULL,
    location character varying(3) NOT NULL DEFAULT 'HQ',
    PRIMARY KEY (staff_id)
);

CREATE TABLE IF NOT EXISTS public.sales_detail
(
    sales_details_id bigint NOT NULL,
    transaction_id bigint NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL,
    price numeric(10, 2) NOT NULL,
    PRIMARY KEY (sales_details_id)
);

CREATE TABLE IF NOT EXISTS public.product_type
(
    product_type_id integer NOT NULL,
    product_type character varying(50) NOT NULL,
    product_category character varying(50),
    PRIMARY KEY (product_type_id)
);

ALTER TABLE IF EXISTS public.sales_transaction
    ADD FOREIGN KEY (customer_id)
    REFERENCES public.customer (customer_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.sales_transaction
    ADD FOREIGN KEY (staff_id)
    REFERENCES public.staff (staff_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.sales_transaction
    ADD FOREIGN KEY (outlet_id)
    REFERENCES public.sales_outlet (outlet_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.product
    ADD FOREIGN KEY (product_type_id)
    REFERENCES public.product_type (product_type_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.sales_detail
    ADD FOREIGN KEY (transaction_id)
    REFERENCES public.sales_transaction (transaction_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.sales_detail
    ADD FOREIGN KEY (product_id)
    REFERENCES public.product (product_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

END;