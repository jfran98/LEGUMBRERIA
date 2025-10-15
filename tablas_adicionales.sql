-- Tablas adicionales para las nuevas funcionalidades de gestión
-- Ejecutar después de la estructura base de legumbreria.sql

-- Tabla para promociones
CREATE TABLE `promociones` (
  `idPromocion` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(200) NOT NULL,
  `descripcion` text,
  `tipo` enum('descuento','cantidad','combo','temporada') NOT NULL,
  `descuento` decimal(5,2) DEFAULT NULL,
  `fechaInicio` date NOT NULL,
  `fechaFin` date NOT NULL,
  `productosAplicables` varchar(100) NOT NULL,
  `estado` enum('activa','inactiva','expirada') DEFAULT 'activa',
  `fechaCreacion` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idPromocion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla para contratos y acuerdos
CREATE TABLE `contratos` (
  `idContrato` int NOT NULL AUTO_INCREMENT,
  `tipo` enum('proveedor','cliente','servicio','distribucion') NOT NULL,
  `parteContratante` varchar(200) NOT NULL,
  `descripcion` text NOT NULL,
  `valor` decimal(15,2) NOT NULL,
  `vigencia` int NOT NULL COMMENT 'Vigencia en meses',
  `fechaInicio` date NOT NULL,
  `fechaFin` date NOT NULL,
  `condicionesEspeciales` text,
  `estado` enum('pendiente','activo','vencido','cancelado') DEFAULT 'pendiente',
  `fechaCreacion` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idContrato`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla para procedimientos internos
CREATE TABLE `procedimientos` (
  `idProcedimiento` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(200) NOT NULL,
  `descripcion` text NOT NULL,
  `area` enum('ventas','inventario','administracion','mantenimiento','calidad') NOT NULL,
  `pasos` text NOT NULL,
  `version` varchar(10) DEFAULT '1.0',
  `estado` enum('activo','inactivo','revision') DEFAULT 'activo',
  `fechaCreacion` timestamp DEFAULT CURRENT_TIMESTAMP,
  `fechaActualizacion` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`idProcedimiento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla para planes de trabajo
CREATE TABLE `planes_trabajo` (
  `idPlan` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(200) NOT NULL,
  `objetivo` text NOT NULL,
  `metas` text NOT NULL,
  `fechaInicio` date NOT NULL,
  `fechaFin` date NOT NULL,
  `responsable` varchar(100) NOT NULL,
  `progreso` decimal(5,2) DEFAULT 0.00,
  `estado` enum('planificado','en_progreso','completado','cancelado') DEFAULT 'planificado',
  `fechaCreacion` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idPlan`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla para KPIs (Indicadores de Rendimiento)
CREATE TABLE `kpis` (
  `idKPI` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `categoria` enum('ventas','operativos','financieros','calidad') NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  `unidad` varchar(20) NOT NULL,
  `meta` decimal(10,2) DEFAULT NULL,
  `fechaActualizacion` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`idKPI`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla para estrategias operativas
CREATE TABLE `estrategias` (
  `idEstrategia` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(200) NOT NULL,
  `tipo` enum('operacional','comercial','tecnologica','organizacional') NOT NULL,
  `descripcion` text NOT NULL,
  `beneficios` text NOT NULL,
  `recursos` text NOT NULL,
  `estado` enum('planificada','en_progreso','completada','pausada') DEFAULT 'planificada',
  `fechaCreacion` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idEstrategia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla para gastos operativos
CREATE TABLE `gastos_operativos` (
  `idGasto` int NOT NULL AUTO_INCREMENT,
  `concepto` varchar(200) NOT NULL,
  `descripcion` text,
  `monto` decimal(10,2) NOT NULL,
  `categoria` enum('suministros','servicios','mantenimiento','otros') NOT NULL,
  `fechaGasto` date NOT NULL,
  `estado` enum('pendiente','aprobado','rechazado') DEFAULT 'pendiente',
  `limiteAprobacion` decimal(10,2) DEFAULT 100000.00,
  `fechaCreacion` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idGasto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla para presupuestos por área
CREATE TABLE `presupuestos` (
  `idPresupuesto` int NOT NULL AUTO_INCREMENT,
  `area` varchar(100) NOT NULL,
  `periodo` varchar(20) NOT NULL COMMENT 'Ej: 2024-Q1',
  `montoAsignado` decimal(15,2) NOT NULL,
  `montoGastado` decimal(15,2) DEFAULT 0.00,
  `descripcion` text,
  `estado` enum('activo','cerrado','modificado') DEFAULT 'activo',
  `fechaCreacion` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idPresupuesto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla para cambios de precio pendientes
CREATE TABLE `cambios_precio` (
  `idCambio` int NOT NULL AUTO_INCREMENT,
  `idProducto` int NOT NULL,
  `precioActual` decimal(10,2) NOT NULL,
  `precioNuevo` decimal(10,2) NOT NULL,
  `motivo` text,
  `estado` enum('pendiente','aprobado','rechazado') DEFAULT 'pendiente',
  `fechaCreacion` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idCambio`),
  FOREIGN KEY (`idProducto`) REFERENCES `productos` (`idProducto`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tabla para cambios en catálogo pendientes
CREATE TABLE `cambios_catalogo` (
  `idCambio` int NOT NULL AUTO_INCREMENT,
  `tipo` enum('nuevo_producto','modificacion','eliminacion') NOT NULL,
  `idProducto` int DEFAULT NULL,
  `datosProducto` json DEFAULT NULL COMMENT 'Datos del producto en formato JSON',
  `descripcion` text NOT NULL,
  `estado` enum('pendiente','aprobado','rechazado') DEFAULT 'pendiente',
  `fechaCreacion` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idCambio`),
  FOREIGN KEY (`idProducto`) REFERENCES `productos` (`idProducto`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insertar datos iniciales para KPIs
INSERT INTO `kpis` (`nombre`, `categoria`, `valor`, `unidad`, `meta`) VALUES
('Tiempo Promedio de Atención', 'operativos', 3.20, 'minutos', 3.00),
('Productos Vendidos/Día', 'ventas', 1247.00, 'unidades', 1500.00),
('Satisfacción del Cliente', 'calidad', 94.20, 'porcentaje', 95.00),
('Eficiencia Operativa', 'operativos', 87.50, 'porcentaje', 90.00),
('Ticket Promedio', 'ventas', 45000.00, 'pesos', 50000.00),
('Conversión', 'ventas', 78.00, 'porcentaje', 80.00),
('Ventas por Hora', 'ventas', 125000.00, 'pesos', 150000.00),
('Rotación Inventario', 'operativos', 4.20, 'veces', 5.00),
('Margen Promedio', 'financieros', 28.50, 'porcentaje', 30.00);

-- Insertar datos iniciales para procedimientos
INSERT INTO `procedimientos` (`nombre`, `descripcion`, `area`, `pasos`, `version`) VALUES
('Recepción de Mercancía', 'Protocolo para recibir y almacenar productos frescos', 'inventario', '1. Verificar cantidad y calidad\n2. Registrar en sistema\n3. Almacenar según categoría\n4. Actualizar stock', '2.1'),
('Atención al Cliente', 'Protocolo de servicio y ventas', 'ventas', '1. Saludar cordialmente\n2. Identificar necesidades\n3. Mostrar productos\n4. Procesar venta\n5. Despedir amablemente', '1.8'),
('Control de Inventario', 'Gestión de stock y rotación', 'inventario', '1. Revisar stock diario\n2. Identificar productos con poco stock\n3. Generar órdenes de compra\n4. Actualizar sistema', '3.0');

-- Insertar datos iniciales para planes de trabajo
INSERT INTO `planes_trabajo` (`nombre`, `objetivo`, `metas`, `fechaInicio`, `fechaFin`, `responsable`, `progreso`) VALUES
('Optimización de Ventas Q1 2024', 'Incrementar las ventas del primer trimestre', 'Meta 1: Incrementar ventas 15%\nMeta 2: Mejorar satisfacción cliente\nMeta 3: Reducir tiempos de atención', '2024-01-01', '2024-03-31', 'Gerente', 68.00),
('Mejora de Eficiencia Operativa', 'Optimizar procesos internos', 'Meta 1: Reducir tiempos de proceso 20%\nMeta 2: Mejorar rotación de inventario\nMeta 3: Capacitar personal', '2024-02-01', '2024-06-30', 'Gerente', 45.00);

-- Insertar datos iniciales para estrategias
INSERT INTO `estrategias` (`nombre`, `tipo`, `descripcion`, `beneficios`, `recursos`) VALUES
('Digitalización de Procesos', 'tecnologica', 'Implementar sistema de gestión digital completo', 'Beneficio 1: Mayor eficiencia\nBeneficio 2: Reducción de errores\nBeneficio 3: Mejor control', 'Recursos humanos: 2 desarrolladores\nRecursos tecnológicos: Software y hardware\nRecursos financieros: $5,000,000'),
('Optimización de Inventario', 'operacional', 'Sistema de rotación inteligente de productos', 'Beneficio 1: Menos desperdicio\nBeneficio 2: Mejor rotación\nBeneficio 3: Mayor rentabilidad', 'Recursos humanos: 1 analista\nRecursos tecnológicos: Sistema de gestión\nRecursos financieros: $2,000,000');

-- Insertar datos iniciales para presupuestos
INSERT INTO `presupuestos` (`area`, `periodo`, `montoAsignado`, `montoGastado`) VALUES
('Ventas', '2024-Q1', 5000000.00, 3200000.00),
('Inventario', '2024-Q1', 3000000.00, 1800000.00),
('Administración', '2024-Q1', 2000000.00, 1200000.00),
('Mantenimiento', '2024-Q1', 1500000.00, 800000.00);
