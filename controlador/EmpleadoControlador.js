// controlador/EmpleadoControlador.js
const dbService = require('../modelo/bd/Conexion');

class EmpleadoControlador {

    static async listarEmpleados(req, res) {
        try {
            const query = 'SELECT * FROM empleados WHERE activo = TRUE ORDER BY nombre ASC';
            const result = await dbService.query(query);
            res.json({ success: true, data: result });
        } catch (err) {
            res.status(500).json({ success: false, message: 'Error al listar empleados', error: err.message });
        }
    }

    static async crearEmpleado(req, res) {
        const { nombre, documento, salario_mensual } = req.body;
        try {
            const query = `
        INSERT INTO empleados (nombre, documento, salario_mensual) 
        VALUES (?, ?, ?) RETURNING *
      `;
            const result = await dbService.query(query, [nombre, documento, salario_mensual]);
            res.json({ success: true, message: 'Empleado creado correctamente', data: result[0] });
        } catch (err) {
            res.status(500).json({ success: false, message: 'Error al crear empleado', error: err.message });
        }
    }

    static async registrarTurno(req, res) {
        const { id_empleado, fecha, hora_inicio, hora_fin } = req.body;
        try {
            const query = `
        INSERT INTO turnos (id_empleado, fecha, hora_inicio, hora_fin) 
        VALUES (?, ?, ?, ?) RETURNING *
      `;
            const result = await dbService.query(query, [id_empleado, fecha, hora_inicio, hora_fin]);
            res.json({ success: true, message: 'Turno registrado correctamente', data: result[0] });
        } catch (err) {
            res.status(500).json({ success: false, message: 'Error al registrar turno', error: err.message });
        }
    }

    static async descontarDia(req, res) {
        const { id_empleado } = req.body;
        try {
            const query = 'SELECT descontar_dia(?) as mensaje';
            const result = await dbService.query(query, [id_empleado]);
            const msg = result[0].mensaje;
            res.json({ success: !msg.includes('Ya se aplicó'), message: msg });
        } catch (err) {
            res.status(500).json({ success: false, message: 'Error al aplicar descuento de día', error: err.message });
        }
    }

    static async descontarHoras(req, res) {
        const { id_empleado, horas } = req.body;
        try {
            const query = 'SELECT descontar_horas(?, ?) as mensaje';
            const result = await dbService.query(query, [id_empleado, horas]);
            res.json({ success: true, message: result[0].mensaje });
        } catch (err) {
            res.status(500).json({ success: false, message: 'Error al aplicar descuento por horas', error: err.message });
        }
    }

    static async obtenerResumenMensual(req, res) {
        try {
            const query = `
        SELECT 
          e.id_empleado,
          e.nombre,
          e.salario_mensual,
          vh.valor_hora,
          e.auxilio_transporte,
          e.descuentos,
          e.horas_descuento_acumuladas,
          COALESCE(SUM(ht.horas_trabajadas), 0) as horas_totales,
          COALESCE(SUM(ht.horas_trabajadas * vh.valor_hora), 0) as subtotal,
          (COALESCE(SUM(ht.horas_trabajadas * vh.valor_hora), 0) + e.auxilio_transporte - e.descuentos) as total_mes
        FROM empleados e
        JOIN vista_valor_hora vh ON e.id_empleado = vh.id_empleado
        LEFT JOIN vista_horas_trabajadas ht ON e.id_empleado = ht.id_empleado AND ht.pagado = FALSE
        WHERE (DATE_TRUNC('month', ht.fecha) = DATE_TRUNC('month', CURRENT_DATE) OR ht.fecha IS NULL)
        GROUP BY e.id_empleado, e.nombre, e.salario_mensual, vh.valor_hora, e.auxilio_transporte, e.descuentos, e.horas_descuento_acumuladas
      `;
            const result = await dbService.query(query);
            res.json({ success: true, data: result });
        } catch (err) {
            res.status(500).json({ success: false, message: 'Error al obtener resumen de nómina', error: err.message });
        }
    }

