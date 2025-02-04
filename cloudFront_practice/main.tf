terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"
}

module "cloudFront" {
  source = "./cloudFront"
  s3_origin_id = module.s3.aws_s3_bucket_id
  s3_bucket = module.s3.s3_bucket
  s3_bucket_regional_domain_name = module.s3.bucket_regional_domain_name
}

module "s3" {
  source = "./s3"
  cloudfront_distribution_arn = module.cloudFront.cloudfront_distribution_value
}
