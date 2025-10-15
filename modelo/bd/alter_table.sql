-- Agregar columnas para el control de intentos fallidos y estado
ALTER TABLE usuarios
ADD COLUMN intentos_fallidos INT DEFAULT 0,
ADD COLUMN estado VARCHAR(20) DEFAULT 'activo';

-- Actualizar registros existentes
UPDATE usuarios SET estado = 'activo' WHERE estado IS NULL;
UPDATE usuarios SET intentos_fallidos = 0 WHERE intentos_fallidos IS NULL;

-- Agregar índices para optimizar las consultas
ALTER TABLE usuarios ADD INDEX idx_estado (estado);
ALTER TABLE usuarios ADD INDEX idx_correo_estado (correo, estado); 

-- Control: cantidad total registrada por lote (no se descuenta en ventas)
ALTER TABLE regproductos ADD COLUMN cantidad1 DECIMAL(10,2) NOT NULL DEFAULT 0;
-- Inicializar con el stock actual existente
UPDATE regproductos SET cantidad1 = cantidad WHERE cantidad1 = 0;

-- Agregar columna metodoPago a la tabla factura
ALTER TABLE factura ADD COLUMN metodoPago ENUM('contraentrega', 'bancolombia', 'nequi') DEFAULT 'contraentrega';
-- Actualizar registros existentes con valor por defecto
UPDATE factura SET metodoPago = 'contraentrega' WHERE metodoPago IS NULL;