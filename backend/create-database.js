const mysql = require('mysql2/promise');
require('dotenv').config();

async function createDatabase() {
  // Parse connection string
  const dbUrl = process.env.DATABASE_URL;
  const match = dbUrl.match(/mysql:\/\/([^:]+):([^@]+)@([^:]+):(\d+)\/([^?]+)/);
  
  if (!match) {
    console.error('Invalid DATABASE_URL format');
    process.exit(1);
  }
  
  const [, user, password, host, port, database] = match;
  const decodedPassword = decodeURIComponent(password);
  
  console.log(`Connecting to MySQL server at ${host}:${port}...`);
  
  try {
    // Connect without specifying database
    const connection = await mysql.createConnection({
      host,
      port: parseInt(port),
      user,
      password: decodedPassword,
    });
    
    console.log('Connected successfully!');
    
    // Create database
    console.log(`Creating database: ${database}...`);
    await connection.query(`
      CREATE DATABASE IF NOT EXISTS \`${database}\`
      CHARACTER SET utf8mb4
      COLLATE utf8mb4_unicode_ci
    `);
    
    console.log(`✅ Database '${database}' created successfully!`);
    
    // Verify
    const [rows] = await connection.query(`SHOW DATABASES LIKE '${database}'`);
    console.log(`✅ Verification: Found ${rows.length} database(s)`);
    
    await connection.end();
    console.log('\n✅ Database setup complete!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating database:', error.message);
    process.exit(1);
  }
}

createDatabase();



