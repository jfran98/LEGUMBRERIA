const mysql = require('mysql2');
const { Pool: PgPool } = require('pg');
const dbConfig = require('./Config');

function convertPlaceholdersForPostgres(sql) {
  let index = 0;
  return sql.replace(/\?/g, () => `$${++index}`);
}

function convertPlaceholdersForMySQL(sql) {
  let index = 0;
  return sql.replace(/\$\d+/g, () => '?');
}

class Conexion {
  constructor() {
    this.client = (dbConfig.client || 'mysql').toLowerCase();

    if (this.client === 'pg' || this.client === 'postgres' || this.client === 'postgresql') {
      this.pool = new PgPool({
        host: dbConfig.host,
        user: dbConfig.user,
        password: dbConfig.password,
        database: dbConfig.database,
        port: dbConfig.port
      });

      // Verifica la conexión en el inicio
      this.pool.connect((err, client, release) => {
        if (err) {
          console.error('❌ Error al conectar a PostgreSQL:', err.message);
        } else {
          console.log('✅ Conectado a PostgreSQL');
          release();
        }
      });
    } else {
      // MySQL por defecto
      this.pool = mysql.createPool({
        host: dbConfig.host,
        user: dbConfig.user,
        password: dbConfig.password,
        database: dbConfig.database,
        port: dbConfig.port
      });

      // Verifica la conexión en el inicio
      this.pool.getConnection((err, connection) => {
        if (err) {
          console.error('❌ Error al conectar a MySQL:', err.message);
        } else {
          console.log('✅ Conectado a MySQL');
          connection.release();
        }
      });
    }
  }

  // Ejecuta consulta en el motor seleccionado
  query(queryString, params) {
    if (this.client === 'pg' || this.client === 'postgres' || this.client === 'postgresql') {
      const sql = convertPlaceholdersForPostgres(queryString);
      return this.pool
        .query(sql, params)
        .then((res) => res.rows)
        .catch((err) => {
          console.error('❌ Error durante la consulta (PG):', err.message);
          throw err;
        });
    }

    // MySQL - convertir $ placeholders a ? si los hay
    const sql = queryString.includes('$') ? convertPlaceholdersForMySQL(queryString) : queryString;
    return this.pool
      .promise()
      .query(sql, params)
      .then(([results]) => results)
      .catch((err) => {
        console.error('❌ Error durante la consulta (MySQL):', err.message);
        throw err;
      });
  }

  async withTransaction(callback) {
    if (this.client === 'pg' || this.client === 'postgres' || this.client === 'postgresql') {
      const client = await this.pool.connect();
      try {
        await client.query('BEGIN');

        // Mock a query method for the client that handles placeholder conversion
        const txQuery = async (sql, params) => {
          const pgSql = convertPlaceholdersForPostgres(sql);
          const res = await client.query(pgSql, params);
          return res.rows;
        };

        const result = await callback(txQuery);
        await client.query('COMMIT');
        return result;
      } catch (err) {
        await client.query('ROLLBACK');
        console.error('❌ Transacción fallida (PG):', err.message);
        throw err;
      } finally {
        client.release();
      }
    } else {
      const connection = await this.pool.promise().getConnection();
      try {
        await connection.beginTransaction();

        const txQuery = async (queryString, params) => {
          const sql = queryString.includes('$') ? convertPlaceholdersForMySQL(queryString) : queryString;
          const [results] = await connection.query(sql, params);
          return results;
        };

        const result = await callback(txQuery);
        await connection.commit();
        return result;
      } catch (err) {
        await connection.rollback();
        console.error('❌ Transacción fallida (MySQL):', err.message);
        throw err;
      } finally {
        connection.release();
      }
    }
  }
}

module.exports = new Conexion();