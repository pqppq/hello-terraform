variable "user_names" {
  description = "Crate IAM users with these names"
  type        = list(string)
  default     = ["neo", "trinity", "morpheus"]
}

variable "cloudwatch_full_access" {
	description = "Give Neo CloudWatch Full Access"
	type = bool
	default = false
}
