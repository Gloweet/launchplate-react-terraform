# GitHub repository variables and secrets configuration

# Use data source to get the repository
data "github_repository" "repo" {
  name = var.repository_name
}

# Create repository secrets
resource "github_actions_secret" "slack_webhook_url" {
  repository      = data.github_repository.repo.name
  secret_name     = "SLACK_WEBHOOK_URL"
  plaintext_value = var.slack_webhook_url
}

resource "github_actions_secret" "aws_role_arn" {
  repository      = data.github_repository.repo.name
  secret_name     = "AWS_ROLE_ARN"
  plaintext_value = var.aws_role_arn
}

# Create Cloudflare API token secrets for different environments
resource "github_actions_secret" "cloudflare_api_token" {
  repository  = data.github_repository.repo.name
  secret_name = "CLOUDFLARE_API_TOKEN"
  plaintext_value = jsonencode({
    prod = var.cloudflare_api_token_prod
    stg  = var.cloudflare_api_token_stg
    dev  = var.cloudflare_api_token_dev
  })
}

# Optional: Add additional repository variables if needed
# For example:
# resource "github_actions_variable" "example_variable" {
#   repository    = data.github_repository.repo.name
#   variable_name = "EXAMPLE_VARIABLE"
#   value         = var.example_variable
# }
