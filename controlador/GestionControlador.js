// controlador/GestionControlador.js
const db = require('../modelo/bd/Conexion');

class GestionControlador {
  
  // ========== CONTROL FINANCIERO ==========
  
  // Obtener gastos operativos
  static async obtenerGastosOperativos() {
    try {
      const gastos = await db.query(`
        SELECT * FROM gastos_operativos 
        ORDER BY fechaCreacion DESC
      `);
      return { success: true, data: gastos };
    } catch (error) {
      console.error('Error al obtener gastos operativos:', error);
      return { success: false, message: 'Error al obtener gastos operativos' };
    }
  }

  // Aprobar gasto operativo
  static async aprobarGasto(idGasto) {
    try {
      await db.query(`
        UPDATE gastos_operativos 
        SET estado = 'aprobado' 
        WHERE idGasto = ?
      `, [idGasto]);
      return { success: true, message: 'Gasto aprobado correctamente' };
    } catch (error) {
      console.error('Error al aprobar gasto:', error);
      return { success: false, message: 'Error al aprobar gasto' };
    }
  }

  // Rechazar gasto operativo
  static async rechazarGasto(idGasto) {
    try {
      await db.query(`
        UPDATE gastos_operativos 
        SET estado = 'rechazado' 
        WHERE idGasto = ?
      `, [idGasto]);
      return { success: true, message: 'Gasto rechazado' };
    } catch (error) {
      console.error('Error al rechazar gasto:', error);
      return { success: false, message: 'Error al rechazar gasto' };
    }
  }

  // Crear nuevo gasto operativo
  static async crearGastoOperativo(datos) {
    try {
      const { concepto, descripcion, monto, categoria, fechaGasto, limiteAprobacion } = datos;
      await db.query(`
        INSERT INTO gastos_operativos 
        (concepto, descripcion, monto, categoria, fechaGasto, limiteAprobacion) 
        VALUES (?, ?, ?, ?, ?, ?)
      `, [concepto, descripcion, monto, categoria, fechaGasto, limiteAprobacion]);
      return { success: true, message: 'Gasto operativo creado correctamente' };
    } catch (error) {
      console.error('Error al crear gasto operativo:', error);
      return { success: false, message: 'Error al crear gasto operativo' };
    }
  }

  // Obtener presupuestos
  static async obtenerPresupuestos() {
    try {
      const presupuestos = await db.query(`
        SELECT *, 
        (montoGastado / montoAsignado * 100) as porcentajeGastado
        FROM presupuestos 
        ORDER BY fechaCreacion DESC
      `);
      return { success: true, data: presupuestos };
    } catch (error) {
      console.error('Error al obtener presupuestos:', error);
      return { success: false, message: 'Error al obtener presupuestos' };
    }
  }

  // Crear/modificar presupuesto
  static async crearPresupuesto(datos) {
    try {
      const { area, periodo, montoAsignado, descripcion } = datos;
      await db.query(`
        INSERT INTO presupuestos 
        (area, periodo, montoAsignado, descripcion) 
        VALUES (?, ?, ?, ?)
      `, [area, periodo, montoAsignado, descripcion]);
      return { success: true, message: 'Presupuesto creado correctamente' };
    } catch (error) {
      console.error('Error al crear presupuesto:', error);
      return { success: false, message: 'Error al crear presupuesto' };
    }
  }

  // ========== GESTIÓN DE PROCESOS Y OPERACIONES ==========

  // Obtener procedimientos
  static async obtenerProcedimientos() {
    try {
      const procedimientos = await db.query(`
        SELECT * FROM procedimientos 
        WHERE estado = 'activo'
        ORDER BY fechaCreacion DESC
      `);
      return { success: true, data: procedimientos };
    } catch (error) {
      console.error('Error al obtener procedimientos:', error);
      return { success: false, message: 'Error al obtener procedimientos' };
    }
  }

  // Crear nuevo procedimiento
  static async crearProcedimiento(datos) {
    try {
      const { nombre, descripcion, area, pasos } = datos;
      await db.query(`
        INSERT INTO procedimientos 
        (nombre, descripcion, area, pasos) 
        VALUES (?, ?, ?, ?)
      `, [nombre, descripcion, area, pasos]);
      return { success: true, message: 'Procedimiento creado correctamente' };
    } catch (error) {
      console.error('Error al crear procedimiento:', error);
      return { success: false, message: 'Error al crear procedimiento' };
    }
  }

