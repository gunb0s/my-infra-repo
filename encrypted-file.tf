provider "aws" {
    region = "ap-northeast-2"
}

data "aws_caller_identity" "self" {}

data "aws_iam_policy_document" "cmk_admin_policy" {
    statement {
        effect = "Allow"
        resources = ["*"]
        actions = ["kms:*"]
        principals {
            type = "AWS"
            identifiers = [data.aws_caller_identity.self.arn]
        }
    }
}

resource "aws_kms_key" "cmk" {
    policy = data.aws_iam_policy_document.cmk_admin_policy.json
}

resource "aws_kms_alias" "cmk" {
    name = "alias/kms-cmk-example"
    target_key_id = aws_kms_key.cmk.id
}