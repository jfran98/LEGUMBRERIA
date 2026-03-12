--
-- PostgreSQL database dump
--

\restrict Yxyc8soOyIxZdNBA3BCISkdawxHnOExE7SDqbiuuEwpiaGAEo9P4DQjUjgjJFrz

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

-- Started on 2026-03-11 20:08:06

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
-- TOC entry 890 (class 1247 OID 16982)
-- Name: estado_token; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.estado_token AS ENUM (
    'activo',
    'revocado'
);


ALTER TYPE public.estado_token OWNER TO postgres;

--
-- TOC entry 884 (class 1247 OID 16931)
-- Name: estado_usuario; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.estado_usuario AS ENUM (
    'activo',
    'bloqueado'
);


ALTER TYPE public.estado_usuario OWNER TO postgres;

--
-- TOC entry 887 (class 1247 OID 16936)
-- Name: rol_usuario; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.rol_usuario AS ENUM (
    'usuario',
    'gerente',
    'empleado'
);


ALTER TYPE public.rol_usuario OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 41573)
-- Name: descontar_dia(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.descontar_dia(p_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_fecha DATE := CURRENT_DATE;
BEGIN
  -- Validar si ya fue descontado hoy
  IF EXISTS (
    SELECT 1 FROM empleados 
    WHERE id_empleado = p_id 
    AND ultima_fecha_descuento = v_fecha
  ) THEN
    RETURN 'Ya se aplicó descuento hoy';
  END IF;

  -- Aplicar descuento (Salario / 30 días)
  UPDATE empleados 
  SET descuentos = descuentos + (salario_mensual / 30),
      ultima_fecha_descuento = v_fecha
  WHERE id_empleado = p_id;

  RETURN 'Descuento de día aplicado correctamente';
END;
$$;


ALTER FUNCTION public.descontar_dia(p_id integer) OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 41574)
-- Name: descontar_horas(integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.descontar_horas(p_id integer, p_horas numeric) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_valor_hora NUMERIC;
BEGIN
  -- Calcular valor hora (Salario / 220 horas laborales mensuales)
  SELECT salario_mensual / 220 
  INTO v_valor_hora 
  FROM empleados 
  WHERE id_empleado = p_id;

  -- Aplicar descuento por horas
  UPDATE empleados 
  SET descuentos = descuentos + (v_valor_hora * p_horas),
      horas_descuento_acumuladas = horas_descuento_acumuladas + p_horas
  WHERE id_empleado = p_id;

  RETURN 'Descuento por horas aplicado correctamente';
END;
$$;


ALTER FUNCTION public.descontar_horas(p_id integer, p_horas numeric) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 236 (class 1259 OID 41477)
-- Name: categorias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categorias (
    idcategoria integer NOT NULL,
    nombre character varying(100) NOT NULL
);


ALTER TABLE public.categorias OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 41476)
-- Name: categorias_idcategoria_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categorias_idcategoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categorias_idcategoria_seq OWNER TO postgres;

--
-- TOC entry 5229 (class 0 OID 0)
-- Dependencies: 235
-- Name: categorias_idcategoria_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categorias_idcategoria_seq OWNED BY public.categorias.idcategoria;


--
-- TOC entry 232 (class 1259 OID 41436)
-- Name: detalles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detalles (
    id integer NOT NULL,
    idfactura integer CONSTRAINT detalles_factura_id_not_null NOT NULL,
    idproductos integer CONSTRAINT detalles_producto_id_not_null NOT NULL,
    stock numeric(10,2) CONSTRAINT detalles_cantidad_not_null NOT NULL,
    precio numeric(10,2) CONSTRAINT detalles_precio_unitario_not_null NOT NULL,
    subtotal numeric(10,2) NOT NULL,
    CONSTRAINT detalles_cantidad_check CHECK ((stock > (0)::numeric)),
    CONSTRAINT detalles_precio_unitario_check CHECK ((precio >= (0)::numeric)),
    CONSTRAINT detalles_subtotal_check CHECK ((subtotal >= (0)::numeric))
);


ALTER TABLE public.detalles OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 41435)
-- Name: detalles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.detalles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.detalles_id_seq OWNER TO postgres;

--
-- TOC entry 5230 (class 0 OID 0)
-- Dependencies: 231
-- Name: detalles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.detalles_id_seq OWNED BY public.detalles.id;


--
-- TOC entry 224 (class 1259 OID 41224)
-- Name: direcciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.direcciones (
    iddireccion integer NOT NULL,
    idusuario integer NOT NULL,
    calle character varying(150) NOT NULL,
    ciudad character varying(100) NOT NULL,
    departamento character varying(100),
    codigo_postal character varying(20),
    referencia text,
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    activo boolean DEFAULT true
);


ALTER TABLE public.direcciones OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 41223)
-- Name: direcciones_iddireccion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.direcciones_iddireccion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.direcciones_iddireccion_seq OWNER TO postgres;

--
-- TOC entry 5231 (class 0 OID 0)
-- Dependencies: 223
-- Name: direcciones_iddireccion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.direcciones_iddireccion_seq OWNED BY public.direcciones.iddireccion;


--
-- TOC entry 240 (class 1259 OID 41526)
-- Name: empleados; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.empleados (
    id_empleado integer NOT NULL,
    nombre character varying(100) NOT NULL,
    documento character varying(20) NOT NULL,
    salario_mensual numeric(12,2) DEFAULT 1750905,
    auxilio_transporte numeric(12,2) DEFAULT 249095,
    activo boolean DEFAULT true,
    descuentos numeric(12,2) DEFAULT 0,
    ultima_fecha_descuento date,
    horas_descuento_acumuladas numeric(5,2) DEFAULT 0,
    idusuario integer
);


ALTER TABLE public.empleados OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 41525)
-- Name: empleados_id_empleado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.empleados_id_empleado_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.empleados_id_empleado_seq OWNER TO postgres;

--
-- TOC entry 5232 (class 0 OID 0)
-- Dependencies: 239
-- Name: empleados_id_empleado_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.empleados_id_empleado_seq OWNED BY public.empleados.id_empleado;


--
-- TOC entry 238 (class 1259 OID 41498)
-- Name: estado; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estado (
    idestado integer NOT NULL,
    nombre character varying(20) NOT NULL
);


ALTER TABLE public.estado OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 41497)
-- Name: estado_idestado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.estado_idestado_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.estado_idestado_seq OWNER TO postgres;

--
-- TOC entry 5233 (class 0 OID 0)
-- Dependencies: 237
-- Name: estado_idestado_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.estado_idestado_seq OWNED BY public.estado.idestado;


--
-- TOC entry 230 (class 1259 OID 41308)
-- Name: factura; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.factura (
    idfactura integer CONSTRAINT factura_id_not_null NOT NULL,
    idusuario integer NOT NULL,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    total numeric(10,2) NOT NULL,
    metodo_pago character varying(30),
    idestado integer DEFAULT 1,
    CONSTRAINT factura_total_check CHECK ((total >= (0)::numeric))
);


ALTER TABLE public.factura OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 41307)
-- Name: factura_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.factura_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.factura_id_seq OWNER TO postgres;

--
-- TOC entry 5234 (class 0 OID 0)
-- Dependencies: 229
-- Name: factura_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.factura_id_seq OWNED BY public.factura.idfactura;


--
-- TOC entry 234 (class 1259 OID 41462)
-- Name: gastos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gastos (
    idgastos integer NOT NULL,
    descripcion character varying(200) NOT NULL,
    monto numeric(10,2) NOT NULL,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT gastos_monto_check CHECK ((monto > (0)::numeric))
);


ALTER TABLE public.gastos OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 41461)
-- Name: gastos_idgastos_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.gastos_idgastos_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.gastos_idgastos_seq OWNER TO postgres;

--
-- TOC entry 5235 (class 0 OID 0)
-- Dependencies: 233
-- Name: gastos_idgastos_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.gastos_idgastos_seq OWNED BY public.gastos.idgastos;


