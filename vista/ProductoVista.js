// vista/ProductoVista.js
const express = require('express');
const router = express.Router();
const ProductoControlador = require('../controlador/ProductoControlador');

// Obtener todos los productos
router.get('/productos', ProductoControlador.obtenerProductos);

// Registrar un nuevo producto
router.post('/productos', ProductoControlador.registrarEntradaProducto);

// Obtener producto por ID
router.get('/productos/:id', ProductoControlador.obtenerProductoPorId);

// Actualizar producto
router.post('/productos/editar/:id', ProductoControlador.actualizarProducto);

// Eliminar producto
router.delete('/productos/:id', ProductoControlador.eliminarProducto);

module.exports = router;
