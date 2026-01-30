param(
    [Parameter(Mandatory = $true)]
    [string]$Server,
    [Parameter(Mandatory = $true)]
    [string]$Database,
    [Parameter(Mandatory = $true)]
    [string]$ManagedIdentityName
)

Write-Host "Authorizing Managed Identity '$ManagedIdentityName' in database '$Database' on server '$Server'..."

try {
    # Get access token for Azure SQL
    $accessToken = az account get-access-token --resource https://database.windows.net/ --query accessToken -o tsv
    if (-not $accessToken) {
        throw "Failed to acquire Azure SQL access token via Azure CLI."
    }

    # Connection using the token
    $conn = New-Object System.Data.SqlClient.SqlConnection
    $conn.ConnectionString = "Data Source=$Server;Initial Catalog=$Database;Encrypt=True;"
    $conn.AccessToken = $accessToken
    
    Write-Host "Opening connection to SQL Server..."
    $conn.Open()
    
    $sql = @"
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = '$ManagedIdentityName')
BEGIN
    PRINT 'Creating user for Managed Identity...';
    CREATE USER [$ManagedIdentityName] FROM EXTERNAL PROVIDER;
END

PRINT 'Assigning roles...';
ALTER ROLE db_datareader ADD MEMBER [$ManagedIdentityName];
ALTER ROLE db_datawriter ADD MEMBER [$ManagedIdentityName];

-- Create table if not exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Quotes')
BEGIN
    PRINT 'Creating Quotes table...';
    CREATE TABLE Quotes (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Text NVARCHAR(MAX) NOT NULL,
        Author NVARCHAR(255) NOT NULL,
        CreatedAt DATETIME DEFAULT GETDATE()
    );
END

-- Seed sample data if empty
IF NOT EXISTS (SELECT 1 FROM Quotes)
BEGIN
    PRINT 'Seeding sample quotes...';
    INSERT INTO Quotes (Text, Author) VALUES 
    ('The only way to do great work is to love what you do.', 'Steve Jobs'),
    ('Innovation distinguishes between a leader and a follower.', 'Steve Jobs'),
    ('Your time is limited, so don''t waste it living someone else''s life.', 'Steve Jobs'),
    ('Stay hungry, stay foolish.', 'Steve Jobs'),
    ('The future belongs to those who believe in the beauty of their dreams.', 'Eleanor Roosevelt');
END
"@

    $query = $conn.CreateCommand()
    $query.CommandText = $sql
    $query.ExecuteNonQuery() | Out-Null
    
    Write-Host "✅ Permissions granted successfully."
    $conn.Close()
}
catch {
    Write-Error "❌ Failed to grant SQL permissions: $($_.Exception.Message)"
    if ($conn.State -eq 'Open') { $conn.Close() }
    exit 1
}
