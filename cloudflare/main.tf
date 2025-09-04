# enforce TLS strict mode
resource "cloudflare_zone_settings_override" "tls" {
  zone_id = var.cloudflare_zone_id
  settings {
    ssl = "strict"
  }
}
