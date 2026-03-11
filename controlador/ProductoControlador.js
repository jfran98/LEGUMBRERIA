const ProductoModelo = require('../modelo/ProductoModelo');

exports.registrarEntradaProducto = async (req, res) => {
  const origen = `[POST ${req.originalUrl}]`;
  console.log(`${origen} INICIO - Solicitud recibida`);

  const {
    nombre,
    descripcion,
    cantidad,
    tipo_venta,
    precio,
    idcategoria
  } = req.body || {};

  // Validaciones básicas
  if (
    !nombre ||
    cantidad === undefined ||
    tipo_venta === undefined ||
    precio === undefined
  ) {
    return res.status(400).json({
      mensaje: 'Campos requeridos: nombre, cantidad, tipo_venta, precio'
    });
  }

  try {
    const idCatFinal = parseInt(idcategoria) || 1; // Default a Legumbres si falla

    const productoId = await ProductoModelo.insertarProducto({
      nombre: String(nombre).trim(),
      descripcion: descripcion ? String(descripcion).trim() : null,
      tipo_venta: String(tipo_venta).toUpperCase(),
      precio: precio,
      stock: cantidad,
      estado: true,
      idcategoria: idCatFinal
    });

    console.log(`${origen} ✅ Producto creado exitosamente. ID: ${productoId}`);
    return res.json({
      success: true,
      idproducto: productoId,
      mensaje: 'Producto creado correctamente'
    });

  } catch (error) {
    console.error(`${origen} ❌ Error al procesar:`, error);
    return res.status(500).json({
      mensaje: `Error al registrar el producto: ${error.message}`,
      error: error.message
    });
  }
};

exports.obtenerProductos = async (req, res) => {
  try {
    const productos = await ProductoModelo.obtenerProductos();
    res.json(productos);
  } catch (error) {
    console.error('Error al obtener productos:', error);
    res.status(500).json({ error: 'Error al obtener la lista de productos' });
  }
};

exports.obtenerProductoPorId = async (req, res) => {
  const { id } = req.params;
  try {
    const producto = await ProductoModelo.obtenerProductoPorId(id);
    if (!producto) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }
    res.json(producto);
  } catch (error) {
    console.error('Error al obtener producto:', error);
    res.status(500).json({ error: 'Error al obtener el producto' });
  }
};

exports.actualizarProducto = async (req, res) => {
  const { id } = req.params;
  const { nombre, descripcion, tipo_venta, precio, cantidad, idcategoria } = req.body;

  try {
    const productoActual = await ProductoModelo.obtenerProductoPorId(id);
    if (!productoActual) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    const idCatFinal = parseInt(idcategoria) || 1;

    await ProductoModelo.actualizarProducto(id, {
      nombre: String(nombre).trim(),
      descripcion: descripcion ? String(descripcion).trim() : null,
      tipo_venta: String(tipo_venta).toUpperCase(),
      precio: precio,
      stock: cantidad,
      idcategoria: idCatFinal
    });

    res.json({ success: true, mensaje: 'Producto actualizado correctamente' });
  } catch (error) {
    console.error('Error al actualizar producto:', error);
    res.status(500).json({ error: 'Error al actualizar el producto' });
  }
};

exports.eliminarProducto = async (req, res) => {
  const { id } = req.params;

  try {
    const producto = await ProductoModelo.obtenerProductoPorId(id);
    if (!producto) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    await ProductoModelo.eliminarProducto(id);

    res.json({ success: true, mensaje: 'Producto eliminado correctamente' });
  } catch (error) {
    console.error('Error al eliminar producto:', error);
    res.status(500).json({ error: 'Error al eliminar el producto' });
  }
};


