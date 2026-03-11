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

// Crear factura con detalles e iniciar pedidos (Checkout)
router.post('/checkout', jwtAuth.verificarToken, async (req, res) => {
  const usuarioDecoded = req.usuario;
  const items = Array.isArray(req.body?.items) ? req.body.items : [];
  let metodoPago = req.body?.metodopago || req.body?.metodoPago || 'contraentrega';

  if (!items.length) {
    return res.status(400).json({ mensaje: 'Carrito vacío' });
  }

  try {
    // Buscar idusuario por documento del token
    let idusuario = usuarioDecoded.idusuario || usuarioDecoded.idUsuario;
    if (!idusuario) {
      const usuarios = util.normalize(await conexion.query('SELECT idusuario FROM public.usuarios WHERE documento = ?', [usuarioDecoded.documento]));
      if (usuarios && usuarios.length) idusuario = usuarios[0].idusuario;
    }

    if (!idusuario) {
      return res.status(400).json({ mensaje: 'Usuario no encontrado' });
    }

    // Calcular el total de la factura
    let total = 0;
    for (const item of items) {
      total += Number(item.subtotal || 0);
    }

    const valorDomicilio = Number(req.body.domicilio || 0);
    total += valorDomicilio;

    // Crear factura con idestado 1 (pendiente)
    const insFactura = util.normalize(await conexion.query(
      "INSERT INTO public.factura (idusuario, total, idestado, metodo_pago) VALUES (?, ?, ?, ?) RETURNING idfactura",
      [idusuario, total, 1, metodoPago.toUpperCase()]
    ));

    if (!insFactura || !insFactura.length) {
      throw new Error('No se pudo obtener el ID de la factura creada');
    }

    const idfactura = insFactura[0].idfactura;

    // Registrar en tabla Pedidos
    const direcciones = util.normalize(await conexion.query('SELECT iddireccion FROM public.direcciones WHERE idusuario = ? AND activo = TRUE LIMIT 1', [idusuario]));
    let iddireccion = direcciones && direcciones.length > 0 ? direcciones[0].iddireccion : null;

    if (!iddireccion) {
      return res.status(400).json({ mensaje: 'No tienes una dirección de envío registrada.' });
    }

    await conexion.query(
      "INSERT INTO public.pedidos (idusuario, iddireccion, total, idestado, idfactura) VALUES (?, ?, ?, ?, ?)",
      [idusuario, iddireccion, total, 1, idfactura]
    );

    const notiVista = require('./NotificacionVista');

    // Registrar detalles y actualizar stock
    for (const item of items) {
      const idproductos = item.idproductos || item.idproducto;
      const stock = Number(item.stock || item.cantidad || 0);
      const precio = Number(item.precio || item.precio_unitario || 0);
      const subtotal = Number(item.subtotal || 0);

      if (!idproductos) continue;

      await conexion.query(
        'INSERT INTO public.detalles (idfactura, idproductos, stock, precio, subtotal) VALUES (?, ?, ?, ?, ?)',
        [idfactura, idproductos, stock, precio, subtotal]
      );

      // Actualizar stock y capturar el nuevo valor
      const resStock = util.normalize(await conexion.query(
        'UPDATE public.productos SET stock = stock - ? WHERE idproductos = ? RETURNING nombre, stock',
        [stock, idproductos]
      ));

      // Notificar stock bajo si el producto bajó de 10
      if (resStock && resStock.length && resStock[0].stock < 10) {
        await notiVista.crearNotificacion({
          rol_destino: 'gerente',
          titulo: '⚠️ Stock Bajo Detectado',
          mensaje: `El producto "${resStock[0].nombre}" tiene solo ${resStock[0].stock} unidades/kg disponibles.`,
          tipo: 'stock'
        });
      }
    }

    // Notificaciones de Nuevo Pedido para el Staff
    await notiVista.crearNotificacion({
      rol_destino: 'empleado',
      titulo: '📦 Nuevo Pedido Recibido',
      mensaje: `Se ha registrado el pedido #${idfactura} por un total de $${total}.`,
      tipo: 'pedido'
    });
    await notiVista.crearNotificacion({
      rol_destino: 'gerente',
      titulo: '💰 Nueva Venta Registrada',
      mensaje: `Venta por $${total}. Factura #${idfactura}.`,
      tipo: 'pedido'
    });

    return res.json({ ok: true, idfactura, metodopago: metodoPago });
  } catch (err) {
    console.error('Error al crear la factura:', err);
    return res.status(500).json({ mensaje: 'Error al crear la factura', detalle: err?.message });
  }
});