  // Obtener planes de trabajo
  static async obtenerPlanesTrabajo() {
    try {
      const planes = await db.query(`
        SELECT * FROM planes_trabajo 
        ORDER BY fechaCreacion DESC
      `);
      return { success: true, data: planes };
    } catch (error) {
      console.error('Error al obtener planes de trabajo:', error);
      return { success: false, message: 'Error al obtener planes de trabajo' };
    }
  }

  // Crear nuevo plan de trabajo
  static async crearPlanTrabajo(datos) {
    try {
      const { nombre, objetivo, metas, fechaInicio, fechaFin, responsable } = datos;
      await db.query(`
        INSERT INTO planes_trabajo 
        (nombre, objetivo, metas, fechaInicio, fechaFin, responsable) 
        VALUES (?, ?, ?, ?, ?, ?)
      `, [nombre, objetivo, metas, fechaInicio, fechaFin, responsable]);
      return { success: true, message: 'Plan de trabajo creado correctamente' };
    } catch (error) {
      console.error('Error al crear plan de trabajo:', error);
      return { success: false, message: 'Error al crear plan de trabajo' };
    }
  }

  // Actualizar progreso de plan
  static async actualizarProgresoPlan(idPlan, progreso) {
    try {
      await db.query(`
        UPDATE planes_trabajo 
        SET progreso = ? 
        WHERE idPlan = ?
      `, [progreso, idPlan]);
      return { success: true, message: 'Progreso actualizado correctamente' };
    } catch (error) {
      console.error('Error al actualizar progreso:', error);
      return { success: false, message: 'Error al actualizar progreso' };
    }
  }

  // Obtener KPIs
  static async obtenerKPIs() {
    try {
      const kpis = await db.query(`
        SELECT * FROM kpis 
        ORDER BY categoria, nombre
      `);
      return { success: true, data: kpis };
    } catch (error) {
      console.error('Error al obtener KPIs:', error);
      return { success: false, message: 'Error al obtener KPIs' };
    }
  }

  // Actualizar KPI
  static async actualizarKPI(idKPI, valor) {
    try {
      await db.query(`
        UPDATE kpis 
        SET valor = ? 
        WHERE idKPI = ?
      `, [valor, idKPI]);
      return { success: true, message: 'KPI actualizado correctamente' };
    } catch (error) {
      console.error('Error al actualizar KPI:', error);
      return { success: false, message: 'Error al actualizar KPI' };
    }
  }

  // Obtener estrategias
  static async obtenerEstrategias() {
    try {
      const estrategias = await db.query(`
        SELECT * FROM estrategias 
        ORDER BY fechaCreacion DESC
      `);
      return { success: true, data: estrategias };
    } catch (error) {
      console.error('Error al obtener estrategias:', error);
      return { success: false, message: 'Error al obtener estrategias' };
    }
  }

  // Crear nueva estrategia
  static async crearEstrategia(datos) {
    try {
      const { nombre, tipo, descripcion, beneficios, recursos } = datos;
      await db.query(`
        INSERT INTO estrategias 
        (nombre, tipo, descripcion, beneficios, recursos) 
        VALUES (?, ?, ?, ?, ?)
      `, [nombre, tipo, descripcion, beneficios, recursos]);
      return { success: true, message: 'Estrategia creada correctamente' };
    } catch (error) {
      console.error('Error al crear estrategia:', error);
      return { success: false, message: 'Error al crear estrategia' };
    }
  }

  // Cambiar estado de estrategia
  static async cambiarEstadoEstrategia(idEstrategia, estado) {
    try {
      await db.query(`
        UPDATE estrategias 
        SET estado = ? 
        WHERE idEstrategia = ?
      `, [estado, idEstrategia]);
      return { success: true, message: 'Estado de estrategia actualizado' };
    } catch (error) {
      console.error('Error al cambiar estado de estrategia:', error);
      return { success: false, message: 'Error al cambiar estado' };
    }
  }

  // ========== GESTIÓN DE PRODUCTOS Y SERVICIOS ==========

  // Obtener promociones
  static async obtenerPromociones() {
    try {
      const promociones = await db.query(`
        SELECT * FROM promociones 
        WHERE estado = 'activa' AND fechaFin >= CURDATE()
        ORDER BY fechaCreacion DESC
      `);
      return { success: true, data: promociones };
    } catch (error) {
      console.error('Error al obtener promociones:', error);
      return { success: false, message: 'Error al obtener promociones' };
    }
  }

