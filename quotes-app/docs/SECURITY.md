# Security & Compliance Guide

## Overview

This application is designed with security-first principles, treating all data (including quotes) as critical PII (Personally Identifiable Information). This document outlines the security measures, compliance features, and best practices implemented.

## Security Principles

### 1. Defense in Depth

Multiple layers of security controls:
- Network isolation (VNet, Private Endpoints)
- Identity and access management (Managed Identities, RBAC)
- Data encryption (at rest and in transit)
- Monitoring and auditing (Application Insights, SQL Auditing)
- Application security (secure coding practices)

### 2. Zero Trust

- No implicit trust based on network location
- Verify explicitly at every access point
- Use least privilege access
- Assume breach and verify end-to-end

### 3. Principle of Least Privilege

- App Service has minimal required permissions
- Managed Identity scoped to specific Key Vault secrets
- SQL authentication uses dedicated service account
- No overly broad permissions granted

## Network Security

### Virtual Network Isolation

```
Public Internet ──┬─→ HTTPS Only ──→ App Service
                  │
                  └──X──→ SQL Database (BLOCKED)
                         
App Service ──VNet──→ Private Endpoint ──→ SQL Database ✓
```

#### Configuration

- **VNet CIDR**: 10.0.0.0/16
- **App Service Subnet**: 10.0.1.0/24
- **Private Endpoint Subnet**: 10.0.2.0/24
- **Public Database Access**: Disabled

### Private Endpoint Benefits

1. Database traffic never traverses public internet
2. Reduces attack surface
3. Enables network segmentation
4. Supports network security groups (NSGs)

### TLS/SSL Configuration

- **Minimum TLS Version**: 1.2
- **App Service**: HTTPS only, HTTP redirects to HTTPS
- **SQL Database**: Encrypted connections enforced
- **Certificate Management**: Automated by Azure

## Data Protection

### Encryption at Rest

#### Azure SQL Database

- **Transparent Data Encryption (TDE)**: Enabled
- **Encryption Algorithm**: AES-256
- **Key Management**: Azure-managed keys
- **Backup Encryption**: Automatic

#### Storage Accounts

- **Service-Side Encryption**: Enabled by default
- **Encryption Scope**: Account level
- **Key Type**: Microsoft-managed keys

### Encryption in Transit

| Connection | Protocol | Encryption |
|------------|----------|------------|
| User → App Service | HTTPS | TLS 1.2+ |
| App Service → SQL | TDS | TLS 1.2+ |
| App Service → Key Vault | HTTPS | TLS 1.2+ |

### Data Classification

All data is treated as **High Sensitivity** PII:

```sql
-- Example: Column-level classification (can be added)
ADD SENSITIVITY CLASSIFICATION TO
    dbo.Quotes.QuoteText
WITH (LABEL='Confidential', INFORMATION_TYPE='Other')
```

## Identity and Access Management

### Managed Identity

#### System-Assigned Identity

App Service uses system-assigned managed identity:

**Benefits:**
- No credentials in code or configuration
- Automatic credential rotation
- Azure AD authentication
- Audit trail in Azure AD logs

**Permissions:**
- Key Vault: Get, List secrets
- No permissions to other resources

### Key Vault Access

```hcl
# App Service → Key Vault
Access Policy:
  - Secret Permissions: Get, List
  - Assignee: App Service Managed Identity
  - Scope: Specific secrets only
```

### SQL Authentication

**Current Implementation**: SQL Authentication
- Strong password (12+ characters)
- Stored in Key Vault
- Connection string never exposed to users

**Recommended Enhancement**: Azure AD Authentication
```sql
CREATE USER [app-service-name] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [app-service-name];
ALTER ROLE db_datawriter ADD MEMBER [app-service-name];
```

## Audit and Monitoring

### SQL Auditing

#### Configuration

- **Enabled**: Yes
- **Audit Destination**: Azure Storage Account
- **Retention Period**: 90 days
- **Storage Replication**: GRS (Geo-Redundant)

#### Audited Events

