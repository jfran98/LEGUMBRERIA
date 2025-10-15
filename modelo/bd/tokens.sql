CREATE TABLE IF NOT EXISTS tokens (
    id INT PRIMARY KEY AUTO_INCREMENT,
    documento VARCHAR(10) NOT NULL,
    token TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP NOT NULL,
    estado ENUM('activo', 'revocado') DEFAULT 'activo',
    FOREIGN KEY (documento) REFERENCES usuarios(documento) ON DELETE CASCADE,
    INDEX idx_token (token(100)),
    INDEX idx_documento (documento)
); 