# resource "aws_instance" "example" {
#     ami = "ami-0d5bb3742db8fc264"
#     instance_type = "t2.micro"

#     # Attach the instance profile
#     iam_instance_profile = aws_iam_instance_profile.instance.name
# }

resource "aws_iam_instance_profile" "instance" {
    role = aws_iam_role.instance.name
}

resource "aws_iam_role" "instance" {
    name_prefix = var.name
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
    statement {
        effect = "Allow"
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy" "example" {
    role = aws_iam_role.instance.id
    policy = data.aws_iam_policy_document.ec2_admin_permissions.json
}

data "aws_iam_policy_document" "ec2_admin_permissions" {
    statement {
        effect = "Allow"
        actions = ["ec2:*"]
        resources = ["*"]
    }
}