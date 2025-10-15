/*
con la funcion crearCliente se cumple el requisito rf-01
*/
require('dotenv').config(); // Asegúrate de cargar las variables .env
const jwt = require('jsonwebtoken');
const { UsuarioModelo: modelo } = require('../modelo/UsuarioModelo');
const enviarCorreoRegistro = require('../utils/mailer');
const { plantillaRegistro } = require('../utils/plantillasCorreo');


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
    const result = await modelo.crearUsuario(doc, name, email, tel, contras, pregunta, respuesta, 'usuario');

    // Generar el token JWT después de crear el usuario
    const jwt = require('jsonwebtoken');
    const JWT_SECRET = process.env.JWT_SECRET;
    const payload = {
      documento: doc,
      correo: email,
      nombres: name,
      rol: 'usuario'
    };
    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '2h' });
    
    // Calcular la fecha de expiración a partir del token
    const decoded = jwt.decode(token);
    const fecha_expiracion = new Date(decoded.exp * 1000);
   
    // GUARDAR EL TOKEN EN LA BASE DE DATOS
    await modelo.guardarToken(token, doc, fecha_expiracion);
    // enviar correo de bienvenida (opcional, no bloquear si falla)
    try {
await enviarCorreoRegistro(
  email,
  'Bienvenido a Legumbrería JM',
  plantillaRegistro(name)
);
    } catch (emailError) {
      console.log('Error al enviar correo de bienvenida:', emailError.message);
      // No bloquear el registro si falla el envío de correo
    }

    // Aquí debes enviar el token en la respuesta:
    res.status(201).json({
        mensaje: 'Usuario registrado exitosamente.',
        token,
        id: result.insertId // o el ID que corresponda
    });
} catch (err) {
    if (err.message.includes("Duplicate entry")) {
        return res.status(409).json({ error: 'Ya existe un usuario con estos datos.',
            sugerencia: 'intenta recuperar la cuenta o inicia sesión.' });
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
      const resultado = await modelo.validarCredenciales(email, password);
      
      if (!resultado) {
        return res.status(401).json({ 
          error: 'Usuario no encontrado',
          mensaje: 'El correo electrónico proporcionado no está registrado'
        });
      }
      // enviar correo de confirmación

    

  // Comentado: envío de correo al iniciar sesión
  try {
  await enviarCorreoRegistro(
       email,
       'Inicio de sesión exitoso - Legumbrería JM',
       `<h3>Hola ${resultado.usuario.nombres},</h3><p>Has iniciado sesión correctamente en tu cuenta. Si no fuiste tú, por favor comunícate con soporte.</p>`
    );
     } catch (emailError) {
     console.log('Error al enviar correo de confirmación:', emailError.message);
    // No bloquear el login si falla el envío de correo
   }

      // Si el usuario existe y las credenciales son correctas
      res.json({ 
        mensaje: 'Inicio de sesión exitoso', 
        usuario: {
          documento: resultado.usuario.documento,
          nombres: resultado.usuario.nombres,
          correo: resultado.usuario.correo,
          estado: resultado.usuario.estado,
          rol: resultado.usuario.rol || 'usuario'
        },
        token: resultado.token // Enviamos el token al cliente
      });

    } catch (err) {
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
    // El middleware auth debe agregar el usuario a req.usuario
    const documento = req.usuario?.documento;
    if (!documento) {
      return res.status(401).json({ error: 'No autenticado' });
    }
    const perfil = await modelo.obtenerPerfil(documento);
    if (!perfil) {
      return res.status(404).json({ error: 'Perfil no encontrado' });
    }
    res.json(perfil);
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener perfil' });
  }
}

// ...existing code...

// Editar perfil
static async editarPerfil(req, res) {
  try {
    const doc = req.usuario.documento;
    const { nombres, telefono, correo } = req.body;

    if (!nombres || !telefono || !correo) {
      return res.status(400).json({ error: 'Todos los campos son obligatorios' });
    }

    await modelo.actualizarPerfil(doc, nombres, telefono, correo);
    
    // enviar correo de confirmación de actualización
    try {
      await enviarCorreoRegistro(
        correo,
        'Perfil actualizado - Legumbrería JM',
        `<h3>Hola ${nombres},</h3><p>Tu perfil ha sido actualizado correctamente. Si no fuiste tú, por favor comunícate con soporte inmediatamente.</p><p>Gracias por confiar en Legumbrería JM 🥦</p>`
      );
      console.log('✅ Correo de confirmación de actualización enviado exitosamente');
    } catch (emailError) {
      console.log('❌ Error al enviar correo de confirmación:', emailError.message);
      // No bloquear la actualización si falla el envío de correo
    }
    
    res.json({ mensaje: 'Perfil actualizado correctamente' });
  } catch (err) {
    res.status(500).json({ error: 'Error al editar perfil', mensaje: err.message });
  }
}




}//cerrar clase controlador

module.exports = UsuarioControlador;