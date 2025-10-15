-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost
-- Tiempo de generación: 20-08-2025 a las 12:55:51
-- Versión del servidor: 8.4.3
-- Versión de PHP: 8.3.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `legumbreria`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles`
--

CREATE TABLE `detalles` (
  `idDetalle` int NOT NULL,
  `idFactura` int NOT NULL,
  `idRegProductos` int NOT NULL,
  `cantidad` int NOT NULL,
  `precioUnitario` double(10,2) NOT NULL,
  `subTotal` double(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura`
--

CREATE TABLE `factura` (
  `idFactura` int NOT NULL,
  `idUsuario` int NOT NULL,
  `fecha` varchar(30) NOT NULL,
  `estado` enum('aprobado','rechazado','pendiente','') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `idProducto` int NOT NULL,
  `nombre` varchar(250) NOT NULL,
  `descripcion` text,
  `unidad` enum('kg','lb','unidad') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `categoria` enum('frutas','verduras','promociones','legumbres','hortalizas','cereales') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `estado` enum('activo','inactivo') DEFAULT 'activo',
  `imagen` varchar(255) NOT NULL DEFAULT '/img/tomate.jpg'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`idProducto`, `nombre`, `descripcion`, `unidad`, `categoria`, `estado`, `imagen`) VALUES