--
-- TOC entry 249 (class 1259 OID 49487)
-- Name: notificaciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notificaciones (
    idnotificacion integer NOT NULL,
    idusuario integer,
    rol_destino public.rol_usuario,
    titulo character varying(100) NOT NULL,
    mensaje text NOT NULL,
    tipo character varying(50) DEFAULT 'sistema'::character varying,
    leido boolean DEFAULT false,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.notificaciones OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 49486)
-- Name: notificaciones_idnotificacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notificaciones_idnotificacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notificaciones_idnotificacion_seq OWNER TO postgres;

--
-- TOC entry 5236 (class 0 OID 0)
-- Dependencies: 248
-- Name: notificaciones_idnotificacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notificaciones_idnotificacion_seq OWNED BY public.notificaciones.idnotificacion;


--
-- TOC entry 246 (class 1259 OID 49465)
-- Name: pagos_empleados; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pagos_empleados (
    idpago integer NOT NULL,
    id_empleado integer NOT NULL,
    fecha_pago date DEFAULT CURRENT_DATE,
    salario_base numeric(12,2),
    descuentos numeric(12,2),
    salario_pagado numeric(12,2),
    metodo_pago character varying(50),
    observacion text
);


ALTER TABLE public.pagos_empleados OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 49464)
-- Name: pagos_empleados_idpago_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pagos_empleados_idpago_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pagos_empleados_idpago_seq OWNER TO postgres;

--
-- TOC entry 5237 (class 0 OID 0)
-- Dependencies: 245
-- Name: pagos_empleados_idpago_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pagos_empleados_idpago_seq OWNED BY public.pagos_empleados.idpago;


--
-- TOC entry 226 (class 1259 OID 41243)
-- Name: pedidos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pedidos (
    idpedido integer NOT NULL,
    idusuario integer NOT NULL,
    iddireccion integer NOT NULL,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    total numeric(10,2) NOT NULL,
    idfactura integer,
    idestado integer DEFAULT 1
);


ALTER TABLE public.pedidos OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 41242)
-- Name: pedidos_idpedido_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pedidos_idpedido_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pedidos_idpedido_seq OWNER TO postgres;

--
-- TOC entry 5238 (class 0 OID 0)
-- Dependencies: 225
-- Name: pedidos_idpedido_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pedidos_idpedido_seq OWNED BY public.pedidos.idpedido;


--
-- TOC entry 228 (class 1259 OID 41273)
-- Name: productos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productos (
    idproductos integer CONSTRAINT productos_id_not_null NOT NULL,
    nombre character varying(150) NOT NULL,
    descripcion text,
    tipo_venta character varying(10) NOT NULL,
    precio numeric(10,2) NOT NULL,
    stock numeric(10,2) DEFAULT 0,
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    costo numeric(10,2) DEFAULT 0 NOT NULL,
    idcategoria integer,
    idestado integer DEFAULT 1,
    CONSTRAINT productos_costo_check CHECK ((costo >= (0)::numeric)),
    CONSTRAINT productos_precio_check CHECK ((precio >= (0)::numeric)),
    CONSTRAINT productos_stock_check CHECK ((stock >= (0)::numeric)),
    CONSTRAINT productos_tipo_venta_check CHECK (((tipo_venta)::text = ANY ((ARRAY['KG'::character varying, 'UNIDAD'::character varying])::text[])))
);


ALTER TABLE public.productos OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 41272)
-- Name: productos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.productos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.productos_id_seq OWNER TO postgres;

--
-- TOC entry 5239 (class 0 OID 0)
-- Dependencies: 227
-- Name: productos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.productos_id_seq OWNED BY public.productos.idproductos;


--
-- TOC entry 222 (class 1259 OID 33011)
-- Name: tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tokens (
    idtoken integer NOT NULL,
    idusuario integer NOT NULL,
    token character varying(500) NOT NULL,
    fechacreacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    fechaexpiracion timestamp without time zone NOT NULL,
    tipo character varying(50) NOT NULL,
    usado boolean DEFAULT false
);


ALTER TABLE public.tokens OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 33010)
-- Name: tokens_idtoken_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tokens_idtoken_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tokens_idtoken_seq OWNER TO postgres;

--
-- TOC entry 5240 (class 0 OID 0)
-- Dependencies: 221
-- Name: tokens_idtoken_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tokens_idtoken_seq OWNED BY public.tokens.idtoken;


--
-- TOC entry 242 (class 1259 OID 41541)
-- Name: turnos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.turnos (
    id_turno integer NOT NULL,
    id_empleado integer,
    fecha date NOT NULL,
    hora_inicio time without time zone NOT NULL,
    hora_fin time without time zone NOT NULL,
    pagado boolean DEFAULT false
);


ALTER TABLE public.turnos OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 41540)
-- Name: turnos_id_turno_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.turnos_id_turno_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.turnos_id_turno_seq OWNER TO postgres;

--
-- TOC entry 5241 (class 0 OID 0)
-- Dependencies: 241
-- Name: turnos_id_turno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.turnos_id_turno_seq OWNED BY public.turnos.id_turno;


--
-- TOC entry 220 (class 1259 OID 16988)
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    idusuario integer NOT NULL,
    documento character varying(20) NOT NULL,
    nombres character varying(100) NOT NULL,
    correo character varying(200) NOT NULL,
    telefono character varying(15),
    contrasena character varying(255) NOT NULL,
    pregunta character varying(200) NOT NULL,
    respuesta character varying(255) NOT NULL,
    intentos_fallidos integer DEFAULT 0,
    estado public.estado_usuario DEFAULT 'activo'::public.estado_usuario,
    rol public.rol_usuario DEFAULT 'usuario'::public.rol_usuario,
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    intentos integer DEFAULT 0
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16987)
-- Name: usuarios_idusuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuarios_idusuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_idusuario_seq OWNER TO postgres;

--
-- TOC entry 5242 (class 0 OID 0)
-- Dependencies: 219
-- Name: usuarios_idusuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuarios_idusuario_seq OWNED BY public.usuarios.idusuario;


--
-- TOC entry 247 (class 1259 OID 49482)
-- Name: vista_horas_trabajadas; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_horas_trabajadas AS
 SELECT id_turno,
    id_empleado,
    fecha,
    hora_inicio,
    hora_fin,
    pagado,
    (EXTRACT(epoch FROM (
        CASE
            WHEN (hora_fin < hora_inicio) THEN (hora_fin + '1 day'::interval)
            ELSE hora_fin
        END - hora_inicio)) / (3600)::numeric) AS horas_trabajadas
   FROM public.turnos t;


ALTER VIEW public.vista_horas_trabajadas OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 41564)
-- Name: vista_pago_nocturno; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_pago_nocturno AS
 SELECT t.id_turno,
    e.nombre,
    t.fecha,
    round((((EXTRACT(epoch FROM (t.hora_fin - t.hora_inicio)) / (3600)::numeric) * (e.salario_mensual / (220)::numeric)) * 1.35), 2) AS pago_nocturno
   FROM (public.turnos t
     JOIN public.empleados e ON ((e.id_empleado = t.id_empleado)))
  WHERE (t.hora_inicio < '06:00:00'::time without time zone);


ALTER VIEW public.vista_pago_nocturno OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 41560)
-- Name: vista_valor_hora; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vista_valor_hora AS
 SELECT id_empleado,
    nombre,
    salario_mensual,
    round((salario_mensual / (220)::numeric), 2) AS valor_hora
   FROM public.empleados e;


ALTER VIEW public.vista_valor_hora OWNER TO postgres;

--
-- TOC entry 4970 (class 2604 OID 41480)
-- Name: categorias idcategoria; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias ALTER COLUMN idcategoria SET DEFAULT nextval('public.categorias_idcategoria_seq'::regclass);


--
-- TOC entry 4967 (class 2604 OID 41439)
-- Name: detalles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalles ALTER COLUMN id SET DEFAULT nextval('public.detalles_id_seq'::regclass);


--
-- TOC entry 4953 (class 2604 OID 41227)
-- Name: direcciones iddireccion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.direcciones ALTER COLUMN iddireccion SET DEFAULT nextval('public.direcciones_iddireccion_seq'::regclass);


--
-- TOC entry 4972 (class 2604 OID 41529)
-- Name: empleados id_empleado; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empleados ALTER COLUMN id_empleado SET DEFAULT nextval('public.empleados_id_empleado_seq'::regclass);


