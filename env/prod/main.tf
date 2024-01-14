module "prod" {
    source = "../../infra"
    ambiente = "producao"
    clusterName = "sgr-cluster-prd"
    sgr-gerencial-service-nome-repositorio = "sgr-gerencial-repo"
    sgr-gerencial-service-db-username = "root"
    sgr-gerencial-service-db-password = "senha123"

    sgr-pagamento-service-nome-repositorio = "sgr-pagamento-repo"
    sgr-pagamento-service-db-username = "root"
    sgr-pagamento-service-db-password = "senha123"
}

# output "IP_alb" {
#   value = module.prod.IP
# }