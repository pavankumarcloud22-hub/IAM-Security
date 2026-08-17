resource "aws_iam_user_group_membership" "developer_memberships" {
  for_each = toset(local.developers)

  user = each.value

  groups = [
    aws_iam_group.developers.name
  ]
}

resource "aws_iam_user_group_membership" "operations_memberships" {
  for_each = toset(local.operations)

  user = each.value

  groups = [
    aws_iam_group.operations.name
  ]
}

resource "aws_iam_user_group_membership" "finance_memberships" {
  for_each = toset(local.finance)

  user = each.value

  groups = [
    aws_iam_group.finance.name
  ]
}

resource "aws_iam_user_group_membership" "analyst_memberships" {
  for_each = toset(local.analysts)

  user = each.value

  groups = [
    aws_iam_group.analysts.name
  ]
}