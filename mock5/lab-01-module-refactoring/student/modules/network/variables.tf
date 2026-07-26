variable "name_stem" { type = string }
variable "vpc_cidr" { type = string }

variable "segment_definitions" {
  type = list(object({
    key               = string
    cidr_block        = string
    availability_zone = string
  }))
}
