resource "cloudflare_record" "ssh" {
  zone_id = var.cloudflare_zone_id
  name    = var.ssh_host
  type    = "CNAME"
  content = cloudflare_tunnel.vm.cname
  proxied = true
}

resource "cloudflare_record" "blue" {
  zone_id = var.cloudflare_zone_id
  name    = var.blue_host
  type    = "CNAME"
  content = cloudflare_tunnel.vm.cname
  proxied = true
}

resource "cloudflare_record" "green" {
  zone_id = var.cloudflare_zone_id
  name    = var.green_host
  type    = "CNAME"
  content = cloudflare_tunnel.vm.cname
  proxied = true
}
