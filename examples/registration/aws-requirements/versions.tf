terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # The requirements modules only create IAM and read the caller identity,
      # so they carry no v6-specific behaviour. Deliberately looser than
      # deployment/ (~> 6.0) to avoid forcing a provider upgrade on an
      # infrastructure repo that installs this alongside other services.
      version = ">= 5.0"
    }
  }
}