(29, 'Manzana Roja', 'Manzanas dulces y crujientes', 'kg', 'frutas', 'activo', '/img/productos/manzana.jpg'),
(30, 'Banano', 'Banano maduro de alta calidad', 'kg', 'frutas', 'activo', '/img/productos/banano.jpg'),
(31, 'Uva Verde', 'Uvas verdes sin semilla', 'kg', 'frutas', 'activo', '/img/productos/uva-verde.jpg'),
(32, 'Sandía', 'Sandía jugosa entera o en tajadas', 'unidad', 'frutas', 'activo', '/img/productos/sandia.jpg'),
(33, 'Mango Tommy', 'Mangos grandes y dulces', 'unidad', 'frutas', 'activo', '/img/productos/mango.jpg'),
(34, 'Papaya', 'Papaya madura lista para comer', 'kg', 'frutas', 'activo', '/img/productos/papaya.jpg'),
(35, 'Fresa', 'Fresas frescas seleccionadas', 'kg', 'frutas', 'activo', '/img/productos/fresa.jpg'),
(36, 'Piña', 'Piña dulce, sin corona', 'unidad', 'frutas', 'activo', '/img/productos/pina.jpg'),
(37, 'Mandarina', 'Mandarinas jugosas', 'kg', 'frutas', 'activo', '/img/productos/mandarina.jpg'),
(38, 'Melón', 'Melón cantaloupe dulce', 'unidad', 'frutas', 'activo', '/img/productos/melon.jpg'),
(39, 'Zanahoria', 'Zanahorias frescas', 'kg', 'verduras', 'activo', '/img/productos/zanahoria.jpg'),
(40, 'Brócoli', 'Brócoli verde y fresco', 'kg', 'verduras', 'activo', '/img/productos/brocoli.jpg'),
(41, 'Coliflor', 'Coliflor blanca grande', 'unidad', 'verduras', 'activo', '/img/productos/coliflor.jpg'),
(42, 'Espinaca', 'Hojas de espinaca limpias', 'kg', 'verduras', 'activo', '/img/productos/espinaca.jpg'),
(43, 'Repollo', 'Repollo verde entero', 'unidad', 'verduras', 'activo', '/img/productos/repollo.jpg'),
(44, 'Remolacha', 'Remolachas medianas', 'kg', 'verduras', 'activo', '/img/productos/remolacha.jpg'),
(45, 'Apio', 'Tallos de apio frescos', 'unidad', 'verduras', 'activo', '/img/productos/apio.jpg'),
(46, 'Lechuga', 'Lechuga crespa', 'unidad', 'verduras', 'activo', '/img/productos/lechuga.jpg'),
(47, 'Acelga', 'Hojas verdes de acelga', 'kg', 'verduras', 'activo', '/img/productos/acelga.jpg'),
(48, 'Rábano', 'Rábanos frescos', 'kg', 'verduras', 'activo', '/img/productos/rabano.jpg'),
(49, 'Combo Frutal', 'Manzana + Banano + Fresa', 'kg', 'promociones', 'activo', '/img/productos/combo-frutas.jpg'),
(50, 'Paquete Vegetales', 'Zanahoria + Brócoli + Apio', 'kg', 'promociones', 'activo', '/img/productos/combo-vegetales.jpg'),
(51, 'Descuento Mandarina', 'Mandarina con 20% off', 'kg', 'promociones', 'activo', '/img/productos/mandarina-descuento.jpg'),
(52, 'Combo Saludable', 'Piña + Espinaca + Avena', 'kg', 'promociones', 'activo', '/img/productos/combo-saludable.jpg'),
(53, 'Avena 2x1', 'Compra 1 y lleva 2', 'kg', 'promociones', 'activo', '/img/productos/avena-promo.jpg'),
(54, 'Oferta Mango', 'Mango Tommy en descuento', 'unidad', 'promociones', 'activo', '/img/productos/mango-promo.jpg'),
(55, 'Semana del Melón', 'Melón con 15% descuento', 'unidad', 'promociones', 'activo', '/img/productos/melon-oferta.jpg'),
(56, 'Legumbre Pack', 'Combo de lentejas + garbanzos', 'kg', 'promociones', 'activo', '/img/productos/legumbre-pack.jpg'),
(57, 'Descuento Coliflor', 'Coliflor a precio especial', 'unidad', 'promociones', 'activo', '/img/productos/coliflor-promo.jpg'),
(58, 'Fresas 3x2', 'Llévate 3, paga 2', 'kg', 'promociones', 'activo', '/img/productos/fresa-promo.jpg'),
(59, 'Lentejas', 'Lentejas secas listas para cocinar', 'kg', 'legumbres', 'activo', '/img/productos/lentejas.jpg'),
(60, 'Fríjol Bola Roja', 'Fríjol tradicional colombiano', 'kg', 'legumbres', 'activo', '/img/productos/frijol.jpg'),
(61, 'Garbanzos', 'Garbanzos secos premium', 'kg', 'legumbres', 'activo', '/img/productos/garbanzos.jpg'),
(62, 'Arvejas Verdes', 'Arvejas secas sin cáscara', 'kg', 'legumbres', 'activo', '/img/productos/arveja.jpg'),
(63, 'Fríjol Negro', 'Fríjol negro entero', 'kg', 'legumbres', 'activo', '/img/productos/frijol-negro.jpg'),
(64, 'Lentejas Rojas', 'Lentejas peladas para cocción rápida', 'kg', 'legumbres', 'activo', '/img/productos/lentejas-rojas.jpg'),
(65, 'Fríjol Blanco', 'Ideal para sopas y ensaladas', 'kg', 'legumbres', 'activo', '/img/productos/frijol-blanco.jpg'),
(66, 'Soya', 'Granos de soya secos', 'kg', 'legumbres', 'activo', '/img/productos/soya.jpg'),
(67, 'Fríjol Verde', 'Fríjol tierno fresco', 'kg', 'legumbres', 'activo', '/img/productos/frijol-verde.jpg'),
(68, 'Guisantes', 'Guisantes secos tipo europeo', 'kg', 'legumbres', 'activo', '/img/productos/guisantes.jpg'),
(69, 'Papa Criolla', 'Papa amarilla pequeña', 'kg', 'hortalizas', 'activo', '/img/productos/papa.jpg'),
(70, 'Yuca', 'Yuca pelada lista para cocinar', 'kg', 'hortalizas', 'activo', '/img/productos/yuca.jpg'),
(71, 'Ñame', 'Ñame blanco fresco', 'kg', 'hortalizas', 'activo', '/img/productos/name.jpg'),
(72, 'Papa Pastusa', 'Papa ideal para puré', 'kg', 'hortalizas', 'activo', '/img/productos/papa-pastusa.jpg'),
(73, 'Plátano Verde', 'Plátano para freír o cocinar', 'kg', 'hortalizas', 'activo', '/img/productos/platano.jpg'),
(74, 'Ahuyama', 'Ahuyama en trozos', 'kg', 'hortalizas', 'activo', '/img/productos/ahuyama.jpg'),
(75, 'Cebolla Cabezona', 'Cebolla blanca grande', 'kg', 'hortalizas', 'activo', '/img/productos/cebolla.jpg'),
(76, 'Cebolla Larga', 'Ideal para guisos y caldos', 'kg', 'hortalizas', 'activo', '/img/productos/cebolla-larga.jpg'),
(77, 'Ajo', 'Cabezas de ajo fresco', 'unidad', 'hortalizas', 'activo', '/img/productos/ajo.jpg'),
(78, 'Tomate Chonto', 'Tomate para cocina', 'kg', 'hortalizas', 'activo', '/img/productos/tomate.jpg'),
(79, 'Arroz Blanco', 'Arroz largo fino', 'kg', 'cereales', 'activo', '/img/productos/arroz.jpg'),
(80, 'Avena en Hojuelas', 'Avena natural', 'kg', 'cereales', 'activo', '/img/productos/avena.jpg'),
(81, 'Maíz Amarillo', 'Grano seco para molienda', 'kg', 'cereales', 'activo', '/img/productos/maiz.jpg'),
(82, 'Trigo', 'Trigo entero para cocción', 'kg', 'cereales', 'activo', '/img/productos/trigo.jpg'),
(83, 'Cebada', 'Grano de cebada perlada', 'kg', 'cereales', 'activo', '/img/productos/cebada.jpg'),
(84, 'Harina de Maíz', 'Harina precocida', 'kg', 'cereales', 'activo', '/img/productos/harina-maiz.jpg'),
(85, 'Quinua', 'Semilla andina nutritiva', 'kg', 'cereales', 'activo', '/img/productos/quinua.jpg'),
(86, 'Centeno', 'Cereal de centeno integral', 'kg', 'cereales', 'activo', '/img/productos/centeno.jpg'),
(87, 'Sorgo', 'Grano seco sin gluten', 'kg', 'cereales', 'activo', '/img/productos/sorgo.jpg'),
(88, 'Harina de Trigo', 'Ideal para panadería', 'kg', 'cereales', 'activo', '/img/productos/harina-trigo.jpg'),
(89, 'Cebolla Blanca', 'Cebolla fresca de sabor suave', 'kg', 'verduras', 'activo', '/img/productos/cebolla-blanca.jpg'),
(90, 'Cebolla Morada', 'Ideal para ensaladas y guisos', 'kg', 'verduras', 'activo', '/img/productos/cebolla-morada.jpg'),
(91, 'Cebolla de Rama', 'Cebolla larga fresca, ideal para guisos y sofritos', 'kg', 'verduras', 'activo', '/img/productos/cebolla-rama.jpg'),
(92, 'anderson', 'el mas gay de 2995403', 'unidad', 'frutas', 'activo', '/img/productos/1755608008376.jpg'),
(93, 'diego', 'el mas adicto a lol', 'unidad', 'hortalizas', 'activo', '/img/productos/1755608295804.jpg'),
(94, 'emanuel', 'qwe', 'unidad', 'promociones', 'activo', '/img/productos/1755615075822.png');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `regproductos`
--

