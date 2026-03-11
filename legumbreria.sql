--
-- PostgreSQL database dump
--

\restrict LfUPrz4GCyprjO0i4FBfYOhn27sTNEmvhhsstESUc4eTRSB30WdWflnzpFV45cL

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

-- Started on 2026-03-04 23:38:22

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
1	1	5	1.00	4800.00	4800.00
2	1	42	1.00	9999.00	9999.00
3	1	4	1.00	3800.00	3800.00
4	1	3	1.00	4500.00	4500.00
5	1	2	1.00	3500.00	3500.00
6	2	41	1.00	9999.00	9999.00
7	2	5	1.00	4800.00	4800.00
8	2	4	1.00	3800.00	3800.00
9	2	42	1.00	9999.00	9999.00
10	2	41	1.00	9999.00	9999.00
11	3	42	1.00	9999.00	9999.00
12	3	29	1.00	2800.00	2800.00
13	3	22	1.00	1500.00	1500.00
14	12	19	1.00	4200.00	4200.00
15	12	29	1.00	2800.00	2800.00
16	12	42	1.00	9999.00	9999.00
17	12	41	1.00	9999.00	9999.00
18	12	27	2.00	5000.00	10000.00
19	13	33	1.00	4500.00	4500.00
20	13	42	1.00	9999.00	9999.00
21	13	41	1.00	9999.00	9999.00
22	13	40	1.00	2500.00	2500.00
23	13	39	1.00	15000.00	15000.00
24	13	38	1.00	1000.00	1000.00
25	14	38	1.00	1000.00	1000.00
26	15	31	1.00	4000.00	4000.00
27	15	13	1.00	3800.00	3800.00
28	15	42	2.00	9999.00	19998.00
29	16	43	1.00	4000.00	4000.00
30	16	5	1.00	4800.00	4800.00
31	16	4	1.00	3800.00	3800.00
32	16	3	1.00	4500.00	4500.00
33	16	15	1.00	9500.00	9500.00
34	16	14	1.00	3000.00	3000.00
35	16	13	1.00	3800.00	3800.00
36	16	12	1.00	4200.00	4200.00
37	17	43	1.00	4000.00	4000.00
38	17	42	1.00	9999.00	9999.00
39	17	41	1.00	9999.00	9999.00
40	17	40	1.00	2500.00	2500.00
41	17	39	1.00	15000.00	15000.00
42	17	38	1.00	1000.00	1000.00
43	17	37	1.00	9000.00	9000.00
44	17	36	2.00	12000.00	24000.00
45	18	29	1.00	2800.00	2800.00
46	18	18	1.00	2500.00	2500.00
47	19	5	1.00	4800.00	4800.00
48	19	43	2.00	4000.00	8000.00
49	19	42	3.00	9999.00	29997.00
50	20	5	1.00	4800.00	4800.00
51	20	43	2.00	4000.00	8000.00
52	20	42	3.00	9999.00	29997.00
53	21	5	1.00	4800.00	4800.00
54	21	43	2.00	4000.00	8000.00
55	21	42	3.00	9999.00	29997.00
\.


--
-- TOC entry 5201 (class 0 OID 41224)
-- Dependencies: 224
-- Data for Name: direcciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.direcciones (iddireccion, idusuario, calle, ciudad, departamento, codigo_postal, referencia, fecha_creacion, activo) FROM stdin;
1	1	Dirección por definir	Medellín	\N	\N	\N	2026-02-18 23:34:51.641103	f
2	1	calle 83 #53 45 laureles	medellin	casa	\N	al lado de consulsidio	2026-02-19 16:33:13.677552	f
3	1	Calle 50 #34 45	Itagüí	Mi Casa	\N	Segundo piso 	2026-02-28 17:18:42.039038	t
4	6	Calle 50 #45	Itagüí	Mi Casa	\N		2026-03-04 16:44:18.223101	t
5	7	Calle 50	Itagüí	Mi Casa	\N		2026-03-04 21:09:50.450577	t
\.


--
-- TOC entry 5217 (class 0 OID 41526)
-- Dependencies: 240
-- Data for Name: empleados; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.empleados (id_empleado, nombre, documento, salario_mensual, auxilio_transporte, activo, descuentos, ultima_fecha_descuento, horas_descuento_acumuladas, idusuario) FROM stdin;
1	jhunior franco	1036453018	1300000.00	162000.00	t	0.00	\N	0.00	1
2	maria antonia estrada	123456789	1300000.00	162000.00	t	0.00	\N	0.00	6
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
11	1	2026-02-26 11:07:14.943633	27198.00	CONTRAENTREGA	2
17	6	2026-03-04 16:44:20.2874	90498.00	CONTRAENTREGA	2
16	1	2026-03-04 15:51:19.03714	52600.00	CONTRAENTREGA	2
15	1	2026-02-28 17:18:43.255433	27798.00	CONTRAENTREGA	2
14	1	2026-02-28 16:50:30.107847	1000.00	CONTRAENTREGA	3
13	1	2026-02-28 15:37:59.983685	42998.00	CONTRAENTREGA	2
12	1	2026-02-28 15:35:03.257305	36998.00	CONTRAENTREGA	3
10	1	2026-02-26 10:53:30.508441	19998.00	CONTRAENTREGA	2
9	1	2026-02-26 10:53:09.652355	36598.00	CONTRAENTREGA	2
2	1	2026-02-19 07:50:33.995842	38597.00	BANCOLOMBIA	3
1	1	2026-02-18 23:34:51.633975	26599.00	CONTRAENTREGA	2
3	1	2026-02-19 08:39:51.821874	14299.00	CONTRAENTREGA	2
18	6	2026-03-04 20:11:57.953459	20300.00	CONTRAENTREGA	1
19	7	2026-03-04 21:09:51.949891	78096.00	CONTRAENTREGA	1
20	7	2026-03-04 21:09:54.994493	78096.00	CONTRAENTREGA	1
21	7	2026-03-04 21:11:34.734724	78096.00	CONTRAENTREGA	1
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
\.


