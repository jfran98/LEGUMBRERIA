const db = require('./bd/Conexion');

const ProductoModelo = {
  insertarProducto: async ({ nombre, categoria, precio, unidad, stock, descripcion, imagen }) => {
    const sql = `
      INSERT INTO productos (nombre, categoria, precio, unidad, stock, descripcion, imagen)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `;
    return await db.query(sql, [nombre, categoria, precio, unidad, stock, descripcion, imagen]);
  }
};

module.exports = ProductoModelo;