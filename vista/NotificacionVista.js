const express = require('express');
const router = express.Router();
const jwtAuth = require('../middleware/authMiddleware');
const conexion = require('../modelo/bd/Conexion');

const util = {
    normalize: (data) => {
        if (!data) return data;
        if (Array.isArray(data)) {
            return data.map(row => {
                const normalizedRow = {};
                for (let key in row) {
                    normalizedRow[key.toLowerCase()] = row[key];
                }
                return normalizedRow;
            });
        }
        const normalizedRow = {};
        for (let key in data) {
            normalizedRow[key.toLowerCase()] = data[key];
        }
        return normalizedRow;
    }
};

// Obtener notificaciones del usuario
router.get('/', jwtAuth.verificarToken, async (req, res) => {
    const usuarioDecoded = req.usuario;
    const idusuario = usuarioDecoded.idusuario || usuarioDecoded.idUsuario;
    const rol = usuarioDecoded.rol;

    try {
        // Buscar notificaciones específicas para el usuario O para su rol
        const sql = `
      SELECT idnotificacion, titulo, mensaje, tipo, leido, fecha
      FROM public.notificaciones
      WHERE (idusuario = ? OR rol_destino = ?)
      ORDER BY fecha DESC
      LIMIT 20
    `;

        const notificaciones = util.normalize(await conexion.query(sql, [idusuario, rol]));
        res.json(notificaciones);
    } catch (err) {
        console.error('❌ Error al obtener notificaciones:', err);
        res.status(500).json({ mensaje: 'Error al obtener notificaciones' });
    }
});

// Marcar notificación como leída
router.put('/leer/:id', jwtAuth.verificarToken, async (req, res) => {
    const idnotificacion = req.params.id;
    try {
        await conexion.query('UPDATE public.notificaciones SET leido = TRUE WHERE idnotificacion = ?', [idnotificacion]);
        res.json({ ok: true });
    } catch (err) {
        console.error('❌ Error al marcar notificación como leída:', err);
        res.status(500).json({ mensaje: 'Error al actualizar notificación' });
    }
});

// Eliminar todas las notificaciones del usuario
router.delete('/limpiar', jwtAuth.verificarToken, async (req, res) => {
    const usuarioDecoded = req.usuario;
    const idusuario = usuarioDecoded.idusuario || usuarioDecoded.idUsuario;
    const rol = usuarioDecoded.rol;

    try {
        await conexion.query('DELETE FROM public.notificaciones WHERE idusuario = ? OR rol_destino = ?', [idusuario, rol]);
        res.json({ ok: true, mensaje: 'Notificaciones eliminadas' });
    } catch (err) {
        console.error('❌ Error al limpiar notificaciones:', err);
        res.status(500).json({ mensaje: 'Error al limpiar notificaciones' });
    }
});

// Función interna para crear notificaciones (para uso desde otros archivos si se exporta el modelo)
router.crearNotificacion = async ({ idusuario, rol_destino, titulo, mensaje, tipo }) => {
    try {
        const sql = `
      INSERT INTO public.notificaciones (idusuario, rol_destino, titulo, mensaje, tipo)
      VALUES (?, ?, ?, ?, ?)
    `;
        await conexion.query(sql, [idusuario || null, rol_destino || null, titulo, mensaje, tipo || 'sistema']);
        return true;
    } catch (err) {
        console.error('❌ Error al crear notificación:', err);
        return false;
    }
};

module.exports = router;
