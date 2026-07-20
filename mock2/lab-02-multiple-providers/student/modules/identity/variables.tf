variable "service_accounts" {
  type = list(object({
    key  = string
    name = string
  }))
}
