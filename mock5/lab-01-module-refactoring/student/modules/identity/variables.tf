variable "name_stem" { type = string }

# Draft interface and implementation disagree on the object attribute name.
variable "shared_naming" {
  type = object({ prefix = string })
}
