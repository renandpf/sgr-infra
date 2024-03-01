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

    sgr-pedido-service-nome-repositorio = "sgr-pedido-repo"
    sgr-pedido-service-db-username = "root"
    sgr-pedido-service-db-password = "senha123"

    aws-access-key-id = "ASIA6ODU67LHWSD2WYXV"
    aws-secret-access-key = "Jsp7X6NbGBRQfOcw7C+aIYyrp31Zet+GvLTCh2m2"
    aws-session-token = "FwoGZXIvYXdzEEsaDKD/ksfzd8UvFeoKQSLGAbBk/E4C8jc3qJ3bNjL48iPh/HaVsnAy1atOqq81uVPTp5KOsD+r190v3mZsO+9SikQNMq17A+OBaFaOWLQtYsZhRFiJJsNQ5+ziG/vNykNGUDKqsghHh+0ZIewGn7iMaDBpavZ7pCdmq9v2PqCdNjdLmV82lzqaSJgaW3Wk2x1CFMNrq4W8p9NH/xwO4wPUTzT/NtD1/eXINn8oAbFLm1szN8/GZF45UqsdLsq0JMpx+DEb2B6cFCqktiMiKPf76KGi5vDNfCimpYivBjItT0xclL9CWJ9oUUy+U//0SpmdpDaSyaclTIXuM0H8Lzkb9meEzKG2OJ9SnbDe"
}