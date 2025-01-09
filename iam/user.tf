module "s3" {
  source = "../s3"
}

resource "aws_iam_user" "toto" {
  name = "toto"
}

resource "aws_iam_user_group_membership" "toto_team_membership" {
  user = aws_iam_user.toto.name
  groups = [aws_iam_group.team.name]
}

resource "aws_iam_group" "team" {
  name = "team"
}

resource "aws_iam_policy" "team_custom_policy" {
  name        = "team_custom_policy"
  path        = "/"
  description = "Custom policy for team access to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowUserToReadWriteItsOwnBucket"
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject"]
        "Resource":[
          "arn:aws:s3:::${module.s3.bucket_name}",
          "arn:aws:s3:::${module.s3.bucket_name}/team/*",
          "arn:aws:s3:::${module.s3.bucket_name}/$${aws:username}/*"
        ],
        "Condition": {
          "StringLike": {
            "s3:prefix": ["$${aws:username}/*", "$${aws:username}"]
          }
        }
      },
      {
        Sid    = "AllowUserToListItsOwnBucket"
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        "Resource":[
          "arn:aws:s3:::${module.s3.bucket_name}",
          "arn:aws:s3:::${module.s3.bucket_name}/team/*",
          "arn:aws:s3:::${module.s3.bucket_name}/$${aws:username}/*"
        ],
        "Condition": {
          "StringLike": {
            "s3:prefix": ["$${aws:username}/*", "$${aws:username}", "team/*", "team"]
          }
        }
      },
      {
        Sid    = "AllowUserToListTeamBucket"
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        "Resource":[
          "arn:aws:s3:::${module.s3.bucket_name}",
        ],
        "Condition": {
          "StringLike": {
            "s3:prefix": ["team/*", "team"]
          }
        }
      }
    ]
  })
}


resource "aws_iam_group_policy_attachment" "team_custom_policy_attachment" {
  group      = aws_iam_group.team.name
  policy_arn = aws_iam_policy.team_custom_policy.arn
}
