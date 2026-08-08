data "aws_iam_policy" "excalidraw_ssm_managed_instance_core" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "excalidraw_iam_role" {
  name = "excalidraw_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "excalidraw_ssm_core" {
  role       = aws_iam_role.excalidraw_iam_role.name
  policy_arn = data.aws_iam_policy.excalidraw_ssm_managed_instance_core.arn
}

resource "aws_iam_instance_profile" "excalidraw_iam_instance_profile" {
  name = "excalidraw_iam_instance_profile"
  role = aws_iam_role.excalidraw_iam_role.name
}
