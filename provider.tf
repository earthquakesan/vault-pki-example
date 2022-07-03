terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.7.0"
    }
  }
}

provider "vault" {
  # Set token via VAULT_TOKEN env var
  # Set address via VAULT_ADDR
}