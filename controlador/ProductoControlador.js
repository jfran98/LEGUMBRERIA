const ProductoModelo = require('../modelo/ProductoModelo');

exports.agregarProducto = async (req, res) => {
  try {
    const { nombre, categoria, precio, unidad, stock, descripcion } = req.body;
    const imagen = req.file ? req.file.filename : null;

    const nuevoProducto = {
      nombre,
      categoria,
      precio,
      unidad,
      stock,
      descripcion,
      imagen
    };

    await ProductoModelo.insertarProducto(nuevoProducto);

    res.status(201).json({ mensaje: '✅ Producto agregado correctamente' });
  } catch (error) {
    console.error('❌ Error al agregar producto:', error);
    res.status(500).json({ mensaje: 'Error al agregar el producto' });
  }
};

