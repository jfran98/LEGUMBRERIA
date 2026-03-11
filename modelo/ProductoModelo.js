const db = require('./bd/Conexion');

const ProductoModelo = {

  // Insertar un nuevo producto
  insertarProducto: async ({ nombre, descripcion, tipo_venta, precio, stock, idestado, idcategoria }) => {
    const isPostgres = db.client === 'pg' || db.client === 'postgres' || db.client === 'postgresql';
    const tipoVentaValid = ['KG', 'UNIDAD'].includes(String(tipo_venta).toUpperCase()) ? String(tipo_venta).toUpperCase() : 'UNIDAD';

    const sql = `
      INSERT INTO public.productos 
      (nombre, descripcion, tipo_venta, precio, stock, idestado, idcategoria)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ${isPostgres ? 'RETURNING idproductos' : ''}
    `;

    try {
      const result = await db.query(sql, [
        nombre,
        descripcion,
        tipoVentaValid,
        precio,
        stock,
        idestado !== undefined ? idestado : 1,
        idcategoria || 1
      ]);

      if (result && result.insertId) return result.insertId;
      if (result && result[0]) {
        const normalized = {};
        for (let key in result[0]) { normalized[key.toLowerCase()] = result[0][key]; }
        return normalized.idproductos;
      }
      return null;
    } catch (err) {
      console.error('Error en ProductoModelo.insertarProducto:', err);
      throw err;
    }
  },

  // Obtener productos con JOIN a categorias
  obtenerProductos: async () => {
    try {
      const sql = `
        SELECT 
            p.idproductos,
            p.nombre,
            p.descripcion,
            p.tipo_venta,
            p.precio,
            p.stock,
            p.idestado,
            e.nombre AS estado_nombre,
            p.idcategoria,
            c.nombre AS categorias,
            p.fecha_creacion,
            LOWER(p.nombre) AS img_key
        FROM public.productos p
        LEFT JOIN public.categorias c ON p.idcategoria = c.idcategoria
        LEFT JOIN public.estado e ON p.idestado = e.idestado
        WHERE p.idestado <> 3
        ORDER BY p.idproductos DESC
      `;
      const rows = await db.query(sql, []);

      if (!rows) return [];
      const rowArray = Array.isArray(rows) ? rows : (rows.rows || []);

      // Normalizar todas las llaves a minúsculas para consistencia frontend
      return rowArray.map(row => {
        const normalizedRow = {};
        for (let key in row) {
          normalizedRow[key.toLowerCase()] = row[key];
        }
        return normalizedRow;
      });
    } catch (err) {
      console.error('Error en ProductoModelo.obtenerProductos:', err);
      throw err;
    }
  },

  // Obtener un producto por ID con JOIN
  obtenerProductoPorId: async (idProducto) => {
    try {
      const sql = `
        SELECT 
            p.idproductos,
            p.nombre,
            p.descripcion,
            p.tipo_venta,
            p.precio,
            p.stock,
            p.idestado,
            e.nombre AS estado_nombre,
            p.idcategoria,
            c.nombre AS categorias,
            p.fecha_creacion,
            LOWER(p.nombre) AS img_key
        FROM public.productos p
        LEFT JOIN public.categorias c ON p.idcategoria = c.idcategoria
        LEFT JOIN public.estado e ON p.idestado = e.idestado
        WHERE p.idproductos = ?
      `;
      const rows = await db.query(sql, [idProducto]);
      const data = Array.isArray(rows) ? rows : (rows.rows || []);

      if (data && data.length > 0) {
        const normalizedRow = {};
        for (let key in data[0]) {
          normalizedRow[key.toLowerCase()] = data[0][key];
        }
        return normalizedRow;
      }
      return null;
    } catch (err) {
      console.error('Error en ProductoModelo.obtenerProductoPorId:', err);
      throw err;
    }
  },

  // Actualizar un producto existente
  actualizarProducto: async (idproductos, { nombre, descripcion, tipo_venta, precio, stock, idcategoria, idestado }) => {
    const tipoVentaValid = ['KG', 'UNIDAD'].includes(String(tipo_venta).toUpperCase()) ? String(tipo_venta).toUpperCase() : 'UNIDAD';

    const sql = `
      UPDATE public.productos 
      SET nombre = ?, descripcion = ?, tipo_venta = ?, precio = ?, stock = ?, idcategoria = ?, idestado = ?
      WHERE idproductos = ?
    `;
    try {
      return await db.query(sql, [
        nombre,
        descripcion,
        tipoVentaValid,
        precio,
        stock,
        idcategoria,
        idestado !== undefined ? idestado : 1,
        idproductos
      ]);
    } catch (err) {
      console.error('Error en ProductoModelo.actualizarProducto:', err);
      throw err;
    }
  },

  // "Eliminar" un producto (borrado lógico: marcar como rechazado / inactivo)
  eliminarProducto: async (idProducto) => {
    const sql = `
      UPDATE public.productos
      SET stock = 0, idestado = 3
      WHERE idproductos = ?
    `;
    try {
      return await db.query(sql, [idProducto]);
    } catch (err) {
      console.error('Error en ProductoModelo.eliminarProducto:', err);
      throw err;
    }
  }

};

module.exports = ProductoModelo;
