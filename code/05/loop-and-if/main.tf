resource "aws_iam_user" "example" {
  # count = 3
  # name = "user.${count.index}"

  # count = length(var.user_names)
  # name = var.user_names[count.index]

	for_each = toset(var.user_names)
	name = each.value
}
