# BattleOne Infrastructure - Terraform Variables

variable "digitalocean_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "ssh_private_key" {
  description = "SSH private key for droplet access"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for droplet access"
  type        = string
}

variable "region" {
  description = "DigitalOcean region for resources"
  type        = string
  default     = "nyc1"
}

variable "droplet_size" {
  description = "Size of the DigitalOcean droplet"
  type        = string
  default     = "s-2vcpu-2gb"
}

# Database Configuration
variable "postgres_password" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
  default     = "battleone"
}

variable "postgres_user" {
  description = "PostgreSQL username"
  type        = string
  default     = "battleone_user"
}

variable "redis_password" {
  description = "Redis cache password"
  type        = string
  sensitive   = true
}

variable "kratos_log_level" {
  description = "Kratos logging level"
  type        = string
  default     = "warn"
}