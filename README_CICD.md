# CI/CD Setup - Quick Start Guide

## 🚀 Quick Setup (5 minutes)

### Step 1: Initialize Git (if not already done)

```bash
# Navigate to your project directory
cd c:\Users\adars\Desktop\bigDataProjects\netfilxdbt\netfilx

# Initialize git repository
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit with CI/CD setup"
```

### Step 2: Create GitHub Repository

1. Go to [GitHub](https://github.com) and create a new repository
2. Don't initialize with README (you already have one)
3. Copy the repository URL

### Step 3: Push to GitHub

```bash
# Add remote origin
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Push to GitHub
git push -u origin main
```

### Step 4: Configure GitHub Secrets

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each of these secrets:

| Secret Name | Example Value | Description |
|------------|---------------|-------------|
| `SNOWFLAKE_ACCOUNT` | `xy12345.us-east-1` | Your Snowflake account identifier |
| `SNOWFLAKE_USER` | `dbt_service_user` | Snowflake username |
| `SNOWFLAKE_PASSWORD` | `SecurePassword123!` | Snowflake password |
| `SNOWFLAKE_ROLE` | `TRANSFORMER` | Snowflake role |
| `SNOWFLAKE_DATABASE` | `MOVIELENS` | Your database name |
| `SNOWFLAKE_WAREHOUSE` | `TRANSFORMING` | Snowflake warehouse |
| `SNOWFLAKE_SCHEMA` | `ANALYTICS` | Production schema name |

**How to find your Snowflake account identifier:**
```sql
-- Run this in Snowflake
SELECT CURRENT_ACCOUNT();
SELECT CURRENT_REGION();
```

Your account identifier is typically: `ACCOUNT_LOCATOR.REGION` (e.g., `xy12345.us-east-1`)

### Step 5: Test CI/CD

1. Create a new branch:
   ```bash
   git checkout -b test-ci-cd
   ```

2. Make a small change to any model file

3. Commit and push:
   ```bash
   git add .
   git commit -m "Test CI/CD pipeline"
   git push origin test-ci-cd
   ```

4. Go to GitHub and create a Pull Request

5. Watch the CI pipeline run! Go to **Actions** tab to see progress

### Step 6: Deploy to Production

1. Merge your PR to main
2. The production workflow will automatically run
3. Check the **Actions** tab to monitor deployment

## 📋 What Each Workflow Does

### 1. **dbt CI** (`dbt_ci.yml`)
- **Triggers**: On pull requests
- **Purpose**: Test changes before merging
- **Creates**: Isolated schema per PR (`ANALYTICS_CI_123`)
- **Runs**: compile → seed → run → test

### 2. **dbt Production** (`dbt_prod.yml`)
- **Triggers**: On merge to main
- **Purpose**: Deploy to production
- **Schema**: Production schema (`ANALYTICS`)
- **Runs**: seed → snapshot → run → test → docs

### 3. **dbt Slim CI** (`dbt_slim_ci.yml`)
- **Triggers**: On pull requests (optional, faster)
- **Purpose**: Only test modified models
- **Benefit**: Faster CI for large projects

## 🔧 Customization

### Change Schedule (Add Scheduled Runs)

Create `.github/workflows/dbt_scheduled.yml`:

```yaml
name: dbt Scheduled Run

on:
  schedule:
    - cron: '0 8 * * *'  # Every day at 8 AM UTC
  workflow_dispatch:      # Manual trigger

jobs:
  # ... use the same job config as dbt_prod.yml
```

### Multiple Environments

Add staging environment to secrets with prefix:
- `SNOWFLAKE_STAGING_ACCOUNT`
- `SNOWFLAKE_STAGING_USER`
- etc.

### Slack Notifications

Add to the end of each workflow job:

```yaml
- name: Slack Notification
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## 🛠️ Alternative CI/CD Platforms

### GitLab CI/CD

Create `.gitlab-ci.yml`:

```yaml
stages:
  - test
  - deploy

dbt_test:
  stage: test
  image: python:3.11
  script:
    - pip install dbt-snowflake
    - dbt deps
    - dbt run
    - dbt test
  only:
    - merge_requests

dbt_deploy:
  stage: deploy
  image: python:3.11
  script:
    - pip install dbt-snowflake
    - dbt deps
    - dbt run --target prod
    - dbt test --target prod
  only:
    - main
```

### Azure DevOps

Create `azure-pipelines.yml`:

```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: UsePythonVersion@0
  inputs:
    versionSpec: '3.11'
    
- script: |
    pip install dbt-snowflake
    dbt deps
    dbt run
    dbt test
  displayName: 'Run dbt'
```

## 📊 Monitoring & Alerts

### Add to GitHub Actions for email alerts:

Settings → Actions → General → Enable "Send notifications for failed workflows"

### Monitor in Snowflake:

```sql
-- View recent dbt runs
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE USER_NAME = 'DBT_SERVICE_USER'
  AND START_TIME > DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY START_TIME DESC;
```

## 🔒 Security Best Practices

1. ✅ Use service accounts, not personal accounts
2. ✅ Rotate credentials every 90 days
3. ✅ Use least privilege access (specific roles)
4. ✅ Enable MFA on Snowflake accounts
5. ✅ Review GitHub Actions logs for sensitive data
6. ✅ Use GitHub environment protection rules

## 📚 Next Steps

1. ✅ Set up CI/CD (you're here!)
2. Configure data quality tests
3. Set up dbt documentation hosting
4. Add more sophisticated scheduling
5. Integrate with data observability tools (Monte Carlo, Datafold)
6. Set up data lineage visualization

## 🆘 Troubleshooting

### "Could not find profile"
- Ensure secrets are set correctly in GitHub
- Check the `profiles.yml` generation in workflow

### "Connection failed"
- Verify Snowflake account identifier format
- Check network policies in Snowflake
- Ensure user has correct permissions

### "Package installation failed"
- Check `packages.yml` syntax
- Verify package versions are compatible

### "Model compilation failed"
- Run `dbt compile` locally first
- Check model SQL syntax
- Verify source tables exist

## 📞 Support

- [dbt Slack Community](https://www.getdbt.com/community/join-the-community/)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Snowflake Support](https://community.snowflake.com/)