// Obtener factura con detalles (para el usuario dueño)
router.get('/factura/:id', jwtAuth.verificarToken, async (req, res) => {
  const usuarioDecoded = req.usuario;
  const idfactura = Number(req.params.id || 0);

  try {
    const facturas = util.normalize(await conexion.query(
      `SELECT f.idfactura, f.fecha, COALESCE(e.nombre, 'pendiente') as estado, f.metodo_pago, f.total,
              u.idusuario, u.documento, u.nombres, u.correo, u.telefono
       FROM public.factura f
       JOIN public.usuarios u ON u.idusuario = f.idusuario
       LEFT JOIN public.estado e ON e.idestado = f.idestado
       WHERE f.idfactura = ?`,
      [idfactura]
    ));

    if (!facturas.length) {
      return res.status(404).json({ mensaje: 'Factura no encontrada' });
    }
    const factura = facturas[0];

    // Verificar que el usuario sea el dueño o empleado/gerente
    if (usuarioDecoded.rol === 'usuario' && factura.documento !== usuarioDecoded.documento) {
      return res.status(403).json({ mensaje: 'No tienes permisos para ver esta factura' });
    }

    const detalles = util.normalize(await conexion.query(
      `SELECT d.id, d.stock, d.precio, d.subtotal,
              p.idproductos, p.nombre, p.descripcion
       FROM public.detalles d
       JOIN public.productos p ON p.idproductos = d.idproductos
       WHERE d.idfactura = ?`,
      [idfactura]
    ));

    return res.json({
      factura: {
        idfactura: factura.idfactura,
        fecha: factura.fecha,
        estado: factura.estado,
        metodopago: factura.metodo_pago,
        total: factura.total
      },
      usuario: {
        documento: factura.documento,
        nombres: factura.nombres,
        correo: factura.correo,
        telefono: factura.telefono
      },
      detalles: detalles.map(d => ({
        iddetalle: d.id,
        idproducto: d.idproductos,
        nombre: d.nombre,
        descripcion: d.descripcion,
        cantidad: Number(d.stock),
        preciounitario: Number(d.precio),
        subtotal: Number(d.subtotal)
      })),
      total: factura.total
    });
  } catch (err) {
    console.error('Error al consultar factura:', err);
    return res.status(500).json({ mensaje: 'Error al consultar la factura', detalle: err?.message });
  }
});