--
-- TOC entry 5221 (class 0 OID 49465)
-- Dependencies: 246
-- Data for Name: pagos_empleados; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pagos_empleados (idpago, id_empleado, fecha_pago, salario_base, descuentos, salario_pagado, metodo_pago, observacion) FROM stdin;
1	2	2026-02-26	\N	0.00	256545.44	Transferencia	Pago mensual - Horas: 16.0
2	1	2026-02-26	\N	0.00	162000.00	Transferencia	Pago mensual - Horas: 0.0
3	2	2026-02-26	\N	0.00	256545.44	Transferencia	Pago mensual - Horas: 16.0
4	2	2026-02-26	\N	0.00	256545.44	Transferencia	Pago mensual - Horas: 16.0
5	2	2026-02-26	1300000.00	0.00	256545.44	Transferencia	Pago mensual - Horas: 16.0
6	2	2026-03-04	1300000.00	0.00	209272.72	Transferencia	Pago mensual - Horas: 8.0
\.


--
-- TOC entry 5203 (class 0 OID 41243)
-- Dependencies: 226
-- Data for Name: pedidos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pedidos (idpedido, idusuario, iddireccion, fecha, total, idfactura, idestado) FROM stdin;
13	6	4	2026-03-04 20:11:57.997734	20300.00	18	1
14	7	5	2026-03-04 21:09:51.979248	78096.00	19	1
15	7	5	2026-03-04 21:09:54.99915	78096.00	20	1
16	7	5	2026-03-04 21:11:34.782726	78096.00	21	1
\.


--
-- TOC entry 5205 (class 0 OID 41273)
-- Dependencies: 228
-- Data for Name: productos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.productos (idproductos, nombre, descripcion, tipo_venta, precio, stock, fecha_creacion, costo, idcategoria, idestado) FROM stdin;
1	tomate	frescos del campo	KG	2100.00	100.00	2026-02-17 11:05:30.309083	0.00	\N	1
6	banano	Banano fresco maduro	KG	3200.00	150.00	2026-02-18 22:14:13.650201	0.00	2	1
7	fresa	Fresa fresca roja	KG	9000.00	80.00	2026-02-18 22:14:13.650201	0.00	2	1
8	mandarina	Mandarina dulce	KG	3500.00	120.00	2026-02-18 22:14:13.650201	0.00	2	1
9	mango	Mango tropical maduro	KG	4500.00	90.00	2026-02-18 22:14:13.650201	0.00	2	1
10	manzana	Manzana roja importada	KG	7800.00	100.00	2026-02-18 22:14:13.650201	0.00	2	1
11	melon	Melón dulce fresco	KG	4000.00	70.00	2026-02-18 22:14:13.650201	0.00	2	1
16	acelga	Acelga fresca verde	KG	2800.00	100.00	2026-02-18 22:14:47.145417	0.00	3	1
17	apio	Apio fresco	KG	2600.00	100.00	2026-02-18 22:14:47.145417	0.00	3	1
20	cebolla cabezona	Cebolla blanca cabezona	KG	2200.00	150.00	2026-02-18 22:14:47.145417	0.00	3	1
21	cebolla morada	Cebolla morada fresca	KG	2500.00	120.00	2026-02-18 22:14:47.145417	0.00	3	1
23	coliflor	Coliflor fresca blanca	KG	4000.00	80.00	2026-02-18 22:14:47.145417	0.00	3	1
24	espinaca	Espinaca fresca verde	KG	3000.00	100.00	2026-02-18 22:14:47.145417	0.00	3	1
25	lechuga	Lechuga fresca verde	UNIDAD	2000.00	150.00	2026-02-18 22:14:47.145417	0.00	3	1
26	pepino	Pepino fresco	KG	2500.00	120.00	2026-02-18 22:14:47.145417	0.00	3	1
28	rabano	Rábano fresco rojo	KG	3500.00	80.00	2026-02-18 22:14:47.145417	0.00	3	1
30	repollo	Repollo verde fresco	KG	2200.00	130.00	2026-02-18 22:14:47.145417	0.00	3	1
32	zanahoria	Zanahoria fresca	KG	2700.00	150.00	2026-02-18 22:14:47.145417	0.00	3	1
34	arroz integral	Arroz integral natural	KG	5500.00	200.00	2026-02-18 22:15:02.444372	0.00	4	1
35	avena	Avena en hojuelas	KG	4800.00	150.00	2026-02-18 22:15:02.444372	0.00	4	1
4	habichuelas	Habichuela fresca verde	KG	3800.00	97.00	2026-02-18 22:13:50.02425	0.00	1	1
2	mango	sdgsdfsdf	KG	3500.00	122.00	2026-02-18 21:34:12.203395	0.00	1	1
3	arveja	Arveja verde seca seleccionada	KG	4500.00	98.00	2026-02-18 22:13:50.02425	0.00	1	1
15	uva-verde	Uva verde sin semilla	KG	9500.00	69.00	2026-02-18 22:14:13.650201	0.00	2	1
14	sandia	Sandía jugosa fresca	KG	3000.00	99.00	2026-02-18 22:14:13.650201	0.00	2	1
13	pina	Piña dulce fresca	KG	3800.00	58.00	2026-02-18 22:14:13.650201	0.00	2	1
12	papaya	Papaya tropical madura	KG	4200.00	79.00	2026-02-18 22:14:13.650201	0.00	2	1
22	cebollin	Cebollín fresco	UNIDAD	1500.00	199.00	2026-02-18 22:14:47.145417	0.00	3	1
19	brocoli	Brócoli fresco verde	KG	4200.00	89.00	2026-02-18 22:14:47.145417	0.00	3	1
42	diego	Producto especial diego	UNIDAD	9999.00	2.00	2026-02-18 23:02:43.563486	0.00	3	1
27	pimenton	Pimentón rojo fresco	KG	5000.00	88.00	2026-02-18 22:14:47.145417	0.00	3	1
33	berenjena	Berenjena fresca morada	KG	4500.00	79.00	2026-02-18 22:14:47.145417	0.00	3	1
41	anderson	Producto especial anderson	UNIDAD	9999.00	5.00	2026-02-18 23:02:43.563486	0.00	3	1
40	tomillo y laurel	Mezcla de tomillo y laurel	UNIDAD	2500.00	98.00	2026-02-18 22:15:25.994797	0.00	5	1
31	tomate	Tomate rojo fresco	KG	4000.00	149.00	2026-02-18 22:14:47.145417	0.00	3	1
39	flor de jamaica	Flor de jamaica seca	KG	15000.00	58.00	2026-02-18 22:15:25.994797	0.00	5	1
38	cilantro	Cilantro fresco	UNIDAD	1000.00	197.00	2026-02-18 22:15:25.994797	0.00	5	1
37	ajo	Ajo fresco nacional	KG	9000.00	69.00	2026-02-18 22:15:25.994797	0.00	5	1
36	granola	Granola natural	KG	12000.00	98.00	2026-02-18 22:15:02.444372	0.00	4	1
29	remolacha	Remolacha fresca	KG	2800.00	97.00	2026-02-18 22:14:47.145417	0.00	3	1
18	auyama	Auyama fresca	KG	2500.00	119.00	2026-02-18 22:14:47.145417	0.00	3	1
5	lenteja	Lenteja seca nacional	KG	4800.00	94.00	2026-02-18 22:13:50.02425	0.00	1	1
43	Aguacate	Maduros y deliciosos	KG	4000.00	27.00	2026-02-28 17:42:43.894534	0.00	1	1
\.


