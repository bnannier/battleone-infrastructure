# Outputs for BattleOne Infrastructure

output "droplet_ip" {
  description = "Public IP address of the BattleOne droplet"
  value       = digitalocean_droplet.battleone_droplet.ipv4_address
}

output "droplet_private_ip" {
  description = "Private IP address of the BattleOne droplet"
  value       = digitalocean_droplet.battleone_droplet.ipv4_address_private
}

output "postgres_connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${var.postgres_user}:${var.postgres_password}@${digitalocean_droplet.battleone_droplet.ipv4_address_private}:5432/${var.postgres_db}"
  sensitive   = true
}

output "redis_connection_string" {
  description = "Redis connection string"
  value       = "redis://:${var.redis_password}@${digitalocean_droplet.battleone_droplet.ipv4_address_private}:6379"
  sensitive   = true
}

output "kratos_public_url" {
  description = "Kratos public API URL"
  value       = "http://${digitalocean_droplet.battleone_droplet.ipv4_address}:4433"
}

output "kratos_admin_url" {
  description = "Kratos admin API URL"
  value       = "http://${digitalocean_droplet.battleone_droplet.ipv4_address_private}:4434"
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh root@${digitalocean_droplet.battleone_droplet.ipv4_address}"
}