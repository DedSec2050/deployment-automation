variable "cloudflare_api_token" { type = string }
variable "cloudflare_account_id" { type = string }
variable "cloudflare_zone_id" { type = string }
variable "root_domain" { type = string }

variable "ssh_host"   { 
    type = string 
    default = "ssh" 
}

variable "blue_host"  { 
    type = string 
    default = "blue" 
}

variable "green_host" { 
    type = string 
    default = "green" 
}

variable "allowed_email_domain" { 
    type = string 
    default = "200630.xyz" 
}