  // Crear nueva promoción
  static async crearPromocion(datos) {
    try {
      const { nombre, descripcion, tipo, descuento, fechaInicio, fechaFin, productosAplicables } = datos;
      await db.query(`
        INSERT INTO promociones 
        (nombre, descripcion, tipo, descuento, fechaInicio, fechaFin, productosAplicables) 
        VALUES (?, ?, ?, ?, ?, ?, ?)
      `, [nombre, descripcion, tipo, descuento, fechaInicio, fechaFin, productosAplicables]);
      return { success: true, message: 'Promoción creada correctamente' };
    } catch (error) {
      console.error('Error al crear promoción:', error);
      return { success: false, message: 'Error al crear promoción' };
    }
  }

  // Obtener cambios de precio pendientes
  static async obtenerCambiosPrecio() {
    try {
      const cambios = await db.query(`
        SELECT cp.*, p.nombre as nombreProducto 
        FROM cambios_precio cp
        JOIN productos p ON cp.idProducto = p.idProducto
        WHERE cp.estado = 'pendiente'
        ORDER BY cp.fechaCreacion DESC
      `);
      return { success: true, data: cambios };
    } catch (error) {
      console.error('Error al obtener cambios de precio:', error);
      return { success: false, message: 'Error al obtener cambios de precio' };
    }
  }

  // Aprobar cambio de precio
  static async aprobarCambioPrecio(idCambio) {
    try {
      const cambio = await db.query(`
        SELECT * FROM cambios_precio WHERE idCambio = ?
      `, [idCambio]);
      
      if (cambio.length === 0) {
        return { success: false, message: 'Cambio de precio no encontrado' };
      }

      // Actualizar precio en regproductos
      await db.query(`
        UPDATE regproductos 
        SET precioVentaMenor = ?, precioVentaMayor = ?
        WHERE idProducto = ?
      `, [cambio[0].precioNuevo, cambio[0].precioNuevo, cambio[0].idProducto]);

      // Marcar cambio como aprobado
      await db.query(`
        UPDATE cambios_precio 
        SET estado = 'aprobado' 
        WHERE idCambio = ?
      `, [idCambio]);

      return { success: true, message: 'Cambio de precio aprobado correctamente' };
    } catch (error) {
      console.error('Error al aprobar cambio de precio:', error);
      return { success: false, message: 'Error al aprobar cambio de precio' };
    }
  }

  // Rechazar cambio de precio
  static async rechazarCambioPrecio(idCambio) {
    try {
      await db.query(`
        UPDATE cambios_precio 
        SET estado = 'rechazado' 
        WHERE idCambio = ?
      `, [idCambio]);
      return { success: true, message: 'Cambio de precio rechazado' };
    } catch (error) {
      console.error('Error al rechazar cambio de precio:', error);
      return { success: false, message: 'Error al rechazar cambio de precio' };
    }
  }

  // Obtener cambios en catálogo pendientes
  static async obtenerCambiosCatalogo() {
    try {
      const cambios = await db.query(`
        SELECT cc.*, p.nombre as nombreProducto 
        FROM cambios_catalogo cc
        LEFT JOIN productos p ON cc.idProducto = p.idProducto
        WHERE cc.estado = 'pendiente'
        ORDER BY cc.fechaCreacion DESC
      `);
      return { success: true, data: cambios };
    } catch (error) {
      console.error('Error al obtener cambios en catálogo:', error);
      return { success: false, message: 'Error al obtener cambios en catálogo' };
    }
  }

  // Aprobar cambio en catálogo
  static async aprobarCambioCatalogo(idCambio) {
    try {
      const cambio = await db.query(`
        SELECT * FROM cambios_catalogo WHERE idCambio = ?
      `, [idCambio]);
      
      if (cambio.length === 0) {
        return { success: false, message: 'Cambio en catálogo no encontrado' };
      }

      const datosCambio = cambio[0];

      if (datosCambio.tipo === 'nuevo_producto') {
        // Crear nuevo producto
        const datosProducto = JSON.parse(datosCambio.datosProducto);
        await db.query(`
          INSERT INTO productos 
          (nombre, descripcion, unidad, categoria, estado, imagen) 
          VALUES (?, ?, ?, ?, 'activo', ?)
        `, [datosProducto.nombre, datosProducto.descripcion, datosProducto.unidad, datosProducto.categoria, datosProducto.imagen]);
      }

      // Marcar cambio como aprobado
      await db.query(`
        UPDATE cambios_catalogo 
        SET estado = 'aprobado' 
        WHERE idCambio = ?
      `, [idCambio]);

      return { success: true, message: 'Cambio en catálogo aprobado correctamente' };
    } catch (error) {
      console.error('Error al aprobar cambio en catálogo:', error);
      return { success: false, message: 'Error al aprobar cambio en catálogo' };
    }
  }

