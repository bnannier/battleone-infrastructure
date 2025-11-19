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

variable "laptop_ssh_public_key" {
  description = "Laptop SSH public key for additional access"
  type        = string
  default     = ""
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

variable "datadog_api_key" {
  description = "Datadog API Key for monitoring (deprecated - use Better Stack)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "datadog_site" {
  description = "Datadog site (deprecated - use Better Stack)"
  type        = string
  default     = "datadoghq.com"
}

# Better Stack monitoring variables
variable "betterstack_source_token" {
  description = "Better Stack source token for log ingestion"
  type        = string
  sensitive   = true
}

variable "betterstack_ingestion_host" {
  description = "Better Stack ingestion host (e.g., in.logs.betterstack.com)"
  type        = string
  default     = "in.logs.betterstack.com"
}