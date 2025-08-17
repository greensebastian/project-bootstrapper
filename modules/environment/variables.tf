variable "domain" {
  description = "Domain the project belongs to."
  type        = string
}

variable "name" {
  description = "Name of the project."
  type        = string
}

variable "environment_name" {
  description = "Name of environment."
  type        = string
}

variable "administrators_group_object_id" {
  description = "Object id of security group of owners."
  type        = string
}

variable "users" {
  description = "Users involved in the project."
  type = object({
    contributors = set(string)
    readers      = set(string)
  })
}

variable "github_repository" {
  type = object({
    organization = string
    name         = string
  })
}
