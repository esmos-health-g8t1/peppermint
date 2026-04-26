variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
  default     = "esmos-healthcare-rg"
}

variable "aca_env_name" {
  description = "Name of the Container Apps Environment"
  type        = string
  default     = "esmos-env"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "image_tag" {
  description = "Tag for the docker image to deploy"
  type        = string
  default     = "latest"
}

variable "db_user" {
  description = "Dedicated Postgres user for Peppermint (least-privilege)"
  type        = string
  default     = "peppermint_user"
}

variable "db_password" {
  description = "Password for the dedicated Peppermint Postgres user"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "Host URL of the managed Postgres Flexible Server"
  type        = string
}

variable "secret_key" {
  description = "Secret key for Peppermint auth"
  type        = string
  sensitive   = true
  default     = "peppermint4life_override_in_prod"
}
