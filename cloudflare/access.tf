# SSH Access app
resource "cloudflare_access_application" "ssh" {
  zone_id          = var.cloudflare_zone_id
  name             = "SSH VM"
  domain           = "${var.ssh_host}.${var.root_domain}"
  type             = "ssh"
  session_duration = "24h"
}

resource "cloudflare_access_policy" "ssh_allow_domain" {
  application_id = cloudflare_access_application.ssh.id
  zone_id        = var.cloudflare_zone_id
  name           = "Allow ${var.allowed_email_domain}"
  decision       = "allow"

  include {
    email_domain = [var.allowed_email_domain]
  }
}

# Blue app
resource "cloudflare_access_application" "blue" {
  zone_id          = var.cloudflare_zone_id
  name             = "Blue App"
  domain           = "${var.blue_host}.${var.root_domain}"
  type             = "self_hosted"
  session_duration = "24h"
}

resource "cloudflare_access_policy" "blue_allow" {
  application_id = cloudflare_access_application.blue.id
  zone_id        = var.cloudflare_zone_id
  name           = "Allow ${var.allowed_email_domain}"
  decision       = "allow"

  include {
    email_domain = [var.allowed_email_domain]
  }
}

# Green app
resource "cloudflare_access_application" "green" {
  zone_id          = var.cloudflare_zone_id
  name             = "Green App"
  domain           = "${var.green_host}.${var.root_domain}"
  type             = "self_hosted"
  session_duration = "24h"
}

resource "cloudflare_access_policy" "green_allow" {
  application_id = cloudflare_access_application.green.id
  zone_id        = var.cloudflare_zone_id
  name           = "Allow ${var.allowed_email_domain}"
  decision       = "allow"

  include {
    email_domain = [var.allowed_email_domain]
  }
}
