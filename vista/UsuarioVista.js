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
// Editar perfil
router.put('/usuario/editar', verificarToken, CRutas.editarPerfil);

// Cambiar rol (Solo Gerente)
router.post('/cambiar-rol', verificarToken, CRutas.cambiarRol);


// direcciones
const conexion = require('../modelo/bd/Conexion');

// Obtener direcciones del usuario
router.get('/perfil/direcciones', verificarToken, async (req, res) => {
    console.log('📡 [UsuarioVista] GET /perfil/direcciones solicitado');
    const usuarioDecoded = req.usuario;
    let idusuario = usuarioDecoded.idusuario || usuarioDecoded.idUsuario;

    try {
        if (!idusuario) {
            const u = await conexion.query('SELECT idusuario FROM usuarios WHERE documento = ?', [usuarioDecoded.documento]);
            if (u && u.length) idusuario = u[0].idusuario;
        }

        if (!idusuario) {
            console.warn('⚠️ [UsuarioVista] No se pudo identificar al usuario para direcciones');
            return res.status(404).json({ mensaje: 'Usuario no encontrado' });
        }

        const dirs = await conexion.query(
            'SELECT iddireccion, idusuario, calle AS direccion, ciudad, departamento AS titulo, referencia FROM direcciones WHERE idusuario = ? AND activo = TRUE',
            [idusuario]
        );
        console.log(`✅ [UsuarioVista] Direcciones encontradas: ${dirs.length}`);
        res.json(Array.isArray(dirs) ? dirs : []);
    } catch (error) {
        console.error('❌ [UsuarioVista] Error al obtener direcciones:', error);
        res.status(500).json({ error: 'Error al obtener direcciones', detalle: error.message });
    }
});

// Guardar nueva dirección
router.post('/perfil/direcciones', verificarToken, async (req, res) => {
    console.log('📡 [UsuarioVista] POST /perfil/direcciones solicitado');
    const usuarioDecoded = req.usuario;
    let idusuario = usuarioDecoded.idusuario || usuarioDecoded.idUsuario;
    const { titulo, direccion, ciudad, referencia } = req.body;

    try {
        if (!idusuario) {
            const u = await conexion.query('SELECT idusuario FROM usuarios WHERE documento = ?', [usuarioDecoded.documento]);
            if (u && u.length) idusuario = u[0].idusuario;
        }

        if (!idusuario) return res.status(404).json({ mensaje: 'Usuario no encontrado' });

        await conexion.query(
            'INSERT INTO direcciones (idusuario, calle, ciudad, referencia, departamento) VALUES (?, ?, ?, ?, ?)',
            [idusuario, direccion, ciudad, referencia, titulo]
        );

        console.log('✅ [UsuarioVista] Dirección guardada con éxito');
        res.status(201).json({ ok: true });
    } catch (error) {
        console.error('❌ [UsuarioVista] Error al guardar dirección:', error);
        res.status(500).json({ error: 'Error al guardar dirección', detalle: error.message });
    }
});

// Eliminar dirección (Borrado Lógico)
router.delete('/perfil/direcciones/:id', verificarToken, async (req, res) => {
    console.log(`📡 [UsuarioVista] DELETE /perfil/direcciones/${req.params.id} solicitado (Lógico)`);
    const id = req.params.id;
    try {
        await conexion.query('UPDATE direcciones SET activo = FALSE WHERE iddireccion = ?', [id]);
        console.log('✅ [UsuarioVista] Dirección desactivada');
        res.json({ ok: true });
    } catch (error) {
        console.error('❌ [UsuarioVista] Error al desactivar dirección:', error);
        res.status(500).json({ error: 'Error al eliminar dirección', detalle: error.message });
    }
});

module.exports = router;
