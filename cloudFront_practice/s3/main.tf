// S3 bucket
resource "aws_s3_bucket" "my-unique-bucket-1234-2602-86978" {
  bucket = "my-unique-bucket-1234-2602-86978"

  tags = {
    Name = "New Bucket"
  }
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.my-unique-bucket-1234-2602-86978.id
  key          = "index.html"
  content      = <<-EOF
  <h1>Hello World</h1>
  EOF
  content_type = "text/html"
  depends_on   = [aws_s3_bucket.my-unique-bucket-1234-2602-86978]
}

resource "aws_s3_bucket_policy" "allow_oac_access_only" {
  bucket = aws_s3_bucket.my-unique-bucket-1234-2602-86978.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Action = "s3:GetObject"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Resource = "${aws_s3_bucket.my-unique-bucket-1234-2602-86978.arn}/*"
        Condition = {
          StringEquals = {
             "AWS:SourceArn" = var.cloudfront_distribution_arn
          }
        }
      }
    ]
  })
}

output "aws_s3_bucket_id" {
  value = aws_s3_bucket.my-unique-bucket-1234-2602-86978.id
}

output "s3_bucket" {
  value = aws_s3_bucket.my-unique-bucket-1234-2602-86978.bucket
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.my-unique-bucket-1234-2602-86978.bucket_regional_domain_name
}
