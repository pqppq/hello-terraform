variable "user_names" {
  description = "Crate IAM users with these names"
  type        = list(string)
  default     = ["neo", "trinity", "morpheus"]
}

variable "hero_thousand_faces" {
  description = "map"
  type        = map(string)
  default = {
    eno      = "hero"
    trinity  = "love interest"
    morpheus = "mentor"
  }
}
