output "tunnel_cname" {
  value = cloudflare_tunnel.vm.cname
}

output "tunnel_id" {
  value = cloudflare_tunnel.vm.id
}

output "tunnel_token" {
  value     = cloudflare_tunnel.vm.tunnel_token
  sensitive = true
}

output "ssh_fqdn" {
  value = cloudflare_record.ssh.hostname
}

output "blue_fqdn" {
  value = cloudflare_record.blue.hostname
}

output "green_fqdn" {
  value = cloudflare_record.green.hostname
}
