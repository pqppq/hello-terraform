# brittle approach
# output "neo_cloudwatch_policy_arn" {
# value = (
# 	var.give_cloudwatch_access
# 		? aws_iam_user_policy_attachment.neo_cloudwatch_full_access[*].policy_arn
# 		: aws_iam_user_policy_attachment.neo_cloudwatch_read_only_access[*].policy_arn
# 	)
# }

# safer approach
output "neo_cloudwatch_policy_arn" {
value = one(concat(
		aws_iam_user_policy_attachment.neo_cloudwatch_full_access[*].policy_arn,
		aws_iam_user_policy_attachment.neo_cloudwatch_read_only_access[*].policy_arn
	))
}

output "for_directive_index_if" {
	value = <<EOF
		%{ for i, name in var.user_names }
			${name}%{ if i < length(var.user_names) -1 }, %{ endif }
		%{ endfor }
	EOF
	# ->
	# neo,
	# trinity,
	# morpheus
}