--
-- TOC entry 4971 (class 2604 OID 41501)
-- Name: estado idestado; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estado ALTER COLUMN idestado SET DEFAULT nextval('public.estado_idestado_seq'::regclass);


--
-- TOC entry 4964 (class 2604 OID 41311)
-- Name: factura idfactura; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.factura ALTER COLUMN idfactura SET DEFAULT nextval('public.factura_id_seq'::regclass);


--
-- TOC entry 4968 (class 2604 OID 41465)
-- Name: gastos idgastos; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gastos ALTER COLUMN idgastos SET DEFAULT nextval('public.gastos_idgastos_seq'::regclass);


--
-- TOC entry 4982 (class 2604 OID 49490)
-- Name: notificaciones idnotificacion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notificaciones ALTER COLUMN idnotificacion SET DEFAULT nextval('public.notificaciones_idnotificacion_seq'::regclass);


--
-- TOC entry 4980 (class 2604 OID 49468)
-- Name: pagos_empleados idpago; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagos_empleados ALTER COLUMN idpago SET DEFAULT nextval('public.pagos_empleados_idpago_seq'::regclass);


--
-- TOC entry 4956 (class 2604 OID 41246)
-- Name: pedidos idpedido; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos ALTER COLUMN idpedido SET DEFAULT nextval('public.pedidos_idpedido_seq'::regclass);


--
-- TOC entry 4959 (class 2604 OID 41276)
-- Name: productos idproductos; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos ALTER COLUMN idproductos SET DEFAULT nextval('public.productos_id_seq'::regclass);


--
-- TOC entry 4950 (class 2604 OID 33014)
-- Name: tokens idtoken; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens ALTER COLUMN idtoken SET DEFAULT nextval('public.tokens_idtoken_seq'::regclass);


--
-- TOC entry 4978 (class 2604 OID 41544)
-- Name: turnos id_turno; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turnos ALTER COLUMN id_turno SET DEFAULT nextval('public.turnos_id_turno_seq'::regclass);


--
-- TOC entry 4944 (class 2604 OID 16991)
-- Name: usuarios idusuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN idusuario SET DEFAULT nextval('public.usuarios_idusuario_seq'::regclass);


--
-- TOC entry 5213 (class 0 OID 41477)
-- Dependencies: 236
-- Data for Name: categorias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categorias (idcategoria, nombre) FROM stdin;
1	Legumbres
2	Frutas
3	Hortalizas
4	Cereales
5	Hierbas
\.


--
-- TOC entry 5209 (class 0 OID 41436)
-- Dependencies: 232
-- Data for Name: detalles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.detalles (id, idfactura, idproductos, stock, precio, subtotal) FROM stdin;
1	1	3	1.00	3800.00	3800.00
2	1	2	1.00	5500.00	5500.00
3	1	1	1.00	4500.00	4500.00
4	2	64	18.00	15000.00	270000.00
5	3	3	1.00	3800.00	3800.00
6	3	2	1.00	5500.00	5500.00
7	3	1	1.00	4500.00	4500.00
8	3	25	1.00	9500.00	9500.00
9	3	24	1.00	8500.00	8500.00
10	4	66	1.00	1500.00	1500.00
11	4	3	1.00	3800.00	3800.00
\.


--
-- TOC entry 5201 (class 0 OID 41224)
-- Dependencies: 224
-- Data for Name: direcciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.direcciones (iddireccion, idusuario, calle, ciudad, departamento, codigo_postal, referencia, fecha_creacion, activo) FROM stdin;
1	19	calle 45 # 34	Itagüí	casa 2segundo piso	\N		2026-03-05 10:25:29.799611	f
2	3	calle 45 # 34	Itagüí	casa 2segundo piso	\N	dsggds	2026-03-10 07:55:35.485659	t
\.


--
-- TOC entry 5217 (class 0 OID 41526)
-- Dependencies: 240
-- Data for Name: empleados; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.empleados (id_empleado, nombre, documento, salario_mensual, auxilio_transporte, activo, descuentos, ultima_fecha_descuento, horas_descuento_acumuladas, idusuario) FROM stdin;
1	guadalupe estrada franco	1036453016	1750905.00	249095.00	t	0.00	\N	0.00	18
\.


--
-- TOC entry 5215 (class 0 OID 41498)
-- Dependencies: 238
-- Data for Name: estado; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.estado (idestado, nombre) FROM stdin;
1	pendiente
2	aprobada
3	rechazada
\.


--
-- TOC entry 5207 (class 0 OID 41308)
-- Dependencies: 230
-- Data for Name: factura; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.factura (idfactura, idusuario, fecha, total, metodo_pago, idestado) FROM stdin;
1	19	2026-03-05 10:25:29.83389	28800.00	CONTRAENTREGA	1
2	19	2026-03-05 10:40:38.083731	285000.00	CONTRAENTREGA	1
3	3	2026-03-10 07:55:35.49972	46800.00	BANCOLOMBIA	2
4	3	2026-03-10 08:05:55.305952	20300.00	CONTRAENTREGA	1
\.


--
-- TOC entry 5211 (class 0 OID 41462)
-- Dependencies: 234
-- Data for Name: gastos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.gastos (idgastos, descripcion, monto, fecha) FROM stdin;
\.


--
-- TOC entry 5223 (class 0 OID 49487)
-- Dependencies: 249
-- Data for Name: notificaciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notificaciones (idnotificacion, idusuario, rol_destino, titulo, mensaje, tipo, leido, fecha) FROM stdin;
1	\N	empleado	📦 Nuevo Pedido Recibido	Se ha registrado el pedido #1 por un total de $28800.	pedido	f	2026-03-05 10:25:29.853745
2	\N	gerente	💰 Nueva Venta Registrada	Venta por $28800. Factura #1.	pedido	f	2026-03-05 10:25:29.856212
4	\N	empleado	📦 Nuevo Pedido Recibido	Se ha registrado el pedido #2 por un total de $285000.	pedido	f	2026-03-05 10:40:38.163024
5	\N	gerente	💰 Nueva Venta Registrada	Venta por $285000. Factura #2.	pedido	f	2026-03-05 10:40:38.16391
6	\N	empleado	📦 Nuevo Pedido Recibido	Se ha registrado el pedido #3 por un total de $46800.	pedido	f	2026-03-10 07:55:35.532416
7	\N	gerente	💰 Nueva Venta Registrada	Venta por $46800. Factura #3.	pedido	f	2026-03-10 07:55:35.536078
8	3	\N	✅ Pedido aprobado	Tu pedido por $46800.00 ha sido aprobado.	pedido	f	2026-03-10 07:59:18.377179
9	\N	empleado	📦 Nuevo Pedido Recibido	Se ha registrado el pedido #4 por un total de $20300.	pedido	f	2026-03-10 08:05:55.391257
10	\N	gerente	💰 Nueva Venta Registrada	Venta por $20300. Factura #4.	pedido	f	2026-03-10 08:05:55.39482
3	\N	gerente	⚠️ Stock Bajo Detectado	El producto "Flor de Jamaica" tiene solo 2.00 unidades/kg disponibles.	stock	t	2026-03-05 10:40:38.160323
\.


--
-- TOC entry 5221 (class 0 OID 49465)
-- Dependencies: 246
-- Data for Name: pagos_empleados; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pagos_empleados (idpago, id_empleado, fecha_pago, salario_base, descuentos, salario_pagado, metodo_pago, observacion) FROM stdin;
1	1	2026-03-10	1750905.00	0.00	312764.28	Transferencia	Pago mensual - Horas: 8.0
\.


--
-- TOC entry 5203 (class 0 OID 41243)
-- Dependencies: 226
-- Data for Name: pedidos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pedidos (idpedido, idusuario, iddireccion, fecha, total, idfactura, idestado) FROM stdin;
1	19	1	2026-03-05 10:25:29.839852	28800.00	1	1
2	19	1	2026-03-05 10:40:38.14464	285000.00	2	1
4	3	2	2026-03-10 08:05:55.371923	20300.00	4	1
\.