- All database operations
- Login attempts (success and failure)
- Permission changes
- Schema modifications
- Data access patterns

#### Audit Log Access

```bash
# Query audit logs
az storage blob list \
  --account-name <storage-account> \
  --container-name sqldbauditlogs \
  --output table
```

### Application Insights

#### Telemetry Collection

- Request tracking
- Dependency tracking (SQL queries)
- Exception tracking
- Custom events (quote retrieval)
- Performance counters

#### Security Monitoring

```javascript
// Custom security event
client.trackEvent({
  name: 'UnauthorizedAccess',
  properties: {
    ip: request.ip,
    endpoint: request.url
  }
});
```

### Azure Monitor

#### Configured Alerts

1. **High CPU Usage**: CPU > 80% for 5 minutes
2. **Database Connectivity**: Failed SQL connections
3. **Application Errors**: Exception rate threshold
4. **Resource Health**: Service degradation

#### Log Analytics Queries

```kusto
// Failed database connections
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.SQL"
| where Category == "Errors"
| project TimeGenerated, Message, ResourceGroup

// Application exceptions
exceptions
| where timestamp > ago(1h)
| summarize count() by type, outerMessage
```

## Compliance Features

### GDPR Compliance

#### Data Subject Rights

1. **Right to Access**: Query API available
2. **Right to Erasure**: Soft delete capability
3. **Data Portability**: Export functionality
4. **Purpose Limitation**: Data used only for display

#### Data Processing

```javascript
// Data minimization - only essential fields
const quote = {
  id: row.Id,
  text: row.QuoteText,
  author: row.Author
  // No user tracking, no cookies, no personal data collection
};
```

### HIPAA Considerations

While quotes aren't health data, the infrastructure supports HIPAA:

✅ Encryption at rest and in transit
✅ Access controls and authentication
✅ Audit logging
✅ Backup and disaster recovery
✅ Incident response capability

**Note**: Full HIPAA compliance requires Business Associate Agreement (BAA) with Microsoft.

### SOC 2 Alignment

| Control | Implementation |
|---------|----------------|
| Access Control | Managed Identity, RBAC |
| Encryption | TDE, TLS 1.2+ |
| Monitoring | Application Insights, Audit Logs |
| Availability | Zone Redundancy, Auto-scaling |
| Change Management | Terraform IaC |

## Security Best Practices

### Application Security

#### Input Validation

```javascript
// Parameterized queries prevent SQL injection
await pool.request()
  .input('text', sql.NVarChar(sql.MAX), quote.text)
  .input('author', sql.NVarChar(255), quote.author)
  .query('INSERT INTO Quotes (QuoteText, Author) VALUES (@text, @author)');
```

#### Output Encoding

```javascript
// Frontend sanitization
const sanitized = DOMPurify.sanitize(quoteText);
```

#### Error Handling

```javascript
// Never expose internal errors
catch (error) {
  console.error('Internal error:', error); // Log internally
  res.status(500).json({ 
    error: 'An error occurred' // Generic message to user
  });
}
```

### Infrastructure Security

#### Terraform State Security

