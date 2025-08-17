variable "domain" {
  description = "Domain the project belongs to."
  type        = string
}

variable "name" {
  description = "Name of the project."
  type        = string
}

variable "administrators" {
  description = "Administrator users."
  type        = set(string)
}

variable "environments" {
  description = "Environments to create for the project."
  type = map(object({
    users = object({
      contributors = set(string)
      readers      = set(string)
    })
  }))
}
