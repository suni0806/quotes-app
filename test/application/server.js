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
  try {
    console.log('Using database connection string:', sqlConfig.connectionString.replace(/Password=[^;]+/, 'Password=***'));
    pool = await sql.connect(sqlConfig);
    console.log('Connected to Azure SQL Database');
  } catch (err) {
    console.error('Database connection failed:', err);
    throw err;
  }
}


// Middleware
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Health check endpoint for Azure App Service
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString()
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
async function startServer() {
  try {
    await initializeDatabase();

    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
      console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
    });
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
}

startServer();
