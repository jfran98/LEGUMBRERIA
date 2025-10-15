// vista/ProductoVista.js
const express = require('express');
const router = express.Router();
const multer = require('multer');
const mysql = require('mysql2');
const path = require('path');

// Configurar multer para subida de imágenes
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'public/img/productos'); // Asegúrate que esta carpeta exista
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ storage });

// Normalizador de categoría para mantener valores consistentes
function normalizarCategoria(valor) {
  if (!valor) return null;
  const v = String(valor).trim().toLowerCase();
  if (v.startsWith('frut')) return 'frutas';
  if (v.startsWith('verd')) return 'verduras';
  if (['promo', 'promos', 'promocion', 'promoción', 'promociones', 'oferta', 'ofertas'].includes(v)) return 'promociones';
  if (v.startsWith('legumbr')) return 'legumbres';
  if (v.startsWith('cereal')) return 'cereales';
  if (v.startsWith('hortal')) return 'hortalizas';
  return null;
}

// Conexión a la base de datos
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '12345', // tu contraseña
  database: 'legumbreria'
});

// Ruta para agregar productos con soporte de imagen (con fallback si la columna no existe)
router.post('/productos', upload.single('imagen'), (req, res) => {
  const { nombre, descripcion, cantidad, precioCompra, precioVentaMenor, precioVentaMayor, categoria, unidad } = req.body;
  const imagenSubida = req.file ? `/img/productos/${req.file.filename}` : null;
  const imagenParaGuardar = imagenSubida || '/img/tomate.jpg';
  const recibioArchivo = !!req.file;
  const categoriaNormalizada = normalizarCategoria(categoria);
  const unidadNormalizada = (unidad && ['kg', 'lb', 'unidad'].includes(String(unidad).toLowerCase()))
    ? String(unidad).toLowerCase()
    : null;
  if (!recibioArchivo) {
    console.log('[POST /legumbreria/productos] No se recibió archivo "imagen". Content-Type:', req.headers['content-type']);
  } else {
    console.log('[POST /legumbreria/productos] Archivo recibido:', req.file.filename, 'Ruta:', imagenSubida);
  }

  const continuarRegistro = (idProducto) => {
    // Intentar insertar con columna cantidad1; si no existe, crearla y reintentar
    const insertarReg = () => {
      db.query(
        'INSERT INTO regproductos (idProducto, cantidad, cantidad1, precioCompra, precioVentaMenor, precioVentaMayor, fechaRegistro, estado) VALUES (?, ?, ?, ?, ?, ?, NOW(), "Disponible")',
        [idProducto, cantidad, cantidad, precioCompra, precioVentaMenor, precioVentaMayor],
        (err2) => {
          if (err2) return res.status(500).json({ error: err2 && (err2.sqlMessage || err2.message) || 'Error en la base de datos' });
          res.json({ success: true, idProducto, imagen: imagenSubida, imagenUsada: imagenParaGuardar, recibioArchivo });
        }
      );
    };

    db.query('SHOW COLUMNS FROM regproductos LIKE "cantidad1"', (errCheck, rows) => {
      if (errCheck) return res.status(500).json({ error: errCheck && (errCheck.sqlMessage || errCheck.message) || 'Error en la base de datos' });
      if (!rows || rows.length === 0) {
        // Crear la columna y reintentar
        db.query('ALTER TABLE regproductos ADD COLUMN cantidad1 DECIMAL(10,2) NOT NULL DEFAULT 0', (errAlt) => {
          if (errAlt && errAlt.code !== 'ER_DUP_FIELDNAME') {
            return res.status(500).json({ error: errAlt && (errAlt.sqlMessage || errAlt.message) || 'Error en la base de datos' });
          }
          insertarReg();
        });
      } else {
        insertarReg();
      }
    });
  };

  // Intentar insertar con columna imagen; si no existe, crearla dinámicamente y reintentar
  const insertarConImagen = () => {
    db.query(
      'INSERT INTO productos (nombre, descripcion, categoria, unidad, imagen, estado) VALUES (?, ?, ?, ?, ?, "activo")',
      [nombre || null, descripcion, categoriaNormalizada, unidadNormalizada, imagenParaGuardar],
      (err, result) => {
        if (err) {
          if (err.code === 'ER_BAD_FIELD_ERROR') {
            // Crear columnas faltantes y reintentar: nombre, imagen, categoria, unidad
            return db.query('ALTER TABLE productos ADD COLUMN nombre VARCHAR(255) NULL', () => {
              return db.query('ALTER TABLE productos ADD COLUMN imagen VARCHAR(255) NULL', () => {
                return db.query('ALTER TABLE productos ADD COLUMN categoria VARCHAR(50) NULL', () => {
                  return db.query("ALTER TABLE productos ADD COLUMN unidad ENUM('kg','lb','unidad') NULL", () => {
                    // Reintentar insert completo
                    return db.query(
                      'INSERT INTO productos (nombre, descripcion, categoria, unidad, imagen, estado) VALUES (?, ?, ?, ?, ?, "activo")',
                      [nombre || null, descripcion, categoriaNormalizada, unidadNormalizada, imagenParaGuardar],
                      (reErr, reResult) => {
                        if (reErr) {
                          // Si aún falla, insertar mínimo
                          return db.query(
                            'INSERT INTO productos (descripcion, estado) VALUES (?, "activo")',
                            [descripcion],
                            (err2, result2) => {
                              if (err2) return res.status(500).json({ error: err2 && (err2.sqlMessage || err2.message) || 'Error en la base de datos' });
                              continuarRegistro(result2.insertId);
                            }
                          );
                        }
                        continuarRegistro(reResult.insertId);
                      }
                    );
                  });
                });
              });
            });
          }
          return res.status(500).json({ error: err && (err.sqlMessage || err.message) || 'Error en la base de datos' });
        }
        continuarRegistro(result.insertId);
      }
    );
  };

  insertarConImagen();
});

