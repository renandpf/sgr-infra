terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      #LAST -> 5.22.0
      # version = "~> 3.27" 
      version = "~> 5.22.0"

    }
  }
  #LAST 1.6.2
  # required_version = ">= 0.14.9" 
  required_version = ">= 1.6.2"
}

provider "aws" {
  profile = "pupposoft"
  region  = "us-west-2"
}