--
-- TOC entry 5199 (class 0 OID 33011)
-- Dependencies: 222
-- Data for Name: tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tokens (idtoken, idusuario, token, fechacreacion, fechaexpiracion, tipo, usado) FROM stdin;
1	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NjU0MTk0NzMsImV4cCI6MTc2NTUwNTg3M30.AmH6D_Y7uJusO9SeBsPy5pdrFjgCqlsf7m87eRbDTxE	2025-12-10 21:17:53.544575	2025-12-11 21:17:53.544	auth	f
2	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NjU0MzE0OTYsImV4cCI6MTc2NTUxNzg5Nn0.5OcTI-rifm6zPelv6qDd1WungrM2lOTtHewaiCKkgGU	2025-12-11 00:38:16.537334	2025-12-12 00:38:16.536	auth	f
3	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NjU0MzE1ODUsImV4cCI6MTc2NTUxNzk4NX0.dT5WyfruBtdU4WJvkFFqJ6kJPVRCE8nqIERV_oidxOM	2025-12-11 00:39:45.721547	2025-12-12 00:39:45.72	auth	f
4	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzA3MzA5NTUsImV4cCI6MTc3MDgxNzM1NX0.zMr8HT3sUuSUlSLw2BpYKy4K8nibyZKLo_1aSQ_Wh_s	2026-02-10 08:42:35.143705	2026-02-11 08:42:35.139	auth	f
5	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzA3MzQ3NzQsImV4cCI6MTc3MDgyMTE3NH0.XvehUbOcdm9XP51GYQAogMwTDDI7GHKxCMUAmDL5EOQ	2026-02-10 09:46:14.950932	2026-02-11 09:46:14.949	auth	f
6	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzA3MzU0MDgsImV4cCI6MTc3MDgyMTgwOH0.x9HfCTP7hUgasEdSjlZwaP4o4B-jrDtcWGHBBQ9a6OU	2026-02-10 09:56:48.172485	2026-02-11 09:56:48.171	auth	f
7	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzA3MzU0MDksImV4cCI6MTc3MDgyMTgwOX0.8XBn-boSbzSDSlAxUVxhhxGZ68dztDgVH3YoPMjT9a0	2026-02-10 09:56:49.068578	2026-02-11 09:56:49.067	auth	f
8	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEyMzQ1Njc4OTAiLCJjb3JyZW8iOiJ0ZXN0QGV4YW1wbGUuY29tIiwibm9tYnJlcyI6IlRlc3QgVXNlciIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzA3Mzc2ODUsImV4cCI6MTc3MDgyNDA4NX0.CwTVyiAUUO5uj8xqoIssbh-R16DPLoGQ3o4vF3lf9sc	2026-02-10 10:34:45.331242	2026-02-11 10:34:45.328	auth	f
9	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzA3MzgyNzMsImV4cCI6MTc3MDgyNDY3M30.VuLJ9UXKmZi-1liY4hPv4Mk3rtqdpQmlKz16yDLfpQo	2026-02-10 10:44:33.621671	2026-02-11 10:44:33.62	auth	f
10	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjIsImRvY3VtZW50byI6IjEyNDU2Nzg5MDkiLCJjb3JyZW8iOiJqaHVuaW9yLmZyYW5nYXJAZ21haWwuY29tIiwibm9tYnJlcyI6ImpodW5pb3IgZnJhbmNvIiwicm9sIjoidXN1YXJpbyIsImlhdCI6MTc3MDczODMwOSwiZXhwIjoxNzcwODI0NzA5fQ.tBOgi9pMO84_DmqZ1Sp6yfjsGyFtEtLxbw_ZIxPW7AE	2026-02-10 10:45:09.803823	2026-02-11 10:45:09.802	auth	f
11	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzA3Mzg1MTUsImV4cCI6MTc3MDgyNDkxNX0.Y87HVna_9THIDl15s-MIbK8MPJen1E2q3WsGkm3uBxo	2026-02-10 10:48:35.347329	2026-02-11 10:48:35.343	auth	f
12	4	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjQsImRvY3VtZW50byI6IjEyMzU0Njc2IiwiY29ycmVvIjoiamh1bmlvci5mcmFuZ2FyMkBnbWFpbC5jb20iLCJub21icmVzIjoiamh1bmlvciBmcmFuY28iLCJyb2wiOiJ1c3VhcmlvIiwiaWF0IjoxNzcwNzM4NTgyLCJleHAiOjE3NzA4MjQ5ODJ9.93Sykr7KgWiTiz1l0iu63cKQ4XiDzw3AaaT3HrK7oJI	2026-02-10 10:49:42.208822	2026-02-11 10:49:42.208	auth	f
13	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjUsImRvY3VtZW50byI6IjM5MjUyMTg1ODIiLCJjb3JyZW8iOiJ0ZXN0XzE3NzA3Mzg3NDg3NTNAZmxvdy5jb20iLCJub21icmVzIjoiVGVzdCBGbG93IFVzZXIiLCJyb2wiOiJ1c3VhcmlvIiwiaWF0IjoxNzcwNzM4NzQ4LCJleHAiOjE3NzA4MjUxNDh9.ZxteJo3wPTb-R1JR75rwEqn6mpcIB8rfphVS6RRVtMc	2026-02-10 10:52:28.964492	2026-02-11 10:52:28.962	auth	f
14	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjUsImRvY3VtZW50byI6IjM5MjUyMTg1ODIiLCJjb3JyZW8iOiJ0ZXN0XzE3NzA3Mzg3NDg3NTNAZmxvdy5jb20iLCJub21icmVzIjoiVGVzdCBGbG93IFVzZXIiLCJyb2wiOiJ1c3VhcmlvIiwiaWF0IjoxNzcwNzM4NzUyLCJleHAiOjE3NzA4MjUxNTJ9.-X_LKnq6ZCRwwiYh40rA4echKri-ZLI-nX_W1rn8R50	2026-02-10 10:52:32.112645	2026-02-11 10:52:32.11	auth	f
15	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzA3Mzg4OTgsImV4cCI6MTc3MDgyNTI5OH0.uTFVwyGvmyvI25zDPIyQS-VsebnAySrFPnaQ-JqWmAA	2026-02-10 10:54:58.85697	2026-02-11 10:54:58.856	auth	f
16	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzA3MzkxMDYsImV4cCI6MTc3MDgyNTUwNn0.yGsFzvhOPrFY0Y8NlKhjCOJzpun84Pe0gy0nCeatmMo	2026-02-10 10:58:26.168331	2026-02-11 10:58:26.167	auth	f
17	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzA4MTUzODQsImV4cCI6MTc3MDkwMTc4NH0.d0JKSvkNsu-PFI1YkMEFaDoqAfh7Qf-7XnqWVPCUd7I	2026-02-11 08:09:44.463477	2026-02-12 08:09:44.462	auth	f
18	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzA4MzE1ODIsImV4cCI6MTc3MDkxNzk4Mn0.yuwapEL8mJULVTTDIQx4DEhsUlQn4BcVmcvk8Vh1kH4	2026-02-11 12:39:42.659956	2026-02-12 12:39:42.659	auth	f
19	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzA4NDkxODYsImV4cCI6MTc3MDkzNTU4Nn0.1AWXBXXzNK31KAqDxPndTxHHk5RnY7Haj_r0DOSLUe0	2026-02-11 17:33:06.256023	2026-02-12 17:33:06.254	auth	f
20	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzA4NDk0OTYsImV4cCI6MTc3MDkzNTg5Nn0.hEpevO87ySIs6QgAfZnbUhTzs1APkgyjrnHi-jyE82Y	2026-02-11 17:38:16.63416	2026-02-12 17:38:16.633	auth	f
21	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzA5MDE0MDMsImV4cCI6MTc3MDk4NzgwM30.4Og805D9MfAiReyaxPaUuzNo8EVfhxpEVqItQEXezOw	2026-02-12 08:03:23.236715	2026-02-13 08:03:23.235	auth	f
22	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzA5MDM5OTAsImV4cCI6MTc3MDk5MDM5MH0.WFAEPnLHdJoKtRwb6RgbPiD_w65DBbaTyS6IQ_O3h6w	2026-02-12 08:46:30.38572	2026-02-13 08:46:30.381	auth	f
23	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzA5OTAwMjgsImV4cCI6MTc3MTA3NjQyOH0.A_aaHBwLtBZUg4nbEihcZfotIe_7rSsOjTA49s_RzBs	2026-02-13 08:40:28.595184	2026-02-14 08:40:28.593	auth	f
24	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzEyNTQ4MjgsImV4cCI6MTc3MTM0MTIyOH0.c50xUsr7MhEu3Vlm2uT7zefnYQhTEi3o1zI7zgMppW4	2026-02-16 10:13:48.57762	2026-02-17 10:13:48.576	auth	f
25	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzEyNTQ4MzEsImV4cCI6MTc3MTM0MTIzMX0.SCo45DQe8XClSTxotUrXE5VFiep807Yb_HmcApk3D3I	2026-02-16 10:13:51.484068	2026-02-17 10:13:51.483	auth	f
26	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzEzNDIyNjQsImV4cCI6MTc3MTQyODY2NH0.Z4mOsoQJGxWp-SM82m9uVJasIWsAAl3iKL3f8GIvWRg	2026-02-17 10:31:04.87455	2026-02-18 10:31:04.873	auth	f
27	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzE0MjkxNjYsImV4cCI6MTc3MTUxNTU2Nn0.7p-_AAkZ65gBBFYTwgriJQMNkazm3QrlKid8O4WpIeY	2026-02-18 10:39:26.455656	2026-02-19 10:39:26.454	auth	f
28	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzE0NjUyNTMsImV4cCI6MTc3MTU1MTY1M30.9HUa88bNnpZpgyB_NqriVzKo14L6AV7NsJRcynZ15nM	2026-02-18 20:40:53.738491	2026-02-19 20:40:53.737	auth	f
29	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzE1MDUzMzgsImV4cCI6MTc3MTU5MTczOH0.KS4gh8avvSaay8HmnSJAqhur5bIkgqyrdvuR8MytdeI	2026-02-19 07:48:58.900316	2026-02-20 07:48:58.898	auth	f
30	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzE1MDUzNTAsImV4cCI6MTc3MTU5MTc1MH0.jeZ5oed7eWPS3ZTzeAcTu2rSGYPkSa7Tbi2r0ohjc_k	2026-02-19 07:49:10.35948	2026-02-20 07:49:10.358	auth	f
31	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzE1MDUzNTEsImV4cCI6MTc3MTU5MTc1MX0.8XNBO1FiTKH5Wb95yjIqocJpoKUh3CgXjc_zJZ38QKM	2026-02-19 07:49:11.502888	2026-02-20 07:49:11.501	auth	f
32	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzE1MDUzNjEsImV4cCI6MTc3MTU5MTc2MX0.n-yScrSUse7CGBFHL8EQisvCRnvH0XayuMXXnPbQciw	2026-02-19 07:49:21.244804	2026-02-20 07:49:21.243	auth	f
33	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzE1MDUzNjcsImV4cCI6MTc3MTU5MTc2N30.2EdMrUms6R1grHohD9Z3KT5EGKa6c4gCqB_d2Efcfps	2026-02-19 07:49:27.302917	2026-02-20 07:49:27.301	auth	f
34	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzE1MDUzNjcsImV4cCI6MTc3MTU5MTc2N30.2EdMrUms6R1grHohD9Z3KT5EGKa6c4gCqB_d2Efcfps	2026-02-19 07:49:27.642145	2026-02-20 07:49:27.641	auth	f
35	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzE1MDg1NzMsImV4cCI6MTc3MTU5NDk3M30._hHVS_iF3I6flq7Pd857jsjmseE-oETY1r0BIU32tRc	2026-02-19 08:42:53.681992	2026-02-20 08:42:53.681	auth	f
36	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzE1MTU3ODQsImV4cCI6MTc3MTYwMjE4NH0.godyxz_ZwandFn5wBEYwADZ2Pq5QcMtsc8w6IUuQB3Q	2026-02-19 10:43:04.216452	2026-02-20 10:43:04.216	auth	f
37	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZFVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzE1MTY4MDYsImV4cCI6MTc3MTYwMzIwNn0.VkPPHc-8jiSZD2fXA0jzwmpKuuXnSFVc5_2-K_8k1cc	2026-02-19 11:00:06.975737	2026-02-20 11:00:06.974	auth	f
38	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzE1MjIzMTksImV4cCI6MTc3MTYwODcxOX0.sRP8XA_aZZ7jaaS0IqKYp2B6eyFcS9cds6BmzHyt_wc	2026-02-19 12:31:59.918058	2026-02-20 12:31:59.916	auth	f
39	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzE1MzQ0MDMsImV4cCI6MTc3MTYyMDgwM30.8OgaIaVsu_VPsJflWfFs1TnNqGckc6atIDZDjO9Mwzk	2026-02-19 15:53:23.741166	2026-02-20 15:53:23.739	auth	f
40	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIxMTQ0NDIsImV4cCI6MTc3MjIwMDg0Mn0.jVJfn_KECYXKUnfhcLc9Ic9VeawqXrXErOJhxJ06YAs	2026-02-26 09:00:42.576142	2026-02-27 09:00:42.574	auth	f
41	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIxMjA4MjMsImV4cCI6MTc3MjIwNzIyM30.W6rB6mNeXflvGRxmz72X30eUF1zTs0TIUmgZpfGP-Ww	2026-02-26 10:47:03.886579	2026-02-27 10:47:03.885	auth	f
42	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjYsImRvY3VtZW50byI6IjEyMzQ1Njc4OSIsImNvcnJlbyI6Im1hZUBnbWFpbC5jb20iLCJub21icmVzIjoibWFyaWEgYW50b25pYSBlc3RyYWRhIiwicm9sIjoidXN1YXJpbyIsImlhdCI6MTc3MjEyNzI3MSwiZXhwIjoxNzcyMjEzNjcxfQ.KGmmUPu4TaeO4D95vzplJXlUeIvsMHRgWAQZHXdDJ6Q	2026-02-26 12:34:31.680532	2026-02-27 12:34:31.679	auth	f
43	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjYsImRvY3VtZW50byI6IjEyMzQ1Njc4OSIsImNvcnJlbyI6Im1hZUBnbWFpbC5jb20iLCJub21icmVzIjoibWFyaWEgYW50b25pYSBlc3RyYWRhIiwicm9sIjoiZW1wbGVhZG8iLCJpYXQiOjE3NzIxMjk1MzgsImV4cCI6MTc3MjIxNTkzOH0.fS2zpl09PEd7TG9rfNXcsHYzt5k5QnNldYtgHAwBKJ8	2026-02-26 13:12:18.946025	2026-02-27 13:12:18.945	auth	f
44	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIxMzc3ODksImV4cCI6MTc3MjIyNDE4OX0.904SbuaAZh0HpQIzGiXJViRbRsb240bqzORXYzpF-rw	2026-02-26 15:29:49.336044	2026-02-27 15:29:49.335	auth	f
45	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIxMzc3ODksImV4cCI6MTc3MjIyNDE4OX0.904SbuaAZh0HpQIzGiXJViRbRsb240bqzORXYzpF-rw	2026-02-26 15:29:49.475409	2026-02-27 15:29:49.474	auth	f
46	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNTg0ODEsImV4cCI6MTc3MjM0NDg4MX0.mS8W4LHKgwFHSlS7i-_jHkeR8YutJDJDIxetNONHkio	2026-02-28 01:01:21.075774	2026-03-01 01:01:21.075	auth	f
47	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNTg1ODQsImV4cCI6MTc3MjM0NDk4NH0.7u5u2HiqYVvh3xjYAC3QT1rgWO6iInBti7LrHPwlJwo	2026-02-28 01:03:04.038936	2026-03-01 01:03:04.038	auth	f
48	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNTkwMzksImV4cCI6MTc3MjM0NTQzOX0._mdF9BIlygCjYebMTmWZbP_nJyLx1wERcsABct6IKL0	2026-02-28 01:10:39.039911	2026-03-01 01:10:39.039	auth	f
49	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNTkxMjAsImV4cCI6MTc3MjM0NTUyMH0.WTuhTQg_-N2BWot6HaNx4uiw-uM5Tuma6WegJD_LNnk	2026-02-28 01:12:00.932557	2026-03-01 01:12:00.927	auth	f
50	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNTkyNTIsImV4cCI6MTc3MjM0NTY1Mn0.EbYwt0O4sYRwqxKpBuvkyxEwJkseFd-hdKTq7i8wu5I	2026-02-28 01:14:12.381155	2026-03-01 01:14:12.38	auth	f
51	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNTkyNzIsImV4cCI6MTc3MjM0NTY3Mn0.XH8vLVLY3ssfNl8lJhB9Sp1SeInqhM8Fxa3xIcRCYuU	2026-02-28 01:14:32.906113	2026-03-01 01:14:32.905	auth	f
52	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNTkzMzEsImV4cCI6MTc3MjM0NTczMX0.vq9BCWxpXhi-pWp_EuX4oX2f7r5yUoL_VVHyFJX7KZU	2026-02-28 01:15:31.339385	2026-03-01 01:15:31.337	auth	f
53	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNTk0NTUsImV4cCI6MTc3MjM0NTg1NX0.mbWG_8b7kyqDibrrmGJ7hpxRh6eehG1YtGVhwaDHouU	2026-02-28 01:17:35.386538	2026-03-01 01:17:35.385	auth	f
54	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNTk1OTUsImV4cCI6MTc3MjM0NTk5NX0.IK1j_RCVzhEQCNMF_YkeM_slRBeLrZAu8nqRepYq54Y	2026-02-28 01:19:55.944788	2026-03-01 01:19:55.944	auth	f
55	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNTk2MTEsImV4cCI6MTc3MjM0NjAxMX0.rd6Y0PPX13ix4eOSSKTxKB1TU5aLC6CHSECip_pqj7M	2026-02-28 01:20:11.247835	2026-03-01 01:20:11.247	auth	f
56	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNTk3MTYsImV4cCI6MTc3MjM0NjExNn0.2bUGq9KfwCsIFULWMWK5ht6VITQN48qQbLc2uvP6KXU	2026-02-28 01:21:56.724861	2026-03-01 01:21:56.723	auth	f
57	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNjAyNjMsImV4cCI6MTc3MjM0NjY2M30.QC3a7qjhksgMtx6lzaxdRRP9H_vlN-_HG4qMxSm9ZX4	2026-02-28 01:31:03.556234	2026-03-01 01:31:03.555	auth	f
58	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNjEwNzUsImV4cCI6MTc3MjM0NzQ3NX0.wd5NbCyQCwJS9phkwH3Yp62OsOcz47soMHpZN6flrio	2026-02-28 01:44:35.626072	2026-03-01 01:44:35.625	auth	f
59	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNjMxOTMsImV4cCI6MTc3MjM0OTU5M30.qVFBP6truZt3CKhbYGweeayFj1zyQ_s8uKRgKFBp4s8	2026-02-28 02:19:53.284763	2026-03-01 02:19:53.284	auth	f
60	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNjM4MDQsImV4cCI6MTc3MjM1MDIwNH0.dchmJwHX_pVryVQWmEelo1EYGawXt2msNQ2Jay2NFu4	2026-02-28 02:30:04.141708	2026-03-01 02:30:04.141	auth	f
61	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNjM5NTQsImV4cCI6MTc3MjM1MDM1NH0.gFpSejBJgBYAxEtqpm7oToYnABLtgb4wiZDwto9Z0IQ	2026-02-28 02:32:34.33502	2026-03-01 02:32:34.334	auth	f
62	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNjUzMzgsImV4cCI6MTc3MjM1MTczOH0.E19AM6-7rTg_7wZubXlT6gMaURlOjypKwcgy5-eLfeY	2026-02-28 02:55:38.96636	2026-03-01 02:55:38.965	auth	f
63	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIyNjY4NjIsImV4cCI6MTc3MjM1MzI2Mn0.XwprABFBRhLR7jncatOc2oR1p6L9Ux3Xrl7Y9foBJAs	2026-02-28 03:21:02.299097	2026-03-01 03:21:02.298	auth	f
64	7	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjcsImRvY3VtZW50byI6IjEyMzQ1Njc4OTkiLCJjb3JyZW8iOiJndWFkYWx1cGVAZ21haWwuY29tIiwibm9tYnJlcyI6Imd1YWRhbHVwZSBlc3RyYWRhIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzIyOTA5MzQsImV4cCI6MTc3MjM3NzMzNH0.bHZhZF4fNlh9a_bXlOf1sg8jt4P5rs9XedBJJ6cYSQ8	2026-02-28 10:02:14.408576	2026-03-01 10:02:14.407	auth	f
65	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIzMDY0NDAsImV4cCI6MTc3MjM5Mjg0MH0.OVYdGAoaf3a0S6WxhlbNFJ1EDCqorjB97vOyEEPNoy0	2026-02-28 14:20:40.671926	2026-03-01 14:20:40.667	auth	f
66	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIzMDY0NjcsImV4cCI6MTc3MjM5Mjg2N30.466o8kVX792S4zCQ-BRVZBCSOJDsqCUgDQSR-0HRoR0	2026-02-28 14:21:07.460907	2026-03-01 14:21:07.459	auth	f
67	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIzMDY0ODAsImV4cCI6MTc3MjM5Mjg4MH0.3_7VbgxnFqiX1PhFkZ_NqA0Q4IFEYHTTuvkUdFiXWQw	2026-02-28 14:21:20.430141	2026-03-01 14:21:20.428	auth	f
68	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIzMDY1MDYsImV4cCI6MTc3MjM5MjkwNn0.x2d_stAabjBGoaCzlgRro_C434TIGhKY8cmXvuD2y1o	2026-02-28 14:21:46.589907	2026-03-01 14:21:46.588	auth	f
69	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIzMDY1NDYsImV4cCI6MTc3MjM5Mjk0Nn0.s6Dpkf_zNeUm6zlyRJax-IR9t7wCkq6TiTnE3cnY_8k	2026-02-28 14:22:26.230386	2026-03-01 14:22:26.229	auth	f
70	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIzMDY3ODQsImV4cCI6MTc3MjM5MzE4NH0.U2KSot6aXMHML5yH77gq_8YemNyqzTM0ElAcuPZRrn8	2026-02-28 14:26:24.726301	2026-03-01 14:26:24.723	auth	f
71	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIzMDY4MDYsImV4cCI6MTc3MjM5MzIwNn0.FqQa0ZET257r-R203_6EILgQziS66euslJFbprxEcRQ	2026-02-28 14:26:46.723821	2026-03-01 14:26:46.721	auth	f
72	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIzMDg5MzQsImV4cCI6MTc3MjM5NTMzNH0.dScPx4PcLWsh-WfePYOYiLYJUp8ZYn8kzRGr1ztKkIA	2026-02-28 15:02:14.470427	2026-03-01 15:02:14.468	auth	f
73	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIzMDg5NTIsImV4cCI6MTc3MjM5NTM1Mn0.byd-KITE3OcMG0NyURhilrkVMl2LFgkIBSNqhLHPB2g	2026-02-28 15:02:32.924651	2026-03-01 15:02:32.922	auth	f
74	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIzMTAwMzQsImV4cCI6MTc3MjM5NjQzNH0.EzJI2bwkPIEttw3a6PNZGyq8N8cIb8na2KcoRPWV4rw	2026-02-28 15:20:34.118371	2026-03-01 15:20:34.115	auth	f
75	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzIzMTAzNjUsImV4cCI6MTc3MjM5Njc2NX0.aPbc38NeXOe7MI1326EV9TTw_UzzMY1BtvbKWZ4Epuw	2026-02-28 15:26:05.66126	2026-03-01 15:26:05.658	auth	f
76	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjEsImRvY3VtZW50byI6IjEwMzY0NTMwMTgiLCJjb3JyZW8iOiJqaHVuaW9yQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NzI2NTY1MDMsImV4cCI6MTc3Mjc0MjkwM30.z--Hr1QP__dQEmZWF71FZtiCIGUyUukaDckTbOAbEyM	2026-03-04 15:35:03.603806	2026-03-05 15:35:03.603	auth	f
77	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjYsImRvY3VtZW50byI6IjEyMzQ1Njc4OSIsImNvcnJlbyI6Im1hZUBnbWFpbC5jb20iLCJub21icmVzIjoibWFyaWEgYW50b25pYSBlc3RyYWRhIiwicm9sIjoiZW1wbGVhZG8iLCJpYXQiOjE3NzI2NTc5MjAsImV4cCI6MTc3Mjc0NDMyMH0.A4SowPRkTdiodDaWvChBeiHYWgzSJ-5H5O7N72ddITQ	2026-03-04 15:58:40.161247	2026-03-05 15:58:40.16	auth	f
78	7	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZHVzdWFyaW8iOjcsImRvY3VtZW50byI6IjEyMzQ1Njc4OTkiLCJjb3JyZW8iOiJndWFkYWx1cGVAZ21haWwuY29tIiwibm9tYnJlcyI6Imd1YWRhbHVwZSBlc3RyYWRhIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NzI2NTgwNDYsImV4cCI6MTc3Mjc0NDQ0Nn0.EqlOYzCglUmfhjYzdd4Rp11Auu5-i49uFYDvmnYvTpw	2026-03-04 16:00:46.097581	2026-03-05 16:00:46.096	auth	f
\.


