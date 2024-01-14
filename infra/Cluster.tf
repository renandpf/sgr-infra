module "sgr-cluster" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = var.clusterName

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 1
      }
    }
  }
}