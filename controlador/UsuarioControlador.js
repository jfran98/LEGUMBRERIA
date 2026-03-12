/*
con la funcion crearCliente se cumple el requisito rf-01
*/
require('dotenv').config(); // Asegúrate de cargar las variables .env
const jwt = require('jsonwebtoken');
const { UsuarioModelo: modelo } = require('../modelo/UsuarioModelo');


class UsuarioControlador {
  // funcion crear nuevo cliente
  static async crearUsuario(req, res) {
    const { t1: doc, t2: name, t3: email, t4: tel, t5: contras, pregunta, respuesta } = req.body;

    // ------------👁️‍🗨️ validaciones👁️‍🗨️----------------
    // Validar campos vacíos❓❓❓❓❓----------------
    const errorCampos = UsuarioControlador.verCampos(doc, name, email, tel, contras, pregunta, respuesta, 'usuario');
    if (errorCampos) {
      return res.status(400).json({ error: errorCampos });
    }
    // Validar documento❓❓❓❓❓❓-------------------
    const erorIde = UsuarioControlador.verIde(doc);
    if (erorIde) {
      return res.status(400).json({ error: erorIde });
    }
    // Validar nombres completos ❓❓❓❓❓❓❓------------
    const errornom = UsuarioControlador.vernom(name);
    if (errornom) {
      return res.status(400).json({ error: errornom });
    }
    // Validar teléfono❓❓❓❓❓❓❓-----------------------
    const errortel = UsuarioControlador.verTel(tel);
    if (errortel) {
      return res.status(400).json({ error: errortel });
    }
    // Validar correo❓❓❓❓❓❓❓--------------------------
    const errorem = UsuarioControlador.veremail(email);
    if (errorem) {
      return res.status(400).json({ error: errorem });
    }
    // Validar contraseña❓❓❓❓❓❓-----------------------
    const errorkey = UsuarioControlador.verkey(contras);
    if (errorkey) {
      return res.status(400).json({ error: errorkey });
    }
    if (!pregunta || !respuesta) {
      return res.status(400).json({ error: 'Debes seleccionar una pregunta de seguridad y escribir una respuesta.' });
    }


    try {
      // Aquí forzamos el rol a 'usuario'
      const nuevoUsuario = await modelo.crearUsuario(doc, name, email, tel, contras, pregunta, respuesta, 'usuario');

      // Generar el token JWT usando el método del modelo
      const token = await modelo.generarToken(nuevoUsuario);

      res.status(201).json({
        mensaje: 'Usuario registrado exitosamente.',
        token,
        id: nuevoUsuario.idusuario || nuevoUsuario.idUsuario
      });
    } catch (err) {
      if (err.message.includes("Duplicate entry") || err.message.includes("violates unique constraint")) {
        return res.status(409).json({
          error: 'Ya existe un usuario con estos datos.',
          sugerencia: 'intenta recuperar la cuenta o inicia sesión.'
        });
      } else {
        return res.status(500).json({ error: 'Error inesperado: ' + err.message });
      }
    }

    // ------------👁️‍🗨️ fin validaciones👁️‍🗨️------------

  }//cerrar crearcliente-------------------------------

  //👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊
  //-------------------validaciones----------------------------
  //👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊

