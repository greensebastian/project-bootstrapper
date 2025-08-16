variable "domain" {
  description = "Domain the project belongs to."
  type        = string
}

variable "name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "Name of environment."
  type        = string
}

variable "users" {
  description = "Users to assign to project roles."
  type = object({
    administrators = set(string)
    contributors   = set(string)
    readers        = set(string)
  })
}
