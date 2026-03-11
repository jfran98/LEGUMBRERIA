
const dbService = require('./modelo/bd/Conexion');

async function migrate() {
    try {
        console.log('--- MIGRATION START ---');

        console.log('Adding "pagado" column to turnos...');
        await dbService.query('ALTER TABLE turnos ADD COLUMN IF NOT EXISTS pagado BOOLEAN DEFAULT FALSE');

        console.log('Dropping vista_horas_trabajadas...');
        await dbService.query('DROP VIEW IF EXISTS public.vista_horas_trabajadas CASCADE');

        console.log('Creating vista_horas_trabajadas...');
        const viewQuery = `
            CREATE VIEW public.vista_horas_trabajadas AS
            SELECT id_turno,
                id_empleado,
                fecha,
                hora_inicio,
                hora_fin,
                pagado,
                (EXTRACT(epoch FROM (
                    CASE
                        WHEN (hora_fin < hora_inicio) THEN (hora_fin + '1 day'::interval)
                        ELSE hora_fin
                    END - hora_inicio)) / (3600)::numeric) AS horas_trabajadas
            FROM public.turnos t;
        `;
        await dbService.query(viewQuery);

        console.log('✅ Migration successful');
        process.exit(0);
    } catch (err) {
        console.error('❌ Migration failed:', err);
        process.exit(1);
    }
}

migrate();