CREATE TABLE `regproductos` (
  `idRegProducto` int NOT NULL,
  `idProducto` int NOT NULL,
  `cantidad` int NOT NULL,
  `precioCompra` double(10,2) NOT NULL,
  `precioVentaMenor` double(10,2) NOT NULL,
  `precioVentaMayor` double(10,2) NOT NULL,
  `fechaRegistro` varchar(50) NOT NULL,
  `estado` varchar(30) NOT NULL DEFAULT 'Disponible'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `regproductos`
--

INSERT INTO `regproductos` (`idRegProducto`, `idProducto`, `cantidad`, `precioCompra`, `precioVentaMenor`, `precioVentaMayor`, `fechaRegistro`, `estado`) VALUES
(134, 29, 100, 1.20, 1.60, 1.50, '2025-08-18 12:45:41', 'Disponible'),
(135, 30, 90, 0.80, 1.20, 1.10, '2025-08-18 12:45:41', 'Disponible'),
(136, 31, 70, 2.00, 2.80, 2.50, '2025-08-18 12:45:41', 'Disponible'),
(137, 32, 50, 3.00, 3.80, 3.60, '2025-08-18 12:45:41', 'Disponible'),
(138, 33, 60, 1.50, 2.00, 1.90, '2025-08-18 12:45:41', 'Disponible'),
(139, 34, 100, 1.20, 1.80, 1.70, '2025-08-18 12:45:41', 'Disponible'),
(140, 35, 80, 2.20, 2.80, 2.60, '2025-08-18 12:45:41', 'Disponible'),
(141, 36, 40, 2.00, 3.00, 2.80, '2025-08-18 12:45:41', 'Disponible'),
(142, 37, 90, 1.30, 1.80, 1.70, '2025-08-18 12:45:41', 'Disponible'),
(143, 38, 55, 3.50, 4.20, 4.00, '2025-08-18 12:45:41', 'Disponible'),
(144, 39, 120, 1.00, 1.50, 1.40, '2025-08-18 12:45:41', 'Disponible'),
(145, 40, 60, 1.60, 2.20, 2.00, '2025-08-18 12:45:41', 'Disponible'),
(146, 41, 80, 1.80, 2.40, 2.30, '2025-08-18 12:45:41', 'Disponible'),
(147, 42, 90, 0.90, 1.40, 1.30, '2025-08-18 12:45:41', 'Disponible'),
(148, 43, 70, 2.20, 2.90, 2.70, '2025-08-18 12:45:41', 'Disponible'),
(149, 44, 50, 1.50, 2.00, 1.90, '2025-08-18 12:45:41', 'Disponible'),
(150, 45, 100, 1.10, 1.70, 1.60, '2025-08-18 12:45:41', 'Disponible'),
(151, 46, 65, 1.30, 1.90, 1.80, '2025-08-18 12:45:41', 'Disponible'),
(152, 47, 85, 1.60, 2.10, 2.00, '2025-08-18 12:45:41', 'Disponible'),
(153, 48, 95, 1.00, 1.40, 1.30, '2025-08-18 12:45:41', 'Disponible'),
(154, 49, 50, 3.00, 4.00, 3.80, '2025-08-18 12:45:41', 'Disponible'),
(155, 50, 60, 2.80, 3.60, 3.40, '2025-08-18 12:45:41', 'Disponible'),
(156, 51, 80, 1.20, 1.60, 1.50, '2025-08-18 12:45:41', 'Disponible'),
(157, 52, 40, 2.90, 3.70, 3.50, '2025-08-18 12:45:41', 'Disponible'),
(158, 53, 100, 1.00, 1.50, 1.40, '2025-08-18 12:45:41', 'Disponible'),
(159, 54, 75, 1.50, 2.00, 1.90, '2025-08-18 12:45:41', 'Disponible'),
(160, 55, 65, 1.90, 2.60, 2.40, '2025-08-18 12:45:41', 'Disponible'),
(161, 56, 55, 2.00, 2.80, 2.70, '2025-08-18 12:45:41', 'Disponible'),
(162, 57, 60, 1.70, 2.30, 2.10, '2025-08-18 12:45:41', 'Disponible'),
(163, 58, 80, 1.30, 1.90, 1.80, '2025-08-18 12:45:41', 'Disponible'),
(164, 59, 100, 0.90, 1.40, 1.30, '2025-08-18 12:45:41', 'Disponible'),
(165, 60, 85, 1.40, 1.90, 1.80, '2025-08-18 12:45:41', 'Disponible'),
(166, 61, 95, 2.00, 2.60, 2.50, '2025-08-18 12:45:41', 'Disponible'),
(167, 62, 60, 1.00, 1.50, 1.40, '2025-08-18 12:45:41', 'Disponible'),
(168, 63, 80, 1.70, 2.20, 2.10, '2025-08-18 12:45:41', 'Disponible'),
(169, 64, 90, 1.30, 1.80, 1.70, '2025-08-18 12:45:41', 'Disponible'),
(170, 65, 70, 2.10, 2.90, 2.70, '2025-08-18 12:45:41', 'Disponible'),
(171, 66, 65, 1.50, 2.10, 2.00, '2025-08-18 12:45:41', 'Disponible'),
(172, 67, 55, 1.90, 2.50, 2.30, '2025-08-18 12:45:41', 'Disponible'),
(173, 68, 45, 1.80, 2.40, 2.20, '2025-08-18 12:45:41', 'Disponible'),
(174, 69, 110, 1.20, 1.60, 1.50, '2025-08-18 12:45:41', 'Disponible'),
(175, 70, 120, 1.10, 1.50, 1.40, '2025-08-18 12:45:41', 'Disponible'),
(176, 71, 60, 2.10, 2.80, 2.60, '2025-08-18 12:45:41', 'Disponible'),
(177, 72, 130, 1.30, 1.80, 1.70, '2025-08-18 12:45:41', 'Disponible'),
(178, 73, 140, 1.40, 1.90, 1.80, '2025-08-18 12:45:41', 'Disponible'),
(179, 74, 80, 1.00, 1.50, 1.40, '2025-08-18 12:45:41', 'Disponible'),
(180, 75, 75, 1.80, 2.50, 2.30, '2025-08-18 12:45:41', 'Disponible'),
(181, 76, 85, 1.60, 2.20, 2.10, '2025-08-18 12:45:41', 'Disponible'),
(182, 77, 90, 1.70, 2.30, 2.20, '2025-08-18 12:45:41', 'Disponible'),
(183, 78, 100, 1.50, 2.00, 1.90, '2025-08-18 12:45:41', 'Disponible'),
(184, 79, 120, 1.20, 1.60, 1.50, '2025-08-18 12:45:41', 'Disponible'),
(185, 80, 110, 1.10, 1.50, 1.40, '2025-08-18 12:45:41', 'Disponible'),
(186, 81, 95, 0.90, 1.30, 1.20, '2025-08-18 12:45:41', 'Disponible'),
(187, 82, 105, 1.30, 1.80, 1.70, '2025-08-18 12:45:41', 'Disponible'),
(188, 83, 80, 1.50, 2.00, 1.90, '2025-08-18 12:45:41', 'Disponible'),
(189, 84, 100, 1.60, 2.20, 2.10, '2025-08-18 12:45:41', 'Disponible'),
(190, 85, 85, 2.10, 2.80, 2.60, '2025-08-18 12:45:41', 'Disponible'),
(191, 86, 90, 2.20, 2.90, 2.70, '2025-08-18 12:45:41', 'Disponible'),
(192, 87, 70, 1.70, 2.30, 2.10, '2025-08-18 12:45:41', 'Disponible'),
(193, 88, 65, 1.40, 1.90, 1.80, '2025-08-18 12:45:41', 'Disponible'),
(194, 89, 100, 0.80, 1.20, 1.10, '2025-08-18 13:45:30', 'Disponible'),
(195, 90, 90, 0.90, 1.30, 1.20, '2025-08-18 13:45:30', 'Disponible'),
(196, 91, 75, 1.00, 1.50, 1.40, '2025-08-18 13:45:30', 'Disponible'),
(197, 92, 1, 1.00, 1.00, 1.00, '2025-08-19 07:53:28', 'Disponible'),
(198, 93, 1, 1.00, 1.00, 1.00, '2025-08-19 07:58:15', 'Disponible'),
(199, 94, 1, 1.00, 1.00, 1.00, '2025-08-19 09:51:15', 'Disponible');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tokens`
--

CREATE TABLE `tokens` (
  `idToken` int NOT NULL,
  `documento` varchar(20) NOT NULL,
  `token` varchar(500) NOT NULL,
  `fecha_expiracion` datetime NOT NULL,
  `estado` enum('activo','revocado') DEFAULT 'activo',
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `tokens`
--

INSERT INTO `tokens` (`idToken`, `documento`, `token`, `fecha_expiracion`, `estado`, `fecha_creacion`) VALUES
(4, '1036680506', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudG8iOiIxMDM2NjgwNTA2IiwiY29ycmVvIjoiamh1bmlvci5mcmFuZ2FyQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NTQ1Mzk0MjQsImV4cCI6MTc1NDU0NjYyNH0.jY2FzjMYn6hSBYjRBrNQ4fNc_AMl45u2EpNMMnvBYfU', '2025-08-07 01:03:44', 'activo', '2025-08-07 04:03:44'),
(5, '1036680506', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudG8iOiIxMDM2NjgwNTA2IiwiY29ycmVvIjoiamh1bmlvci5mcmFuZ2FyQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NTQ1Mzk0OTcsImV4cCI6MTc1NDYyNTg5N30.61FWxOp6TKE_q1U9rJ8RY3SQEQYNEBRu6L53V1qZH5Q', '2025-08-07 23:04:57', 'activo', '2025-08-07 04:04:57'),
(6, '1020323618', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudG8iOiIxMDIwMzIzNjE4IiwiY29ycmVvIjoibWFlQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJtYXJpYSBhbnRvbmlhIGVzdHJhZGEiLCJyb2wiOiJ1c3VhcmlvIiwiaWF0IjoxNzU0NTQwNTU5LCJleHAiOjE3NTQ1NDc3NTl9.TmUD29JisFMR_T5ey7mM8wwMXbuJ1x0fHbYlAqjxujk', '2025-08-07 01:22:39', 'activo', '2025-08-07 04:22:39'),
(7, '1020323618', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudG8iOiIxMDIwMzIzNjE4IiwiY29ycmVvIjoibWFlQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJtYXJpYSBhbnRvbmlhIGVzdHJhZGEiLCJyb2wiOiJlbXBsZWFkbyIsImlhdCI6MTc1NDU0MDY3MywiZXhwIjoxNzU0NjI3MDczfQ.Ydrwvq0FjTbgvV6z3OcEB1UFYAdBqh_V844-oDC4q3E', '2025-08-07 23:24:34', 'activo', '2025-08-07 04:24:33'),
(8, '1234567890', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudG8iOiIxMjM0NTY3ODkwIiwiY29ycmVvIjoiamh1bmlpX2ZyYW5raWl0b0Bob3RtYWlsLmNvbSIsIm5vbWJyZXMiOiJwcnVlYmEgbnVtZXJvIHVubyIsInJvbCI6InVzdWFyaW8iLCJpYXQiOjE3NTUwMjg0MTQsImV4cCI6MTc1NTAzNTYxNH0.bZVjLvwnpas1_leS-shiEz6iem-k22I9gBStXFYiiJ4', '2025-08-12 16:53:34', 'activo', '2025-08-12 19:53:34'),
(9, '1036680506', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudG8iOiIxMDM2NjgwNTA2IiwiY29ycmVvIjoiamh1bmlvci5mcmFuZ2FyQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NTUwMjkwMDcsImV4cCI6MTc1NTExNTQwN30.R4UCtawr-f0QqqtKMrlSfBoanQQbYt45SuoJVD2l_co', '2025-08-13 15:03:28', 'activo', '2025-08-12 20:03:27'),
(10, '1036680506', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudG8iOiIxMDM2NjgwNTA2IiwiY29ycmVvIjoiamh1bmlvci5mcmFuZ2FyQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NTUxMDAzODEsImV4cCI6MTc1NTE4Njc4MX0.ThtAnP5UmBoRehCTHVxmL3YLR2ea4AMz7E6kqy16MHo', '2025-08-14 10:53:01', 'activo', '2025-08-13 15:53:01'),
(11, '1036680506', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudG8iOiIxMDM2NjgwNTA2IiwiY29ycmVvIjoiamh1bmlvci5mcmFuZ2FyQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NTUxMDAzODQsImV4cCI6MTc1NTE4Njc4NH0.Tcw13g8YpLaU7jusEfZiOQVvnmkCwDT0Geg2rQRlrQM', '2025-08-14 10:53:04', 'activo', '2025-08-13 15:53:04'),
(12, '1036680506', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudG8iOiIxMDM2NjgwNTA2IiwiY29ycmVvIjoiamh1bmlvci5mcmFuZ2FyQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NTU1Mjc4MTAsImV4cCI6MTc1NTYxNDIxMH0._Gwa6oosvPM6n9KIkMILuWXOnLtLIBCuvc-snviydlk', '2025-08-19 09:36:50', 'activo', '2025-08-18 14:36:50'),
(13, '1036680506', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudG8iOiIxMDM2NjgwNTA2IiwiY29ycmVvIjoiamh1bmlvci5mcmFuZ2FyQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NTU1Mjc4MTIsImV4cCI6MTc1NTYxNDIxMn0.LlMX2PagPsw8OrjB41BtdlOdrUKP8-7THRWW3zWgMpg', '2025-08-19 09:36:52', 'activo', '2025-08-18 14:36:52'),
(14, '1036680506', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudG8iOiIxMDM2NjgwNTA2IiwiY29ycmVvIjoiamh1bmlvci5mcmFuZ2FyQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NTU2MTQ5OTAsImV4cCI6MTc1NTcwMTM5MH0.43PU7ewXWw8PktJCtfYRjDgAAcaOWAxgjI_cEJrka8c', '2025-08-20 09:49:50', 'activo', '2025-08-19 14:49:50'),
(15, '1036680506', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudG8iOiIxMDM2NjgwNTA2IiwiY29ycmVvIjoiamh1bmlvci5mcmFuZ2FyQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NTU2MTQ5OTAsImV4cCI6MTc1NTcwMTM5MH0.43PU7ewXWw8PktJCtfYRjDgAAcaOWAxgjI_cEJrka8c', '2025-08-20 09:49:51', 'activo', '2025-08-19 14:49:50'),
(16, '1036680506', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudG8iOiIxMDM2NjgwNTA2IiwiY29ycmVvIjoiamh1bmlvci5mcmFuZ2FyQGdtYWlsLmNvbSIsIm5vbWJyZXMiOiJqaHVuaW9yIGZyYW5jbyIsInJvbCI6ImdlcmVudGUiLCJpYXQiOjE3NTU2MTQ5OTIsImV4cCI6MTc1NTcwMTM5Mn0.qc6IZ5HPmgT_eLfJSjjsQj41qiWJGDd6R_YJ7J1XaBY', '2025-08-20 09:49:52', 'activo', '2025-08-19 14:49:52');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `idUsuario` int NOT NULL,
  `documento` varchar(20) NOT NULL,
  `nombres` varchar(100) NOT NULL,
  `correo` varchar(200) NOT NULL,
  `telefono` varchar(15) DEFAULT NULL,
  `contrasena` varchar(255) NOT NULL,
  `pregunta` varchar(200) NOT NULL,
  `respuesta` varchar(255) NOT NULL,
  `intentos_fallidos` int DEFAULT '0',
  `estado` enum('activo','bloqueado') DEFAULT 'activo',
  `rol` enum('usuario','gerente','empleado') DEFAULT 'usuario',
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`idUsuario`, `documento`, `nombres`, `correo`, `telefono`, `contrasena`, `pregunta`, `respuesta`, `intentos_fallidos`, `estado`, `rol`, `fecha_creacion`) VALUES
(10, '1036680506', 'jhunior franco', 'jhunior.frangar@gmail.com', '3138837956', '$2b$10$voE050gwofpsK.rW.TmC6.Z.Dr1HtZGMFNSleBMwEF3BvgSH9PUKe', '¿Cuál es el nombre de tu primera mascota?', '$2b$10$tdYpMSyeZZQx/bvLM3uxduogZ5RD4LUK4w3WtG2ocRZPUvQ4oC9OS', 0, 'activo', 'gerente', '2025-08-07 04:03:44'),
(11, '1020323618', 'maria antonia estrada', 'mae@gmail.com', '3207550942', '$2b$10$eaQ2JRlnxMBjakHUxRTEgegMlxNBVG.14sDuqPie87/Nh/VAEbB/S', '¿En qué ciudad naciste?', '$2b$10$I05Km3lMYToeRcR/WtwWPO6tP6RHbefnrMKCydQWyC54zBO7AN1SG', 0, 'activo', 'empleado', '2025-08-07 04:22:39'),
(12, '1234567890', 'prueba numero uno', 'jhunii_frankiito@hotmail.com', '3112324545', '$2b$10$V8BQVd6NNb413gY7Zllk4ebGdMYM/7lOYUnk5c4eeYKElK9CrdZ86', '¿En qué ciudad naciste?', '$2b$10$1gtjrPsOzFfvYPqMp4mlpOofcDW6ren45nzSPiP8nDOtrvlRGTU8K', 0, 'activo', 'usuario', '2025-08-12 19:53:34');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `detalles`
--
ALTER TABLE `detalles`
  ADD KEY `idFactura` (`idFactura`),
  ADD KEY `idRegProductos` (`idRegProductos`);

--
-- Indices de la tabla `factura`
--
ALTER TABLE `factura`
  ADD PRIMARY KEY (`idFactura`),
  ADD KEY `idUsuario` (`idUsuario`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`idProducto`);

--
-- Indices de la tabla `regproductos`
--
ALTER TABLE `regproductos`
  ADD PRIMARY KEY (`idRegProducto`),
  ADD KEY `idProducto` (`idProducto`);

--
-- Indices de la tabla `tokens`
--
ALTER TABLE `tokens`
  ADD PRIMARY KEY (`idToken`),
  ADD KEY `idx_tokens_token` (`token`),
  ADD KEY `idx_tokens_documento` (`documento`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`idUsuario`),
  ADD UNIQUE KEY `documento` (`documento`),
  ADD UNIQUE KEY `correo` (`correo`),
  ADD KEY `idx_usuarios_documento` (`documento`),
  ADD KEY `idx_usuarios_correo` (`correo`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `factura`
--
ALTER TABLE `factura`
  MODIFY `idFactura` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `idProducto` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=95;

--
-- AUTO_INCREMENT de la tabla `regproductos`
--
ALTER TABLE `regproductos`
  MODIFY `idRegProducto` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=200;

--
-- AUTO_INCREMENT de la tabla `tokens`
--
ALTER TABLE `tokens`
  MODIFY `idToken` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `idUsuario` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `detalles`
--
ALTER TABLE `detalles`
  ADD CONSTRAINT `detalles_ibfk_1` FOREIGN KEY (`idFactura`) REFERENCES `factura` (`idFactura`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalles_ibfk_2` FOREIGN KEY (`idRegProductos`) REFERENCES `regproductos` (`idRegProducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `factura`
--
ALTER TABLE `factura`
  ADD CONSTRAINT `factura_ibfk_1` FOREIGN KEY (`idUsuario`) REFERENCES `usuarios` (`idUsuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `regproductos`
--
ALTER TABLE `regproductos`
  ADD CONSTRAINT `regproductos_ibfk_1` FOREIGN KEY (`idProducto`) REFERENCES `productos` (`idProducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `tokens`
--
ALTER TABLE `tokens`
  ADD CONSTRAINT `tokens_ibfk_1` FOREIGN KEY (`documento`) REFERENCES `usuarios` (`documento`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
