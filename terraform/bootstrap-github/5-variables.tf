# Variables for GitHub repository configuration

variable "github_token" {
  description = "GitHub personal access token with repository permissions"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub owner (organization or username)"
  type        = string
}

variable "repository_name" {
  description = "Name of the GitHub repository"
  type        = string
  default     = "launchplate-react"
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  sensitive   = true
  default     = "https://hooks.slack.com/services/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"
}

variable "aws_role_arn" {
  description = "AWS IAM role ARN for GitHub Actions OIDC"
  type        = string
  sensitive   = true
  default     = "arn:aws:iam:::role/ReactLaunchplateGitHubActionsOIDCRole"
}

variable "cloudflare_api_token_prod" {
  description = "Cloudflare API token for production environment"
  type        = string
  sensitive   = true
  default     = "myTokenProd"
}

variable "cloudflare_api_token_stg" {
  description = "Cloudflare API token for staging environment"
  type        = string
  sensitive   = true
  default     = "myTokenStg"
}

variable "cloudflare_api_token_dev" {
  description = "Cloudflare API token for development environment"
  type        = string
  sensitive   = true
  default     = "myTokenDev"
}
