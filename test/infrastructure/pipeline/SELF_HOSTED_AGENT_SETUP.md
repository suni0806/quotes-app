# Self-Hosted Agent Setup Guide

This guide will help you set up a self-hosted Azure DevOps agent to run your pipelines without needing Microsoft-hosted parallelism.

## Prerequisites

- Azure DevOps organization and project access
- A machine (Windows, Linux, or macOS) to host the agent
- Administrator/sudo access on the host machine
- Internet connectivity

## Step 1: Create an Agent Pool in Azure DevOps

1. Navigate to your Azure DevOps organization: `https://dev.azure.com/{your-organization}`
2. Go to **Organization Settings** (bottom left corner)
3. Under **Pipelines**, click **Agent pools**
4. Click **Add pool**
5. Select **Self-hosted** as the pool type
6. Name it `Default` (or another name - update the pipeline YAML if you use a different name)
7. Grant access permission to all pipelines (recommended for testing)
8. Click **Create**

## Step 2: Generate a Personal Access Token (PAT)

1. Click on your profile icon (top right) → **Personal access tokens**
2. Click **+ New Token**
3. Configure the token:
   - **Name**: `Self-Hosted Agent`
   - **Organization**: Select your organization
   - **Expiration**: Choose appropriate duration (90 days recommended)
   - **Scopes**: Select **Agent Pools (read, manage)**
4. Click **Create**
5. **IMPORTANT**: Copy the token immediately - you won't be able to see it again!

## Step 3: Download and Configure the Agent

### For Windows:

**Option 1: Download from GitHub (Recommended if CDN is blocked)**

```powershell
# Create a directory for the agent
mkdir C:\azagent
cd C:\azagent

# Download the latest agent from GitHub releases
# Visit https://github.com/microsoft/azure-pipelines-agent/releases to get the latest version
$agentVersion = "3.248.0"  # Update this to the latest version
Invoke-WebRequest -Uri "https://github.com/microsoft/azure-pipelines-agent/releases/download/v$agentVersion/vsts-agent-win-x64-$agentVersion.zip" -OutFile "agent.zip"

# Extract the agent
Expand-Archive -Path "agent.zip" -DestinationPath .

# Configure the agent
.\config.cmd
```

**Option 2: Manual Download (If PowerShell download fails)**

1. Open your browser and go to: https://github.com/microsoft/azure-pipelines-agent/releases
2. Download the latest `vsts-agent-win-x64-*.zip` file
3. Create folder `C:\azagent` and extract the zip file there
4. Open PowerShell in `C:\azagent` and run `.\config.cmd`

**Option 3: Azure CDN (Original method)**

```powershell
# This may fail if your network blocks the CDN
Invoke-WebRequest -Uri "https://vstsagentpackage.azureedge.net/agent/3.248.0/vsts-agent-win-x64-3.248.0.zip" -OutFile "agent.zip"
```

### For Linux/Ubuntu:

```bash
# Create a directory for the agent
mkdir ~/azagent && cd ~/azagent

# Download the agent (check for latest version)
wget https://vstsagentpackage.azureedge.net/agent/3.236.1/vsts-agent-linux-x64-3.236.1.tar.gz

# Extract the agent
tar zxvf vsts-agent-linux-x64-3.236.1.tar.gz

# Configure the agent
./config.sh
```

### For macOS:

```bash
# Create a directory for the agent
mkdir ~/azagent && cd ~/azagent

# Download the agent
curl -O https://vstsagentpackage.azureedge.net/agent/3.236.1/vsts-agent-osx-x64-3.236.1.tar.gz

# Extract the agent
tar zxvf vsts-agent-osx-x64-3.236.1.tar.gz

# Configure the agent
./config.sh
```

## Step 4: Configure the Agent (Interactive Prompts)

When you run the config script, you'll be prompted for:

1. **Server URL**: `https://dev.azure.com/{your-organization}`
2. **Authentication type**: Press Enter for PAT
3. **Personal access token**: Paste the PAT you created earlier
4. **Agent pool**: Enter `Default` (or the name you created)
5. **Agent name**: Press Enter for default or provide a custom name
6. **Work folder**: Press Enter for default (`_work`)
7. **Run as service**: 
   - Windows: `Y` (recommended)
   - Linux/macOS: `Y` if you want it to run automatically

## Step 5: Start the Agent

### Run as Interactive Process (for testing):

**Windows:**
```powershell
.\run.cmd
```

**Linux/macOS:**
```bash
./run.sh
```

### Run as Service (recommended for production):

**Windows:**
```powershell
# The service is automatically installed if you chose 'Y' during configuration
# Check service status in Services app or:
Get-Service vstsagent*
```

**Linux (systemd):**
```bash
sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh status
```

**macOS:**
```bash
./svc.sh install
./svc.sh start
./svc.sh status
```

## Step 6: Install Required Dependencies

Your pipeline uses Terraform and Azure CLI. Install these on your agent machine:

### Terraform:

**Windows (using Chocolatey):**
```powershell
choco install terraform
```

**Linux:**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**macOS:**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

### Azure CLI:

**Windows:**
```powershell
# Download and run the MSI installer from:
# https://aka.ms/installazurecliwindows
```

**Linux:**
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

**macOS:**
```bash
brew update && brew install azure-cli
```

## Step 7: Verify Agent is Online

1. Go to Azure DevOps → **Organization Settings** → **Agent pools**
2. Click on your pool (`Default`)
3. Go to the **Agents** tab
4. You should see your agent listed with a green status indicator

## Step 8: Update Pipeline Configuration

The pipeline has already been updated to use the self-hosted pool. Verify the pool name matches:

```yaml
pool:
  name: 'Default'  # Change this if you used a different pool name
```

## Troubleshooting

### Agent Not Appearing Online
- Check if the agent service is running
- Verify PAT has correct permissions and hasn't expired
- Check firewall settings (agent needs outbound HTTPS access)

### Pipeline Fails with Missing Tools
- Ensure Terraform and Azure CLI are installed on the agent machine
- Verify the tools are in the system PATH
- Restart the agent service after installing new tools

### Permission Issues
- Ensure the agent service account has necessary permissions
- On Linux/macOS, check file permissions in the agent directory

### Service Connection Issues
- Verify your Azure service connections are configured in Azure DevOps
- Check that service principals have appropriate permissions

## Additional Resources

- [Azure DevOps Self-hosted Agents Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/agents)
- [Latest Agent Releases](https://github.com/microsoft/azure-pipelines-agent/releases)
- [Terraform Installation Guide](https://developer.hashicorp.com/terraform/install)
- [Azure CLI Installation Guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

## Security Best Practices

1. **Rotate PATs regularly** - Set expiration dates and renew before expiry
2. **Limit agent pool access** - Only grant access to necessary pipelines
3. **Keep agents updated** - Regularly update the agent software
4. **Secure the host machine** - Apply security patches and use firewalls
5. **Use dedicated machines** - Don't run agents on development machines in production
