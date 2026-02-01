# Contributing to Azure Random Quotes Application

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Respect differing viewpoints and experiences

## How to Contribute

### Reporting Issues

1. **Search existing issues** first to avoid duplicates
2. **Use issue templates** when available
3. **Provide detailed information**:
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (Azure region, Terraform version, etc.)
   - Error messages and logs

### Suggesting Enhancements

1. **Check existing feature requests**
2. **Describe the use case** clearly
3. **Explain the benefits**
4. **Consider alternatives** you've explored

### Pull Requests

#### Before Submitting

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Test thoroughly**
5. **Update documentation**

#### Pull Request Guidelines

- **One feature per PR**: Keep changes focused
- **Follow coding standards**: Match existing code style
- **Write clear commit messages**:
  ```
  feat: Add geo-replication support
  fix: Correct connection string format
  docs: Update deployment guide
  ```
- **Include tests** where applicable
- **Update README** if needed

#### PR Checklist

- [ ] Code follows project style guidelines
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] Terraform validates successfully
- [ ] Application runs without errors
- [ ] No sensitive data (passwords, keys) in commits
- [ ] .gitignore updated if new file types added

## Development Setup

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd test
   ```

2. **Install dependencies**
   ```bash
   # Application
   cd app
   npm install
   
   # Scripts
   cd ../scripts
   npm install
   ```

3. **Configure environment**
   ```bash
   cp app/.env.example app/.env
   # Edit app/.env with your values
   ```

4. **Run locally**
   ```bash
   cd app
   npm start
   ```

### Testing Changes

#### Terraform Changes

```bash
cd terraform

# Format code
terraform fmt

# Validate
terraform validate

# Plan (without applying)
terraform plan
```

#### Application Changes

```bash
cd app

# Run locally
npm start

# Check for errors
npm run lint  # If linting configured
```

## Coding Standards

### Terraform

```hcl
# Use consistent naming
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project}-${var.environment}"
  location = var.location
  
  tags = local.common_tags
}

# Add comments for complex resources
# This creates a zone-redundant SQL database for high availability
resource "azurerm_mssql_database" "main" {
  # ...
}

# Use variables for reusable values
variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus2"
}
```

### JavaScript/Node.js

```javascript
// Use async/await
async function getQuote() {
  try {
    const result = await pool.request().query('SELECT...');
    return result.recordset[0];
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
}

// Use descriptive variable names
const quoteText = result.QuoteText;
const authorName = result.Author;

// Add comments for business logic
// Query for a random quote using SQL Server's NEWID() function
// which provides better randomization than JavaScript Math.random()
const query = 'SELECT TOP 1 * FROM Quotes ORDER BY NEWID()';
```

### Documentation

```markdown
# Clear headings

## Subsections with context

**Bold** for emphasis
`code` for inline code
\`\`\`bash
code blocks for commands
\`\`\`

- Bullet points for lists
- One item per line
```

## Security Guidelines

### Never Commit

- ❌ Passwords or API keys
- ❌ Connection strings
- ❌ `.env` files
- ❌ `terraform.tfvars` with real values
- ❌ Private keys or certificates

### Always

- ✅ Use `.env.example` templates
- ✅ Reference Key Vault for secrets
- ✅ Use parameterized SQL queries
- ✅ Validate and sanitize input
- ✅ Log securely (no sensitive data in logs)

## Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

### Examples

```
feat(terraform): Add geo-replication support

Implement active geo-replication for SQL Database to enable
cross-region disaster recovery.

Closes #123
```

```
fix(app): Correct connection pool timeout

Set appropriate timeout values to prevent connection exhaustion
under high load.

Fixes #456
```

## Review Process

### What Reviewers Look For

1. **Functionality**: Does it work as intended?
2. **Security**: Are there security implications?
3. **Performance**: Will it impact performance?
4. **Maintainability**: Is the code readable and maintainable?
5. **Documentation**: Is it properly documented?
6. **Testing**: Is it adequately tested?

### Responding to Feedback

- **Be receptive**: Feedback helps improve code quality
- **Ask questions**: If feedback is unclear, ask for clarification
- **Discuss**: Have constructive discussions about alternatives
- **Make changes**: Address feedback promptly
- **Learn**: Use feedback as a learning opportunity

## Release Process

1. **Version bump** in package.json
2. **Update CHANGELOG.md**
3. **Create release tag**
   ```bash
   git tag -a v1.1.0 -m "Release version 1.1.0"
   git push origin v1.1.0
   ```
4. **Create release notes** on GitHub

## Project Structure

```
quotes-app/
├── terraform/          # Infrastructure as Code
│   ├── main.tf        # Main Terraform configuration
│   ├── variables.tf   # Input variables
│   ├── outputs.tf     # Output values
│   └── *.tf          # Additional modules
├── app/               # Web application
│   ├── server.js     # Express server
│   ├── public/       # Static files
│   └── package.json  # Node.js dependencies
├── scripts/          # Utility scripts
│   └── seed-database.js
├── docs/             # Additional documentation
├── .github/          # GitHub configuration
│   └── workflows/    # CI/CD pipelines
└── README.md         # Main documentation
```

## Areas for Contribution

### High Priority

- [ ] CI/CD pipeline with GitHub Actions
- [ ] Automated testing suite
- [ ] Performance optimizations
- [ ] Additional security hardening

### Medium Priority

- [ ] Azure Front Door integration
- [ ] Multi-region deployment
- [ ] Enhanced monitoring dashboards
- [ ] Cost optimization analysis

### Low Priority

- [ ] Additional quote categories
- [ ] Quote submission feature
- [ ] Admin dashboard
- [ ] API rate limiting

## Getting Help

- **Documentation**: Check existing docs first
- **Issues**: Search for existing issues
- **Discussions**: Start a discussion for questions
- **Contact**: Reach out to maintainers

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing! 🎉