--
-- TOC entry 5205 (class 0 OID 41273)
-- Dependencies: 228
-- Data for Name: productos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.productos (idproductos, nombre, descripcion, tipo_venta, precio, stock, fecha_creacion, costo, idcategoria, idestado) FROM stdin;
4	Aguacate	Aguacate Hass maduro	KG	4000.00	50.00	2026-03-04 23:49:49.299603	2500.00	2	1
5	Arándanos	Caja de arándanos frescos	UNIDAD	6500.00	30.00	2026-03-04 23:49:49.299603	4500.00	2	1
6	Banano	Banano maduro de Urabá	KG	3200.00	150.00	2026-03-04 23:49:49.299603	1800.00	2	1
7	Combo Frutas	Canasta surtida de frutas	UNIDAD	25000.00	10.00	2026-03-04 23:49:49.299603	18000.00	2	1
8	Frambuesas	Frambuesas frescas en domo	UNIDAD	8500.00	20.00	2026-03-04 23:49:49.299603	6000.00	2	1
9	Fresa	Fresa fresca seleccionada	KG	7500.00	60.00	2026-03-04 23:49:49.299603	5000.00	2	1
10	Granadilla	Granadilla dulce	KG	6200.00	40.00	2026-03-04 23:49:49.299603	4000.00	2	1
11	Guayaba	Guayaba manzana	KG	3500.00	100.00	2026-03-04 23:49:49.299603	2000.00	2	1
12	Kiwi	Kiwi importado maduro	KG	12000.00	30.00	2026-03-04 23:49:49.299603	8500.00	2	1
13	Lulo	Lulo para jugo	KG	4800.00	70.00	2026-03-04 23:49:49.299603	3000.00	2	1
14	Mandarina	Mandarina Oneco	KG	3800.00	120.00	2026-03-04 23:49:49.299603	2200.00	2	1
15	Mango	Mango Tomy maduro	KG	3500.00	150.00	2026-03-04 23:49:49.299603	2100.00	2	1
16	Manzana	Manzana roja gala	KG	7800.00	100.00	2026-03-04 23:49:49.299603	5500.00	2	1
17	Maracuyá	Maracuyá fresca	KG	5200.00	80.00	2026-03-04 23:49:49.299603	3500.00	2	1
18	Melón	Melón dulce	KG	4000.00	40.00	2026-03-04 23:49:49.299603	2500.00	2	1
19	Mora	Mora de castilla	KG	4500.00	60.00	2026-03-04 23:49:49.299603	2800.00	2	1
20	Papaya	Papaya melona madura	KG	4200.00	50.00	2026-03-04 23:49:49.299603	2600.00	2	1
21	Piña	Piña oro miel	KG	3800.00	60.00	2026-03-04 23:49:49.299603	2200.00	2	1
22	Pitahaya	Pitahaya amarilla	KG	14000.00	25.00	2026-03-04 23:49:49.299603	9500.00	2	1
23	Sandía	Sandía baby dulce	KG	3000.00	40.00	2026-03-04 23:49:49.299603	1800.00	2	1
26	Acelga	Acelga fresca por atado	UNIDAD	2800.00	40.00	2026-03-04 23:49:49.299603	1500.00	3	1
27	Alcachofa	Alcachofa fresca	UNIDAD	3500.00	20.00	2026-03-04 23:49:49.299603	2200.00	3	1
28	Apio	Apio españa fresco	UNIDAD	2600.00	45.00	2026-03-04 23:49:49.299603	1400.00	3	1
29	Arracacha	Arracacha amarilla	KG	4200.00	60.00	2026-03-04 23:49:49.299603	2800.00	3	1
30	Auyama	Auyama porción o entera	KG	2500.00	100.00	2026-03-04 23:49:49.299603	1200.00	3	1
31	Berenjena	Berenjena morada	KG	4500.00	30.00	2026-03-04 23:49:49.299603	2800.00	3	1
32	Brócoli	Brócoli por cabeza	UNIDAD	4200.00	40.00	2026-03-04 23:49:49.299603	2600.00	3	1
33	Calabacín	Calabacín verde	KG	3200.00	50.00	2026-03-04 23:49:49.299603	2000.00	3	1
34	Cebolla Cabezona	Cebolla blanca cabezona	KG	2200.00	200.00	2026-03-04 23:49:49.299603	1400.00	3	1
35	Cebolla Morada	Cebolla roja cabezona	KG	2500.00	150.00	2026-03-04 23:49:49.299603	1600.00	3	1
36	Cebolla Puerro	Tallo de cebolla puerro	UNIDAD	2800.00	30.00	2026-03-04 23:49:49.299603	1800.00	3	1
37	Cebollín	Atado de cebollín	UNIDAD	1500.00	50.00	2026-03-04 23:49:49.299603	800.00	3	1
38	Coliflor	Coliflor blanca fresca	UNIDAD	4000.00	35.00	2026-03-04 23:49:49.299603	2500.00	3	1
39	Combo Vegetales	Mezcla surtida de vegetales	UNIDAD	18000.00	15.00	2026-03-04 23:49:49.299603	12000.00	3	1
40	Espárragos	Atado de espárragos verdes	UNIDAD	9500.00	20.00	2026-03-04 23:49:49.299603	6500.00	3	1
41	Espinaca	Espinaca fresca por atado	UNIDAD	2500.00	40.00	2026-03-04 23:49:49.299603	1500.00	3	1
42	Jengibre	Raíz de jengibre	KG	12000.00	20.00	2026-03-04 23:49:49.299603	8000.00	3	1
43	Lechuga	Lechuga Batavia fresca	UNIDAD	2000.00	80.00	2026-03-04 23:49:49.299603	1200.00	3	1
44	Mazorca	Mazorca dulce tierna	UNIDAD	1800.00	100.00	2026-03-04 23:49:49.299603	900.00	3	1
45	Ñame	Ñame espino	KG	3800.00	60.00	2026-03-04 23:49:49.299603	2200.00	3	1
46	Papa	Papa capira	KG	2800.00	500.00	2026-03-04 23:49:49.299603	1800.00	3	1
47	Papa Criolla	Papa criolla limpia	KG	3500.00	200.00	2026-03-04 23:49:49.299603	2200.00	3	1
48	Pepino	Pepino cohombro	KG	2500.00	100.00	2026-03-04 23:49:49.299603	1500.00	3	1
49	Pimentón	Pimentón rojo/verde	KG	5000.00	70.00	2026-03-04 23:49:49.299603	3200.00	3	1
50	Plátano Maduro	Plátano maduro selección	KG	3200.00	150.00	2026-03-04 23:49:49.299603	1900.00	3	1
51	Plátano Verde	Plátano verde Hartón	KG	3000.00	150.00	2026-03-04 23:49:49.299603	1800.00	3	1
52	Rábano	Rábano rojo fresco	KG	3500.00	40.00	2026-03-04 23:49:49.299603	2000.00	3	1
53	Remolacha	Remolacha fresca	KG	2800.00	120.00	2026-03-04 23:49:49.299603	1500.00	3	1
54	Repollo	Repollo verde liso	KG	2200.00	80.00	2026-03-04 23:49:49.299603	1200.00	3	1
55	Tomate	Tomate chonto maduro	KG	2100.00	250.00	2026-03-04 23:49:49.299603	1200.00	3	1
56	Yuca	Yuca regional fresca	KG	3500.00	100.00	2026-03-04 23:49:49.299603	2000.00	3	1
57	Zanahoria	Zanahoria fresca limpia	KG	2700.00	200.00	2026-03-04 23:49:49.299603	1600.00	3	1
58	Champiñones	Champiñones en bandeja	UNIDAD	4500.00	30.00	2026-03-04 23:49:49.299603	3200.00	3	1
59	Arroz Integral	Arroz integral premium	KG	5500.00	200.00	2026-03-04 23:49:49.299603	3800.00	4	1
60	Avena	Avena en hojuelas	KG	4800.00	150.00	2026-03-04 23:49:49.299603	3000.00	4	1
61	Granola	Granola artesanal con frutos secos	KG	12000.00	50.00	2026-03-04 23:49:49.299603	8500.00	4	1
63	Cilantro	Atado de cilantro fresco	UNIDAD	1000.00	100.00	2026-03-04 23:49:49.299603	500.00	5	1
65	Tomillo y Laurel	Mix de hierbas finas	UNIDAD	2500.00	50.00	2026-03-04 23:49:49.299603	1500.00	5	1
2	Frijol Verde	Frijol verde en vaina	KG	5500.00	78.00	2026-03-04 23:49:49.299603	3500.00	1	1
1	Arveja	Arveja verde fresca	KG	4500.00	98.00	2026-03-04 23:49:49.299603	3000.00	1	1
25	Uva Verde	Uva verde sin semilla	KG	9500.00	49.00	2026-03-04 23:49:49.299603	7000.00	2	1
67	Ajo	ricos y sabrosos	KG	1000.00	30.00	2026-03-11 10:05:49.187506	0.00	1	1
62	Ajo	Dientes de ajo pelados/enteros	KG	9000.00	0.00	2026-03-04 23:49:49.299603	6000.00	5	3
64	Flor de Jamaica	Flor de Jamaica seca para infusiones	KG	15000.00	20.00	2026-03-04 23:49:49.299603	10000.00	5	1
24	Uva Roja	Uva roja con semilla	KG	8500.00	49.00	2026-03-04 23:49:49.299603	6000.00	2	1
66	Mazorca	rica y  deliciosa	KG	1500.00	199.00	2026-03-10 08:00:15.826622	0.00	1	1
3	Habichuelas	Habichuela larga y fresca	KG	3800.00	97.00	2026-03-04 23:49:49.299603	2500.00	1	1
\.


