# BattleOne Infrastructure - Terraform Outputs

output "droplet_ip" {
  description = "IP address of the infrastructure droplet"
  value       = digitalocean_droplet.battleone_infrastructure.ipv4_address
}

output "droplet_id" {
  description = "ID of the infrastructure droplet"
  value       = digitalocean_droplet.battleone_infrastructure.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = digitalocean_vpc.battleone_vpc.id
}

output "volume_id" {
  description = "ID of the data volume"
  value       = digitalocean_volume.battleone_data.id
}

output "ssh_key_id" {
  description = "ID of the SSH key"
  value       = digitalocean_ssh_key.battleone_key.id
}

output "firewall_id" {
  description = "ID of the firewall"
  value       = digitalocean_firewall.battleone_firewall.id
}

output "postgres_connection_string" {
  description = "PostgreSQL connection string (internal network)"
  value       = "postgres://${var.postgres_user}:${var.postgres_password}@postgres:5432/${var.postgres_db}"
  sensitive   = true
}

output "redis_connection_string" {
  description = "Redis connection string (internal network)"
  value       = "redis://:${var.redis_password}@redis:6379/0"
  sensitive   = true
}

output "kratos_public_url" {
  description = "Kratos public API URL (internal network)"
  value       = "http://kratos:4433"
}

output "kratos_admin_url" {
  description = "Kratos admin API URL (internal network)"
  value       = "http://kratos:4434"
}

output "kratos_health_url" {
  description = "Kratos health check URL (external)"
  value       = "http://${digitalocean_droplet.battleone_infrastructure.ipv4_address}:4433/health/ready"
}