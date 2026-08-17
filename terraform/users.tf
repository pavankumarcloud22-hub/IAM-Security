locals {
  developers = [
    "dev-user-01",
    "dev-user-02",
    "dev-user-03",
    "dev-user-04"
  ]

  operations = [
    "ops-user-01",
    "ops-user-02"
  ]

  finance = [
    "finance-user-01"
  ]

  analysts = [
    "analyst-user-01",
    "analyst-user-02",
    "analyst-user-03"
  ]

  all_users = toset(concat(
    local.developers,
    local.operations,
    local.finance,
    local.analysts
  ))
}

resource "aws_iam_user" "users" {
  for_each = local.all_users

  name = each.value
  path = "/"
}