--
-- TOC entry 5199 (class 0 OID 33011)
-- Dependencies: 222
-- Data for Name: tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tokens (idtoken, idusuario, token, fechacreacion, fechaexpiracion, tipo, usado) FROM stdin;
1	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzI3MTc0NjUsImV4cCI6MTc3MjgwMzg2NX0.UdUsNrjsPsCTeviu_n3a4TglajLNPUAt7iS6tMqdQUY	2026-03-05 08:31:05.459198	2026-03-06 08:31:05.458	auth	f
2	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzI3MTgxNDcsImV4cCI6MTc3MjgwNDU0N30.5sQkWBncotBSw2ayuqd2KIYhapMypDi3HJU0f8G50cc	2026-03-05 08:42:27.177868	2026-03-06 08:42:27.178	auth	f
3	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzI3MTg2OTEsImV4cCI6MTc3MjgwNTA5MX0.saW-Fb714J45L0cWWr68mHjuk8LhTYNwLkHtMcCX_eM	2026-03-05 08:51:31.331109	2026-03-06 08:51:31.331	auth	f
4	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzI3MTg3NzgsImV4cCI6MTc3MjgwNTE3OH0.kmuQzIkf1oxGAmmimOFouvpFsZS5tfXH-kO9oOI45HM	2026-03-05 08:52:58.075478	2026-03-06 08:52:58.077	auth	f
5	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzI3MTg4NDcsImV4cCI6MTc3MjgwNTI0N30.dkJsL4BNnkp2D3VOrxVucnlhgMNPUVXRLsscyPD_Rig	2026-03-05 08:54:07.389778	2026-03-06 08:54:07.392	auth	f
6	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzI3MTg4NDksImV4cCI6MTc3MjgwNTI0OX0.npFgY4mYN6m4r29-FV8lvDn8tqpbJkiBQTqr7hWlRJI	2026-03-05 08:54:09.532097	2026-03-06 08:54:09.534	auth	f
7	18	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjE4LCJkb2N1bWVudG8iOiIxMDM2NDUzMDE2IiwiY29ycmVvIjoiZ3VhZGFsdXBlQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJndWFkYWx1cGUgZXN0cmFkYSBmcmFuY28iLCJyb2wiOiJ1c3VhcmlvIiwiaWF0IjoxNzcyNzE4OTM0LCJleHAiOjE3NzI4MDUzMzR9.j_f-bWQK9ekd1gJNcosy1C9r3LCNm0EIhrByE-3FsBc	2026-03-05 08:55:34.952722	2026-03-06 08:55:34.953	auth	f
8	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzI3MTkwMTQsImV4cCI6MTc3MjgwNTQxNH0.pAQSNPrWka0z0VS8NPpoRP_ejIufmw_jVMhRqtpfONI	2026-03-05 08:56:54.808868	2026-03-06 08:56:54.808	auth	f
9	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzI3MjQwNjYsImV4cCI6MTc3MjgxMDQ2Nn0.tJUocwmbkF8-2oQuU5ZLtLTgcLEfGtSZqneqZrwxLzA	2026-03-05 10:21:06.935729	2026-03-06 10:21:06.935	auth	f
10	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzI3MjQwNzEsImV4cCI6MTc3MjgxMDQ3MX0.p3UCvoOke1o8YvtF0QO7A3h-A0V9oGz_4u_26hRh3hI	2026-03-05 10:21:11.253799	2026-03-06 10:21:11.253	auth	f
11	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzI3MjQwNzMsImV4cCI6MTc3MjgxMDQ3M30.9spxHybR483fEgTSiYdoG6vSqCctSFvGTJ96A9QTG_I	2026-03-05 10:21:13.635543	2026-03-06 10:21:13.635	auth	f
12	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzI3MjQwNzMsImV4cCI6MTc3MjgxMDQ3M30.9spxHybR483fEgTSiYdoG6vSqCctSFvGTJ96A9QTG_I	2026-03-05 10:21:13.826219	2026-03-06 10:21:13.826	auth	f
13	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzI3MjQwODksImV4cCI6MTc3MjgxMDQ4OX0.K_MptAebdyChOAscJOpZimCg2lHZ1Y-Xa0lpSBO8ABg	2026-03-05 10:21:29.549461	2026-03-06 10:21:29.549	auth	f
14	18	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjE4LCJkb2N1bWVudG8iOiIxMDM2NDUzMDE2IiwiY29ycmVvIjoiZ3VhZGFsdXBlQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJndWFkYWx1cGUgZXN0cmFkYSBmcmFuY28iLCJyb2wiOiJ1c3VhcmlvIiwiaWF0IjoxNzcyNzI0MTI3LCJleHAiOjE3NzI4MTA1Mjd9.DRF53vIhEEAepiav6Pahv_cmHzof0SMpASMvC96XJGI	2026-03-05 10:22:07.155888	2026-03-06 10:22:07.155	auth	f
15	18	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjE4LCJkb2N1bWVudG8iOiIxMDM2NDUzMDE2IiwiY29ycmVvIjoiZ3VhZGFsdXBlQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJndWFkYWx1cGUgZXN0cmFkYSBmcmFuY28iLCJyb2wiOiJ1c3VhcmlvIiwiaWF0IjoxNzcyNzI0MTI5LCJleHAiOjE3NzI4MTA1Mjl9.N07fHBzLXJrucN1Zo35vVb36RzijuvN1-4mObWcEI18	2026-03-05 10:22:09.354806	2026-03-06 10:22:09.354	auth	f
16	18	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjE4LCJkb2N1bWVudG8iOiIxMDM2NDUzMDE2IiwiY29ycmVvIjoiZ3VhZGFsdXBlQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJndWFkYWx1cGUgZXN0cmFkYSBmcmFuY28iLCJyb2wiOiJ1c3VhcmlvIiwiaWF0IjoxNzcyNzI0MTQ1LCJleHAiOjE3NzI4MTA1NDV9.o4W_S5VNEgQfFqxMvibeJ_m19cxPA8eKNav_pkG03-4	2026-03-05 10:22:25.720149	2026-03-06 10:22:25.72	auth	f
17	18	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjE4LCJkb2N1bWVudG8iOiIxMDM2NDUzMDE2IiwiY29ycmVvIjoiZ3VhZGFsdXBlQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJndWFkYWx1cGUgZXN0cmFkYSBmcmFuY28iLCJyb2wiOiJ1c3VhcmlvIiwiaWF0IjoxNzcyNzI0MTY0LCJleHAiOjE3NzI4MTA1NjR9.GMmvLfBZHapGYYF_y8FRbpqnrVO8yTbCFq1FaP1Gdlo	2026-03-05 10:22:44.067749	2026-03-06 10:22:44.068	auth	f
18	18	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjE4LCJkb2N1bWVudG8iOiIxMDM2NDUzMDE2IiwiY29ycmVvIjoiZ3VhZGFsdXBlQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJndWFkYWx1cGUgZXN0cmFkYSBmcmFuY28iLCJyb2wiOiJ1c3VhcmlvIiwiaWF0IjoxNzcyNzI0MTc4LCJleHAiOjE3NzI4MTA1Nzh9.tus88yGkR9S5JGfRlfridBC5fhKJXnKHGhuGIbyXWP4	2026-03-05 10:22:58.325797	2026-03-06 10:22:58.326	auth	f
19	19	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjE5LCJkb2N1bWVudG8iOiIxMjM0NTY3ODkwIiwiY29ycmVvIjoibWFlQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJtYXJpYSBhbnRvbmlhIGVzdHJhZGEiLCJyb2wiOiJ1c3VhcmlvIiwiaWF0IjoxNzcyNzI0MjcyLCJleHAiOjE3NzI4MTA2NzJ9.KPHbmsxTaUxjtA-w25anJ0jRB778yKUii8IcTS6A8iY	2026-03-05 10:24:32.976384	2026-03-06 10:24:32.975	auth	f
20	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjc5MzQsImV4cCI6MTc3MzE1NDMzNH0.JieK1lRFu_EC7wnpZnaL6TBTFK3PNLegMkDyxx4YT9I	2026-03-09 09:52:14.523505	2026-03-10 09:52:14.519	auth	f
21	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgyNjIsImV4cCI6MTc3MzE1NDY2Mn0.mie4beP5izGXcoB8NZq27saKcqsX_9jfwJXkMGQ1LWM	2026-03-09 09:57:42.099343	2026-03-10 09:57:42.098	auth	f
22	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgyNjYsImV4cCI6MTc3MzE1NDY2Nn0.EtE3xcqKcF3hShkVcDb8xz8YW5YmOZcgwn4ac-uTVGw	2026-03-09 09:57:46.942969	2026-03-10 09:57:46.942	auth	f
23	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgyNzAsImV4cCI6MTc3MzE1NDY3MH0.NXFIEwKoAHY_LBwpTNjDKJg0KagSUtp3EUxlF16aZpk	2026-03-09 09:57:50.723103	2026-03-10 09:57:50.722	auth	f
24	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgyNzAsImV4cCI6MTc3MzE1NDY3MH0.NXFIEwKoAHY_LBwpTNjDKJg0KagSUtp3EUxlF16aZpk	2026-03-09 09:57:50.936306	2026-03-10 09:57:50.935	auth	f
25	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgyNzEsImV4cCI6MTc3MzE1NDY3MX0.WBCIWraDAs14wFMu1uansx7bSB9Gj6a8mZFMkRZsqS0	2026-03-09 09:57:51.175501	2026-03-10 09:57:51.174	auth	f
26	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgyNzEsImV4cCI6MTc3MzE1NDY3MX0.WBCIWraDAs14wFMu1uansx7bSB9Gj6a8mZFMkRZsqS0	2026-03-09 09:57:51.388537	2026-03-10 09:57:51.388	auth	f
27	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgyODMsImV4cCI6MTc3MzE1NDY4M30.2eOxon6iGiYS16XhT7iWgnCwmM9La6JLoPYL7GpN3nk	2026-03-09 09:58:03.345323	2026-03-10 09:58:03.344	auth	f
28	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgyOTAsImV4cCI6MTc3MzE1NDY5MH0.g3IvNuPCN6qm4UvLnPxWd-20Nk6YIn_X_9yDCeG0Lnk	2026-03-09 09:58:10.004655	2026-03-10 09:58:10.004	auth	f
29	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgyOTMsImV4cCI6MTc3MzE1NDY5M30.f5ZkyRIxIkTt_2XHuUPd685lEUB028pVBuP6AIrrMVs	2026-03-09 09:58:13.82663	2026-03-10 09:58:13.826	auth	f
30	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgyOTQsImV4cCI6MTc3MzE1NDY5NH0.ZP2dhXWG9jcoAUWbAFDIZMzJcMx3b1twxzh2cI2RuLc	2026-03-09 09:58:14.537743	2026-03-10 09:58:14.537	auth	f
31	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgyOTQsImV4cCI6MTc3MzE1NDY5NH0.ZP2dhXWG9jcoAUWbAFDIZMzJcMx3b1twxzh2cI2RuLc	2026-03-09 09:58:14.703034	2026-03-10 09:58:14.702	auth	f
32	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgyOTUsImV4cCI6MTc3MzE1NDY5NX0.fmYGmTBo9o6C7fiuYVLJ--Mo04x_WTJmRcNMKchjJFw	2026-03-09 09:58:15.180472	2026-03-10 09:58:15.179	auth	f
33	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgyOTUsImV4cCI6MTc3MzE1NDY5NX0.fmYGmTBo9o6C7fiuYVLJ--Mo04x_WTJmRcNMKchjJFw	2026-03-09 09:58:15.321844	2026-03-10 09:58:15.321	auth	f
34	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgyOTYsImV4cCI6MTc3MzE1NDY5Nn0.y8HTbJh59YcBcuI4_C2LYdMxlOcUt3m01neocoiQSus	2026-03-09 09:58:16.020501	2026-03-10 09:58:16.019	auth	f
35	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgzMTEsImV4cCI6MTc3MzE1NDcxMX0.FgY8OC5cwu9TtAZ4SBHvlb4ggyHybk-RLeo47vGV60s	2026-03-09 09:58:31.223661	2026-03-10 09:58:31.222	auth	f
36	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgzMTIsImV4cCI6MTc3MzE1NDcxMn0.ymxqrHT0_s_zf1MK4e3NKIk7oCjqvrNtYTs2md6WIHc	2026-03-09 09:58:32.787434	2026-03-10 09:58:32.786	auth	f
37	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgzMTQsImV4cCI6MTc3MzE1NDcxNH0.oT9bMWIMNgGKJ0evlbBM9PU0qjJI4X5jlz5XoopWeoM	2026-03-09 09:58:34.522782	2026-03-10 09:58:34.521	auth	f
38	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgzMTUsImV4cCI6MTc3MzE1NDcxNX0.fTB-8RdYD4tWHViFQ7PYPThDr-fRR73cUsn2SWHuRko	2026-03-09 09:58:35.690033	2026-03-10 09:58:35.689	auth	f
39	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMwNjgzMTUsImV4cCI6MTc3MzE1NDcxNX0.fTB-8RdYD4tWHViFQ7PYPThDr-fRR73cUsn2SWHuRko	2026-03-09 09:58:35.814697	2026-03-10 09:58:35.813	auth	f
40	18	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjE4LCJkb2N1bWVudG8iOiIxMDM2NDUzMDE2IiwiY29ycmVvIjoiZ3VhZGFsdXBlQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJndWFkYWx1cGUgZXN0cmFkYSBmcmFuY28iLCJyb2wiOiJ1c3VhcmlvIiwiaWF0IjoxNzczMTQ1MTg4LCJleHAiOjE3NzMyMzE1ODh9.LwFQxwS_Ma7rF03fTIWuzrL5cfw6wG0OzKyqV9tASwY	2026-03-10 07:19:48.543977	2026-03-11 07:19:48.542	auth	f
41	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMxNDY1MzEsImV4cCI6MTc3MzIzMjkzMX0.17gw5uG1FJpRPCCcgrfHhaw7DPdH1avBdKLUdGcmNB8	2026-03-10 07:42:11.147449	2026-03-11 07:42:11.145	auth	f
42	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzMxNDcyNTQsImV4cCI6MTc3MzIzMzY1NH0.7HdvKD-_iFptrnoMD2cTXuSGeq3N9JfQiTZRQB39aus	2026-03-10 07:54:14.192247	2026-03-11 07:54:14.191	auth	f
43	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzMxNDcyNTgsImV4cCI6MTc3MzIzMzY1OH0.kyy2zHOh8y6gBMPlk4OsCU8igoelWct2GNOC68bMHFo	2026-03-10 07:54:18.083705	2026-03-11 07:54:18.082	auth	f
44	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzMxNDcyNjUsImV4cCI6MTc3MzIzMzY2NX0.fYv0xGhSMf7NxtJTIZUFNiLoz0-9ARjrGYup2w-dRFk	2026-03-10 07:54:25.381127	2026-03-11 07:54:25.379	auth	f
45	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzMxNDcyNjYsImV4cCI6MTc3MzIzMzY2Nn0.Dt8URXWYFc7WBA8jAtqX83bQv5hxyUKhPN6DI8tHcsQ	2026-03-10 07:54:26.938254	2026-03-11 07:54:26.937	auth	f
46	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzMxNDcyNjcsImV4cCI6MTc3MzIzMzY2N30.jxhnJE67m3QSctva3oG4z3QNPFQd0fcDioCO_PuUrTY	2026-03-10 07:54:27.565282	2026-03-11 07:54:27.564	auth	f
47	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzMxNDcyNjcsImV4cCI6MTc3MzIzMzY2N30.jxhnJE67m3QSctva3oG4z3QNPFQd0fcDioCO_PuUrTY	2026-03-10 07:54:27.755874	2026-03-11 07:54:27.754	auth	f
48	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzMxNDcyNzAsImV4cCI6MTc3MzIzMzY3MH0.OdvV-Di38cjlGx-Sn_bzhr2yvS1_Q3raaUCZtZz7gqo	2026-03-10 07:54:30.757471	2026-03-11 07:54:30.756	auth	f
49	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzMxNDcyNzUsImV4cCI6MTc3MzIzMzY3NX0.oDIQor-n4GQ3XFozcqLJTXYVsoBZmyBF8OW9FCufvlg	2026-03-10 07:54:35.513085	2026-03-11 07:54:35.511	auth	f
50	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzMxNDcyNzUsImV4cCI6MTc3MzIzMzY3NX0.oDIQor-n4GQ3XFozcqLJTXYVsoBZmyBF8OW9FCufvlg	2026-03-10 07:54:35.528903	2026-03-11 07:54:35.527	auth	f
51	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjMsImRvY3VtZW50byI6IjEwMzY2ODA1MDYiLCJjb3JyZW8iOiJzZWJhc3RoaWFubG9wZXpmcmFuY29AZ21haWwuY29tIiwibm9tYnJlcyI6InNlYmFzaGlhbiBsb3BleiIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzMxNDcyNzksImV4cCI6MTc3MzIzMzY3OX0.DHhDQSPuwKJq8BzoV7EsBZ-6cw7Ln9El-AFiBzQnmeo	2026-03-10 07:54:39.445527	2026-03-11 07:54:39.444	auth	f
52	18	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjE4LCJkb2N1bWVudG8iOiIxMDM2NDUzMDE2IiwiY29ycmVvIjoiZ3VhZGFsdXBlQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJndWFkYWx1cGUgZXN0cmFkYSBmcmFuY28iLCJyb2wiOiJlbXBsZWFkbyIsImlhdCI6MTc3MzE0NzUyMywiZXhwIjoxNzczMjMzOTIzfQ.xtjFrJqANI8rrF-9ThCYjtHTgM2bDm_X9CqJj4k8H78	2026-03-10 07:58:43.164185	2026-03-11 07:58:43.163	auth	f
53	18	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjE4LCJkb2N1bWVudG8iOiIxMDM2NDUzMDE2IiwiY29ycmVvIjoiZ3VhZGFsdXBlQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJndWFkYWx1cGUgZXN0cmFkYSBmcmFuY28iLCJyb2wiOiJlbXBsZWFkbyIsImlhdCI6MTc3MzE0NzUyNCwiZXhwIjoxNzczMjMzOTI0fQ.Bo5PXTDKTOrlIzS6iFHK31TLDox2XnZd4aW_CQfQCKg	2026-03-10 07:58:44.74372	2026-03-11 07:58:44.743	auth	f
54	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMyNDAyMzIsImV4cCI6MTc3MzMyNjYzMn0.gACQMwHf_FQRuBMyANJRaRkDktS7V4rs0TU0sX0frBg	2026-03-11 09:43:52.472655	2026-03-12 09:43:52.469	auth	f
55	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMyNDAyNDcsImV4cCI6MTc3MzMyNjY0N30.DbzkOPJeD3NEi7RR0mHRKEQGj6iVptjHvA0TwRM_pLs	2026-03-11 09:44:07.249288	2026-03-12 09:44:07.247	auth	f
56	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTAiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzMyNDAyNDgsImV4cCI6MTc3MzMyNjY0OH0.axyV1aB3FkxO7PDLxSrfPc5jepuzBW4n9sXWlxGHg40	2026-03-11 09:44:08.979718	2026-03-12 09:44:08.978	auth	f
\.


