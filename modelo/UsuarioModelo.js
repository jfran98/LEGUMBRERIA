/*
1. este es rf-01 crear usuario cliente funcon crearClientes
*/

const dbService = require('./bd/Conexion');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// Clave secreta para firmar el token - En producción, esto debería estar en variables de entorno
const JWT_SECRET = '12345@jJ';

class UsuarioModelo {
  // funcion para crear nuevos clientes
static async crearUsuario(doc, name, email, tel, contras, pregunta, respuesta, rol = 'usuario') {
    try {
    const salto = 10;
    const contra = await bcrypt.hash(contras, salto);
    const respuestaHasheada = await bcrypt.hash(respuesta, salto);

    const query = `
      INSERT INTO usuarios 
      (documento, nombres, correo, telefono, contrasena, pregunta, respuesta, intentos_fallidos, estado, rol) 
      VALUES (?, ?, ?, ?, ?, ?, ?, 0, "activo", ?)
    `;
    return await dbService.query(query, [doc, name, email, tel, contra, pregunta, respuestaHasheada, rol]);
  } catch (err) {
    throw new Error(`Error al crear su nueva cuenta: ${err.message}`);
  }
}//cerrar crear cliente
 



   static async buscaCorreo(email) {
    const query = 'SELECT * FROM usuarios WHERE correo = ?';
    try {
      const result = await dbService.query(query, [email]);
      return result.length ? result[0] : null;
    } catch (err) {
      throw new Error(`Error al buscar el usuario por correo: ${err.message}`);
    }
  }

  static async actualizarIntentosFallidos(documento, intentos) {
    const query = 'UPDATE usuarios SET intentos_fallidos = ?, estado = ? WHERE documento = ?';
    const estado = intentos >= 3 ? 'bloqueado' : 'activo';
    try {
      await dbService.query(query, [intentos, estado, documento]);
    } catch (err) {
      throw new Error(`Error al actualizar intentos fallidos: ${err.message}`);
    }
  }

  static async resetearIntentosFallidos(documento) {
    const query = 'UPDATE usuarios SET intentos_fallidos = 0, estado = "activo" WHERE documento = ?';
    try {
      await dbService.query(query, [documento]);
    } catch (err) {
      throw new Error(`Error al resetear intentos fallidos: ${err.message}`);
    }
  }

  // Método para generar token JWT y guardarlo en la base de datos
  static async generarToken(usuario) {
    const payload = {
      documento: usuario.documento,
      correo: usuario.correo,
      nombres: usuario.nombres,
      rol: usuario.rol || 'usuario' // <-- Asegurar que siempre tenga un rol
    };

    try {
      // Generar el token con expiración de 24 horas
      const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '24h' });
      
      // Calcular la fecha de expiración
      const fecha_expiracion = new Date();
      fecha_expiracion.setHours(fecha_expiracion.getHours() + 24);
      
      // Guardar el token en la base de datos
      const query = 'INSERT INTO tokens (documento, token, fecha_expiracion) VALUES (?, ?, ?)';
      await dbService.query(query, [usuario.documento, token, fecha_expiracion]);

      return token;
    } catch (error) {
      throw new Error(`Error al generar el token: ${error.message}`);
    }
  }

  // Método para verificar si un token es válido en la base de datos
  static async verificarToken(token) {
    const query = 'SELECT * FROM tokens WHERE token = ? AND estado = "activo" AND fecha_expiracion > NOW()';
    try {
      const result = await dbService.query(query, [token]);
      return result.length > 0;
    } catch (error) {
      throw new Error(`Error al verificar el token: ${error.message}`);
    }
  }

  // Método para revocar un token
  static async revocarToken(token) {
    const query = 'UPDATE tokens SET estado = "revocado" WHERE token = ?';
    try {
      await dbService.query(query, [token]);
    } catch (error) {
      throw new Error(`Error al revocar el token: ${error.message}`);
    }
  }

  // Método para limpiar tokens expirados
  static async limpiarTokensExpirados() {
    const query = 'DELETE FROM tokens WHERE fecha_expiracion < NOW() OR estado = "revocado"';
    try {
      await dbService.query(query);
    } catch (error) {
      throw new Error(`Error al limpiar tokens expirados: ${error.message}`);
    }
  }

  // Modificar el método validarCredenciales para usar el nuevo sistema de tokens
  static async validarCredenciales(email, password) {
    if (!email || !password) {
      throw new Error('Correo y contraseña son obligatorios');
    }

    try {
      const usuario = await this.buscaCorreo(email);
      if (!usuario) {
        return null;
      }

      if (usuario.estado === 'bloqueado') {
        throw new Error('Su cuenta está bloqueada por múltiples intentos fallidos. Por favor, contacte al administrador.');
      }

      const match = await bcrypt.compare(password, usuario.contrasena);
      
      if (!match) {
        const nuevoIntentos = (usuario.intentos_fallidos || 0) + 1;
        const intentosRestantes = 3 - nuevoIntentos;
        await this.actualizarIntentosFallidos(usuario.documento, nuevoIntentos);
        
        if (nuevoIntentos >= 3) {
          throw new Error('Su cuenta ha sido bloqueada por múltiples intentos fallidos. Por favor, contacte al administrador.');
        }
        
        throw new Error(`Contraseña incorrecta. Le quedan ${intentosRestantes} ${intentosRestantes === 1 ? 'intento' : 'intentos'} antes de que su cuenta sea bloqueada.`);
      }

      await this.resetearIntentosFallidos(usuario.documento);
      
      // Generar y guardar el nuevo token
      const token = await this.generarToken(usuario);
      
      return {
        usuario,
        token
      };
    } catch (err) {
      throw new Error(err.message);
    }
  }

  // Obtener perfil
static async obtenerPerfil(documento) {
  const query = 'SELECT documento, nombres, correo, telefono FROM usuarios WHERE documento = ?';
  const resultado = await dbService.query(query, [documento]);
  return resultado.length ? resultado[0] : null;
}

// Actualizar perfil
static async actualizarPerfil(documento, nombres, telefono, correo) {
  const query = 'UPDATE usuarios SET nombres = ?, telefono = ?, correo = ? WHERE documento = ?';
  await dbService.query(query, [nombres, telefono, correo, documento]);
}
// Cambiar contraseña

//guardar token
static async guardarToken(token, documento, fecha_expiracion) {
  const query = 'INSERT INTO tokens (token, documento, fecha_expiracion, estado) VALUES (?, ?, ?, "activo")';
  console.log('Guardando token:', { token, documento, fecha_expiracion });
  try {
    await dbService.query(query, [token, documento, fecha_expiracion]);
  } catch (err) {
    console.error('Error al guardar el token:', err.message);
    throw err;
  }
}

} //cerrar clase

module.exports = { UsuarioModelo, JWT_SECRET };

