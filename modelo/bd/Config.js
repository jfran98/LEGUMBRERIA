require('dotenv').config();

const requiredEnvVars = ['DB_HOST', 'DB_USER', 'DB_PASSWORD', 'DB_NAME'];

// Validar que todas las variables requeridas estén definidas
requiredEnvVars.forEach((key) => {
  if (!process.env[key]) {
    console.warn(`⚠️  La variable de entorno ${key} no está definida.`);
  }
});

// Configuración de la conexión a la base de datos (cliente dual)
const dbConfig = {
  client: process.env.DB_CLIENT || 'mysql', // Usar variable de entorno
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '', // Sin contraseña por defecto
  database: process.env.DB_NAME || 'legumbreria',
  port: process.env.DB_PORT ? Number(process.env.DB_PORT) : 3306
};

module.exports = dbConfig;