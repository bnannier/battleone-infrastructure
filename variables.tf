# Variables for BattleOne Infrastructure

variable "digitalocean_token" {
  description = "DigitalOcean API Token"
  type        = string
  sensitive   = true
}

variable "spaces_access_key" {
  description = "DigitalOcean Spaces Access Key"
  type        = string
  sensitive   = true
}

variable "spaces_secret_key" {
  description = "DigitalOcean Spaces Secret Key"
  type        = string
  sensitive   = true
}

variable "ssh_private_key" {
  description = "Private SSH key for droplet access"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Public SSH key for droplet access"
  type        = string
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "tor1"
}

variable "droplet_size" {
  description = "Droplet size"
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "postgres_user" {
  description = "PostgreSQL user"
  type        = string
  default     = "battleone_user"
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
  default     = "battleone"
}

variable "redis_password" {
  description = "Redis password"
  type        = string
  sensitive   = true
}