  static verCampos(doc, name, email, tel, contras, pregunta, respuesta) {
    if (!doc || !name || !email || !tel || !contras || !pregunta || !respuesta) {
      return 'Todos los campos son obligatorios.';
    }
    return null; // no encontro campos vacios
  }//cerrar verCampos
  //validar documento
  static verIde(doc) {
    if (!/^\d{8,10}$/.test(doc)) {
      return 'La identificación debe tener entre 8 y 10 dígitos numéricos.';
    } else {
      return null; // Todo bien
    }
  }//cerrar documento
  //verificar nombres completos
  static vernom(name) {
    const nom = /^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]{3,100}$/;
    if (!nom.test(name)) {
      return 'Nombres y apellidos invalidos minimo 3 caracteres o maximo 100 solo letras minuscula o ]Mayuscula';
    } else {
      return null;
    }
  }
  //verificar telefono
  static verTel(tel) {
    if (!/^\d{10}$/.test(tel)) {
      return 'El teléfono debe tener exactamente 10 dígitos numéricos.';
    } else {
      return null; // todo bien
    }
  }
  //validar correo
  static veremail(email) {
    const er = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!er.test(email) || email.length > 200) {
      return 'Correo inválido. Ejemplo válido: ejemplo@email.com';
    } else {
      return null;
    }
  }//cerrar veremail
  //verificar contraseña
  static verkey(contras) {
    const key = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$/;
    if (!key.test(contras)) {
      return 'La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un símbolo especial.';
    } else {
      return null;
    }
  }
  //👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊👊
  // Validar correo y contraseña
  static async validarCredencial(req, res) {
    const { t3: email, t5: password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Correo y contraseña son obligatorios' });
    }

    try {
      console.time('Login_Total');
      console.log('🔍 [CONTROLADOR] Iniciando validación de credenciales...');
      console.time('DB_ValidarCredenciales');
      const resultado = await modelo.validarCredenciales(email, password);
      console.timeEnd('DB_ValidarCredenciales');
      console.log('✅ [CONTROLADOR] DB respondió:', resultado ? 'Usuario encontrado' : 'No encontrado');

      if (!resultado) {
        return res.status(401).json({
          error: 'Usuario no encontrado',
          mensaje: 'El correo electrónico proporcionado no está registrado'
        });
      }
      // enviar correo de confirmación



      // Comentado: envío de correo al iniciar sesión
      // Si el usuario existe y las credenciales son correctas
      console.log('🚀 [CONTROLADOR] Enviando respuesta exitosa al cliente...');
      console.timeEnd('Login_Total');
      res.json({
        mensaje: 'Inicio de sesión exitoso',
        usuario: {
          documento: resultado.usuario.documento, // Antes documento
          nombres: resultado.usuario.nombres,
          correo: resultado.usuario.correo,
          estado: resultado.usuario.estado,
          rol: resultado.usuario.rol || 'usuario'
        },
        token: resultado.token // Enviamos el token al cliente
      });

    } catch (err) {
      console.timeEnd('Login_Total');
      // Manejar específicamente el error de cuenta bloqueada
      if (err.message.includes('bloqueada')) {
        return res.status(403).json({
          error: 'Cuenta bloqueada',
          mensaje: err.message
        });
      }

      // Manejar error de contraseña incorrecta con intentos restantes
      if (err.message.includes('Contraseña incorrecta')) {
        return res.status(401).json({
          error: 'Credenciales incorrectas',
          mensaje: err.message
        });
      }

      // Otros errores del servidor
      res.status(500).json({
        error: 'Error en el servidor',
        mensaje: err.message
      });
    }
  }

  // Método de prueba para verificar el token
  static async verificarAcceso(req, res) {
    try {
      res.json({
        mensaje: 'Acceso autorizado',
        usuario: req.usuario
      });
    } catch (error) {
      res.status(500).json({
        error: 'Error en el servidor',
        mensaje: error.message
      });
    }
  }

  // Método para cerrar sesión (revocar token)
  static async cerrarSesion(req, res) {
    try {
      const token = req.headers.authorization?.split(' ')[1];
      if (token) {
        await modelo.revocarToken(token);
      }
      res.json({
        mensaje: 'Sesión cerrada exitosamente'
      });
    } catch (error) {
      res.status(500).json({
        error: 'Error al cerrar sesión',
        mensaje: error.message
      });
    }
  }

  // ...existing code...
  static async verPerfil(req, res) {
    try {
      // El middleware auth utiliza el token que contiene 'documento'
      const documento = req.usuario?.documento;
      console.log('🔍 [Controlador] Buscando perfil para documento:', documento);

      if (!documento) {
        console.log('❌ [Controlador] No se encontró documento en el token payload:', req.usuario);
        // Fallback por si el payload trae idUsuario pero no documento, o si trae documento (caso legacy)
        const fallbackDoc = req.usuario?.documento;
        if (!fallbackDoc) return res.status(401).json({ error: 'No autenticado' });
      }

      const perfil = await modelo.obtenerPerfil(documento || req.usuario.documento);
      if (!perfil) {
        return res.status(404).json({ error: 'Perfil no encontrado' });
      }
      res.json(perfil);
    } catch (err) {
      console.error('❌ [Controlador] Error verPerfil:', err.message);
      res.status(500).json({ error: 'Error al obtener perfil' });
    }
  }

  // ...existing code...

  // Editar perfil
  static async editarPerfil(req, res) {
    try {
      const doc = req.usuario.documento || req.usuario.documento;
      const { nombres, telefono, correo } = req.body;

      if (!nombres || !telefono || !correo) {
        return res.status(400).json({ error: 'Todos los campos son obligatorios' });
      }

      res.json({ mensaje: 'Perfil actualizado correctamente' });
    } catch (err) {
      res.status(500).json({ error: 'Error al editar perfil', mensaje: err.message });
    }
  }  // Cambiar rol (Solo Gerente)
  static async cambiarRol(req, res) {
    const { email, rol, documento, salario_mensual, auxilio_transporte } = req.body;
    const { rol: solRol } = req.usuario;

    if (solRol !== 'gerente') {
      return res.status(403).json({ error: 'No tienes permisos para cambiar roles' });
    }

    if (!email || !rol) {
      return res.status(400).json({ error: 'Correo y rol son obligatorios' });
    }

    try {
      const datosNomina = { documento, salario_mensual, auxilio_transporte };
      await modelo.cambiarRol(email, rol, datosNomina);
      res.json({ success: true, mensaje: 'Rol y datos de nómina actualizados correctamente' });
    } catch (err) {
      res.status(500).json({ error: 'Error al cambiar rol', mensaje: err.message });
    }
  }

}//cerrar clase controlador

module.exports = UsuarioControlador;