    static async obtenerResumenPersonal(req, res) {
        try {
            const { idusuario } = req.usuario;
            console.log(`[Sync] Iniciando búsqueda para idusuario: ${idusuario}`);

            const query = `
                SELECT 
                    e.id_empleado, e.nombre, e.salario_mensual, e.descuentos, e.horas_descuento_acumuladas,
                    (COALESCE(SUM(v.horas_trabajadas), 0) * (e.salario_mensual / 220)) + e.auxilio_transporte - e.descuentos as total_mes
                FROM empleados e
                LEFT JOIN vista_horas_trabajadas v ON e.id_empleado = v.id_empleado AND v.pagado = FALSE
                WHERE e.idusuario = ?
                GROUP BY e.id_empleado, e.nombre, e.salario_mensual, e.descuentos, e.horas_descuento_acumuladas, e.auxilio_transporte
            `;
            let rows = await dbService.query(query, [idusuario]);

            if (!rows || rows.length === 0) {
                console.log(`[Sync] Empleado no encontrado, intentando auto-crear...`);
                const qUser = 'SELECT idusuario, nombres as nombre, documento, rol FROM usuarios WHERE idusuario = ?';
                const users = await dbService.query(qUser, [idusuario]);

                if (users && users.length > 0) {
                    const u = users[0];
                    console.log(`[Sync] Usuario encontrado: ${u.nombre} (Rol: ${u.rol})`);
                    if (u.rol === 'empleado' || u.rol === 'gerente') {
                        const qIns = `
                            INSERT INTO empleados (nombre, documento, idusuario, salario_mensual, auxilio_transporte, activo)
                            VALUES (?, ?, ?, 1300000, 162000, TRUE)
                        `;
                        await dbService.query(qIns, [u.nombre, u.documento, u.idusuario]);
                        console.log(`[Sync] Registro creado exitosamente para ${u.nombre}`);
                        rows = await dbService.query(query, [idusuario]);
                    }
                } else {
                    console.warn(`[Sync] Usuario no encontrado en la tabla usuarios para ID: ${idusuario}`);
                }
            }

            if (!rows || rows.length === 0) {
                return res.status(404).json({ success: false, message: 'Empleado no encontrado' });
            }
            res.json({ success: true, data: rows[0] });
        } catch (error) {
            console.error('[Sync] Error en obtenerResumenPersonal:', error);
            res.status(500).json({ success: false, message: 'Error de servidor: ' + error.message });
        }
    }

    static async registrarPago(req, res) {
        try {
            const { id_empleado, salario_base, descuentos, salario_pagado, metodo_pago, observacion } = req.body;

            if (!id_empleado) return res.status(400).json({ success: false, message: 'ID de empleado requerido' });

            await dbService.withTransaction(async (tx) => {
                // 1. Insertar el pago en el historial
                const qIns = `
                    INSERT INTO pagos_empleados (id_empleado, salario_base, descuentos, salario_pagado, metodo_pago, observacion)
                    VALUES (?, ?, ?, ?, ?, ?)
                `;
                await tx(qIns, [id_empleado, salario_base, descuentos, salario_pagado, metodo_pago, observacion]);

                // 2. Reiniciar descuentos y horas en la tabla empleados
                const qUpdEmp = `
                    UPDATE empleados 
                    SET descuentos = 0, horas_descuento_acumuladas = 0 
                    WHERE id_empleado = ?
                `;
                await tx(qUpdEmp, [id_empleado]);

                // 3. Marcar turnos como pagados
                const qUpdTur = `
                    UPDATE turnos 
                    SET pagado = TRUE 
                    WHERE id_empleado = ? AND pagado = FALSE
                `;
                await tx(qUpdTur, [id_empleado]);
            });

            res.json({ success: true, message: 'Pago registrado exitosamente (Transacción Atómica)' });
        } catch (error) {
            console.error('[Pago] Error en registrarPago:', error);
            res.status(500).json({ success: false, message: 'Error al registrar pago (Transacción revertida)' });
        }
    }

    static async obtenerHistorialPagos(req, res) {
        try {
            const { idusuario, rol } = req.usuario;
            let query = `
                SELECT 
                    e.nombre,
                    p.fecha_pago,
                    p.salario_base,
                    p.descuentos,
                    p.salario_pagado,
                    p.metodo_pago,
                    p.observacion
                FROM pagos_empleados p
                JOIN empleados e ON e.id_empleado = p.id_empleado
            `;
            let params = [];

            if (rol !== 'gerente') {
                // Si no es gerente, solo ve sus propios pagos
                query += ' WHERE e.idusuario = ?';
                params.push(idusuario);
            }

            query += ' ORDER BY p.fecha_pago DESC';

            const result = await dbService.query(query, params);
            res.json({ success: true, data: result });
        } catch (error) {
            console.error('[Pago] Error en obtenerHistorialPagos:', error);
            res.status(500).json({ success: false, message: 'Error al obtener historial' });
        }
    }
}

module.exports = EmpleadoControlador;