--
-- TOC entry 5219 (class 0 OID 41541)
-- Dependencies: 242
-- Data for Name: turnos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.turnos (id_turno, id_empleado, fecha, hora_inicio, hora_fin, pagado) FROM stdin;
1	2	2026-02-26	02:00:00	10:00:00	t
2	2	2026-02-26	02:00:00	10:00:00	t
3	2	2026-03-04	02:00:00	10:00:00	t
\.


--
-- TOC entry 5197 (class 0 OID 16988)
-- Dependencies: 220
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (idusuario, documento, nombres, correo, telefono, contrasena, pregunta, respuesta, intentos_fallidos, estado, rol, fecha_creacion, intentos) FROM stdin;
2	1245678909	jhunior franco	jhunior.frangar@gmail.com	3207550942	$2b$10$ss9Mof/36wNd5ko3/GeQJukn4yEBCU5WUAQr1CqWPxthgNupde9KG	¿Cuál es el nombre de tu primera mascota?	$2b$10$MIFsL.Yzez2pJaCQNVIgDus1aHQn1k2ltcdNXpfHQ0UBdTY00/Lce	0	activo	usuario	2026-02-10 10:45:09.761032	0
4	12354676	jhunior franco	jhunior.frangar2@gmail.com	3207550942	$2b$10$QnZHOnEyxKJyPZscXCu7QuqURIbnmQgzwRtZmCqb/eK9wqKold5w.	¿Cuál es el nombre de tu primera mascota?	$2b$10$pvDouB/bO8DRI2eTqTmexOFCJbJisxkdyL9Jn1rvGSOqQf1D1MWBm	0	activo	usuario	2026-02-10 10:49:42.205718	0
5	3925218582	Test Flow User	test_1770738748753@flow.com	3001234567	$2b$10$9y21Dc8.aI6NVWlLfH0Ikuqx3ksjR4q7/2SQFXz37MjZ6.P71nvOq	Color	$2b$10$iaHbYLgZJdQptQGrE/hYpuUkHcxdbDnYgLgC6b31pzlAPARIJQJFq	0	activo	usuario	2026-02-10 10:52:28.924238	0
1	1036453018	jhunior franco	jhunior@gmail.com	3207550942	$2b$10$aPFdggDlLG94o7o7udwKNOxfXo5QRzF6A7FP37fCMnPZ6NYyiCjBC	¿Cuál es el nombre de tu primera mascota?	$2b$10$FYArebxHF.BYqtXdSoMjpu3R4B7neZxK5ohvX7UObIYHFnXRtHiie	0	activo	gerente	2025-12-10 21:17:53.477726	0
6	123456789	maria antonia estrada	mae@gmail.com	3138837956	$2b$10$Fbws4N2wwzCZmSJiucJOZOakFbwGmKMDQeDGy300uu3ZSXFskbVe6	¿Cuál es el nombre de tu primera mascota?	$2b$10$f1PbEifxp5a0QRszhw/uYus8BBYMoIsUOT6X4RnQJ1TscIxMZryQy	0	activo	empleado	2026-02-26 12:34:31.676201	0
7	1234567899	guadalupe estrada franco	guadalupe@gmail.com	3214567890	$2b$10$UP5kJ3FOO74vwvq9yuAtDOiGBfjEyBxQ3XQqhb6gKgpZVwj2s42/a	¿En qué ciudad naciste?	$2b$10$AxGRMScbsebWVp8gVza.Cebp47aAgCt7x4OuKk9cla0v2.9.wIAC6	0	activo	usuario	2026-02-28 10:02:14.400403	0
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

