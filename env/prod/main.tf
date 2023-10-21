module "prod" {
    source = "../../infra"
    nome_repositorio = "sgr-service-spring"
    cargoIAM = "producao"
    ambiente = "producao"
}

output "IP_alb" {
  value = module.prod.IP
}