--
-- TOC entry 5219 (class 0 OID 41541)
-- Dependencies: 242
-- Data for Name: turnos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.turnos (id_turno, id_empleado, fecha, hora_inicio, hora_fin, pagado) FROM stdin;
1	1	2026-03-10	02:00:00	10:00:00	t
\.


--
-- TOC entry 5197 (class 0 OID 16988)
-- Dependencies: 220
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (idusuario, documento, nombres, correo, telefono, contrasena, pregunta, respuesta, intentos_fallidos, estado, rol, fecha_creacion, intentos) FROM stdin;
3	1036680506	sebashian lopez	sebasthianlopezfranco@gmail.com	3207550942	$2b$10$C7yRmbirKmInmRHwnSMgwejY96U/1loUk2wVHKaT.c4c0ased7qQK	¿Cuál es el nombre de tu primera mascota?	$2b$10$fQ8PfGYc44jC2mz8S3epX.rjizRlPD/OSq1YLdAaDzm2JRGAO//eO	0	activo	usuario	2026-03-05 08:51:31.288584	0
18	1036453016	guadalupe estrada franco	guadalupe@gmail.com	3207550947	$2b$10$7W.R0hZJ/KZCcX55LpjBNuaQTk2p.peoqEXLUTkAvWJj6QkW10TnK	¿Cuál es el nombre de tu primera mascota?	$2b$10$jKbBKyBLyeEzTnkEJYXuTeNcZLa8VBojVrg1j/Srz2CgE.Qs68N0i	0	activo	empleado	2026-03-05 08:55:34.891477	0
19	1234567890	maria antonia estrada	mae@gmail.com	3138837956	$2b$10$XczrTuzYUicnnufmmW1rEOrUIO7C3xEYjDfnMG1OfGrFvIGut3MoS	¿Cuál es el nombre de tu primera mascota?	$2b$10$X/U1AV2O4ZaHsMWRliLdJOO1nwPKkTqLr4exlucEzBMnep/yAVYpe	0	activo	usuario	2026-03-05 10:24:32.972851	0
1	1036453010	jhunior franco	jhunior@gmail.com	3234565678	$2b$10$I7hhrzOi5YX5ShVgT8mlOeFgCcS7N57Ux0w1i9Uf714GjyvaeqJSS	¿Cuál es el nombre de tu primera mascota?	$2b$10$kp4Sdani2C1zCnJWHT3bmOW0o3.TClknBboMmVnLl2ZjhqFm3T75q	0	activo	gerente	2026-03-05 08:31:05.446317	0
\.


