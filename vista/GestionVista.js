// vista/GestionVista.js
const express = require('express');
const GestionControlador = require('../controlador/GestionControlador');
const jwtAuth = require('../middleware/authMiddleware');

const router = express.Router();

// ========== CONTROL FINANCIERO ==========

// Obtener gastos operativos
router.get('/gastos-operativos', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.obtenerGastosOperativos();
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Aprobar gasto operativo
router.put('/gastos-operativos/:id/aprobar', jwtAuth.verificarToken, async (req, res) => {
  try {
    const { id } = req.params;
    const resultado = await GestionControlador.aprobarGasto(id);
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Rechazar gasto operativo
router.put('/gastos-operativos/:id/rechazar', jwtAuth.verificarToken, async (req, res) => {
  try {
    const { id } = req.params;
    const resultado = await GestionControlador.rechazarGasto(id);
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Crear nuevo gasto operativo
router.post('/gastos-operativos', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.crearGastoOperativo(req.body);
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Obtener presupuestos
router.get('/presupuestos', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.obtenerPresupuestos();
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Crear presupuesto
router.post('/presupuestos', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.crearPresupuesto(req.body);
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// ========== GESTIÓN DE PROCESOS Y OPERACIONES ==========

// Obtener procedimientos
router.get('/procedimientos', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.obtenerProcedimientos();
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Crear procedimiento
router.post('/procedimientos', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.crearProcedimiento(req.body);
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Obtener planes de trabajo
router.get('/planes-trabajo', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.obtenerPlanesTrabajo();
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Crear plan de trabajo
router.post('/planes-trabajo', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.crearPlanTrabajo(req.body);
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Actualizar progreso de plan
router.put('/planes-trabajo/:id/progreso', jwtAuth.verificarToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { progreso } = req.body;
    const resultado = await GestionControlador.actualizarProgresoPlan(id, progreso);
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Obtener KPIs
router.get('/kpis', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.obtenerKPIs();
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Actualizar KPI
router.put('/kpis/:id', jwtAuth.verificarToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { valor } = req.body;
    const resultado = await GestionControlador.actualizarKPI(id, valor);
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Obtener estrategias
router.get('/estrategias', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.obtenerEstrategias();
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Crear estrategia
router.post('/estrategias', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.crearEstrategia(req.body);
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Cambiar estado de estrategia
router.put('/estrategias/:id/estado', jwtAuth.verificarToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { estado } = req.body;
    const resultado = await GestionControlador.cambiarEstadoEstrategia(id, estado);
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// ========== GESTIÓN DE PRODUCTOS Y SERVICIOS ==========

// Obtener promociones
router.get('/promociones', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.obtenerPromociones();
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Crear promoción
router.post('/promociones', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.crearPromocion(req.body);
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Obtener cambios de precio pendientes
router.get('/cambios-precio', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.obtenerCambiosPrecio();
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Aprobar cambio de precio
router.put('/cambios-precio/:id/aprobar', jwtAuth.verificarToken, async (req, res) => {
  try {
    const { id } = req.params;
    const resultado = await GestionControlador.aprobarCambioPrecio(id);
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Rechazar cambio de precio
router.put('/cambios-precio/:id/rechazar', jwtAuth.verificarToken, async (req, res) => {
  try {
    const { id } = req.params;
    const resultado = await GestionControlador.rechazarCambioPrecio(id);
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Obtener cambios en catálogo pendientes
router.get('/cambios-catalogo', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.obtenerCambiosCatalogo();
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Aprobar cambio en catálogo
router.put('/cambios-catalogo/:id/aprobar', jwtAuth.verificarToken, async (req, res) => {
  try {
    const { id } = req.params;
    const resultado = await GestionControlador.aprobarCambioCatalogo(id);
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Obtener contratos
router.get('/contratos', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.obtenerContratos();
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Crear contrato
router.post('/contratos', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.crearContrato(req.body);
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Aprobar contrato
router.put('/contratos/:id/aprobar', jwtAuth.verificarToken, async (req, res) => {
  try {
    const { id } = req.params;
    const resultado = await GestionControlador.aprobarContrato(id);
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Obtener métricas comerciales
router.get('/metricas-comerciales', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.obtenerMetricasComerciales();
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

// Obtener ventas por categoría
router.get('/ventas-categoria', jwtAuth.verificarToken, async (req, res) => {
  try {
    const resultado = await GestionControlador.obtenerVentasPorCategoria();
    res.json(resultado);
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
});

module.exports = router;
