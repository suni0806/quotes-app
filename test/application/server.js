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

// Connection pool
let pool;

// Initialize database connection
async function initializeDatabase() {
  const server = process.env.SQL_SERVER;
  const database = process.env.SQL_DATABASE;

  if (!server || !database) {
    console.error('CRITICAL: SQL_SERVER or SQL_DATABASE environment variables are missing!');
    return;
  }

  try {
    console.log('Attempting to connect to database using Managed Identity...');
    console.log(`Target - Server: ${server}, Database: ${database}`);

    const config = {
      server: server,
      database: database,
      authentication: {
        type: 'azure-active-directory-msi-vm'
      },
      options: {
        encrypt: true,
        trustServerCertificate: false,
        enableArithAbort: true,
        port: 1433,
        connectTimeout: 30000
      }
    };

    pool = await sql.connect(config);
    console.log('✅ Connected to Azure SQL Database via Managed Identity');
  } catch (err) {
    console.error('❌ Database connection failed:', err.message);
    if (appInsights.defaultClient) {
      appInsights.defaultClient.trackException({ exception: err });
    }
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
      server: process.env.SQL_SERVER || 'Not Configured',
      database: process.env.SQL_DATABASE || 'Not Configured',
      authType: 'Managed Identity (Entra ID)'
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
