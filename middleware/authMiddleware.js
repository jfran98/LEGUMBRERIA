const jwt = require('jsonwebtoken');
const { UsuarioModelo, JWT_SECRET } = require('../modelo/UsuarioModelo');

const verificarToken = async (req, res, next) => {
    // Obtener el token del header
    const token = req.headers.authorization?.split(' ')[1]; // Bearer TOKEN

    if (!token) {
        return res.status(401).json({
            error: 'Acceso denegado',
            mensaje: 'Token no proporcionado'
        });
    }

    try {
        // Verificar el token con JWT
        const decoded = jwt.verify(token, JWT_SECRET);
        
        // Verificar si el token está activo en la base de datos
        const tokenValido = await UsuarioModelo.verificarToken(token);
        
        if (!tokenValido) {
            return res.status(401).json({
                error: 'Token inválido',
                mensaje: 'El token ha sido revocado o ha expirado'
            });
        }

        // Agregar la información del usuario decodificada a la request
        req.usuario = decoded;
        
        // Continuar con la siguiente función
        next();
    } catch (error) {
        return res.status(401).json({
            error: 'Token inválido',
            mensaje: 'El token proporcionado no es válido o ha expirado'
        });
    }
};

function soloGerenteOEmpleado(req, res, next) {
  const usuario = req.usuario; // Esto lo pone el middleware de autenticación
  if (usuario.rol === 'gerente' || usuario.rol === 'empleado') {
    return next();
  }
  return res.status(403).json({ error: 'Acceso solo para gerentes o empleados' });
}

module.exports = { verificarToken, soloGerenteOEmpleado }; 