resource "aws_iam_user" "example" {
  count = length(var.user_names) # -> 3
  name = var.user_names[count.index] # -> "neo", "trinity", "morpheus"
}

resource "aws_iam_policy" "cloudwatch_read_only" {
  name   = "cloudwatch-read-only"
  policy = data.aws_iam_policy_document.cloudwatch_read_only.json
}

resource "aws_iam_policy" "cloudwatch_full_access" {
  name   = "cloudwatch-full-access"
  policy = data.aws_iam_policy_document.cloudwatch_full_access.json
}

resource "aws_iam_user_policy_attachment" "neo_cloudwatch_full_access" {
	count = var.cloudwatch_full_access ? 1 : 0

	user       = aws_iam_user.example[0].name
	policy_arn = aws_iam_policy.cloudwatch_full_access.arn
}

resource "aws_iam_user_policy_attachment" "neo_cloudwatch_read_only_access" {
	count = var.cloudwatch_full_access ? 0 : 1

	user       = aws_iam_user.example[0].name
	policy_arn = aws_iam_policy.cloudwatch_read_only.arn
}

data "aws_iam_policy_document" "cloudwatch_read_only" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cloudwatch_full_access" {
  statement {
    effect    = "Allow"
    actions   = ["cloudwatch:*"]
    resources = ["*"]
  }
}
