resource "aws_iam_group" "developers" {
  name = "StartupCo-Developers"
}

resource "aws_iam_group" "operations" {
  name = "StartupCo-Operations"
}

resource "aws_iam_group" "finance" {
  name = "StartupCo-Finance"
}

resource "aws_iam_group" "analysts" {
  name = "StartupCo-Analysts"
}