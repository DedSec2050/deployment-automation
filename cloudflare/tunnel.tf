resource "random_id" "tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_tunnel" "vm" {
  account_id = var.cloudflare_account_id
  name       = "${var.ssh_host}.${var.root_domain}"
  secret     = base64encode(random_id.tunnel_secret.b64_std)
}

resource "cloudflare_tunnel_config" "vm" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.vm.id

  config {
    ingress_rule {
      hostname = "${var.ssh_host}.${var.root_domain}"
      service  = "ssh://localhost:22"
    }
    ingress_rule {
      hostname = "${var.blue_host}.${var.root_domain}"
      service  = "http://localhost:3030"
    }
    ingress_rule {
      hostname = "${var.green_host}.${var.root_domain}"
      service  = "http://localhost:4040"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}