// Obtener todos los pedidos (solo empleados y gerentes)
router.get('/pedidos', jwtAuth.verificarToken, async (req, res) => {
  const usuarioDecoded = req.usuario;

  if (!['empleado', 'gerente'].includes(usuarioDecoded.rol)) {
    return res.status(403).json({ mensaje: 'No tienes permisos' });
  }

  try {
    const dataPedidos = util.normalize(await conexion.query(
      `SELECT p.idpedido, p.fecha, e.nombre as estado, p.total, p.idusuario,
              u.documento, u.nombres, u.correo, u.telefono,
              p.idfactura, f.metodo_pago as metodopago
       FROM public.pedidos p
       JOIN public.usuarios u ON u.idusuario = p.idusuario
       LEFT JOIN public.factura f ON f.idfactura = p.idfactura
       JOIN public.estado e ON e.idestado = p.idestado
       ORDER BY p.fecha DESC`
    ));

    const pedidosConDetalles = await Promise.all(dataPedidos.map(async (p) => {
      let currentIdFactura = p.idfactura;
      if (!currentIdFactura) {
        const recovery = util.normalize(await conexion.query(
          'SELECT idfactura FROM public.factura WHERE idusuario = ? AND total = ? ORDER BY ABS(EXTRACT(EPOCH FROM (fecha - ?))) LIMIT 1',
          [p.idusuario, p.total, p.fecha]
        ));
        if (recovery && recovery.length) {
          currentIdFactura = recovery[0].idfactura;
          conexion.query('UPDATE public.pedidos SET idfactura = ? WHERE idpedido = ?', [currentIdFactura, p.idpedido]).catch(e => console.error(e));
        }
      }

      if (currentIdFactura) {
        const detalles = util.normalize(await conexion.query(
          `SELECT prod.nombre, d.stock AS cantidad, d.precio AS preciounitario, d.subtotal AS subtotal
           FROM public.detalles d 
           JOIN public.productos prod ON prod.idproductos = d.idproductos 
           WHERE d.idfactura = ?`,
          [currentIdFactura]
        ));
        return { ...p, idfactura: currentIdFactura, detalles };
      }
      return { ...p, detalles: [] };
    }));

    return res.json({ pedidos: pedidosConDetalles });
  } catch (err) {
    console.error('Error en /pedidos:', err);
    return res.status(500).json({ mensaje: 'Error al consultar pedidos', detalle: err.message });
  }
});

// Cambiar estado de un pedido (solo empleados y gerentes)
router.put('/pedido/:id/estado', jwtAuth.verificarToken, async (req, res) => {
  const idpedido = Number(req.params.id || 0);
  const { idestado } = req.body;
  const usuarioDecoded = req.usuario;

  if (!idpedido) return res.status(400).json({ mensaje: 'ID de pedido inválido' });
  if (![1, 2, 3].includes(Number(idestado))) return res.status(400).json({ mensaje: 'Estado inválido' });
  if (!['empleado', 'gerente'].includes(usuarioDecoded.rol)) return res.status(403).json({ mensaje: 'Sin permisos' });

  try {
    const pedidosArr = util.normalize(await conexion.query(
      'SELECT idpedido, idusuario, total, idfactura FROM public.pedidos WHERE idpedido = ?',
      [idpedido]
    ));

    if (!pedidosArr.length) return res.status(404).json({ mensaje: 'Pedido no encontrado' });

    const pedidoData = pedidosArr[0];
    const idestadoNuevo = Number(idestado);

    if (idestadoNuevo === 2 || idestadoNuevo === 3) {
      await conexion.query('DELETE FROM pedidos WHERE idpedido = ?', [idpedido]);

      const notiVista = require('./NotificacionVista');
      await notiVista.crearNotificacion({
        idusuario: pedidoData.idusuario,
        titulo: idestadoNuevo === 2 ? '✅ Pedido aprobado' : '🛑 Pedido rechazado',
        mensaje: idestadoNuevo === 2
          ? `Tu pedido por $${pedidoData.total} ha sido aprobado.`
          : `Tu pedido por $${pedidoData.total} ha sido rechazado.`,
        tipo: 'pedido'
      });
    } else {
      await conexion.query('UPDATE pedidos SET idestado = ? WHERE idpedido = ?', [idestadoNuevo, idpedido]);
    }

    if (pedidoData.idfactura) {
      await conexion.query('UPDATE factura SET idestado = ? WHERE idfactura = ?', [idestadoNuevo, pedidoData.idfactura]);
    }

    return res.json({ ok: true, borrado: (idestadoNuevo === 2 || idestadoNuevo === 3) });
  } catch (err) {
    console.error('Error al actualizar estado:', err);
    return res.status(500).json({ mensaje: 'Error de servidor' });
  }
});