// Obtener productos con JOIN (alineado al esquema)
router.get('/productos', (req, res) => {
  const consultar = (incluirImagen) => {
    const sql = incluirImagen
      ? `
        SELECT 
          p.idProducto, p.descripcion, p.estado, p.categoria, p.imagen,
          r.cantidad, r.precioCompra, r.precioVentaMenor, r.precioVentaMayor, r.fechaRegistro, r.estado AS estadoRegistro
        FROM productos p
        LEFT JOIN regproductos r ON p.idProducto = r.idProducto
        WHERE p.estado = 'activo'
      `
      : `
        SELECT 
          p.idProducto, p.descripcion, p.estado, p.categoria,
          r.cantidad, r.precioCompra, r.precioVentaMenor, r.precioVentaMayor, r.fechaRegistro, r.estado AS estadoRegistro
        FROM productos p
        LEFT JOIN regproductos r ON p.idProducto = r.idProducto
        WHERE p.estado = 'activo'
      `;

    db.query(sql, (err, results) => {
      if (err) {
        if (incluirImagen && err.code === 'ER_BAD_FIELD_ERROR') {
          // Intentar crear la columna y reconsultar con imagen
          return db.query('ALTER TABLE productos ADD COLUMN imagen VARCHAR(255) NULL', (altErr) => {
            if (altErr && altErr.code !== 'ER_DUP_FIELDNAME') {
              // Si no es posible crearla, consultar sin imagen
              return consultar(false);
            }
            // Reintentar con imagen
            return consultar(true);
          });
        }
        return res.status(500).json({ error: err && (err.sqlMessage || err.message) || 'Error en la base de datos' });
      }
      // Asegurar una imagen por defecto si falta el campo o viene null
      const conImagenPorDefecto = results.map((p) => ({
        ...p,
        imagen: p.imagen || '/img/tomate.jpg'
      }));
      res.json(conImagenPorDefecto);
    });
  };

  consultar(true);
});

module.exports = router;
