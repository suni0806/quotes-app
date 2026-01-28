const sql = require('mssql');
require('dotenv').config();

// Famous quotes data
const quotes = [
  { text: "The only way to do great work is to love what you do.", author: "Steve Jobs" },
  { text: "Innovation distinguishes between a leader and a follower.", author: "Steve Jobs" },
  { text: "Life is what happens when you're busy making other plans.", author: "John Lennon" },
  { text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt" },
  { text: "It is during our darkest moments that we must focus to see the light.", author: "Aristotle" },
  { text: "Whoever is happy will make others happy too.", author: "Anne Frank" },
  { text: "Do not go where the path may lead, go instead where there is no path and leave a trail.", author: "Ralph Waldo Emerson" },
  { text: "You will face many defeats in life, but never let yourself be defeated.", author: "Maya Angelou" },
  { text: "The greatest glory in living lies not in never falling, but in rising every time we fall.", author: "Nelson Mandela" },
  { text: "In the end, it's not the years in your life that count. It's the life in your years.", author: "Abraham Lincoln" },
  { text: "Never let the fear of striking out keep you from playing the game.", author: "Babe Ruth" },
  { text: "Life is either a daring adventure or nothing at all.", author: "Helen Keller" },
  { text: "Many of life's failures are people who did not realize how close they were to success when they gave up.", author: "Thomas Edison" },
  { text: "You have brains in your head. You have feet in your shoes. You can steer yourself any direction you choose.", author: "Dr. Seuss" },
  { text: "If life were predictable it would cease to be life, and be without flavor.", author: "Eleanor Roosevelt" },
  { text: "The whole secret of a successful life is to find out what is one's destiny to do, and then do it.", author: "Henry Ford" },
  { text: "In order to write about life first you must live it.", author: "Ernest Hemingway" },
  { text: "The big lesson in life, baby, is never be scared of anyone or anything.", author: "Frank Sinatra" },
  { text: "Sing like no one's listening, love like you've never been hurt, dance like nobody's watching, and live like it's heaven on earth.", author: "Mark Twain" },
  { text: "Curiosity about life in all of its aspects, I think, is still the secret of great creative people.", author: "Leo Burnett" },
  { text: "Life is not a problem to be solved, but a reality to be experienced.", author: "Soren Kierkegaard" },
  { text: "The unexamined life is not worth living.", author: "Socrates" },
  { text: "Turn your wounds into wisdom.", author: "Oprah Winfrey" },
  { text: "The way to get started is to quit talking and begin doing.", author: "Walt Disney" },
  { text: "Don't let yesterday take up too much of today.", author: "Will Rogers" },
  { text: "You learn more from failure than from success. Don't let it stop you. Failure builds character.", author: "Unknown" },
  { text: "It's not whether you get knocked down, it's whether you get up.", author: "Vince Lombardi" },
  { text: "If you are working on something that you really care about, you don't have to be pushed. The vision pulls you.", author: "Steve Jobs" },
  { text: "People who are crazy enough to think they can change the world, are the ones who do.", author: "Rob Siltanen" },
  { text: "Failure will never overtake me if my determination to succeed is strong enough.", author: "Og Mandino" },
  { text: "We may encounter many defeats but we must not be defeated.", author: "Maya Angelou" },
  { text: "Knowing is not enough; we must apply. Wishing is not enough; we must do.", author: "Johann Wolfgang Von Goethe" },
  { text: "Imagine your life is perfect in every respect; what would it look like?", author: "Brian Tracy" },
  { text: "We generate fears while we sit. We overcome them by action.", author: "Dr. Henry Link" },
  { text: "Whether you think you can or think you can't, you're right.", author: "Henry Ford" },
  { text: "Security is mostly a superstition. Life is either a daring adventure or nothing.", author: "Helen Keller" },
  { text: "The man who has confidence in himself gains the confidence of others.", author: "Hasidic Proverb" },
  { text: "The only limit to our realization of tomorrow will be our doubts of today.", author: "Franklin D. Roosevelt" },
  { text: "Creativity is intelligence having fun.", author: "Albert Einstein" },
  { text: "What you lack in talent can be made up with desire, hustle and giving 110% all the time.", author: "Don Zimmer" },
  { text: "Do what you can with all you have, wherever you are.", author: "Theodore Roosevelt" },
  { text: "Develop an 'Attitude of Gratitude'. Say thank you to everyone you meet for everything they do for you.", author: "Brian Tracy" },
  { text: "You are never too old to set another goal or to dream a new dream.", author: "C.S. Lewis" },
  { text: "To see what is right and not do it is a lack of courage.", author: "Confucius" },
  { text: "Reading is to the mind, as exercise is to the body.", author: "Brian Tracy" },
  { text: "Fake it until you make it! Act as if you had all the confidence you require until it becomes your reality.", author: "Brian Tracy" },
  { text: "The future belongs to the competent. Get good, get better, be the best!", author: "Brian Tracy" },
  { text: "For every reason it's not possible, there are hundreds of people who have faced the same circumstances and succeeded.", author: "Jack Canfield" },
  { text: "Things work out best for those who make the best of how things work out.", author: "John Wooden" },
  { text: "A room without books is like a body without a soul.", author: "Marcus Tullius Cicero" }
];

// SQL connection configuration
const sqlConfig = {
  server: process.env.SQL_SERVER || 'localhost',
  database: process.env.SQL_DATABASE || 'quotesdb',
  user: process.env.SQL_USERNAME,
  password: process.env.SQL_PASSWORD,
  options: {
    encrypt: true,
    trustServerCertificate: process.env.NODE_ENV === 'development',
    enableArithAbort: true
  }
};

// If using connection string
if (process.env.DATABASE_CONNECTION_STRING) {
  sqlConfig.connectionString = process.env.DATABASE_CONNECTION_STRING;
  sqlConfig.options = {
    encrypt: true,
    trustServerCertificate: false,
    enableArithAbort: true
  };
}

async function seedDatabase() {
  let pool;
  
  try {
    console.log('Connecting to database...');
    pool = await sql.connect(sqlConfig);
    console.log('Connected successfully!');

    // Create table if it doesn't exist
    console.log('\nCreating Quotes table if it doesn\'t exist...');
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Quotes')
      BEGIN
        CREATE TABLE Quotes (
          Id INT PRIMARY KEY IDENTITY(1,1),
          QuoteText NVARCHAR(MAX) NOT NULL,
          Author NVARCHAR(255) NOT NULL,
          CreatedAt DATETIME2 DEFAULT GETUTCDATE()
        );
        
        CREATE INDEX IX_Quotes_CreatedAt ON Quotes(CreatedAt);
        CREATE INDEX IX_Quotes_Author ON Quotes(Author);
      END
    `);
    console.log('Table ready!');

    // Check if table already has data
    const countResult = await pool.request().query('SELECT COUNT(*) as count FROM Quotes');
    const existingCount = countResult.recordset[0].count;
    
    if (existingCount > 0) {
      console.log(`\nDatabase already contains ${existingCount} quotes.`);
      const readline = require('readline').createInterface({
        input: process.stdin,
        output: process.stdout
      });
      
      const answer = await new Promise(resolve => {
        readline.question('Do you want to clear existing data and reseed? (yes/no): ', resolve);
      });
      readline.close();

      if (answer.toLowerCase() === 'yes' || answer.toLowerCase() === 'y') {
        console.log('Clearing existing data...');
        await pool.request().query('DELETE FROM Quotes');
        console.log('Existing data cleared.');
      } else {
        console.log('Keeping existing data. Exiting...');
        await pool.close();
        return;
      }
    }

    // Insert quotes
    console.log(`\nInserting ${quotes.length} quotes...`);
    let successCount = 0;
    
    for (const quote of quotes) {
      try {
        await pool.request()
          .input('text', sql.NVarChar(sql.MAX), quote.text)
          .input('author', sql.NVarChar(255), quote.author)
          .query('INSERT INTO Quotes (QuoteText, Author) VALUES (@text, @author)');
        
        successCount++;
        process.stdout.write(`\rProgress: ${successCount}/${quotes.length}`);
      } catch (err) {
        console.error(`\nError inserting quote: "${quote.text.substring(0, 50)}..." - ${err.message}`);
      }
    }

    console.log(`\n\n✅ Successfully seeded database with ${successCount} quotes!`);

    // Display sample quotes
    console.log('\nSample quotes from database:');
    const sampleResult = await pool.request().query(`
      SELECT TOP 3 Id, QuoteText, Author 
      FROM Quotes 
      ORDER BY NEWID()
    `);
    
    sampleResult.recordset.forEach((quote, index) => {
      console.log(`\n${index + 1}. "${quote.QuoteText}"`);
      console.log(`   - ${quote.Author}`);
    });

    // Display statistics
    const stats = await pool.request().query(`
      SELECT 
        COUNT(*) as TotalQuotes,
        COUNT(DISTINCT Author) as TotalAuthors
      FROM Quotes
    `);
    
    console.log('\n📊 Database Statistics:');
    console.log(`   Total Quotes: ${stats.recordset[0].TotalQuotes}`);
    console.log(`   Unique Authors: ${stats.recordset[0].TotalAuthors}`);

  } catch (err) {
    console.error('❌ Error seeding database:', err);
    process.exit(1);
  } finally {
    if (pool) {
      await pool.close();
      console.log('\nDatabase connection closed.');
    }
  }
}

// Run the seed function
console.log('=================================');
console.log('  Database Seeding Script');
console.log('=================================\n');

seedDatabase()
  .then(() => {
    console.log('\n✨ Seeding completed successfully!');
    process.exit(0);
  })
  .catch(err => {
    console.error('Fatal error:', err);
    process.exit(1);
  });
