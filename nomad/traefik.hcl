job "betamax" {
  datacenters = ["dc1"]

  task "web" {
    driver = "docker"

    config {
      image = "seqvence/static-site"

      port_map {
        web = 80
      }
    }

    service {
      name = "betamax"
      port = "web"

      tags = [
        "traefik.frontend.entrypoints=http",
        "traefik.frontend.backend=${NOMAD_JOB_NAME}",
        "traefik.frontend.passHostHeader=true",
        "traefik.frontend.rule=Host:${NOMAD_JOB_NAME}.chinook.aws.wescale.fr",
        "traefik.backends.${NOMAD_JOB_NAME}.servers.${NOMAD_JOB_NAME}_0.url=http://${NOMAD_ADDR_web}/",
        "traefik.tags=public"
      ]

      check {
        type     = "tcp"
        port     = "web"
        interval = "10s"
        timeout  = "2s"
      }
    }

    resources {
      cpu    = 200
      memory = 200

      network {
        mbits = 50

        port "web" {}
      }
    }
  }
}