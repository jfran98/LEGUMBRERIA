const express = require('express');
const CRutas = require('../controlador/UsuarioControlador');
const router = express.Router();
const { verificarToken } = require('../middleware/authMiddleware'); // asegúrate de tener este middleware

// Rutas de usuario
//crear usuarios
router.post('/usuario', CRutas.crearUsuario);
//iniciar sesion
router.post('/login', CRutas.validarCredencial);
// Ver perfil actual
router.get('/usuario/perfil', verificarToken, CRutas.verPerfil);
//editar perfil
router.put('/usuario/editar', verificarToken, CRutas.editarPerfil);


module.exports = router; 
