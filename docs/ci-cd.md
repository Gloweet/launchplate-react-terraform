# CI/CD Setup with GitHub Actions and AWS

This document outlines how to set up CI/CD using GitHub Actions with AWS OIDC federation.

## GitHub Actions to AWS OIDC Authentication

### 1. Set up AWS IAM OIDC Provider

```bash
# Create the OIDC provider in AWS
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list "a031c46782e6e6c662c2c87c76da9aa62ccabd8e"
```

You get the following output:
```
{
  "OpenIDConnectProviderArn": "arn:aws:iam::AWS_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
}
### 2. Create IAM Role for GitHub Actions

Create an IAM role with the following trust policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<AWS_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:<GITHUB_ORG>/<REPO_NAME>:*"
        }
      }
    }
  ]
}
```
Replace `<AWS_ACCOUNT_ID>` with your AWS account ID, retrieved from the previous step.
Replace `<GITHUB_ORG>` and `<REPO_NAME>` with your GitHub organization and repository names.

You can also create the role using aws CLI:
```bin/sh
cd docs
aws iam create-role --role-name ReactLaunchplateGitHubActionsOIDCRole --assume-role-policy-document file://oidc-provider-role.json
```

As an output, we get:
```json
{
    "Role": {
        "Path": "/",
        "RoleName": "ReactLaunchplateGitHubActionsOIDCRole",
        "Arn": "arn:aws:iam::<AWS_ACCOUNT_ID>:role/ReactLaunchplateGitHubActionsOIDCRole",
        ...
    }
}
```

### 3. Attach Policies to Role

We need to attach the necessary policies to this role (e.g., S3FullAccess, CloudFrontFullAccess, Route53FullAccess, etc.)

First, we need to create the policy. Modify [oidc-provider-policy.json](oidc-provider-policy.json) by replacing `<PROJECT_NAME>` with your project name (e.g., `launchplate-react`) and `<AWS_ACCOUNT_ID>` with your AWS account ID.

```bin/sh
aws iam create-policy --policy-name ReactLaunchplateGitHubActionsOIDCRolePolicy --policy-document file://oidc-provider-policy.json
```

You get the following output:
```json
{
    "Policy": {
        "PolicyName": "ReactLaunchplateGitHubActionsOIDCRolePolicy",
        "Arn": "arn:aws:iam::<AWS_ACCOUNT_ID>:policy/ReactLaunchplateGitHubActionsOIDCRolePolicy",
        ...
    }
}
```

Then, we can attach the policy to the role:

```bin/sh
aws iam attach-role-policy --role-name ReactLaunchplateGitHubActionsOIDCRole --policy-arn arn:aws:iam::<AWS_ACCOUNT_ID>:policy/ReactLaunchplateGitHubActionsOIDCRolePolicy
```

### 3. GitHub Repository Secrets

1. See the Github repository variables & secrets to set in [.auto.tfvars.example](../terraform/bootstrap-github/.auto.tfvars.example).
2. Copy-paste the contents of [.auto.tfvars.example](../terraform/bootstrap-github/.auto.tfvars.example) into your own `.auto.tfvars` file.
3. Run `terraform init` to initialize the Terraform workspace.
4. Run `terraform apply` to push the variables and secrets to your Github repository.

To access the teams of the organization members, you need to create a PAT with the read:org scope.
1. Go to your Github account settings.
2. Click on "Developer settings".
3. Click on "Personal access tokens".
4. Click on "Tokens (classic)".
5. Click on "Generate new token".
6. Give the token a name and select the "read:org" scope.
7. Click on "Generate token".

## Passing Secrets to Terraform

### Method 1: Environment Variables

GitHub secrets can be passed to Terraform via environment variables:

```yaml
steps:
  - name: Apply Terraform
    env:
      TF_VAR_secret_value: ${{ secrets.SECRET_VALUE }}
    run: terraform apply
```

Add the following secrets:
- `CLOUDFLARE_API_TOKEN` with the value `{"prod":"myTokenProd","stg":"myTokenStg","dev":"myTokenDev"}`
- `AWS_ROLE_ARN`
- `SLACK_WEBHOOK_URL`

### Method 2: AWS Secrets Manager

For sensitive production values, use AWS Secrets Manager:

1. Store secrets in AWS Secrets Manager
2. Grant the GitHub Actions IAM role access to these secrets
3. Retrieve and use secrets in Terraform:

```hcl
data "aws_secretsmanager_secret" "example" {
  name = "my-secret"
}

data "aws_secretsmanager_secret_version" "example" {
  secret_id = data.aws_secretsmanager_secret.example.id
}

locals {
  secret_value = jsondecode(data.aws_secretsmanager_secret_version.example.secret_string)["key"]
}
```

## CI/CD Pipeline Overview

1. **CI Trigger**:
   - On push to environment branches (qa, staging, main)
   - On pull requests to these branches
   - Manual workflow dispatch

2. **CI Process**:
   - Run linting and tests
   - Build React application
   - Validate Terraform configurations

3. **CD Process**:
   - Plan Terraform changes
   - Apply Terraform changes (only on merge/push to environment branches)
   - Deploy the React application to S3
   - Invalidate CloudFront cache

4. **Post-Deployment**:
   - Send Slack notification on completion
