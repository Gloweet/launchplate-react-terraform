# Outputs from the GitHub repository configuration

output "repository_name" {
  description = "The name of the GitHub repository"
  value       = data.github_repository.repo.name
}

output "repository_html_url" {
  description = "The HTML URL of the GitHub repository"
  value       = data.github_repository.repo.html_url
}

output "slack_webhook_url_secret_created" {
  description = "Confirmation that the Slack webhook URL secret was created"
  value       = github_actions_secret.slack_webhook_url.secret_name
  sensitive   = false
}

output "aws_role_arn_secret_created" {
  description = "Confirmation that the AWS role ARN secret was created"
  value       = github_actions_secret.aws_role_arn.secret_name
  sensitive   = false
}

output "cloudflare_api_token_secret_created" {
  description = "Confirmation that the Cloudflare API token secret was created"
  value       = github_actions_secret.cloudflare_api_token.secret_name
  sensitive   = false
}
