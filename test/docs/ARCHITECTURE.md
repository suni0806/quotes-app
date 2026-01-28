# Architecture Documentation

## System Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet                              │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ HTTPS
                           │
                  ┌────────▼────────┐
                  │  Azure App      │
                  │  Service        │
                  │  (Zone Redundant)│
                  └────────┬────────┘
                           │
                           │ VNet Integration
                           │
        ┌──────────────────┼──────────────────┐
        │                                     │
        │         Virtual Network             │
        │                                     │
        │  ┌──────────────┐  ┌────────────┐ │
        │  │  App Service │  │  Private   │ │
        │  │  Subnet      │  │  Endpoint  │ │
        │  │              │  │  Subnet    │ │
        │  └──────────────┘  └─────┬──────┘ │
        │                           │        │
        └───────────────────────────┼────────┘
                                    │
                          ┌─────────▼─────────┐
                          │  Private Endpoint │
                          │  (SQL Database)   │
                          └─────────┬─────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │                               │
            ┌───────▼────────┐          ┌──────────▼────────┐
            │  Azure SQL     │          │   Key Vault       │
            │  Database      │          │   (Secrets)       │
            │  (Zone         │          │                   │
            │   Redundant)   │          └───────────────────┘
            └────────────────┘
```

## Security Architecture (PII Protection)

### Network Security

1. **No Public Database Access**
   - Azure SQL Database has `public_network_access_enabled = false`
   - Only accessible via Private Endpoint within VNet

2. **VNet Isolation**
   - Dedicated Virtual Network (10.0.0.0/16)
   - Separate subnets for different purposes
   - Private DNS zones for name resolution

3. **Encryption**
   - **In Transit**: TLS 1.2+ enforced on all connections
   - **At Rest**: Transparent Data Encryption (TDE) enabled
   - **Backups**: Encrypted automatically

### Authentication & Authorization

1. **Managed Identity**
   - App Service uses System Assigned Managed Identity
   - No credentials stored in application code
   - Automatic rotation by Azure

2. **Azure Key Vault**
   - All secrets stored in Key Vault
   - RBAC-based access control
   - Audit logging enabled

3. **SQL Authentication**
   - Strong password requirements enforced
   - Azure AD integration available
   - Connection strings never exposed

### Compliance Features

1. **Audit Logging**
   - SQL Server auditing enabled
   - Logs stored in GRS storage account
   - 90-day retention policy

2. **Data Protection**
   - Zone-redundant backups
   - Point-in-time restore (7 days)
   - Long-term retention (yearly)

## High Availability Architecture

### Availability Zones

1. **App Service**
   - Premium v2 tier with zone balancing
   - Minimum 2 instances across zones
   - Auto-scaling based on CPU (2-5 instances)

2. **SQL Database**
   - Premium tier (P1) with zone redundancy
   - 99.995% SLA
   - Automatic failover

### Scalability

```
Load Distribution:
─────────────────

         Users
           │
           ▼
    ┌─────────────┐
    │ Azure Front │  (Optional future enhancement)
    │ Door / CDN  │
    └──────┬──────┘
           │
    ┌──────┴──────┐
    │             │
    ▼             ▼
Instance 1    Instance 2    ... Instance N
   (AZ1)        (AZ2)           (AZ3)
    │             │              │
    └─────────────┴──────────────┘
                  │
                  ▼
           Azure SQL DB
         (Zone Redundant)
```

### Monitoring

1. **Application Insights**
   - Real-time performance monitoring
   - Custom telemetry tracking
   - Automated alerts

2. **Log Analytics**
   - Centralized logging
   - Query and analysis
   - 30-day retention

## Data Flow

### Request Flow

1. **User Request**
   ```
   User → HTTPS → App Service (Public Endpoint)
   ```

2. **Database Query**
   ```
   App Service → VNet Integration → Private Endpoint → SQL Database
   ```

3. **Secret Retrieval**
   ```
   App Service → Managed Identity → Key Vault → Secret
   ```

### Security Layers

```
Layer 1: HTTPS/TLS Encryption
Layer 2: App Service Network Rules
Layer 3: VNet Integration
Layer 4: Private Endpoint
Layer 5: SQL Server Authentication
Layer 6: Database-level Security
Layer 7: TDE (Data at Rest)
```

## Infrastructure Components

### Compute

- **App Service Plan**: Premium v2 (P1v2)
- **Instances**: 2-5 (auto-scaling)
- **OS**: Linux
- **Runtime**: Node.js 18 LTS

### Database

- **Tier**: Premium (P1)
- **Storage**: 500 GB max
- **DTU**: 125
- **Backup**: Automated with long-term retention

### Storage

- **Audit Logs**: GRS (Geo-Redundant Storage)
- **Replication**: 6 copies across regions

### Networking

- **VNet**: 10.0.0.0/16
- **Subnets**:
  - App Service: 10.0.1.0/24
  - Private Endpoints: 10.0.2.0/24

## Cost Optimization

### Current Configuration (High Availability)

- App Service Plan (P1v2): ~$100/month
- SQL Database (P1): ~$465/month
- Key Vault: ~$0.03/10,000 operations
- Storage (Audit): ~$20/month
- Application Insights: ~$2.30/GB

**Estimated Monthly Cost**: ~$585-$600

### Cost-Optimized Configuration (Dev/Test)

- App Service Plan (B1): ~$13/month
- SQL Database (S1): ~$30/month
- Other services: ~$25/month

**Estimated Monthly Cost**: ~$70

## Disaster Recovery

### Backup Strategy

1. **Automated Backups**
   - Frequency: Continuous (every 5-10 minutes)
   - Retention: 7 days (configurable)
   - Type: Full, differential, and transaction log

2. **Long-Term Retention**
   - Weekly: 1 week
   - Monthly: 1 month
   - Yearly: 1 year

### Recovery Objectives

- **RPO (Recovery Point Objective)**: < 5 minutes
- **RTO (Recovery Time Objective)**: < 1 hour

### Failover Scenarios

1. **Zone Failure**: Automatic failover to another zone
2. **Region Failure**: Manual geo-restore from backups
3. **Data Corruption**: Point-in-time restore

## Security Best Practices Implemented

✅ Principle of Least Privilege
✅ Defense in Depth
✅ Zero Trust Network Access
✅ Encryption at Rest and in Transit
✅ Audit Logging
✅ Secrets Management
✅ Network Isolation
✅ Automatic Updates
✅ Monitoring and Alerting
✅ Backup and Recovery

## Future Enhancements

1. **Azure Front Door**
   - Global load balancing
   - WAF protection
   - DDoS protection

2. **Geo-Replication**
   - Active geo-replication for SQL
   - Multi-region deployment

3. **Azure AD Integration**
   - Azure AD authentication
   - Conditional access policies

4. **Advanced Monitoring**
   - Custom dashboards
   - Automated incident response
   - Performance optimization

5. **DevOps Pipeline**
   - CI/CD with GitHub Actions
   - Automated testing
   - Infrastructure as Code validation
