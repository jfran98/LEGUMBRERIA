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
      (documento, nombres, correo, telefono, contrasena, pregunta, respuesta, intentos, estado, rol) 
      VALUES (?, ?, ?, ?, ?, ?, ?, 0, 'activo', ?)
      RETURNING *
    `;
      const result = await dbService.query(query, [doc, name, email, tel, contra, pregunta, respuestaHasheada, rol]);
      if (!result || !result.length) return null;

      const normalizedRow = {};
      for (let key in result[0]) {
        normalizedRow[key.toLowerCase()] = result[0][key];
      }
      return normalizedRow;
    } catch (err) {
      throw new Error(`Error al crear su nueva cuenta: ${err.message}`);
    }
  }//cerrar crear cliente

  static async buscaCorreo(email) {
    const query = 'SELECT * FROM usuarios WHERE correo = ?';
    try {
      const result = await dbService.query(query, [email]);
      if (!result.length) return null;

      const normalizedRow = {};
      for (let key in result[0]) {
        normalizedRow[key.toLowerCase()] = result[0][key];
      }
      return normalizedRow;
    } catch (err) {
      throw new Error(`Error al buscar el usuario por correo: ${err.message}`);
    }
  }

  static async actualizarIntentosFallidos(documento, intentos) {
    const query = 'UPDATE usuarios SET intentos = ?, estado = ? WHERE documento = ?';
    const estado = intentos >= 3 ? 'bloqueado' : 'activo';
    try {
      await dbService.query(query, [intentos, estado, documento]);
    } catch (err) {
      throw new Error(`Error al actualizar intentos fallidos: ${err.message}`);
    }
  }

  static async resetearIntentosFallidos(documento) {
    const query = 'UPDATE usuarios SET intentos = 0, estado = ? WHERE documento = ?';
    try {
      await dbService.query(query, ['activo', documento]);
    } catch (err) {
      throw new Error(`Error al resetear intentos fallidos: ${err.message}`);
    }
  }

  // Método para generar token JWT y guardarlo en la base de datos
  static async generarToken(usuario) {
    const payload = {
      idusuario: usuario.idusuario || usuario.idUsuario,
      documento: usuario.documento,
      correo: usuario.correo,
      nombres: usuario.nombres,
      rol: usuario.rol || 'usuario'
    };

    try {
      // Generar el token con expiración de 24 horas
      const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '24h' });

      // Calcular la fecha de expiración
      const fechaExpiracion = new Date();
      fechaExpiracion.setHours(fechaExpiracion.getHours() + 24);

      // Guardar el token en la base de datos
      const query = 'INSERT INTO tokens (idusuario, token, fechaexpiracion, tipo) VALUES (?, ?, ?, ?)';
      await dbService.query(query, [usuario.idusuario || usuario.idUsuario, token, fechaExpiracion, 'auth']);

      return token;
    } catch (error) {
      throw new Error(`Error al generar el token: ${error.message}`);
    }
  }

  // Método para verificar si un token es válido en la base de datos
  static async verificarToken(token) {
    const query = 'SELECT * FROM tokens WHERE token = ? AND usado = FALSE AND fechaexpiracion > NOW()';
    try {
      const result = await dbService.query(query, [token]);
      return result.length > 0;
    } catch (error) {
      throw new Error(`Error al verificar el token: ${error.message}`);
    }
  }

  // Método para revocar un token
  static async revocarToken(token) {
    const query = 'UPDATE tokens SET usado = TRUE WHERE token = ?';
    try {
      await dbService.query(query, [token]);
    } catch (error) {
      throw new Error(`Error al revocar el token: ${error.message}`);
    }
  }

  // Método para limpiar tokens expirados
  static async limpiarTokensExpirados() {
    const query = 'DELETE FROM tokens WHERE fechaexpiracion < NOW() OR usado = TRUE';
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
        const nuevoIntentos = (usuario.intentos || 0) + 1;
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
    if (!resultado.length) return null;

    const normalizedRow = {};
    for (let key in resultado[0]) {
      normalizedRow[key.toLowerCase()] = resultado[0][key];
    }
    return normalizedRow;
  }

  // Actualizar perfil
  static async actualizarPerfil(documento, nombres, telefono, correo) {
    const query = 'UPDATE usuarios SET nombres = ?, telefono = ?, correo = ? WHERE documento = ?';
    await dbService.query(query, [nombres, telefono, correo, documento]);
  }

  //guardar token
  static async guardarToken(token, idusuario, fechaExpiracion) {
    const query = 'INSERT INTO tokens (token, idusuario, fechaexpiracion, tipo, usado) VALUES (?, ?, ?, ?, FALSE)';
    try {
      await dbService.query(query, [token, idusuario, fechaExpiracion, 'auth']);
    } catch (err) {
      console.error('Error al guardar el token:', err.message);
      throw err;
    }
  }

  // Cambiar rol por correo y actualizar datos de nómina
  static async cambiarRol(email, nuevoRol, datosNomina = {}) {
    try {
      // 1. Actualizar rol en la tabla usuarios
      // 1. Actualizar rol y documento en la tabla usuarios
      const { documento } = datosNomina;
      let queryUser = 'UPDATE usuarios SET rol = ? WHERE correo = ?';
      let paramsUser = [nuevoRol, email];

      if (documento && (nuevoRol === 'empleado' || nuevoRol === 'gerente')) {
        queryUser = 'UPDATE usuarios SET rol = ?, documento = ? WHERE correo = ?';
        paramsUser = [nuevoRol, documento, email];
      }

      await dbService.query(queryUser, paramsUser);

      // 2. Si es empleado o gerente, sincronizar con la tabla empleados
      if (nuevoRol === 'empleado' || nuevoRol === 'gerente') {
        const { documento, salario_mensual, auxilio_transporte } = datosNomina;

        // Obtener nombres del usuario para la tabla empleados
        const u = await this.buscaCorreo(email);
        if (!u) return true;

        const nombre = u.nombres || u.nombre;

        // Verificar si ya existe en empleados por documento o por nombre
        const qCheck = 'SELECT id_empleado FROM empleados WHERE documento = ? OR nombre = ?';
        const eExist = await dbService.query(qCheck, [documento, nombre]);

        if (eExist && eExist.length > 0) {
          // Actualizar
          const qUpd = `
            UPDATE empleados 
            SET salario_mensual = ?, auxilio_transporte = ?, documento = ?, idusuario = ?, activo = TRUE 
            WHERE id_empleado = ?
          `;
          await dbService.query(qUpd, [salario_mensual, auxilio_transporte, documento, u.idusuario, eExist[0].id_empleado]);
        } else {
          // Insertar
          const qIns = `
            INSERT INTO empleados (nombre, documento, salario_mensual, auxilio_transporte, idusuario, activo)
            VALUES (?, ?, ?, ?, ?, TRUE)
          `;
          await dbService.query(qIns, [nombre, documento, salario_mensual, auxilio_transporte, u.idusuario]);
        }
      } else {
        // Si vuelve a ser 'usuario', podríamos desactivarlo en la tabla empleados si existe
        // Pero el requerimiento no lo pide explícitamente, así que solo lo dejamos así por ahora.
      }

      return true;
    } catch (err) {
      throw new Error(`Error al cambiar el rol y sincronizar nómina: ${err.message}`);
    }
  }

} //cerrar clase

module.exports = { UsuarioModelo, JWT_SECRET };
