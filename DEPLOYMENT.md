# dbt Project Deployment Guide

This document explains how to deploy the dbt project and use the CI/CD pipelines.

## Prerequisites

1. **Git Repository**: Your project should be in a Git repository (GitHub, GitLab, etc.)
2. **Snowflake Account**: Active Snowflake account with appropriate permissions
3. **CI/CD Platform**: GitHub Actions (already configured) or alternative

## Deployment Options

### Option 1: GitHub Actions (Recommended)

#### Setup Steps:

1. **Push your code to GitHub**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin <your-github-repo-url>
   git push -u origin main
   ```

2. **Configure GitHub Secrets**:
   Go to your GitHub repository → Settings → Secrets and variables → Actions → New repository secret

   Add the following secrets:
   - `SNOWFLAKE_ACCOUNT`: Your Snowflake account identifier (e.g., `xy12345.us-east-1`)
   - `SNOWFLAKE_USER`: Snowflake username
   - `SNOWFLAKE_PASSWORD`: Snowflake password
   - `SNOWFLAKE_ROLE`: Snowflake role (e.g., `TRANSFORMER`)
   - `SNOWFLAKE_DATABASE`: Database name (e.g., `MOVIELENS`)
   - `SNOWFLAKE_WAREHOUSE`: Warehouse name (e.g., `TRANSFORMING`)
   - `SNOWFLAKE_SCHEMA`: Schema name (e.g., `ANALYTICS`)

3. **Configure GitHub Environment** (Optional but recommended):
   - Go to Settings → Environments
   - Create a "production" environment
   - Add protection rules (e.g., require approval before deployment)

#### Workflows Included:

1. **dbt_ci.yml**: Runs on pull requests
   - Creates isolated CI schema per PR
   - Runs dbt compile, run, and test
   - Uploads artifacts for review

2. **dbt_prod.yml**: Runs on merge to main
   - Deploys to production schema
   - Runs seeds, snapshots, models, and tests
   - Archives artifacts for 30 days

3. **dbt_slim_ci.yml**: Optimized CI (optional)
   - Only runs modified models and their downstream dependencies
   - Faster CI runs for large projects

### Option 2: dbt Cloud

dbt Cloud is a managed solution that handles deployment, scheduling, and monitoring.

#### Setup Steps:

1. Sign up at [cloud.getdbt.com](https://cloud.getdbt.com)
2. Connect your GitHub repository
3. Configure Snowflake connection
4. Create deployment environments (Dev, Staging, Prod)
5. Set up jobs and schedules

**Advantages**:
- No infrastructure management
- Built-in IDE and documentation hosting
- Advanced monitoring and alerting
- Easy scheduling

### Option 3: Manual Deployment

For simpler deployments or development:

1. **Install dbt locally**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install dbt-snowflake
   ```

2. **Configure profiles.yml** (`~/.dbt/profiles.yml`):
   ```yaml
   netfilx:
     target: dev
     outputs:
       dev:
         type: snowflake
         account: YOUR_ACCOUNT
         user: YOUR_USER
         password: YOUR_PASSWORD
         role: YOUR_ROLE
         database: YOUR_DATABASE
         warehouse: YOUR_WAREHOUSE
         schema: YOUR_SCHEMA_DEV
         threads: 4
       
       prod:
         type: snowflake
         account: YOUR_ACCOUNT
         user: YOUR_USER
         password: YOUR_PASSWORD
         role: YOUR_ROLE
         database: YOUR_DATABASE
         warehouse: YOUR_WAREHOUSE
         schema: YOUR_SCHEMA_PROD
         threads: 8
   ```

3. **Deploy to production**:
   ```bash
   dbt deps
   dbt seed --target prod
   dbt snapshot --target prod
   dbt run --target prod
   dbt test --target prod
   dbt docs generate --target prod
   ```

## Best Practices

### 1. Environment Strategy

- **Dev**: Personal development schema for each developer
- **CI**: Ephemeral schemas for pull request testing
- **Staging**: Pre-production environment for final testing
- **Prod**: Production environment

### 2. Git Workflow

```
feature-branch → PR → CI runs → Code review → Merge to main → Production deploy
```

### 3. Schema Naming Convention

- Dev: `ANALYTICS_DEV_<username>`
- CI: `ANALYTICS_CI_<pr_number>`
- Prod: `ANALYTICS`

### 4. Security

- Never commit `profiles.yml` or credentials
- Use environment variables or secrets management
- Rotate credentials regularly
- Use service accounts for CI/CD

### 5. Monitoring

- Set up Snowflake query monitoring
- Monitor GitHub Actions run times
- Track dbt test failures
- Review data freshness

## Scheduling Production Runs

### GitHub Actions (Scheduled)

Add to `.github/workflows/dbt_scheduled.yml`:

```yaml
on:
  schedule:
    - cron: '0 6 * * *'  # Run at 6 AM UTC daily
```

### dbt Cloud

Configure job schedules in the UI with cron expressions.

### Airflow/Dagster

For more complex orchestration:
- Use dbt Core with Airflow DAGs
- Use Dagster with dbt integration
- Trigger dbt via REST API

## Troubleshooting

### Common Issues:

1. **Connection Failed**: Check Snowflake credentials in secrets
2. **Package Installation Failed**: Verify `packages.yml` syntax
3. **Model Compilation Failed**: Check SQL syntax and ref() calls
4. **Tests Failed**: Review test configurations and data quality

### Debug Commands:

```bash
dbt debug                    # Test connection
dbt compile --select model_name  # Compile specific model
dbt run-operation list_schemas   # List available schemas
dbt ls --select state:modified+  # Show modified models
```

## Additional Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [dbt Discourse Community](https://discourse.getdbt.com/)
- [Snowflake + dbt Guide](https://docs.getdbt.com/reference/warehouse-setups/snowflake-setup)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## Next Steps

1. Set up GitHub repository and secrets
2. Test CI/CD workflow with a sample PR
3. Configure production deployment schedule
4. Set up monitoring and alerts
5. Document your specific deployment process
