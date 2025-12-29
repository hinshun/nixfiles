{ ... }:
{
  provider.aws = {
    region = "us-east-1";
  };

  resource.aws_s3_bucket.zerofs = {
    bucket = "hinshun-infra-zerofs";
    force_destroy = true;
    tags = {
      Purpose = "zerofs storage";
    };
  };

  resource.aws_iam_user.zerofs = {
    name = "zerofs";
    tags = {
      Purpose = "zerofs S3 access";
    };
  };

  resource.aws_iam_user_policy.zerofs = {
    name = "zerofs-s3-access";
    user = "\${aws_iam_user.zerofs.name}";
    policy = builtins.toJSON {
      Version = "2012-10-17";
      Statement = [{
        Effect = "Allow";
        Action = [
          "s3:GetObject"
          "s3:PutObject"
          "s3:DeleteObject"
          "s3:ListBucket"
        ];
        Resource = [
          "\${aws_s3_bucket.zerofs.arn}"
          "\${aws_s3_bucket.zerofs.arn}/*"
        ];
      }];
    };
  };

  resource.aws_iam_access_key.zerofs = {
    user = "\${aws_iam_user.zerofs.name}";
  };
}
