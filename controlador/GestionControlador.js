// controlador/GestionControlador.js
const db = require('../modelo/bd/Conexion');

class GestionControlador {

  // ========== CONTROL FINANCIERO ==========

  // ELIMINADO: Funciones de Gastos, Presupuestos, Procedimientos, etc. que dependen de tablas inexistentes
  // El usuario solicitó no agregar más columnas por ahora.

  // ========== ANÁLISIS DE VENTAS (MANTENIDO) ==========

  // ========== ANÁLISIS DE VENTAS ==========

  // Análisis completo para el dashboard
  static async obtenerAnalisisVentasCompleto() {
    try {
      // 1. Top 5 Productos más vendidos (histórico)
      const masVendidos = await db.query(`
        SELECT p.nombre, SUM(d.stock) as total
        FROM detalles d
        JOIN productos p ON d.idproductos = p.idproductos
        JOIN factura f ON d.idfactura = f.idfactura
        WHERE f.idestado = 2
        GROUP BY p.idproductos, p.nombre
        ORDER BY total DESC
        LIMIT 5
      `);

      // 2. Top 5 Productos sin rotación (que no se han vendido en los últimos 30 días)
      const sinRotacion = await db.query(`
        SELECT p.nombre, p.stock
        FROM productos p
        WHERE p.idproductos NOT IN (
          SELECT DISTINCT idproductos FROM detalles d
          JOIN factura f ON d.idfactura = f.idfactura
          WHERE f.fecha > CURRENT_DATE - INTERVAL '30 days'
        ) AND p.stock > 0
        LIMIT 5
      `);

      // 3. Ventas por día de la semana (últimos 7 días)
      const ventasDia = await db.query(`
        SELECT TO_CHAR(fecha, 'DD/MM') as dia, SUM(total) as total
        FROM factura
        WHERE idestado = 2 AND fecha >= CURRENT_DATE - INTERVAL '7 days'
        GROUP BY dia
        ORDER BY dia
      `);

      // 4. Ventas por categoría
      const ventasCategoria = await db.query(`
        SELECT c.nombre as categoria, SUM(d.subtotal) as total
        FROM detalles d
        JOIN productos p ON d.idproductos = p.idproductos
        JOIN categorias c ON p.idcategoria = c.idcategoria
        JOIN factura f ON d.idfactura = f.idfactura
        WHERE f.idestado = 2
        GROUP BY c.nombre
        ORDER BY total DESC
      `);

      return {
        success: true,
        data: {
          masVendidos,
          sinRotacion,
          ventasDia,
          ventasCategoria
        }
      };
    } catch (error) {
      console.error('Error al obtener análisis completo:', error);
      return { success: false, message: 'Error al obtener análisis' };
    }
  }

  // Resumen diario (últimas 24 horas)
  static async obtenerReporteDiario() {
    try {
      const resumen = await db.query(`
        SELECT 
          COUNT(*) as total_pedidos,
          COALESCE(SUM(total), 0) as total_ventas,
          (
            SELECT p.nombre 
            FROM detalles d 
            JOIN productos p ON d.idproductos = p.idproductos
            JOIN factura f2 ON d.idfactura = f2.idfactura
            WHERE f2.fecha >= CURRENT_DATE AND f2.idestado = 2
            GROUP BY p.nombre 
            ORDER BY SUM(d.stock) DESC LIMIT 1
          ) as producto_estrella
        FROM factura f
        WHERE f.fecha >= CURRENT_DATE AND f.idestado = 2
      `);

      return { success: true, data: resumen[0] };
    } catch (error) {
      console.error('Error al obtener reporte diario:', error);
      return { success: false, message: 'Error al obtener reporte diario' };
    }
  }

  // Historial detallado de ventas
  static async obtenerHistorialVentas() {
    try {
      const historial = await db.query(`
        SELECT f.idfactura, f.fecha, f.total, u.nombres as cliente, e.nombre as estado
        FROM factura f
        JOIN usuarios u ON f.idusuario = u.idusuario
        JOIN estado e ON f.idestado = e.idestado
        ORDER BY f.fecha DESC
        LIMIT 50
      `);
      return { success: true, data: historial };
    } catch (error) {
      console.error('Error al obtener historial de ventas:', error);
      return { success: false, message: 'Error al obtener historial' };
    }
  }
}

module.exports = GestionControlador;
