# Application-Only Deployment Guide

## Overview

These workflows deploy **only the application code** to existing Azure App Service instances. The infrastructure must already be deployed using Terraform.

## 📁 Files

- **GitHub Actions**: `.github/workflows/deploy-app.yml`
- **Azure DevOps**: `azure-pipelines-app.yml`

## 🎯 When to Use

Use these application-only workflows when:
- ✅ Infrastructure is already deployed
- ✅ You only changed application code
- ✅ You want faster deployments
- ✅ You want to avoid Terraform operations
- ✅ Multiple teams manage app vs infrastructure

## 🚀 GitHub Actions Setup

### 1. Required Secrets

Add these secrets to your GitHub repository:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AZURE_CREDENTIALS` | Azure service principal JSON | `{"clientId": "..."}` |
| `APP_SERVICE_NAME_PROD` | Production App Service name | `app-quotes-prod-abc123` |
| `APP_SERVICE_NAME_STAGING` | Staging App Service name | `app-quotes-staging-abc123` |
| `APP_SERVICE_NAME_DEV` | Development App Service name | `app-quotes-dev-abc123` |

### 2. Get App Service Names

After deploying infrastructure with Terraform:

```bash
cd infrastructure
terraform output app_service_name
```

Add this value to GitHub Secrets.

### 3. Trigger Deployment

**Automatic:**
- Push to `main` branch with changes in `application/` folder

**Manual:**
```
1. Go to Actions tab
2. Select "Deploy Application Only"
3. Click "Run workflow"
4. Choose environment (production/staging/development)
5. Click "Run workflow"
```

### 4. Monitor Deployment

1. Go to Actions tab
2. Click on the running workflow
3. Watch build and deploy jobs
4. Check health check results

## 🔧 Azure DevOps Setup

### 1. Configure Service Connection

1. Go to Project Settings → Service connections
2. Create "Azure Resource Manager" connection
3. Name it: `azure-service-connection`

### 2. Add Pipeline Variables

Navigate to: Pipelines → Your Pipeline → Edit → Variables

| Variable Name | Value | Secret? |
|---------------|-------|---------|
| `APP_SERVICE_NAME_PROD` | Production app name | No |
| `APP_SERVICE_NAME_STAGING` | Staging app name | No |
| `APP_SERVICE_NAME_DEV` | Development app name | No |

### 3. Create Pipeline

```bash
# In Azure DevOps
Pipelines → New Pipeline 
→ Azure Repos Git 
→ Select your repo 
→ Existing Azure Pipelines YAML file 
→ Select: /azure-pipelines-app.yml
```

### 4. Run Pipeline

**Automatic:**
- Push to `main` with changes in `application/` folder

**Manual:**
```
1. Go to Pipelines
2. Select your pipeline
3. Click "Run pipeline"
4. Select environment parameter
5. Click "Run"
```

## 📋 What Gets Deployed

### Included:
✅ `server.js` - Application server
✅ `package.json` - Dependencies
✅ `public/` - Frontend files
✅ `node_modules/` - Production dependencies

### Excluded:
❌ `scripts/` - Database scripts (not needed in app)
❌ `.env` files - Use App Service configuration
❌ `.example` files - Template files only
❌ `*.md` files - Documentation

## 🔄 Deployment Flow

```
1. Build Stage
   ├─ Checkout code
   ├─ Install Node.js
   ├─ Install dependencies (production only)
   ├─ Run linting (optional)
   ├─ Create ZIP package
   └─ Upload artifact

2. Deploy Stage
   ├─ Download artifact
   ├─ Azure login
   ├─ Deploy to App Service
   ├─ Wait 30 seconds
   ├─ Health check (/health endpoint)
   └─ API test (/api/quote endpoint)

3. Notify Stage
   └─ Report success/failure
```

## ⚡ Performance

**Full deployment (with Terraform):** ~15-20 minutes
**Application-only deployment:** ~3-5 minutes

**Time saved:** ~12-15 minutes per deployment! 🚀

## 🧪 Testing

The workflow automatically tests:

1. **Health Endpoint**: `/health`
   - Verifies app is running
   - 12 attempts over 2 minutes

2. **API Endpoint**: `/api/quote`
   - Tests database connectivity
   - Checks response format

## 📊 Multi-Environment Support

Deploy to different environments:

### GitHub Actions
```bash
# Manual trigger allows selecting:
- production
- staging  
- development
```

### Azure DevOps
```bash
# Pipeline parameters allow selecting:
- production
- staging
- development
```

## 🔒 Security

✅ Uses service principal/connection for authentication
✅ No credentials in code
✅ Secrets stored in GitHub/Azure DevOps
✅ Production deployments can require approval
✅ Health checks verify successful deployment

## 🆘 Troubleshooting

### "App Service not found"
**Solution:** Verify App Service name in secrets/variables matches actual Azure resource

### "Health check failed"
**Solutions:**
- App Service may need more startup time
- Check Application Insights for errors
- Verify environment variables are set
- Check if database connection works

### "Package deployment failed"
**Solutions:**
- Verify service principal has permissions
- Check App Service is running
- Ensure deployment slot is available
- Check App Service logs

### "API test shows no data"
**Solution:** Database needs to be seeded. Run the seed script:
```bash
cd application/scripts
npm install
node seed-database.js
```

## 💡 Best Practices

✅ **Test locally first** before deploying
✅ **Use staging** environment for testing
✅ **Monitor logs** in Application Insights
✅ **Set up alerts** for failures
✅ **Enable auto-scaling** for production
✅ **Use deployment slots** for zero-downtime
✅ **Keep dependencies updated** regularly

## 🔄 Rollback

If deployment fails or has issues:

```bash
# In Azure Portal
App Service → Deployment Center → Deployment History
→ Select previous successful deployment
→ Click "Redeploy"
```

Or trigger workflow with previous commit.

## 📈 Monitoring After Deployment

1. **Application Insights**
   - Check request rates
   - Monitor response times
   - Review exceptions

2. **App Service Logs**
   ```bash
   az webapp log tail \
     --name <app-service-name> \
     --resource-group <resource-group>
   ```

3. **Manual Testing**
   - Visit application URL
   - Click "Get New Quote" button
   - Verify different quotes appear

## 🔗 Related Documentation

- [Full Deployment (with Terraform)](../.github/workflows/README.md)
- [Manual Deployment](DEPLOYMENT.md)
- [Application Structure](STRUCTURE.md)
- [Infrastructure Setup](../infrastructure/README.md)

## ⏭️ Next Steps

1. ✅ Deploy infrastructure first (if not already deployed)
2. ✅ Configure secrets/variables for app deployment
3. ✅ Run application deployment workflow
4. ✅ Verify application is working
5. ✅ Set up monitoring and alerts

---

**Quick Start:**
```bash
# 1. Get your App Service name
cd infrastructure
terraform output app_service_name

# 2. Add to GitHub Secrets or Azure DevOps Variables
# APP_SERVICE_NAME_PROD = <output-from-above>

# 3. Push code or trigger workflow manually
```

That's it! Your application will be deployed in ~3-5 minutes. 🚀
