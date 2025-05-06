### AWS 에게 Github Actions 에서 발급한 OIDC 토큰을 신뢰하도록 설정
# Create an IAM OIDC identity provider that trusts GitHub
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [
    data.tls_certificate.github.certificates[0].sha1_fingerprint
  ]
}

# Fetch GitHub's OIDC thumbprint
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}
###

### Github Actions 에서 사용할 IAM 역할 생성
resource "aws_iam_role" "github_actions" {
  name               = "github-actions-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

### Github Actions 에서 사용할 IAM 역할에 대한 신뢰 정책 생성
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      # The repos and branches defined in var.allowed_repos_branches
      # will be able to assume this IAM role
      values = [
        for a in var.allowed_repos_branches :
        "repo:${a["org"]}/${a["repo"]}:ref:refs/heads/${a["branch"]}"
      ]
    }
  }
}

resource "aws_iam_role_policy" "github_actions_admin" {
  name = "github-actions-admin-policy"
  role = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions_admin.json
}

data "aws_iam_policy_document" "github_actions_admin" {
  statement {
    effect = "Allow"
    actions = ["*"]
    resources = ["*"]
  }
}
