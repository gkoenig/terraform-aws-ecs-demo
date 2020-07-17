variable "namespace" {
  description = "Namespace (e.g. `cp` or `cloudposse`)"
  type        = string
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  type        = string
}

variable "region" {
  type = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)"
}
variable "delimiter" {
  default     = "-"
}