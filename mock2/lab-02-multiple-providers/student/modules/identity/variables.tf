variable "service_accounts" {
  type = map(object({
    name = string
  }))
}
