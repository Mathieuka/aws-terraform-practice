// CloudFront
locals {
  s3_origin_id = var.s3_origin_id
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [
    var.s3_bucket,
  ]
  origin {
    domain_name = var.s3_bucket_regional_domain_name
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

output "aws_cloudfront_distribution" {
  value = aws_cloudfront_distribution.s3_distribution.arn
}


output "cloudfront_distribution_value" {
  value = aws_cloudfront_distribution.s3_distribution.arn
}
