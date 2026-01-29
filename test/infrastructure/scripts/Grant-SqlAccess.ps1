param (
    [Parameter(Mandatory=$true)]
    [string]$SqlServerFqdn,

    [Parameter(Mandatory=$true)]
    [string]$SqlDatabaseName,

    [Parameter(Mandatory=$true)]
    [string]$AppServiceName,

    [Parameter(Mandatory=$true)]
    [string]$AccessToken
)

$ErrorActionPreference = "Stop"

Write-Host "Granting Entra ID access to App Service: $AppServiceName on $SqlServerFqdn"

# SQL script to create user and grant roles
$sqlScript = @"
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = '$AppServiceName')
BEGIN
    CREATE USER [$AppServiceName] FROM EXTERNAL PROVIDER;
    ALTER ROLE db_datareader ADD MEMBER [$AppServiceName];
    ALTER ROLE db_datawriter ADD MEMBER [$AppServiceName];
    ALTER ROLE db_ddladmin ADD MEMBER [$AppServiceName];
END
"@

# Define connection string
$connString = "Server=tcp:$SqlServerFqdn,1433;Initial Catalog=$SqlDatabaseName;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

try {
    # Using Microsoft.Data.SqlClient (modern) or System.Data.SqlClient (legacy)
    # Most Windows agents have System.Data.SqlClient available by default.
    $conn = New-Object System.Data.SqlClient.SqlConnection($connString)
    $conn.AccessToken = $AccessToken
    $conn.Open()
    
    $command = $conn.CreateCommand()
    $command.CommandText = $sqlScript
    $null = $command.ExecuteNonQuery()
    
    $conn.Close()
    Write-Host "Successfully granted Entra ID access to SQL Database."
}
catch {
    Write-Error "Failed to grant SQL access: $($_.Exception.Message)"
    exit 1
}