--
-- TOC entry 5243 (class 0 OID 0)
-- Dependencies: 235
-- Name: categorias_idcategoria_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categorias_idcategoria_seq', 5, true);


--
-- TOC entry 5244 (class 0 OID 0)
-- Dependencies: 231
-- Name: detalles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.detalles_id_seq', 11, true);


--
-- TOC entry 5245 (class 0 OID 0)
-- Dependencies: 223
-- Name: direcciones_iddireccion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.direcciones_iddireccion_seq', 2, true);


--
-- TOC entry 5246 (class 0 OID 0)
-- Dependencies: 239
-- Name: empleados_id_empleado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.empleados_id_empleado_seq', 1, true);


--
-- TOC entry 5247 (class 0 OID 0)
-- Dependencies: 237
-- Name: estado_idestado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.estado_idestado_seq', 1, false);


--
-- TOC entry 5248 (class 0 OID 0)
-- Dependencies: 229
-- Name: factura_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.factura_id_seq', 4, true);


--
-- TOC entry 5249 (class 0 OID 0)
-- Dependencies: 233
-- Name: gastos_idgastos_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.gastos_idgastos_seq', 1, false);


--
-- TOC entry 5250 (class 0 OID 0)
-- Dependencies: 248
-- Name: notificaciones_idnotificacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notificaciones_idnotificacion_seq', 10, true);