  // Obtener contratos
  static async obtenerContratos() {
    try {
      const contratos = await db.query(`
        SELECT * FROM contratos 
        ORDER BY fechaCreacion DESC
      `);
      return { success: true, data: contratos };
    } catch (error) {
      console.error('Error al obtener contratos:', error);
      return { success: false, message: 'Error al obtener contratos' };
    }
  }

  // Crear nuevo contrato
  static async crearContrato(datos) {
    try {
      const { tipo, parteContratante, descripcion, valor, vigencia, condicionesEspeciales } = datos;
      
      // Calcular fechas
      const fechaInicio = new Date();
      const fechaFin = new Date();
      fechaFin.setMonth(fechaFin.getMonth() + vigencia);

      await db.query(`
        INSERT INTO contratos 
        (tipo, parteContratante, descripcion, valor, vigencia, fechaInicio, fechaFin, condicionesEspeciales) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      `, [tipo, parteContratante, descripcion, valor, vigencia, fechaInicio, fechaFin, condicionesEspeciales]);
      
      return { success: true, message: 'Contrato creado correctamente' };
    } catch (error) {
      console.error('Error al crear contrato:', error);
      return { success: false, message: 'Error al crear contrato' };
    }
  }

  // Aprobar contrato
  static async aprobarContrato(idContrato) {
    try {
      await db.query(`
        UPDATE contratos 
        SET estado = 'activo' 
        WHERE idContrato = ?
      `, [idContrato]);
      return { success: true, message: 'Contrato aprobado correctamente' };
    } catch (error) {
      console.error('Error al aprobar contrato:', error);
      return { success: false, message: 'Error al aprobar contrato' };
    }
  }

  // Obtener métricas comerciales
  static async obtenerMetricasComerciales() {
    try {
      const metricas = await db.query(`
        SELECT 
          SUM(rp.precioVentaMenor * rp.cantidad) as ventasMes,
          COUNT(DISTINCT p.idProducto) as productosActivos,
          AVG(rp.precioVentaMenor / rp.precioCompra * 100 - 100) as margenPromedio,
          COUNT(DISTINCT f.idFactura) as rotacionInventario
        FROM regproductos rp
        JOIN productos p ON rp.idProducto = p.idProducto
        LEFT JOIN detalles d ON rp.idRegProducto = d.idRegProductos
        LEFT JOIN factura f ON d.idFactura = f.idFactura
        WHERE rp.estado = 'Disponible' 
        AND p.estado = 'activo'
        AND MONTH(rp.fechaRegistro) = MONTH(CURDATE())
      `);
      
      return { success: true, data: metricas[0] || {} };
    } catch (error) {
      console.error('Error al obtener métricas comerciales:', error);
      return { success: false, message: 'Error al obtener métricas comerciales' };
    }
  }

  // Obtener ventas por categoría
  static async obtenerVentasPorCategoria() {
    try {
      const ventas = await db.query(`
        SELECT 
          p.categoria,
          SUM(d.subTotal) as totalVentas,
          COUNT(DISTINCT d.idFactura) as cantidadVentas
        FROM detalles d
        JOIN regproductos rp ON d.idRegProductos = rp.idRegProducto
        JOIN productos p ON rp.idProducto = p.idProducto
        JOIN factura f ON d.idFactura = f.idFactura
        WHERE f.estado = 'aprobado'
        AND MONTH(f.fecha) = MONTH(CURDATE())
        GROUP BY p.categoria
        ORDER BY totalVentas DESC
      `);
      
      return { success: true, data: ventas };
    } catch (error) {
      console.error('Error al obtener ventas por categoría:', error);
      return { success: false, message: 'Error al obtener ventas por categoría' };
    }
  }
}

module.exports = GestionControlador;
