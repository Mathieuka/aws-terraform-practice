// CloudFront
locals {
  s3_origin_id = aws_s3_bucket.my-unique-bucket-1234-2602-86978.id
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [
    aws_s3_bucket.my-unique-bucket-1234-2602-86978,
  ]
  origin {
    domain_name = aws_s3_bucket.my-unique-bucket-1234-2602-86978.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_OAC.id
  }
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "S3 Website Distribution"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

// CloudFront OAC
resource "aws_cloudfront_origin_access_control" "s3_OAC" {
  name                              = "S3 OAC"
  description                       = "CloudFront access to S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

output "oac_id" {
  value       = aws_cloudfront_origin_access_control.s3_OAC.id
  description = "OAC ID"
}

output "oac_etag" {
  value       = aws_cloudfront_origin_access_control.s3_OAC.etag
  description = "OAC ETag"
}

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
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}
