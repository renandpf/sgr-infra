module "prod" {
    source = "../../infra"
    nome_repositorio = "sgr-service-spring"
    cargoIAM = "producao"
    ambiente = "producao"
    secret-token = "5Evk0PWG3Xb81q0fP3Q6zb5pTs0VOScDkoE28qjG4UbzHgp7v64lI5NXzVZeJxBdWF4yZ1LQSiaX3IGcDxua2BcfxV9tmWbSrCov"
    token-expiration-time-seconds = "1200"
    sgr-security-db-username = "root"
    sgr-security-db-password = "senha123"
    sgr-service-db-username = "root"
    sgr-service-db-password = "senha123"
}

output "IP_alb" {
  value = module.prod.IP
}