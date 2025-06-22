#!/bin/bash

# Explore terraform resources using terraform-rover
# cf. https://github.com/im2nguyen/rover

# Install terraform-rover:
# brew install terraform-rover

set -euo pipefail

echo "Checking terraform version:"
/opt/homebrew/bin/terraform --version

echo "Running terraform plan..."
terraform plan -out plan.out

echo "Running terraform-rover..."
terraform-rover -planPath plan.out -tfPath /opt/homebrew/bin/terraform

echo "Done."
