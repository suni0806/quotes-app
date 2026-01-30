const express = require('express');
const sql = require('mssql');
const appInsights = require('applicationinsights');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8080;

// Initialize Application Insights if connection string is available
if (process.env.APPLICATIONINSIGHTS_CONNECTION_STRING) {
  appInsights.setup(process.env.APPLICATIONINSIGHTS_CONNECTION_STRING)
    .setAutoDependencyCorrelation(true)
    .setAutoCollectRequests(true)
    .setAutoCollectPerformance(true)
    .setAutoCollectExceptions(true)
    .setAutoCollectDependencies(true)
    .setAutoCollectConsole(true)
    .setUseDiskRetryCaching(true)
    .start();

  console.log('Application Insights initialized');
}

// SQL connection configuration
const sqlConfig = {
  connectionString: process.env.DATABASE_CONNECTION_STRING,
  options: {
    encrypt: true, // Use encryption for data in transit
    trustServerCertificate: false,
    enableArithAbort: true,
    requestTimeout: 30000
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  }
};

// Connection pool
let pool;

// Initialize database connection
async function initializeDatabase() {
  const connStr = process.env.DATABASE_CONNECTION_STRING;

  if (!connStr) {
    console.error('CRITICAL: DATABASE_CONNECTION_STRING is missing!');
    return;
  }

  // Check if it's still a Key Vault reference
  if (connStr.startsWith('@Microsoft.KeyVault')) {
    console.warn('DATABASE_CONNECTION_STRING is still a Key Vault reference. Waiting for resolution...');
    // We don't throw here, let the next attempt handle it
    return;
  }

  try {
    console.log('Attempting to connect to database...');
    // Simple mask for security
    const maskedConn = connStr.replace(/Password=[^;]+/, 'Password=***');
    console.log(`Using Connection String: ${maskedConn}`);

    pool = await sql.connect(sqlConfig);
    console.log('✅ Connected to Azure SQL Database');
  } catch (err) {
    console.error('❌ Database connection failed:', err.message);
    // We don't exit the process here, allow the server to remain up for diagnostics
  }
}

// Middleware
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Basic Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    dbConnected: !!(pool && pool.connected),
    timestamp: new Date().toISOString()
  });
});

// Detailed Health check for diagnostics
app.get('/health/detailed', (req, res) => {
  res.status(200).json({
    status: 'online',
    database: {
      connected: !!(pool && pool.connected),
      hasConnectionString: !!process.env.DATABASE_CONNECTION_STRING,
      isKeyVaultResolved: process.env.DATABASE_CONNECTION_STRING ? !process.env.DATABASE_CONNECTION_STRING.startsWith('@Microsoft.KeyVault') : false
    },
    environment: {
      nodeEnv: process.env.NODE_ENV || 'production',
      port: PORT,
      identity: process.env.IDENTITY_ENDPOINT ? 'Available' : 'Not Found'
    },
    timestamp: new Date().toISOString()
  });
});

// Re-attempt connection manually
app.post('/api/db/reconnect', async (req, res) => {
  await initializeDatabase();
  res.json({
    status: pool && pool.connected ? 'Connected' : 'Failed',
    message: 'Check logs for details'
  });
});

// Get random quote endpoint
app.get('/api/quote', async (req, res) => {
  // ... lines 71+ remain similar but with better error messaging ...
  try {
    if (!pool || !pool.connected) {
      throw new Error('Database not connected');
    }

    // Query for a random quote
    const result = await pool.request().query(`
      SELECT TOP 1 Id, Text, Author
      FROM Quotes
      ORDER BY NEWID()
    `);

    if (result.recordset.length === 0) {
      return res.status(404).json({
        error: 'No quotes found in database',
        message: 'Please seed the database with quotes first'
      });
    }

    const quote = result.recordset[0];

    // Track custom telemetry
    if (appInsights.defaultClient) {
      appInsights.defaultClient.trackEvent({
        name: 'QuoteRetrieved',
        properties: {
          quoteId: quote.Id,
          author: quote.Author
        }
      });
    }

    res.json({
      id: quote.Id,
      text: quote.Text,
      author: quote.Author
    });
  } catch (err) {
    console.error('Error fetching quote:', err);

    // Track exception
    if (appInsights.defaultClient) {
      appInsights.defaultClient.trackException({ exception: err });
    }

    res.status(500).json({
      error: 'Failed to fetch quote',
      message: err.message
    });
  }
});

// Get quote count endpoint
app.get('/api/stats', async (req, res) => {
  try {
    if (!pool || !pool.connected) {
      throw new Error('Database not connected');
    }

    const result = await pool.request().query(`
      SELECT COUNT(*) as TotalQuotes FROM Quotes
    `);

    res.json({
      totalQuotes: result.recordset[0].TotalQuotes
    });
  } catch (err) {
    console.error('Error fetching stats:', err);
    res.status(500).json({
      error: 'Failed to fetch statistics',
      message: err.message
    });
  }
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down gracefully...');
  try {
    if (pool) {
      await pool.close();
      console.log('Database connection closed');
    }
    process.exit(0);
  } catch (err) {
    console.error('Error during shutdown:', err);
    process.exit(1);
  }
});

process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down...');
  try {
    if (pool) {
      await pool.close();
      console.log('Database connection closed');
    }
    process.exit(0);
  } catch (err) {
    console.error('Error during shutdown:', err);
    process.exit(1);
  }
});

// Start server
function startServer() {
  app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'production'}`);

    // Attempt database connection after server is up
    initializeDatabase();
  });
}

startServer();