// Obtener pedidos del usuario logueado
router.get('/mis-pedidos', jwtAuth.verificarToken, async (req, res) => {
  const usuarioDecoded = req.usuario;
  let idusuario = usuarioDecoded.idusuario || usuarioDecoded.idUsuario;

  try {
    if (!idusuario) {
      const u = util.normalize(await conexion.query('SELECT idusuario FROM usuarios WHERE documento = ?', [usuarioDecoded.documento]));
      if (u && u.length) idusuario = u[0].idusuario;
    }

    const dataPedidos = util.normalize(await conexion.query(
      `SELECT p.idpedido, p.fecha, e.nombre as estado, p.total
       FROM pedidos p
       JOIN public.estado e ON e.idestado = p.idestado
       WHERE p.idusuario = ?
       ORDER BY p.fecha DESC`,
      [idusuario]
    ));
    return res.json(dataPedidos);
  } catch (err) {
    return res.status(500).json({ mensaje: 'Error al consultar pedidos' });
  }
});

// Obtener facturas del usuario logueado
router.get('/mis-facturas', jwtAuth.verificarToken, async (req, res) => {
  const usuarioDecoded = req.usuario;
  let idusuario = usuarioDecoded.idusuario || usuarioDecoded.idUsuario;

  try {
    if (!idusuario) {
      const u = util.normalize(await conexion.query('SELECT idusuario FROM usuarios WHERE documento = ?', [usuarioDecoded.documento]));
      if (u && u.length) idusuario = u[0].idusuario;
    }

    const dataFacturas = util.normalize(await conexion.query(
      `SELECT f.idfactura, f.fecha, COALESCE(e.nombre, 'pendiente') as estado, f.total
       FROM factura f
       LEFT JOIN public.estado e ON e.idestado = f.idestado
       WHERE f.idusuario = ?
       ORDER BY f.fecha DESC`,
      [idusuario]
    ));
    return res.json(dataFacturas);
  } catch (err) {
    return res.status(500).json({ mensaje: 'Error al consultar facturas' });
  }
});

const enviarCorreo = require('../utils/mailer');
const { plantillaFactura } = require('../utils/plantillasCorreo');

// Enviar factura por correo
router.post('/factura/:id/enviar-correo', jwtAuth.verificarToken, async (req, res) => {
  const idfactura = Number(req.params.id || 0);
  const usuarioDecoded = req.usuario;

  try {
    const facturas = util.normalize(await conexion.query(
      `SELECT f.idfactura, f.fecha, COALESCE(e.nombre, 'pendiente') as estado, f.metodo_pago as metodopago, f.total,
              u.idusuario, u.documento, u.nombres, u.correo, u.telefono
       FROM public.factura f
       JOIN public.usuarios u ON u.idusuario = f.idusuario
       LEFT JOIN public.estado e ON e.idestado = f.idestado
       WHERE f.idfactura = ?`,
      [idfactura]
    ));

    if (!facturas.length) return res.status(404).json({ mensaje: 'Factura no encontrada' });
    const factura = facturas[0];

    if (usuarioDecoded.rol === 'usuario' && factura.documento !== usuarioDecoded.documento) {
      return res.status(403).json({ mensaje: 'Sin permisos' });
    }

    const detalles = util.normalize(await conexion.query(
      `SELECT d.stock AS cantidad, d.precio AS preciounitario, d.subtotal, p.nombre
       FROM public.detalles d
       JOIN public.productos p ON p.idproductos = d.idproductos
       WHERE d.idfactura = ?`,
      [idfactura]
    ));

    const htmlEmail = plantillaFactura(factura, factura, detalles);
    await enviarCorreo(factura.correo, `Detalle de tu Factura #${idfactura}`, htmlEmail);

    return res.json({ ok: true });
  } catch (err) {
    return res.status(500).json({ mensaje: 'Error al enviar correo' });
  }
});

module.exports = router;
