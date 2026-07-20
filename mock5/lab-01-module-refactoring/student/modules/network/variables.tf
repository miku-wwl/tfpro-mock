variable "name_stem" { type = string }
variable "vpc_cidr" { type = string }

# Draft defect: the required final contract supplies an ordered list, but this draft uses a set.
variable "segment_definitions" {
  type = set(object({
    key               = string
    cidr_block        = string
    availability_zone = string
  }))
}