```bash
# Store state remotely with encryption
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

#### Secret Management

```bash
# Never commit secrets to Git
echo "*.tfvars" >> .gitignore
echo ".env" >> .gitignore
echo "*.pem" >> .gitignore
```

#### Network Security Groups (Future Enhancement)

```hcl
resource "azurerm_network_security_group" "app_subnet" {
  # Restrict inbound to App Service only
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
```

## Incident Response

### Detection

1. **Application Insights Alerts**: Real-time notifications
2. **SQL Auditing**: Post-incident investigation
3. **Azure Security Center**: Security recommendations

### Response Plan

#### Phase 1: Detection and Analysis

1. Alert triggered (email/SMS/webhook)
2. Review Application Insights logs
3. Check SQL audit logs
4. Analyze affected resources

#### Phase 2: Containment

```bash
# Isolate compromised App Service
az webapp stop \
  --resource-group <rg> \
  --name <app-name>

# Rotate secrets
az keyvault secret set \
  --vault-name <kv-name> \
  --name sql-connection-string \
  --value <new-connection-string>

# Restart with new secrets
az webapp start \
  --resource-group <rg> \
  --name <app-name>
```

#### Phase 3: Eradication

1. Identify root cause
2. Apply security patches
3. Update Terraform configuration
4. Redeploy infrastructure

#### Phase 4: Recovery

1. Restore from backup if needed
2. Verify system integrity
3. Resume normal operations
4. Monitor closely

#### Phase 5: Lessons Learned

1. Document incident
2. Update procedures
3. Improve monitoring
4. Security training

## Backup and Recovery

### Backup Strategy

#### Database Backups

- **Automated Backups**: Every 5-10 minutes
- **Short-term Retention**: 7 days (configurable up to 35 days)
- **Long-term Retention**: 
  - Weekly: 1 week
  - Monthly: 1 month
  - Yearly: 1 year

#### Point-in-Time Restore

```bash
# Restore to specific point in time
az sql db restore \
  --resource-group <rg> \
  --server <server-name> \
  --name <db-name> \
  --dest-name <restored-db-name> \
  --time "2024-01-27T10:30:00"
```

### Disaster Recovery

**RPO (Recovery Point Objective)**: < 5 minutes
**RTO (Recovery Time Objective)**: < 1 hour

#### DR Procedures

1. **Zone Failure**: Automatic failover (no action needed)
2. **Region Failure**: 
   ```bash
   # Geo-restore from backup
   az sql db restore \
     --resource-group <rg> \
     --server <server-name> \
     --name <db-name> \
     --dest-name <restored-db-name> \
     --restore-point-in-time <time>
   ```

## Penetration Testing

### Pre-Authorization

- Notify Microsoft before testing
- Follow Azure penetration testing rules
- Document scope and methods

### Allowed Testing

✅ Web application scanning
✅ API endpoint testing
✅ Authentication testing
✅ SQL injection testing (non-destructive)

### Prohibited Actions

❌ DDoS attacks
❌ Physical attacks on datacenters
❌ Social engineering of Microsoft staff
❌ Testing other customers' resources

## Security Checklist

### Pre-Deployment

- [ ] Secrets stored in Key Vault
- [ ] Strong passwords generated
- [ ] Terraform state secured
- [ ] No credentials in code
- [ ] .gitignore properly configured

### Post-Deployment

- [ ] Public database access disabled
- [ ] TLS 1.2+ enforced
- [ ] Managed Identity configured
- [ ] Audit logging enabled
- [ ] Monitoring alerts set up
- [ ] Backup validated
- [ ] Access controls reviewed

### Ongoing

- [ ] Regular security scans
- [ ] Patch management
- [ ] Access review (quarterly)
- [ ] Audit log review (monthly)
- [ ] Incident response drills (annually)
- [ ] Compliance assessment (annually)

## Security Contacts

### Azure Security Resources

- Azure Security Center: https://portal.azure.com/#blade/Microsoft_Azure_Security
- Azure Trust Center: https://azure.microsoft.com/en-us/support/trust-center/
- Report Security Issue: secure@microsoft.com

### Compliance Documentation

- Azure Compliance: https://azure.microsoft.com/en-us/resources/microsoft-azure-compliance-offerings/
- Privacy Statement: https://privacy.microsoft.com/
- Service Trust Portal: https://servicetrust.microsoft.com/

## Updates and Maintenance

### Security Updates

```bash
# Update Terraform providers
terraform init -upgrade

# Update Node.js dependencies
cd app
npm audit
npm audit fix

# Update Azure services (automatic)
# Azure manages OS and platform updates
```

### Compliance Reviews

- **Monthly**: Review audit logs
- **Quarterly**: Access control review
- **Annually**: Full security assessment
- **As needed**: Incident response

## Conclusion

This application implements enterprise-grade security controls appropriate for handling PII and sensitive data. The architecture follows Azure security best practices and supports compliance with major frameworks including GDPR, HIPAA, and SOC 2.

For questions or concerns about security, please review Azure Security Center recommendations and consult with your organization's security team.
