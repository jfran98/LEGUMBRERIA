const express = require('express');
const router = express.Router();
const jwtAuth = require('../middleware/authMiddleware');
const mysql = require('mysql2/promise');
const baseConfig = require('../modelo/bd/Config');

// Pool propio con mysql2/promise para manejar transacciones, con fallback
const resolvedConfig = {
  host: baseConfig.host || 'localhost',
  user: baseConfig.user || 'root',
  password: baseConfig.password || '12345',
  database: baseConfig.database || 'legumbreria'
};
const pool = mysql.createPool(resolvedConfig);

// Utilidad: convertir lb a kg
const POUNDS_TO_KG = 0.45359237;

// Crear factura con detalles
router.post('/checkout', jwtAuth.verificarToken, async (req, res) => {
  const usuarioDecoded = req.usuario; // documento, correo, rol
  const items = Array.isArray(req.body?.items) ? req.body.items : [];
  const metodoPago = req.body?.metodoPago; // <-- AÑADIR ESTA LÍNEA

  if (!items.length) {
    return res.status(400).json({ mensaje: 'Carrito vacío' });
  }

  // Validar método de pago y asignar valor por defecto si es necesario
  if (!metodoPago || !['contraentrega', 'bancolombia', 'nequi'].includes(metodoPago)) {
    metodoPago = 'contraentrega'; // Valor por defecto
  }

  let conn;
  try {
    conn = await pool.getConnection();
    await conn.beginTransaction();

    // Sin ALTERs: dejamos que el esquema y el trigger manejen consistencia

    // Buscar idUsuario por documento del token
    const [usuarios] = await conn.query('SELECT idUsuario FROM usuarios WHERE documento = ?', [usuarioDecoded.documento]);
    if (!usuarios.length) {
      await conn.rollback();
      return res.status(400).json({ mensaje: 'Usuario no encontrado' });
    }
    const idUsuario = usuarios[0].idUsuario;

    // Crear factura en estado pendiente CON metodoPago
    const fechaStr = new Date().toISOString();
    const estado = 'pendiente';
    const [insFactura] = await conn.query(
      "INSERT INTO factura (idUsuario, fecha, estado, metodoPago) VALUES (?, ?, ?, ?)",
      [idUsuario, fechaStr, estado, metodoPago]
    );
    const idFactura = insFactura.insertId;

    // Procesar cada item y registrar detalle
    let necesitaIdManualParaDetalles = false;

    for (const rawItem of items) {
      const idProducto = rawItem?.idProducto;
      const unidad = String(rawItem?.unidad || '').toLowerCase();
      const cantidad = Number(rawItem?.cantidad || 0);
      let cantidadKg = Number(rawItem?.cantidadKg || 0);

      if (!idProducto || (!cantidad && !cantidadKg)) {
        await conn.rollback();
        return res.status(400).json({ mensaje: 'Item inválido: falta idProducto o cantidad' });
      }

      // Calcular cantidad en kg si no viene
      if (!cantidadKg) {
        cantidadKg = unidad === 'lb' ? cantidad * POUNDS_TO_KG : cantidad;
      }

      // Buscar el último registro de regproductos para ese producto (precio vigente)
      const [regRows] = await conn.query(
        'SELECT idRegProducto, precioVentaMenor, precioVentaMayor, cantidad FROM regproductos WHERE idProducto = ? ORDER BY fechaRegistro DESC LIMIT 1 FOR UPDATE',
        [idProducto]
      );
      if (!regRows.length) {
        await conn.rollback();
        return res.status(400).json({ mensaje: `Producto ${idProducto} sin registro vigente` });
      }
      const { idRegProducto, precioVentaMenor, precioVentaMayor } = regRows[0];

      // Regla de precio: >= 10 kg usa precioVentaMenor; de lo contrario usa precioVentaMayor
      let precioUnitario = cantidadKg >= 10 ? Number(precioVentaMenor || 0) : Number(precioVentaMayor || 0);
      // Fallback si el precio elegido no existe
      if (!precioUnitario) {
        precioUnitario = Number((cantidadKg >= 10 ? precioVentaMayor : precioVentaMenor) || 0);
      }
      if (!precioUnitario) {
        await conn.rollback();
        return res.status(400).json({ mensaje: `Producto ${idProducto} sin precio de venta válido` });
      }

      const subTotal = Number((cantidadKg * precioUnitario).toFixed(2));

      // Stock y descuento lo maneja el trigger BEFORE INSERT en 'detalles'

      try {
        await conn.query(
          'INSERT INTO detalles (idFactura, idRegProductos, cantidad, precioUnitario, subTotal) VALUES (?, ?, ?, ?, ?)',
          [idFactura, idRegProducto, cantidadKg, precioUnitario, subTotal]
        );
      } catch (e) {
        // Si no hay default para idDetalle, generamos uno manualmente SIN ALTERAR la tabla
        if (e && (e.code === 'ER_NO_DEFAULT_FOR_FIELD' || /Field 'idDetalle' doesn't have a default/i.test(e.message || ''))) {
          const [[{ nextId }]] = await conn.query('SELECT COALESCE(MAX(idDetalle), 0) + 1 AS nextId FROM detalles');
          await conn.query(
            'INSERT INTO detalles (idDetalle, idFactura, idRegProductos, cantidad, precioUnitario, subTotal) VALUES (?, ?, ?, ?, ?, ?)',
            [nextId, idFactura, idRegProducto, cantidadKg, precioUnitario, subTotal]
          );
        } else {
          throw e;
        }
      }
    }

    await conn.commit();
    return res.json({ ok: true, idFactura, metodoPago }); // <-- AÑADIR metodoPago en la respuesta
  } catch (err) {
    if (conn) {
      try { await conn.rollback(); } catch (_) {}
    }
    return res.status(500).json({ mensaje: 'Error al crear la factura', detalle: err?.sqlMessage || err?.message });
  } finally {
    if (conn) conn.release();
  }
});

module.exports = router;
 
// Obtener factura con detalles (solo dueño)
router.get('/factura/:id', jwtAuth.verificarToken, async (req, res) => {
  const usuarioDecoded = req.usuario;
  const idFactura = Number(req.params.id || 0);
  if (!idFactura) return res.status(400).json({ mensaje: 'Factura inválida' });

  let conn;
  try {
    conn = await pool.getConnection();
    // Buscar factura que pertenezca al usuario autenticado CON metodoPago
    const [facturas] = await conn.query(
      `SELECT f.idFactura, f.fecha, COALESCE(f.estado, 'pendiente') as estado, 
              COALESCE(f.metodoPago, 'contraentrega') as metodoPago,
              u.idUsuario, u.documento, u.nombres, u.correo, u.telefono
       FROM factura f
       JOIN usuarios u ON u.idUsuario = f.idUsuario
       WHERE f.idFactura = ? AND u.documento = ?
       LIMIT 1`,
      [idFactura, usuarioDecoded.documento]
    );
    if (!facturas.length) {
      return res.status(404).json({ mensaje: 'Factura no encontrada' });
    }
    const factura = facturas[0];

    const [detalles] = await conn.query(
      `SELECT d.idDetalle, d.cantidad, d.precioUnitario, d.subTotal,
              rp.idRegProducto, rp.idProducto,
              COALESCE(p.descripcion, p.nombre, 'Producto') as descripcion, 
              p.nombre, COALESCE(p.unidad, 'kg') as unidad, 
              p.categoria, COALESCE(p.imagen, '/img/tomate.jpg') as imagen
       FROM detalles d
       JOIN regproductos rp ON rp.idRegProducto = d.idRegProductos
       JOIN productos p ON p.idProducto = rp.idProducto
       WHERE d.idFactura = ?`,
      [idFactura]
    );

    const total = detalles.reduce((acc, it) => acc + Number(it.subTotal || 0), 0);

    return res.json({
      factura: {
        idFactura: factura.idFactura,
        fecha: factura.fecha,
        estado: factura.estado || 'pendiente',
        metodoPago: factura.metodoPago || 'contraentrega',
      },
      usuario: {
        documento: factura.documento || 'No especificado',
        nombres: factura.nombres || 'No especificado',
        correo: factura.correo || 'No especificado',
        telefono: factura.telefono || 'No especificado',
      },
      detalles: detalles.map(d => ({
        idDetalle: d.idDetalle,
        idProducto: d.idProducto,
        nombre: d.descripcion || d.nombre || 'Producto',
        unidad: d.unidad || 'kg',
        categoria: d.categoria || null,
        imagen: d.imagen || '/img/tomate.jpg',
        cantidadKg: Number(d.cantidad || 0),
        precioUnitario: Number(d.precioUnitario || 0),
        subTotal: Number(d.subTotal || 0),
      })),
      total
    });
  } catch (err) {
    return res.status(500).json({ mensaje: 'Error al consultar la factura', detalle: err?.message });
  } finally {
    if (conn) conn.release();
  }
});

// Obtener todos los pedidos (solo empleados y gerentes)
router.get('/pedidos', jwtAuth.verificarToken, async (req, res) => {
  const usuarioDecoded = req.usuario;
  
  console.log('Usuario que solicita pedidos:', usuarioDecoded);
  console.log('Rol del usuario:', usuarioDecoded.rol);
  
  // Verificar que el usuario sea empleado o gerente
  if (!['empleado', 'gerente'].includes(usuarioDecoded.rol)) {
    console.log('Usuario sin permisos, rol:', usuarioDecoded.rol);
    return res.status(403).json({ mensaje: 'No tienes permisos para acceder a esta información' });
  }

  let conn;
  try {
    console.log('Conectando a la base de datos...');
    conn = await pool.getConnection();
    console.log('Conexión establecida');
    
    // Obtener todas las facturas con información del usuario y detalles
    console.log('Consultando facturas...');
    const [facturas] = await conn.query(
      `SELECT f.idFactura, f.fecha, COALESCE(f.estado, 'pendiente') as estado, 
              COALESCE(f.metodoPago, 'contraentrega') as metodoPago,
              u.idUsuario, u.documento, u.nombres, u.correo, u.telefono
       FROM factura f
       JOIN usuarios u ON u.idUsuario = f.idUsuario
       ORDER BY f.fecha DESC`
    );

    console.log('Facturas encontradas:', facturas.length);

    const pedidos = [];

    for (const factura of facturas) {
      console.log('Procesando factura:', factura.idFactura);
      
      // Obtener detalles de cada factura
      const [detalles] = await conn.query(
        `SELECT d.idDetalle, d.cantidad, d.precioUnitario, d.subTotal,
                rp.idRegProducto, rp.idProducto,
                COALESCE(p.descripcion, p.nombre, 'Producto') as descripcion, 
                p.nombre, COALESCE(p.unidad, 'kg') as unidad, 
                p.categoria, COALESCE(p.imagen, '/img/tomate.jpg') as imagen
         FROM detalles d
         JOIN regproductos rp ON rp.idRegProducto = d.idRegProductos
         JOIN productos p ON p.idProducto = rp.idProducto
         WHERE d.idFactura = ?`,
        [factura.idFactura]
      );

      console.log(`Detalles encontrados para factura ${factura.idFactura}:`, detalles.length);

      const total = detalles.reduce((acc, it) => acc + Number(it.subTotal || 0), 0);

      pedidos.push({
        idFactura: factura.idFactura,
        fecha: factura.fecha,
        estado: factura.estado || 'pendiente',
        metodoPago: factura.metodoPago || 'contraentrega',
        usuario: {
          documento: factura.documento || 'No especificado',
          nombres: factura.nombres || 'No especificado',
          correo: factura.correo || 'No especificado',
          telefono: factura.telefono || 'No especificado',
        },
        detalles: detalles.map(d => ({
          idDetalle: d.idDetalle,
          idProducto: d.idProducto,
          nombre: d.descripcion || d.nombre || 'Producto',
          unidad: d.unidad || 'kg',
          categoria: d.categoria || null,
          imagen: d.imagen || '/img/tomate.jpg',
          cantidadKg: Number(d.cantidad || 0),
          precioUnitario: Number(d.precioUnitario || 0),
          subTotal: Number(d.subTotal || 0),
        })),
        total
      });
    }

    console.log('Total de pedidos procesados:', pedidos.length);
    return res.json({ pedidos });
  } catch (err) {
    console.error('Error en /pedidos:', err);
    return res.status(500).json({ mensaje: 'Error al consultar los pedidos', detalle: err?.message });
  } finally {
    if (conn) conn.release();
  }
});

// Cambiar estado de un pedido (solo empleados y gerentes)
router.put('/pedido/:id/estado', jwtAuth.verificarToken, async (req, res) => {
  const usuarioDecoded = req.usuario;
  const idFactura = Number(req.params.id || 0);
  const { estado } = req.body;

  if (!idFactura) {
    return res.status(400).json({ mensaje: 'ID de factura inválido' });
  }

  if (!['pendiente', 'aprobado', 'rechazado'].includes(estado)) {
    return res.status(400).json({ mensaje: 'Estado inválido' });
  }

  // Verificar que el usuario sea empleado o gerente
  if (!['empleado', 'gerente'].includes(usuarioDecoded.rol)) {
    return res.status(403).json({ mensaje: 'No tienes permisos para realizar esta acción' });
  }

  let conn;
  try {
    conn = await pool.getConnection();
    
    // Verificar que la factura existe
    const [facturas] = await conn.query(
      'SELECT idFactura, estado FROM factura WHERE idFactura = ?',
      [idFactura]
    );

    if (!facturas.length) {
      return res.status(404).json({ mensaje: 'Factura no encontrada' });
    }

    // Actualizar el estado de la factura
    await conn.query(
      'UPDATE factura SET estado = ? WHERE idFactura = ?',
      [estado, idFactura]
    );

    return res.json({ 
      mensaje: `Estado de la factura #${idFactura} actualizado a ${estado}`,
      idFactura,
      nuevoEstado: estado
    });
  } catch (err) {
    return res.status(500).json({ mensaje: 'Error al actualizar el estado', detalle: err?.message });
  } finally {
    if (conn) conn.release();
  }
});


