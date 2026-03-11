const express = require('express');
require('dotenv').config();
const cors = require('cors');
const rutaUsuario = require('./vista/UsuarioVista');//crea todas las rutas del cliente
const app = express();
const PORT = process.env.PORT || 4545;
const { UsuarioModelo: modelo } = require('./modelo/UsuarioModelo');
const path = require('path'); // ✅ Importación necesaria para usar __dirname con path
const productoVista = require('./vista/ProductoVista');
const ventaVista = require('./vista/VentaVista');
const gestionVista = require('./vista/GestionVista');
const jwt = require('jsonwebtoken');

// Logger global para ver quién intenta conectar
app.use((req, res, next) => {
  console.log(`📡 [${new Date().toLocaleTimeString()}] Recibida solicitud: ${req.method} ${req.url} desde ${req.ip}`);
  next();
});


// Middleware
app.use(cors({
  origin: '*', // Cambiar ['http://tu.com', 'http://yo.com'],
  methods: ['GET', 'POST', 'PUT', 'DELETE'], // Métodos permitidos
  allowedHeaders: ['Content-Type', 'Authorization'], // Encabezados permitidos
  credentials: true // Habilita el envío de credenciales si es necesario
}));

// Middleware para parseo de solicitudes
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.static('public')); // si guardas el HTML ahí
app.use('/', require('./vista/UsuarioVista'));
app.use('/venta', ventaVista);
app.use('/gestion', gestionVista);
app.use('/legumbreria', productoVista);
app.use('/notificaciones', require('./vista/NotificacionVista'));
app.use('/', require('./vista/EmpleadoVista'));


// Middleware para autenticar el token JWT
const claveSecreta = process.env.JWT_SECRET || 'tu_clave_secreta';

function autenticarToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ mensaje: 'Token requerido' });

  jwt.verify(token, claveSecreta, (err, usuario) => {
    if (err) return res.status(403).json({ mensaje: 'Token inválido' });
    req.usuario = usuario;
    next();
  });
}

// prueba de conexion movil
app.get("/api/prueba", (req, res) => {
  console.log("📢 Intento de conexión desde dispositivo móvil detectado");
  res.json({ mensaje: "¡Conexión Exitosa con el Backend!" });
});

// Ruta para obtener el rol del usuario autenticado
app.get('/mi-rol', autenticarToken, async (req, res) => {
  // Si el token contiene el rol directamente:
  if (req.usuario.rol) {
    return res.json({ rol: req.usuario.rol });
  }
  // Si necesitas buscar el usuario en la base de datos:
  try {
    const usuarioBD = await modelo.findOne({ where: { correo: req.usuario.correo } });
    if (!usuarioBD) return res.status(404).json({ mensaje: 'Usuario no encontrado' });
    return res.json({ rol: usuarioBD.rol });
  } catch (error) {
    return res.status(500).json({ mensaje: 'Error de servidor' });
  }
});

// Middleware para manejar errores

// Rutas 
// Montar rutas de usuario solo en '/'
//app.use('/', rutaadmin);
// Iniciar el servidor
app.listen(PORT, "0.0.0.0", () => {
  console.log("=================================");
  console.log(`🚀 Servidor corriendo en:`);
  console.log(`👉 http://localhost:${PORT}`);
  console.log(`👉 http://192.168.1.23:${PORT}`);
  console.log("=================================");
});


