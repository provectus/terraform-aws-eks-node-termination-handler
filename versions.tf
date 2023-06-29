terraform {
  required_version = ">= 1.1"

  required_providers {
    aws        = ">= 4.0.0"
    helm       = ">= 2.0.0"
    kubernetes = ">= 2.0.0"
  }
}
