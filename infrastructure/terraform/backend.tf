# ============================================================================
# Setup: Remote Backend Configuration
# Uses the S3 bucket and DynamoDB table created in setup 
# ============================================================================
# Provide backend values via backend-config.hcl (git-ignored).
# Run: terraform init -backend-config=backend-config.hcl
# ============================================================================

terraform {
  backend "s3" {
    encrypt = true
  }
}