--
-- TOC entry 5251 (class 0 OID 0)
-- Dependencies: 245
-- Name: pagos_empleados_idpago_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pagos_empleados_idpago_seq', 1, true);


--
-- TOC entry 5252 (class 0 OID 0)
-- Dependencies: 225
-- Name: pedidos_idpedido_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pedidos_idpedido_seq', 4, true);


--
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 227
-- Name: productos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.productos_id_seq', 67, true);


--
-- TOC entry 5254 (class 0 OID 0)
-- Dependencies: 221
-- Name: tokens_idtoken_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tokens_idtoken_seq', 56, true);


--
-- TOC entry 5255 (class 0 OID 0)
-- Dependencies: 241
-- Name: turnos_id_turno_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.turnos_id_turno_seq', 1, true);


--
-- TOC entry 5256 (class 0 OID 0)
-- Dependencies: 219
-- Name: usuarios_idusuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuarios_idusuario_seq', 19, true);


--
-- TOC entry 5016 (class 2606 OID 41486)
-- Name: categorias categorias_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_nombre_key UNIQUE (nombre);


--
-- TOC entry 5018 (class 2606 OID 41484)
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (idcategoria);


--
-- TOC entry 5012 (class 2606 OID 41450)
-- Name: detalles detalles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalles
    ADD CONSTRAINT detalles_pkey PRIMARY KEY (id);


--
-- TOC entry 5004 (class 2606 OID 41236)
-- Name: direcciones direcciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.direcciones
    ADD CONSTRAINT direcciones_pkey PRIMARY KEY (iddireccion);


--
-- TOC entry 5022 (class 2606 OID 41539)
-- Name: empleados empleados_documento_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_documento_key UNIQUE (documento);


--
-- TOC entry 5024 (class 2606 OID 41537)
-- Name: empleados empleados_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_pkey PRIMARY KEY (id_empleado);


--
-- TOC entry 5020 (class 2606 OID 41505)
-- Name: estado estado_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estado
    ADD CONSTRAINT estado_pkey PRIMARY KEY (idestado);


--
-- TOC entry 5010 (class 2606 OID 41320)
-- Name: factura factura_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_pkey PRIMARY KEY (idfactura);


--
-- TOC entry 5014 (class 2606 OID 41472)
-- Name: gastos gastos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gastos
    ADD CONSTRAINT gastos_pkey PRIMARY KEY (idgastos);


--
-- TOC entry 5030 (class 2606 OID 49500)
-- Name: notificaciones notificaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notificaciones
    ADD CONSTRAINT notificaciones_pkey PRIMARY KEY (idnotificacion);


--
-- TOC entry 5028 (class 2606 OID 49475)
-- Name: pagos_empleados pagos_empleados_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagos_empleados
    ADD CONSTRAINT pagos_empleados_pkey PRIMARY KEY (idpago);


--
-- TOC entry 5006 (class 2606 OID 41254)
-- Name: pedidos pedidos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_pkey PRIMARY KEY (idpedido);


--
-- TOC entry 5008 (class 2606 OID 41290)
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (idproductos);


--
-- TOC entry 5002 (class 2606 OID 33025)
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (idtoken);


--
-- TOC entry 5026 (class 2606 OID 41550)
-- Name: turnos turnos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turnos
    ADD CONSTRAINT turnos_pkey PRIMARY KEY (id_turno);


--
-- TOC entry 4996 (class 2606 OID 17010)
-- Name: usuarios usuarios_correo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_correo_key UNIQUE (correo);


--
-- TOC entry 4998 (class 2606 OID 17008)
-- Name: usuarios usuarios_documento_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_documento_key UNIQUE (documento);


--
-- TOC entry 5000 (class 2606 OID 17006)
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (idusuario);


--
-- TOC entry 5040 (class 2606 OID 41451)
-- Name: detalles detalles_factura_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalles
    ADD CONSTRAINT detalles_factura_id_fkey FOREIGN KEY (idfactura) REFERENCES public.factura(idfactura) ON DELETE CASCADE;


--
-- TOC entry 5041 (class 2606 OID 41456)
-- Name: detalles detalles_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalles
    ADD CONSTRAINT detalles_producto_id_fkey FOREIGN KEY (idproductos) REFERENCES public.productos(idproductos) ON DELETE RESTRICT;


--
-- TOC entry 5038 (class 2606 OID 41321)
-- Name: factura factura_idusuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_idusuario_fkey FOREIGN KEY (idusuario) REFERENCES public.usuarios(idusuario) ON DELETE RESTRICT;


--
-- TOC entry 5032 (class 2606 OID 41260)
-- Name: pedidos fk_direccion_pedido; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT fk_direccion_pedido FOREIGN KEY (iddireccion) REFERENCES public.direcciones(iddireccion);


--
-- TOC entry 5042 (class 2606 OID 41575)
-- Name: empleados fk_empleado_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT fk_empleado_usuario FOREIGN KEY (idusuario) REFERENCES public.usuarios(idusuario) ON DELETE SET NULL;


--
-- TOC entry 5039 (class 2606 OID 41519)
-- Name: factura fk_factura_estado; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT fk_factura_estado FOREIGN KEY (idestado) REFERENCES public.estado(idestado);


--
-- TOC entry 5044 (class 2606 OID 49476)
-- Name: pagos_empleados fk_pago_empleado; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagos_empleados
    ADD CONSTRAINT fk_pago_empleado FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado) ON DELETE CASCADE;


--
-- TOC entry 5033 (class 2606 OID 41507)
-- Name: pedidos fk_pedido_estado; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT fk_pedido_estado FOREIGN KEY (idestado) REFERENCES public.estado(idestado);


--
-- TOC entry 5034 (class 2606 OID 41492)
-- Name: pedidos fk_pedidos_factura; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT fk_pedidos_factura FOREIGN KEY (idfactura) REFERENCES public.factura(idfactura);


--
-- TOC entry 5036 (class 2606 OID 41513)
-- Name: productos fk_producto_estado; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT fk_producto_estado FOREIGN KEY (idestado) REFERENCES public.estado(idestado);


--
-- TOC entry 5031 (class 2606 OID 41237)
-- Name: direcciones fk_usuario_direccion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.direcciones
    ADD CONSTRAINT fk_usuario_direccion FOREIGN KEY (idusuario) REFERENCES public.usuarios(idusuario) ON DELETE CASCADE;


--
-- TOC entry 5035 (class 2606 OID 41255)
-- Name: pedidos fk_usuario_pedido; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT fk_usuario_pedido FOREIGN KEY (idusuario) REFERENCES public.usuarios(idusuario) ON DELETE CASCADE;


--
-- TOC entry 5045 (class 2606 OID 49501)
-- Name: notificaciones notificaciones_idusuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notificaciones
    ADD CONSTRAINT notificaciones_idusuario_fkey FOREIGN KEY (idusuario) REFERENCES public.usuarios(idusuario) ON DELETE CASCADE;


--
-- TOC entry 5037 (class 2606 OID 41487)
-- Name: productos productos_idcategoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_idcategoria_fkey FOREIGN KEY (idcategoria) REFERENCES public.categorias(idcategoria) ON DELETE SET NULL;


--
-- TOC entry 5043 (class 2606 OID 41551)
-- Name: turnos turnos_id_empleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.turnos
    ADD CONSTRAINT turnos_id_empleado_fkey FOREIGN KEY (id_empleado) REFERENCES public.empleados(id_empleado);


-- Completed on 2026-03-11 20:08:06

--
-- PostgreSQL database dump complete
--

\unrestrict Yxyc8soOyIxZdNBA3BCISkdawxHnOExE7SDqbiuuEwpiaGAEo9P4DQjUjgjJFrz

