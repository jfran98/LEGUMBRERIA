// vista/EmpleadoVista.js
const express = require('express');
const router = express.Router();
const EmpleadoControlador = require('../controlador/EmpleadoControlador');
const jwt = require('jsonwebtoken');

// Middleware de autenticación local (similar al de app.js)
const claveSecreta = process.env.JWT_SECRET || 'tu_clave_secreta';

function autenticarToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.status(401).json({ success: false, message: 'Token requerido' });

    jwt.verify(token, claveSecreta, (err, usuario) => {
        if (err) return res.status(403).json({ success: false, message: 'Token inválido' });
        req.usuario = usuario;
        next();
    });
}

// Rutas de Empleados
router.get('/empleados', autenticarToken, EmpleadoControlador.listarEmpleados);
router.post('/empleados', autenticarToken, EmpleadoControlador.crearEmpleado);

// Rutas de Turnos
router.post('/turnos', autenticarToken, EmpleadoControlador.registrarTurno);

// Rutas de Nómina
router.get('/nomina/mensual', autenticarToken, EmpleadoControlador.obtenerResumenMensual);
router.post('/nomina/descontar-dia', autenticarToken, EmpleadoControlador.descontarDia);
router.post('/nomina/descontar-horas', autenticarToken, EmpleadoControlador.descontarHoras);
router.get('/nomina/mi-resumen', autenticarToken, EmpleadoControlador.obtenerResumenPersonal);
router.post('/nomina/pagar', autenticarToken, EmpleadoControlador.registrarPago);
router.get('/nomina/historial', autenticarToken, EmpleadoControlador.obtenerHistorialPagos);

module.exports = router;