SELECT pg_catalog.setval('public.detalles_id_seq', 55, true);


--
-- TOC entry 5245 (class 0 OID 0)
-- Dependencies: 223
-- Name: direcciones_iddireccion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.direcciones_iddireccion_seq', 5, true);


--
-- TOC entry 5246 (class 0 OID 0)
-- Dependencies: 239
-- Name: empleados_id_empleado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.empleados_id_empleado_seq', 2, true);


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

SELECT pg_catalog.setval('public.factura_id_seq', 21, true);


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

SELECT pg_catalog.setval('public.notificaciones_idnotificacion_seq', 1, false);


--
-- TOC entry 5251 (class 0 OID 0)
-- Dependencies: 245
-- Name: pagos_empleados_idpago_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pagos_empleados_idpago_seq', 6, true);


--
-- TOC entry 5252 (class 0 OID 0)
-- Dependencies: 225
-- Name: pedidos_idpedido_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pedidos_idpedido_seq', 16, true);


--
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 227
-- Name: productos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.productos_id_seq', 43, true);


--
-- TOC entry 5254 (class 0 OID 0)
-- Dependencies: 221
-- Name: tokens_idtoken_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tokens_idtoken_seq', 78, true);


--
-- TOC entry 5255 (class 0 OID 0)
-- Dependencies: 241
-- Name: turnos_id_turno_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.turnos_id_turno_seq', 3, true);


--
-- TOC entry 5256 (class 0 OID 0)
-- Dependencies: 219
-- Name: usuarios_idusuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuarios_idusuario_seq', 7, true);


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


-- Completed on 2026-03-04 23:38:22

--
-- PostgreSQL database dump complete
--

\unrestrict LfUPrz4GCyprjO0i4FBfYOhn27sTNEmvhhsstESUc4eTRSB30WdWflnzpFV45cL

