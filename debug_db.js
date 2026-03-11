
const dbService = require('./modelo/bd/Conexion');

async function check() {
    try {
        console.log('--- EMPLEADOS ---');
        const emps = await dbService.query('SELECT id_empleado, nombre, salario_mensual, auxilio_transporte FROM empleados');
        console.table(emps);

        console.log('--- TURNOS RECIENTES ---');
        const turnos = await dbService.query('SELECT id_turno, id_empleado, fecha, pagado FROM turnos ORDER BY id_turno DESC LIMIT 10');
        console.table(turnos);

        console.log('--- PAGOS RECIENTES ---');
        const pagos = await dbService.query('SELECT * FROM pagos_empleados ORDER BY idpago DESC LIMIT 5');
        console.table(pagos);

        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

check();
