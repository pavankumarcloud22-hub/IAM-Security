data "aws_iam_policy_document" "developer" {

  statement {
    sid    = "EC2Management"
    effect = "Allow"

    actions = [
      "ec2:Describe*",
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:RebootInstances"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "CloudWatchLogsViewing"
    effect = "Allow"

    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ListDevelopmentBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::startupco-dev-app-assets-gp"
    ]
  }

  statement {
    sid    = "ManageDevelopmentObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::startupco-dev-app-assets-gp/*"
    ]
  }
}


resource "aws_iam_policy" "developer" {
  name        = "StartupCo-Developer-Policy"
  description = "Developer access to EC2, CloudWatch logs, and StartupCo development S3 assets"
  policy      = data.aws_iam_policy_document.developer.json
}

resource "aws_iam_group_policy_attachment" "developer" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.developer.arn
}

data "aws_iam_policy_document" "analyst" {

  statement {
    sid    = "ListAnalyticsBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::startupco-analytics-data-gp"
    ]
  }

  statement {
    sid    = "ReadAnalyticsObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::startupco-analytics-data-gp/*"
    ]
  }

  statement {
    sid    = "ViewRDSResources"
    effect = "Allow"

    actions = [
      "rds:Describe*",
      "rds:ListTagsForResource"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "analyst" {
  name        = "StartupCo-Analyst-Policy"
  description = "Read-only analytics S3 and RDS metadata access"
  policy      = data.aws_iam_policy_document.analyst.json
}

resource "aws_iam_group_policy_attachment" "analyst" {
  group      = aws_iam_group.analysts.name
  policy_arn = aws_iam_policy.analyst.arn
}

resource "aws_iam_group_policy_attachment" "finance_readonly" {
  group      = aws_iam_group.finance.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

data "aws_iam_policy_document" "finance" {

  statement {
    sid    = "CostExplorerAccess"
    effect = "Allow"

    actions = [
      "ce:Get*",
      "ce:Describe*",
      "ce:List*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "BudgetManagement"
    effect = "Allow"

    actions = [
      "budgets:ViewBudget",
      "budgets:Describe*",
      "budgets:CreateBudget",
      "budgets:ModifyBudget"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "finance" {
  name        = "StartupCo-Finance-Policy"
  description = "Cost Explorer and AWS Budgets permissions for StartupCo Finance"
  policy      = data.aws_iam_policy_document.finance.json
}

resource "aws_iam_group_policy_attachment" "finance" {
  group      = aws_iam_group.finance.name
  policy_arn = aws_iam_policy.finance.arn
}

resource "aws_iam_group_policy_attachment" "operations_ec2" {
  group      = aws_iam_group.operations.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "operations_cloudwatch" {
  group      = aws_iam_group.operations.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccessV2"
}

resource "aws_iam_group_policy_attachment" "operations_ssm" {
  group      = aws_iam_group.operations.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_group_policy_attachment" "operations_rds" {
  group      = aws_iam_group.operations.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}